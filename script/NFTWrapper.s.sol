// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {NFTWrapper} from "../src/NFTWrapper.sol";

contract NFTWrapperScript is Script {
    NFTWrapper public nftWrapper;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        nftWrapper = new NFTWrapper();

        vm.stopBroadcast();
    }
}
