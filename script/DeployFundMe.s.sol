// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Script } from "forge-std/Script.sol";
import { HelperConfig } from "./HelperConfig.s.sol";
import { FundMe } from "../src/FundMe.sol";

contract DeployFundMe is Script {
  function run() external returns (FundMe, HelperConfig) {
    HelperConfig helperConfig = new HelperConfig();
    address priceFeed = helperConfig.activeNetworkConfig();

    vm.startBroadcast();
    FundMe fundMe = new FundMe(priceFeed);
    vm.stopBroadcast();
    return (fundMe, helperConfig);
  }
}
