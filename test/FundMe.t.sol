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
    assertEq(fundMe.getMinimumUsd(), 5e18);
  }

  function testOwnerIsMsgSender() public {
    assertEq(fundMe.getOwner(), msg.sender);
  }

  function testPriceFeedVersion() public {
    assertEq(fundMe.getVersion(), 4);
  }

  function testFundFailsWithoutEnoughETH() public {
    vm.expectRevert();
    fundMe.fund();
  }

  function testFundUpdatesFundedDataStructure() public {
    vm.startPrank(USER);
    fundMe.fund{ value: SEND_VALUE }();
    vm.stopPrank();
    uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
    assertEq(amountFunded, SEND_VALUE);
  }

  modifier funded() {
    vm.startPrank(USER);
    fundMe.fund{ value: SEND_VALUE }();
    vm.stopPrank();
    _;
  }

  function testAddsFunderToArrayOfFunders() public funded {
    address funder = fundMe.getFunder(0);
    assertEq(funder, USER);
  }

  function testOnlyOwnerCanWithdraw() public funded {
    vm.expectRevert();
    vm.startPrank(USER);
    fundMe.withdraw();
    vm.stopPrank();
  }

  function testWithdrawAsASingleFunder() public funded {
    uint256 startingOwnerBalance = fundMe.getOwner().balance;
    uint256 startingFundMeBalance = address(fundMe).balance;

    vm.startPrank(fundMe.getOwner());
    fundMe.withdraw();
    vm.stopPrank();

    uint256 endingOwnerBalance = fundMe.getOwner().balance;
    uint256 endingFundMeBalance = address(fundMe).balance;
    assertEq(endingFundMeBalance, 0);
    assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
  }

  function testWithdrawFromMultipleFunders() public funded {
    uint160 numberOfFunders = 10;
    uint160 startingFunderIndex = 1;

    for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
      hoax(address(i), SEND_VALUE);
      fundMe.fund{ value: SEND_VALUE }();
    }

    uint256 startingOwnerBalance = fundMe.getOwner().balance;
    uint256 startingFundMeBalance = address(fundMe).balance;

    vm.startPrank(fundMe.getOwner());
    fundMe.withdraw();
    vm.stopPrank();

    assertEq(address(fundMe).balance, 0);
    assertEq(
      startingFundMeBalance + startingOwnerBalance,
      fundMe.getOwner().balance
    );
  }
}
