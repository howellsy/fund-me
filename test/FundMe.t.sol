// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { Test, console } from "forge-std/Test.sol";
import { FundMe } from "../src/FundMe.sol";

contract FundMeTest is Test {
  FundMe fundMe;

  function setUp() external {
    fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
  }

  function testMinimumDollarsFive() public {
    assertEq(fundMe.MINIMUM_USD(), 5e18);
  }

  function testOwnerIsMsgSender() public {
    assertEq(fundMe.i_owner(), address(this));
  }

  function testPriceFeedVersion() public {
    assertEq(fundMe.getVersion(), 4);
  }
}
