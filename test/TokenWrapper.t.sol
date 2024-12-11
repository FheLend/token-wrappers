// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import { TestToken } from "../contracts/TokenWrapper.sol";

contract TokenWraperTest is Test {
    function setUp() public {
        initializeFhe();

        ownerPrivateKey = 0xB0B;
        owner = vm.addr(ownerPrivateKey);
    }

    function testBBlanceOf() external {

    }

}