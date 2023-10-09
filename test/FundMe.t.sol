// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import { Test, console } from "forge-std/Test.sol";
import { FundMe } from "../src/FundMe.sol";
import { DeployFundMe } from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
  FundMe fundMe;

  address USER = makeAddr("user");
  uint256 constant SEND_VALUE = 0.1 ether;
  uint256 constant STARTING_BALANCE = 10 ether;

  function setUp() external {
    DeployFundMe deployFundMe = new DeployFundMe();
    (fundMe, ) = deployFundMe.run();
    vm.deal(USER, STARTING_BALANCE);
  }

  function testMinimumDollarsFive() public {
    assertEq(fundMe.MINIMUM_USD(), 5e18);
  }

  function testOwnerIsMsgSender() public {
    assertEq(fundMe.i_owner(), msg.sender);
  }

  function testPriceFeedVersion() public {
    assertEq(fundMe.getVersion(), 4);
  }

  function testFundFailsWithoutEnoughETH() public {
    vm.expectRevert();
    fundMe.fund();
  }

  function testFundUpdatesFundedDataStructure() public {
    vm.prank(USER);
    fundMe.fund{ value: SEND_VALUE }();
    uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
    assertEq(amountFunded, SEND_VALUE);
  }

  function testAddsFunderToArrayOfFunders() public {
    vm.prank(USER);
    fundMe.fund{ value: SEND_VALUE }();
    address funder = fundMe.getFunder(0);
    assertEq(funder, USER);
  }
}
