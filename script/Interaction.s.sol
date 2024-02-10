// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant SEND_VALUE = 1 ether;

    function fundFundMe(address recentDepoly) public {
        vm.startBroadcast();
        FundMe(payable(recentDepoly)).fund{value: SEND_VALUE}();
        console.log("Funded FundMe with %s", SEND_VALUE);
        vm.stopBroadcast();
    }

    function run() external {
        address recentDeploy = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.startBroadcast();
        fundFundMe(recentDeploy);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address recentDepoly) public {
        vm.startBroadcast();
        FundMe(payable(recentDepoly)).withdraw();
        vm.stopBroadcast();
    }

    function run() external {
        address recentDeploy = DevOpsTools.get_most_recent_deployment(
            "FundMe",
            block.chainid
        );
        vm.broadcast();
        withdrawFundMe(recentDeploy);
        vm.stopBroadcast();
    }
}
