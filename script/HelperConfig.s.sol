// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import { Script } from "forge-std/Script.sol";
import { MockV3Aggregator } from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
  NetworkConfig public activeNetworkConfig;

  uint8 public constant DECIMALS = 8;
  int256 public constant INITIAL_PRICE = 2000e8;

  struct NetworkConfig {
    address priceFeed;
  }

  constructor() {
    if (block.chainid == 11155111) {
      activeNetworkConfig = getSepoliaEthConfig();
    } else {
      activeNetworkConfig = getAnvilEthConfig();
    }
  }

  function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
    NetworkConfig memory sepoliaConfig = NetworkConfig({
      priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
    });

    return sepoliaConfig;
  }

  function getAnvilEthConfig() public returns (NetworkConfig memory) {
    // deploy the mock price feed
    vm.startBroadcast();
    MockV3Aggregator mockPriceFeed = new MockV3Aggregator(
      DECIMALS,
      INITIAL_PRICE
    );
    vm.stopBroadcast();

    NetworkConfig memory anvilConfig = NetworkConfig({
      priceFeed: address(mockPriceFeed)
    });

    return anvilConfig;
  }
}
