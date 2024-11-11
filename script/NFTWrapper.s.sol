// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {NFTWrapper} from "../src/NFTWrapper.sol";
import {NFTWrappedToken} from "../src/NFTWrappedToken.sol";
import {RWANFT} from "../src/RWANFT.sol";

contract NFTWrapperScript is Script {
    NFTWrapper public nftWrapper;
    NFTWrappedToken public nftWrappedToken;
    RWANFT public rwaNFT;
    address public defaultAdmin;
    address public minter;

    function setUp() public {}

    function run() public {
        uint256 privateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(privateKey);

        defaultAdmin = vm.addr(privateKey);
        minter = vm.addr(privateKey);

        rwaNFT = new RWANFT(defaultAdmin, minter);
        nftWrapper = new NFTWrapper(defaultAdmin);
        nftWrapper.createWrappedToken(address(rwaNFT), 1000 * 10 ** 18);
        nftWrappedToken = NFTWrappedToken(nftWrapper.wrapped_token(address(rwaNFT)));

        console.log("NFTWrapper: %s", address(nftWrapper));
        console.log("NFTWrappedToken: %s", address(nftWrappedToken));
        console.log("RWA NFT: %s", address(rwaNFT));

        vm.stopBroadcast();
    }
}
