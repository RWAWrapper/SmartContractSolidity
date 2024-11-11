// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.22;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// 发行者信息
struct Issuer {
    string name;
    string contact;
    string certification;
}

// NFT资产类型
enum AssetType {
    Cash,
    Commodity,
    Stock,
    Bond,
    Credit,
    Art,
    IntellectualProperty
}

struct Valuation {
    string currency;
    uint256 amount;
}

struct Document {
    string documentName;
    string documentType;
    string documentUrl;
}

struct AssetDetails {
    string location;
    string legalStatus;
    Valuation valuation;
    string issuedDate;
    string expiryDate;
    string condition;
    string dimensions;
    string material;
    string color;
    string historicalSignificance;
    Document document;
}

struct Owner {
    string name;
    string contact;
}

struct RoyaltyInfo {
    address recipient;
    uint256 percentage;
}

// NFT元数据
struct RWAMetadata {
    string name;
    string description;
    string image;
    string externalUrl;
    string assetId;
    Issuer issuer;
    AssetType assetType;
    AssetDetails assetDetails;
    Owner currentOwner;
    RoyaltyInfo royaltyInfo;
    string legalJurisdiction;
    string disclaimer;
}

contract RWANFT is ERC721, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    uint256 private _nextTokenId;

    mapping(uint256 => RWAMetadata) public tokenMetadata;

    constructor(address defaultAdmin, address minter)
        ERC721("Real Word Assets", "RWA")
    {
        _grantRole(DEFAULT_ADMIN_ROLE, defaultAdmin);
        _grantRole(MINTER_ROLE, minter);
    }

    function safeMint(address to, RWAMetadata memory metadata) internal onlyRole(MINTER_ROLE) {
        uint256 tokenId = _nextTokenId++;
        _safeMint(to, tokenId);
        tokenMetadata[tokenId] = metadata;
    }

    function getMetadata(uint256 tokenId) public view returns (RWAMetadata memory) {
        return tokenMetadata[tokenId];
    }

    function setMetadata(uint256 tokenId, RWAMetadata memory metadata) public onlyRole(MINTER_ROLE) {
        tokenMetadata[tokenId] = metadata;
    }

    function mint(RWAMetadata memory metadata) public {
        safeMint(msg.sender, metadata);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
