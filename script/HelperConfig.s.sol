// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mock/MockV3Aggregator.sol";

contract HelperConfig is Script {
    uint8 public DECIMAL = 8;
    int256 public INITIAL_PRICE = 20e8;
    struct NetworkConfig {
        address PriceFeed;
    }

    NetworkConfig public activeNetworkConfig;

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaAddress();
        } else {
            activeNetworkConfig = getAnvilAddress();
        }
    }

    function getSepoliaAddress() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaAddress = NetworkConfig({
            PriceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaAddress;
    }

    function getAnvilAddress() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.PriceFeed != address(0)) {
            return activeNetworkConfig;
        }
        vm.startBroadcast();
        MockV3Aggregator mockV3Aggregator = new MockV3Aggregator(
            DECIMAL,
            INITIAL_PRICE
        );
        vm.stopBroadcast();
        NetworkConfig memory anvilAddress = NetworkConfig({
            PriceFeed: address(mockV3Aggregator)
        });
        return anvilAddress;
    }
}
