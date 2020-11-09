pragma solidity =0.6.6;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/math/SafeMath.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721Holder.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import './WeaponNFT.sol';
import './libraries/BakerySwapHelper.sol';

contract WeaponNftMaster is Ownable, Pausable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;

    uint256 public constant MAX_STAKING_POWER = 1E6;

    struct TokenSettings {
        bool enableSynthesis;
        bool enableUpgrade;
        uint256 stakingPowerPercent; // if 0 then using PET price & PET.stakingPowerPercent
        uint256 tokenToGetPercent;
        uint256 burnPercent;
        // fee = amount-amount*tokenToGetPercent - amount*burnPercent
    }

    address public feeAddr; // fee address.
    address public immutable PET;
    address public immutable BAKE;
    address public immutable WEAPON;
    address public immutable BAKERY_SWAP_FACTORY;
    WeaponNFT public immutable weaponNFT;
    address public constant DEAD = 0x000000000000000000000000000000000000dEaD;

    mapping(address => TokenSettings) public tokenSettingsMap;

    event Synthesis(
        address indexed user,
        address indexed token,
        uint256 indexed tokenId,
        uint256 weaponType,
        uint256 amount
    );
    event Upgrade(address indexed user, uint256 indexed tokenId, address indexed token, uint256 amount);

    event FeeAddressTransferred(address indexed previousOwner, address indexed newOwner);
    event UpdateTokenSettings(
        address indexed user,
        address indexed token,
        bool enableSynthesis,
        bool enableUpgrade,
        uint256 stakingPowerPercent,
        uint256 tokenToGetPercent,
        uint256 burnPercent
    );

    constructor(
        address _PET,
        address _weaponNFT,
        address _BAKE,
        address _WEAPON,
        address _feeAddr,
        address _BAKERY_SWAP_FACTORY
    ) public {
        PET = _PET;
        weaponNFT = WeaponNFT(_weaponNFT);
        BAKE = _BAKE;
        WEAPON = _WEAPON;
        feeAddr = _feeAddr;
        emit FeeAddressTransferred(address(0), feeAddr);
        BAKERY_SWAP_FACTORY = _BAKERY_SWAP_FACTORY;
        updateTokenSettings(_PET, true, true, 100, 90, 5);
        updateTokenSettings(_BAKE, true, true, 0, 90, 0);
        updateTokenSettings(_WEAPON, true, true, 100, 0, 90);
    }

    function getPetAmount(address token, uint256 tokenAmount) public view returns (uint256) {
        return
            tokenAmount.mul(BakerySwapHelper.getPrice(BAKERY_SWAP_FACTORY, token, PET)).div(
                BakerySwapHelper.PRICE_MULTIPLE
            );
    }

    function getTokenAmount(address token, uint256 petAmount) public view returns (uint256) {
        return
            petAmount.mul(BakerySwapHelper.getPrice(BAKERY_SWAP_FACTORY, PET, token)).div(
                BakerySwapHelper.PRICE_MULTIPLE
            );
    }

    function _upgrade(
        address token,
        uint256 _amount,
        uint256 _stakingPower,
        uint256 _petToGet,
        uint256 _bakeToGet
    )
        internal
        virtual
        returns (
            uint256 stakingPower,
            uint256 petToGet,
            uint256 bakeToGet
        )
    {
        TokenSettings memory tokenSettings = tokenSettingsMap[token];
        require(_stakingPower < MAX_STAKING_POWER, "it's max level, can't upgrade");

        uint256 toGetAmount = _amount.mul(tokenSettings.tokenToGetPercent).div(100);
        {
            // scope for token,_amount,_stakingPower avoids stack too deep errors
            address _token = token;
            uint256 __amount = _amount;
            uint256 __stakingPower = _stakingPower;
            stakingPower = __stakingPower.add(
                (
                    tokenSettings.stakingPowerPercent == 0
                        ? getPetAmount(_token, __amount).mul(tokenSettingsMap[PET].stakingPowerPercent).div(100)
                        : __amount.mul(tokenSettings.stakingPowerPercent).div(100)
                )
                    .div(10**uint256(ERC20(_token).decimals()))
            );
            require(__stakingPower != 0 || stakingPower >= 400, 'Min stakingPower');
            if (stakingPower > MAX_STAKING_POWER) {
                stakingPower = MAX_STAKING_POWER;
                _amount = MAX_STAKING_POWER.sub(__stakingPower).mul(10**uint256(ERC20(_token).decimals())).mul(100).div(
                    tokenSettings.stakingPowerPercent == 0
                        ? tokenSettingsMap[PET].stakingPowerPercent
                        : tokenSettings.stakingPowerPercent
                );
                if (tokenSettings.stakingPowerPercent == 0) {
                    _amount = getTokenAmount(token, _amount);
                }
            }

            uint256 burnAmount = __amount.mul(tokenSettings.burnPercent).div(100);
            uint256 feeAmount = __amount.sub(toGetAmount).sub(burnAmount);
            if (toGetAmount != 0) {
                IERC20(_token).safeTransferFrom(_msgSender(), address(weaponNFT), toGetAmount);
            }
            if (burnAmount != 0) {
                IERC20(_token).safeTransferFrom(_msgSender(), DEAD, burnAmount);
            }
            if (feeAmount != 0) {
                IERC20(_token).safeTransferFrom(_msgSender(), feeAddr, feeAmount);
            }
        }

        if (token == PET) {
            bakeToGet = _bakeToGet;
            petToGet = _petToGet.add(toGetAmount);
        } else if (token == BAKE) {
            bakeToGet = _bakeToGet.add(toGetAmount);
            petToGet = _petToGet;
        } else {
            bakeToGet = _bakeToGet;
            petToGet = _petToGet;
        }
    }

    function synthesis(
        address token,
        uint256 weaponType,
        uint256 _amount
    ) public whenNotPaused returns (uint256 tokenId) {
        require(tokenSettingsMap[token].enableSynthesis, 'synthesis not support this token');
        (uint256 stakingPower, uint256 petToGet, uint256 bakeToGet) = _upgrade(token, _amount, 0, 0, 0);
        tokenId = weaponNFT.mint(_msgSender(), weaponType, stakingPower, petToGet, bakeToGet);
        emit Synthesis(msg.sender, token, tokenId, weaponType, _amount);
    }

    function upgrade(
        address token,
        uint256 tokenId,
        uint256 _amount
    ) public whenNotPaused {
        require(weaponNFT.ownerOf(tokenId) == _msgSender(), 'only owner can upgrade');
        require(tokenSettingsMap[token].enableUpgrade, 'upgrade not support this token');
        (uint256 weaponType, uint256 stakingPower, , uint256 petToGet, uint256 bakeToGet) = weaponNFT.weaponInfoMap(
            tokenId
        );
        (stakingPower, petToGet, bakeToGet) = _upgrade(token, _amount, stakingPower, petToGet, bakeToGet);
        weaponNFT.update(tokenId, weaponType, stakingPower, petToGet, bakeToGet);
        emit Upgrade(_msgSender(), tokenId, token, _amount);
    }

    function pause() public onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() public onlyOwner whenPaused {
        _unpause();
    }

    function transferFeeAddress(address _feeAddr) public {
        require(msg.sender == feeAddr, 'forbidden');
        feeAddr = _feeAddr;
        emit FeeAddressTransferred(msg.sender, feeAddr);
    }

    function updateTokenSettings(
        address token,
        bool enableSynthesis,
        bool enableUpgrade,
        uint256 stakingPowerPercent,
        uint256 tokenToGetPercent,
        uint256 burnPercent
    ) public onlyOwner {
        tokenSettingsMap[token] = TokenSettings({
            enableSynthesis: enableSynthesis,
            enableUpgrade: enableUpgrade,
            stakingPowerPercent: stakingPowerPercent,
            tokenToGetPercent: tokenToGetPercent,
            burnPercent: burnPercent
        });
        emit UpdateTokenSettings(
            _msgSender(),
            token,
            enableSynthesis,
            enableUpgrade,
            stakingPowerPercent,
            tokenToGetPercent,
            burnPercent
        );
    }
}
