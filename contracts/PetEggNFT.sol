pragma solidity =0.6.6;

import '@openzeppelin/contracts/access/AccessControl.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/ERC721Pausable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract PetEggNFT is ERC721Pausable, AccessControl, Ownable {
    bytes32 public constant UPDATE_TOKEN_URI_ROLE = keccak256('UPDATE_TOKEN_URI_ROLE');
    bytes32 public constant PAUSED_ROLE = keccak256('PAUSED_ROLE');

    struct PetInfo {
        uint256 petType;
        uint256 battlePower;
    }

    mapping(uint256 => PetInfo) public petInfoMap;

    constructor() public ERC721('Pet EGG NFT', 'PETEGGNFT') {
        _setupRole(UPDATE_TOKEN_URI_ROLE, _msgSender());
        _setupRole(PAUSED_ROLE, _msgSender());
    }

    function mint(
        address to,
        uint256 tokenId,
        uint256 _battlePower,
        uint256 _petType
    ) public onlyOwner {
        _mint(to, tokenId);
        petInfoMap[tokenId] = PetInfo({petType: _petType, battlePower: _battlePower});
    }

    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     * openzeppelin/contracts/token/ERC721/ERC721Burnable.sol
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), 'caller is not owner nor approved');
        _burn(tokenId);
        delete petInfoMap[tokenId];
    }

    function setBaseURI(string memory baseURI) public {
        require(hasRole(UPDATE_TOKEN_URI_ROLE, _msgSender()), 'Must have update token uri role');
        _setBaseURI(baseURI);
    }

    function setTokenURI(uint256 tokenId, string memory tokenURI) public {
        require(hasRole(UPDATE_TOKEN_URI_ROLE, _msgSender()), 'Must have update token uri role');
        _setTokenURI(tokenId, tokenURI);
    }

    function pause() public whenNotPaused {
        require(hasRole(PAUSED_ROLE, _msgSender()), 'Must have pause role');
        _pause();
    }

    function unpause() public whenPaused {
        require(hasRole(PAUSED_ROLE, _msgSender()), 'Must have pause role');
        _unpause();
    }

    function approveBulk(address to, uint256[] memory tokenIds) public {
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            approve(to, tokenIds[i]);
        }
    }

    function getApprovedBulk(uint256[] memory tokenIds) public view returns (address[] memory) {
        address[] memory tokenApprovals = new address[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; ++i) {
            tokenApprovals[i] = getApproved(tokenIds[i]);
        }
        return tokenApprovals;
    }
}
