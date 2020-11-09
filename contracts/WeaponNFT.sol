pragma solidity =0.6.6;
pragma experimental ABIEncoderV2;

import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721Pausable.sol';
import '@openzeppelin/contracts/access/AccessControl.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';

contract WeaponNFT is ERC721Pausable, AccessControl, Ownable {
    using SafeERC20 for IERC20;

    struct WeaponInfo {
        uint256 weaponType;
        uint256 stakingPower;
        uint256 level;
        uint256 petToGet;
        uint256 bakeToGet;
    }

    bytes32 public constant MINT_ROLE = keccak256('MINT_ROLE');

    uint256 public nextTokenId = 1;
    uint256 public petReserve;
    uint256 public bakeReserve;

    address public immutable PET;
    address public immutable BAKE;

    mapping(uint256 => WeaponInfo) public weaponInfoMap;

    event Mint(
        address indexed user,
        uint256 indexed tokenId,
        uint256 weaponType,
        uint256 level,
        uint256 stakingPower,
        uint256 petToGet,
        uint256 bakeToGet
    );
    event Burn(
        address indexed user,
        uint256 indexed tokenId,
        uint256 weaponType,
        uint256 level,
        uint256 stakingPower,
        uint256 petToGet,
        uint256 bakeToGet
    );
    event Update(
        address indexed sender,
        uint256 indexed tokenId,
        uint256 weaponType,
        uint256 level,
        uint256 stakingPower,
        uint256 petToGet,
        uint256 bakeToGet
    );
    event Sync(uint256 petReserve, uint256 bakeReserve);

    constructor(address _PET, address _BAKE) public ERC721('Weapon NFT', 'WEAPONNFT') {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        PET = _PET;
        BAKE = _BAKE;
    }

    function getLevel(uint256 stakingPower) public pure returns (uint256 level) {
        level = 1; // < 1k
        if (stakingPower >= 1E3 && stakingPower < 2E3) {
            level = 2;
        } else if (stakingPower >= 2E3 && stakingPower < 5E3) {
            level = 3;
        } else if (stakingPower >= 5E3 && stakingPower < 1E4) {
            level = 4;
        } else if (stakingPower >= 1E4 && stakingPower < 2E4) {
            level = 5;
        } else if (stakingPower >= 2E4 && stakingPower < 5E4) {
            level = 6;
        } else if (stakingPower >= 5E4 && stakingPower < 1E5) {
            level = 7;
        } else if (stakingPower >= 1E5 && stakingPower < 5E5) {
            level = 8;
        } else if (stakingPower >= 5E5 && stakingPower < 1E6) {
            level = 9;
        } else if (stakingPower >= 1E6) {
            level = 10;
        }
    }

    function _sync(
        uint256 pendingPetToGet,
        uint256 pendingBakeToGet,
        bool isAdd
    ) private {
        uint256 balanceOfPet = IERC20(PET).balanceOf(address(this));
        uint256 balanceOfBake = IERC20(BAKE).balanceOf(address(this));
        require(
            pendingPetToGet == 0 ||
                (
                    isAdd
                        ? balanceOfPet.sub(petReserve) == pendingPetToGet
                        : balanceOfPet.add(pendingPetToGet) == petReserve
                ),
            'Error pet amount'
        );
        require(
            pendingBakeToGet == 0 ||
                (
                    isAdd
                        ? balanceOfBake.sub(bakeReserve) == pendingBakeToGet
                        : balanceOfBake.add(pendingBakeToGet) == bakeReserve
                ),
            'Error bake amount'
        );
        if (petReserve != balanceOfPet) {
            petReserve = balanceOfPet;
        }
        if (bakeReserve != balanceOfBake) {
            bakeReserve = balanceOfBake;
        }
        emit Sync(petReserve, bakeReserve);
    }

    function mint(
        address to,
        uint256 weaponType,
        uint256 stakingPower,
        uint256 petToGet,
        uint256 bakeToGet
    ) public returns (uint256 tokenId) {
        require(hasRole(MINT_ROLE, _msgSender()), 'Must have mint role');
        tokenId = nextTokenId;
        _mint(to, tokenId);
        nextTokenId++;
        uint256 level = getLevel(stakingPower);
        weaponInfoMap[tokenId] = WeaponInfo({
            weaponType: weaponType,
            stakingPower: stakingPower,
            level: level,
            petToGet: petToGet,
            bakeToGet: bakeToGet
        });
        _sync(petToGet, bakeToGet, true);
        emit Mint(to, tokenId, weaponType, stakingPower, level, petToGet, bakeToGet);
    }

    function update(
        uint256 tokenId,
        uint256 weaponType,
        uint256 stakingPower,
        uint256 petToGet,
        uint256 bakeToGet
    ) public {
        require(hasRole(MINT_ROLE, _msgSender()), 'Must have mint role');
        uint256 level = getLevel(stakingPower);
        WeaponInfo memory weaponInfo = weaponInfoMap[tokenId];
        // petToGet & bakeToGet must be grant than equal old value
        _sync(petToGet.sub(weaponInfo.petToGet), bakeToGet.sub(weaponInfo.bakeToGet), true);
        weaponInfoMap[tokenId] = WeaponInfo({
            weaponType: weaponType,
            stakingPower: stakingPower,
            level: level,
            petToGet: petToGet,
            bakeToGet: bakeToGet
        });
        emit Update(_msgSender(), tokenId, weaponType, stakingPower, level, petToGet, bakeToGet);
    }

    /**
     * burn token, and send `petToGet` to owner, send `bakeToGet` to owner.
     */
    function burn(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), 'caller is not owner nor approved');
        WeaponInfo memory weaponInfo = weaponInfoMap[tokenId];
        if (weaponInfo.petToGet != 0) {
            IERC20(PET).safeTransfer(ownerOf(tokenId), weaponInfo.petToGet);
        }
        if (weaponInfo.bakeToGet != 0) {
            IERC20(BAKE).safeTransfer(ownerOf(tokenId), weaponInfo.bakeToGet);
        }
        _sync(weaponInfo.petToGet, weaponInfo.bakeToGet, false);
        delete weaponInfoMap[tokenId];
        _burn(tokenId);
        emit Burn(
            _msgSender(),
            tokenId,
            weaponInfo.weaponType,
            weaponInfo.stakingPower,
            weaponInfo.level,
            weaponInfo.petToGet,
            weaponInfo.bakeToGet
        );
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }

    function setTokenURI(uint256 tokenId, string memory tokenURI) public onlyOwner {
        _setTokenURI(tokenId, tokenURI);
    }

    function pause() public onlyOwner whenNotPaused {
        _pause();
    }

    function unpause() public onlyOwner whenPaused {
        _unpause();
    }
}
