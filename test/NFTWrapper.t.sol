// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {NFTWrapper} from "../src/NFTWrapper.sol";

contract NFTWrapperTest is Test {
    NFTWrapper public nftWrapper;

    function setUp() public {
        nftWrapper = new NFTWrapper();
    }

    function test_Increment() public {
        nftWrapper.increment();
        assertEq(nftWrapper.number(), 1);
    }

    function testFuzz_SetNumber(uint256 x) public {
        nftWrapper.setNumber(x);
        assertEq(nftWrapper.number(), x);
    }
}
