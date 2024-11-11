// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {NFTWrapper, RWAMetadata, Issuer, AssetType, AssetDetails, Valuation, Document, Owner, RoyaltyInfo} from "../src/NFTWrapper.sol";
import {NFTWrappedToken} from "../src/NFTWrappedToken.sol";
import {RWANFT} from "../src/RWANFT.sol";

contract NFTWrapperTest is Test {
    NFTWrapper public nftWrapper;
    NFTWrappedToken public nftWrappedToken;
    RWANFT public rwaNFT;

    address public defaultAdmin = makeAddr("defaultAdmin");
    address public minter = makeAddr("minter");
    RWAMetadata defaultMetadata;

    function setUp() public {
        nftWrapper = new NFTWrapper(defaultAdmin);
        rwaNFT = new RWANFT(defaultAdmin, minter);

        // Setup default metadata
        defaultMetadata = RWAMetadata({
            name: "",
            description: "",
            image: "",
            externalUrl: "",
            assetId: "",
            issuer: Issuer({
                name: "",
                contact: "",
                certification: ""
            }),
            assetType: AssetType.Commodity,
            assetDetails: AssetDetails({
                location: "",
                legalStatus: "",
                valuation: Valuation({
                    currency: "",
                    amount: 0
                }),
                issuedDate: "",
                expiryDate: "",
                condition: "",
                dimensions: "",
                material: "",
                color: "",
                historicalSignificance: "",
                document: Document({
                    documentName: "",
                    documentType: "",
                    documentUrl: ""
                })
            }),
            currentOwner: Owner({
                name: "",
                contact: ""
            }),
            royaltyInfo: RoyaltyInfo({
                recipient: address(1),
                percentage: 0
            }),
            legalJurisdiction: "",
            disclaimer: ""
        });
    }

    function test_Get_defaultAdmin() public view {
        assertEq(nftWrapper.defaultAdmin(), defaultAdmin);
        assertNotEq(nftWrapper.defaultAdmin(), address(0));
    }

    function test_Wrap_NFT() public {
        vm.startPrank(defaultAdmin);
        nftWrapper.createWrappedToken(address(rwaNFT), 1000 * 10 ** 18);
        nftWrappedToken = NFTWrappedToken(nftWrapper.wrapped_token(address(rwaNFT)));
        vm.stopPrank();
        assertEq(nftWrappedToken.name(), string.concat("Wrapped ", rwaNFT.name()));
        assertEq(nftWrappedToken.symbol(), string.concat("W-", rwaNFT.symbol()));

        vm.startPrank(minter);
        rwaNFT.mint(defaultMetadata);
        rwaNFT.mint(defaultMetadata);
        vm.stopPrank();
        assertEq(rwaNFT.ownerOf(0), minter);
        assertEq(rwaNFT.ownerOf(1), minter);

        vm.startPrank(minter);
        rwaNFT.setApprovalForAll(address(nftWrapper), true);
        nftWrapper.wrap(address(rwaNFT), 1);
        assertEq(nftWrappedToken.balanceOf(minter), 1000 * 10 ** 18);
        vm.stopPrank();
        assertEq(rwaNFT.ownerOf(1), address(nftWrapper));
    }

    function test_Unwrap_NFT() public {
        vm.startPrank(defaultAdmin);
        nftWrapper.createWrappedToken(address(rwaNFT), 1000 * 10 ** 18);
        nftWrappedToken = NFTWrappedToken(nftWrapper.wrapped_token(address(rwaNFT)));
        vm.stopPrank();
        assertEq(nftWrappedToken.name(), string.concat("Wrapped ", rwaNFT.name()));
        assertEq(nftWrappedToken.symbol(), string.concat("W-", rwaNFT.symbol()));

        vm.startPrank(minter);
        rwaNFT.mint(defaultMetadata);
        rwaNFT.mint(defaultMetadata);
        rwaNFT.mint(defaultMetadata);
        rwaNFT.mint(defaultMetadata);
        vm.stopPrank();


        vm.startPrank(minter);
        rwaNFT.setApprovalForAll(address(nftWrapper), true);
        nftWrapper.wrap(address(rwaNFT), 0);
        nftWrapper.wrap(address(rwaNFT), 1);
        nftWrapper.wrap(address(rwaNFT), 2);
        nftWrapper.wrap(address(rwaNFT), 3);
        vm.stopPrank();

        uint256[] memory pool = nftWrapper.getNFTPools(address(rwaNFT));
        assertEq(pool.length, 4);
        assertEq(pool[0], 0);
        assertEq(pool[1], 1);
        assertEq(pool[2], 2);
        assertEq(pool[3], 3);

        vm.startPrank(minter);
        nftWrappedToken.approve(address(nftWrapper), 1000 * 10 ** 18);
        nftWrapper.unwrap(address(rwaNFT));
        assertEq(rwaNFT.balanceOf(minter), 1);
        vm.stopPrank();
    }

    // function test_Increment() public {
        // nftWrapper.increment();
        // assertEq(nftWrapper.number(), 1);
    // }

    // function testFuzz_SetNumber(uint256 x) public {
    //     nftWrapper.setNumber(x);
    //     assertEq(nftWrapper.number(), x);
    // }
}
