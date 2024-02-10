// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/Interaction.s.sol";

contract InteractionTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant BALANCE = 10 ether;

    uint256 constant SEND_VALUE = 1 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, BALANCE);
    }

    function testFundFundMe() public {
        FundFundMe fundFundMe1 = new FundFundMe();
        fundFundMe1.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe1 = new WithdrawFundMe();
        withdrawFundMe1.withdrawFundMe(address(fundMe));

        assertEq(address(fundMe).balance, 0);
    }
}
