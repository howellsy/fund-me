// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

library PriceConverter {
    /**
     * @notice Get the latest price of a Chainlink price feed as a uint256
     * @dev This function uses the latestRoundData() function from the Chainlink price feed contract
     * @param priceFeed Chainlink price feed contract
     */
    function getPrice(AggregatorV3Interface priceFeed) internal view returns (uint256) {
        (, int256 answer,,,) = priceFeed.latestRoundData();

        return uint256(answer * 10000000000);
    }

    /**
     * @notice Convert ETH to USD
     * @param ethAmount Amount of ETH to convert to USD
     * @param priceFeed Chainlink price feed contract
     */
    function getConversionRate(uint256 ethAmount, AggregatorV3Interface priceFeed) internal view returns (uint256) {
        uint256 ethPrice = getPrice(priceFeed);
        uint256 ethAmountInUsd = (ethPrice * ethAmount) / 1e18;

        return ethAmountInUsd;
    }
}
