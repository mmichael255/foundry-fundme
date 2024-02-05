// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";
import {DeployFundMe} from "../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundme;
    address USER = makeAddr("user");
    uint256 constant BALANCE = 10 ether;

    uint256 constant SEND_VALUE = 0.1 ether;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundme = deployFundMe.run();
        vm.deal(USER, BALANCE);
    }

    function testUSD() public {
        assertEq(fundme.minimumUsd(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        console.log(fundme.i_owner());

        console.log(msg.sender);
        //assertEq(fundme.i_owner(), address(this));
        assertEq(fundme.i_owner(), msg.sender);
    }

    function testGetVersion() public {
        console.log(fundme.getVersion());
        //uint256 version = fundme.getVersion();
        assertEq(fundme.getVersion(), 4);
    }

    function testFundFailsWithoutETH() public {
        vm.expectRevert();
        fundme.fund();
    }

    function testFundUpdate() public {
        vm.prank(USER);
        fundme.fund{value: 1e18}();
        uint256 amount = fundme.getAddressToAmountFunded(USER);
        assertEq(amount, 1e18);
    }

    //what can we do to work with address outside our chain
    //Unit -testing a specific part of our code
    //Integration -testing our code work with other parts of code
    //Forked -testing on simulated real enviroment
    //staging -testing in a real environment that is not prod
}
