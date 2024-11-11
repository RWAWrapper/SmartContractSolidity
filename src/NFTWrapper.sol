// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "./NFTWrappedToken.sol";
import "./RWANFT.sol";

contract NFTWrapper is AccessControl {

    NFTWrappedToken public nftWrappedToken;
    address public defaultAdmin;

    mapping(address => uint256) public conversion_rate;
    mapping(address => address) public wrapped_token;
    mapping(address => uint256[]) public nft_pools;

    constructor(address _defaultAdmin) {
        _grantRole(DEFAULT_ADMIN_ROLE, _defaultAdmin);
        defaultAdmin = _defaultAdmin;
    }

    function generateRandomNumber() public view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, block.number, block.timestamp)));
    }

    function createWrappedToken(address nftContract, uint256 conversionRate) public onlyRole(DEFAULT_ADMIN_ROLE) {
        require(wrapped_token[nftContract] == address(0), "NFT already wrapped");
        RWANFT rwanft = RWANFT(nftContract);
        string memory name = string.concat("Wrapped ", rwanft.name());
        string memory symbol = string.concat("W-", rwanft.symbol());
        nftWrappedToken = new NFTWrappedToken(defaultAdmin, address(this), name, symbol);
        wrapped_token[nftContract] = address(nftWrappedToken);
        conversion_rate[nftContract] = conversionRate;
    }

    function wrap(address nftContract, uint256 tokenId) public {
        require(wrapped_token[nftContract] != address(0), "NFT not wrapped");
        RWANFT rwanft = RWANFT(nftContract);
        rwanft.safeTransferFrom(msg.sender, address(this), tokenId);
        nftWrappedToken.mint(msg.sender, conversion_rate[nftContract]);
        nft_pools[nftContract].push(tokenId);
    }

    function unwrap(address nftContract) public {
        require(wrapped_token[nftContract] != address(0), "NFT not wrapped");
        uint256[] storage tokenIds = nft_pools[nftContract];
        require(tokenIds.length > 0, "No NFTs to unwrap");
        
        uint256 randomIndex = generateRandomNumber() % tokenIds.length;
        uint256 tokenId = tokenIds[randomIndex];
        
        RWANFT rwanft = RWANFT(nftContract);
        NFTWrappedToken wrappedToken = NFTWrappedToken(wrapped_token[nftContract]);
        
        require(wrappedToken.balanceOf(msg.sender) >= conversion_rate[nftContract], "Insufficient wrapped tokens");
        
        wrappedToken.burnFrom(msg.sender, conversion_rate[nftContract]);
        rwanft.safeTransferFrom(address(this), msg.sender, tokenId);
        
        // Remove the unwrapped token from the pool by shifting elements
        for (uint i = randomIndex; i < tokenIds.length - 1; i++) {
            tokenIds[i] = tokenIds[i + 1];
        }
        tokenIds.pop();
    }
}
