pragma solidity =0.6.6;

import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/token/ERC20/SafeERC20.sol';
import '@openzeppelin/contracts/utils/Pausable.sol';
import './libraries/TransferHelper.sol';
import './libraries/BakerySwapHelper.sol';
import './PetEggNFT.sol';

contract PetIDO is Ownable, Pausable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    // 1600W
    uint256 public constant maxTotalIdoAmount = 16 * 1E24;
    uint256 public currentIdoAmount = 0;
    // pet/busd * priceMultiple
    uint256 public petBusdIdoPrice;
    uint256 public constant priceMultiple = 1E8;
    uint256 public mintNFTCount = 1;
    uint256 public minIdoAmount = 1E18 * 833;
    uint256 public minBuyAmount = 1E20;
    address public idoFinAddr;
    address public buyFinAddr;
    address public immutable PET;
    address public immutable bakerySwapFactoryAddr;
    address public immutable BUSD;
    address public immutable WBNB;
    bool public enableBuyNftByPet = false;
    PetEggNFT public immutable NFT;
    mapping(address => bool) public supportTokens;

    event IDO(address indexed token, address indexed sender, uint256 amountToken, uint256 amountPet);
    event IdoFinAddressTransferred(address indexed previousDev, address indexed newDev);
    event BuyFinAddressTransferred(address indexed previousDev, address indexed newDev);
    event SetPetBusdIdoPrice(address indexed sender, uint256 oldPrice, uint256 newPirce);
    event AddSupportToken(address indexed sender, address indexed token);
    event RemoveSupportToken(address indexed sender, address indexed token);
    event BuyNft(address indexed token, address indexed sender, uint256 amountToken);
    event SetEnableBuyNftByPet(address indexed sender, bool isEnable);

    constructor(
        uint256 _petBusdIdoPrice,
        address _idoFinAddr,
        address _buyFinAddr,
        address _PET,
        address _bakerySwapFactoryAddr,
        address _BUSD,
        address _WBNB,
        address _NFT
    ) public {
        petBusdIdoPrice = _petBusdIdoPrice;
        idoFinAddr = _idoFinAddr;
        buyFinAddr = _buyFinAddr;
        emit IdoFinAddressTransferred(address(0), idoFinAddr);
        emit BuyFinAddressTransferred(address(0), buyFinAddr);
        PET = _PET;
        bakerySwapFactoryAddr = _bakerySwapFactoryAddr;
        BUSD = _BUSD;
        WBNB = _WBNB;
        NFT = PetEggNFT(_NFT);
    }

    receive() external payable {
        assert(msg.sender == WBNB);
        // only accept BNB via fallback from the WBNB contract
    }

    function getPrice(address _baseToken, address _quoteToken) public view returns (uint256 price) {
        address pair = BakerySwapHelper.pairFor(bakerySwapFactoryAddr, _baseToken, _quoteToken);
        uint256 baseTokenAmount = IERC20(_baseToken).balanceOf(pair);
        uint256 quoteTokenAmount = IERC20(_quoteToken).balanceOf(pair);
        price = quoteTokenAmount
            .mul(priceMultiple)
            .mul(10**uint256(ERC20(_baseToken).decimals()))
            .div(10**uint256(ERC20(_quoteToken).decimals()))
            .div(baseTokenAmount);
    }

    function _ido(uint256 _amountToken, address _token)
        internal
        virtual
        returns (uint256 amountPet, uint256 amountToken)
    {
        require(supportTokens[_token], 'PetIDO: IDO NOT SUPPORT THIS TOKEN');
        uint256 maxIdoAmountPet = maxTotalIdoAmount.sub(currentIdoAmount);
        require(maxIdoAmountPet != 0, 'PetIDO: IDO IS STOP');
        uint256 tokenBusdPrice = _token == BUSD ? priceMultiple : getPrice(_token, BUSD);
        require(tokenBusdPrice != 0, 'PetIDO: PRICE ERROR');
        amountPet = _amountToken.mul(tokenBusdPrice).mul(10**uint256(ERC20(PET).decimals())).div(petBusdIdoPrice).div(
            10**uint256(ERC20(_token).decimals())
        );
        if (amountPet > maxIdoAmountPet) {
            amountPet = maxIdoAmountPet;
            amountToken = amountPet.mul(petBusdIdoPrice).div(tokenBusdPrice);
        } else {
            amountToken = _amountToken;
            require(amountPet >= minIdoAmount, 'PetIDO: MIN IDO AMOUNT');
        }
        currentIdoAmount = currentIdoAmount.add(amountPet);
    }

    function ido(
        uint256 _amountToken,
        uint256 _petType,
        address _token
    ) public whenNotPaused returns (uint256 amountPet, uint256 amountToken) {
        (amountPet, amountToken) = _ido(_amountToken, _token);
        IERC20(_token).safeTransferFrom(address(msg.sender), idoFinAddr, amountToken);
        IERC20(PET).safeTransfer(address(msg.sender), amountPet);
        NFT.mint(address(msg.sender), mintNFTCount, amountPet.div(1E19), _petType);
        mintNFTCount++;
        emit IDO(_token, msg.sender, amountToken, amountPet);
    }

    function idoBnb(uint256 _petType) public payable whenNotPaused returns (uint256 amountPet, uint256 amountToken) {
        (amountPet, amountToken) = _ido(msg.value, WBNB);
        TransferHelper.safeTransferETH(idoFinAddr, amountToken);
        IERC20(PET).safeTransfer(address(msg.sender), amountPet);
        NFT.mint(address(msg.sender), mintNFTCount, amountPet.div(1E19), _petType);
        mintNFTCount++;
        if (msg.value > amountToken) TransferHelper.safeTransferETH(msg.sender, msg.value - amountToken);
        emit IDO(WBNB, msg.sender, amountToken, amountPet);
    }

    function buyNftByPet(uint256 _amountPet, uint256 _petType) public {
        require(enableBuyNftByPet, 'PetIDO: buyNftByPet NOT SUPPORT');
        require(_amountPet >= minBuyAmount, 'PetIDO: MIN PET AMOUNT');
        IERC20(PET).safeTransferFrom(address(msg.sender), buyFinAddr, _amountPet);
        NFT.mint(address(msg.sender), mintNFTCount, _amountPet.div(1E18), _petType);
        mintNFTCount++;
        emit BuyNft(PET, msg.sender, _amountPet);
    }

    function pauseIdo() public onlyOwner whenNotPaused {
        _pause();
    }

    function unpauseIdo() public onlyOwner whenPaused {
        _unpause();
    }

    function transferIdoFinAddress(address _idoFinAddr) public {
        require(msg.sender == idoFinAddr, 'PetIDO: FORBIDDEN');
        idoFinAddr = _idoFinAddr;
        emit IdoFinAddressTransferred(msg.sender, idoFinAddr);
    }

    function transferBuyFinAddress(address _buyFinAddr) public {
        require(msg.sender == buyFinAddr, 'PetIDO: FORBIDDEN');
        buyFinAddr = _buyFinAddr;
        emit BuyFinAddressTransferred(msg.sender, buyFinAddr);
    }

    function setMinIdoAmount(uint256 _minIdoAmount) public onlyOwner {
        minIdoAmount = _minIdoAmount;
    }

    function setMinBuyAmount(uint256 _minBuyAmount) public onlyOwner {
        minBuyAmount = _minBuyAmount;
    }

    function setPetBusdIdoPrice(uint256 _petBusdIdoPrice) public onlyOwner {
        emit SetPetBusdIdoPrice(msg.sender, petBusdIdoPrice, _petBusdIdoPrice);
        petBusdIdoPrice = _petBusdIdoPrice;
    }

    function addSupportToken(address _token) public onlyOwner {
        supportTokens[_token] = true;
        emit AddSupportToken(msg.sender, _token);
    }

    function removeSupportToken(address _token) public onlyOwner {
        delete supportTokens[_token];
        emit RemoveSupportToken(msg.sender, _token);
    }

    function setEnableBuyNftByPet(bool _enableBuyNftByPet) public onlyOwner {
        require(enableBuyNftByPet != _enableBuyNftByPet, 'PetIDO: NOT NEED UPDATE');
        emit SetEnableBuyNftByPet(msg.sender, _enableBuyNftByPet);
        enableBuyNftByPet = _enableBuyNftByPet;
    }
}
