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
        console.log(fundme.getOwner());

        console.log(msg.sender);
        //assertEq(fundme.i_owner(), address(this));
        assertEq(fundme.getOwner(), msg.sender);
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

    function testFundUpdateAddressToAmountFunded() public {
        vm.prank(USER);
        fundme.fund{value: 1e18}();
        uint256 amount = fundme.getAddressToAmountFunded(USER);
        assertEq(amount, 1e18);
    }

    function testGetFunder() public {
        vm.prank(USER);
        fundme.fund{value: 1e18}();
        address funder = fundme.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundme.fund{value: 1e18}();
        _;
    }

    function testWithdrawFail() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundme.withdraw();
    }

    function testWithdrawSuccess() public funded {
        uint256 beforeOwnerBalance = fundme.getOwner().balance;
        uint256 beforeContractBalance = address(fundme).balance;
        console.log(beforeOwnerBalance);
        console.log(beforeContractBalance);

        vm.prank(fundme.getOwner());
        fundme.withdraw();

        uint256 afterOwnerBalance = fundme.getOwner().balance;
        uint256 afterContractBalance = address(fundme).balance;

        console.log(afterOwnerBalance);
        console.log(afterContractBalance);
        assertEq(afterContractBalance, 0);
        assertEq(afterOwnerBalance, beforeContractBalance + beforeOwnerBalance);
    }

    function testMultiWithdrawSuccess() public {
        uint160 startIndex = 1;
        uint160 endIndex = 10;

        for (uint160 i = startIndex; i <= endIndex; i++) {
            hoax(address(i), 1e18);
            fundme.fund{value: 1e18}();
        }
        uint256 beforeOwnerBalance = fundme.getOwner().balance;
        uint256 beforeContractBalance = address(fundme).balance;
        console.log(beforeOwnerBalance);
        console.log(beforeContractBalance);

        vm.prank(fundme.getOwner());
        fundme.withdraw();

        uint256 afterOwnerBalance = fundme.getOwner().balance;
        uint256 afterContractBalance = address(fundme).balance;

        console.log(afterOwnerBalance);
        console.log(afterContractBalance);
        assertEq(afterContractBalance, 0);
        assertEq(afterOwnerBalance, beforeContractBalance + beforeOwnerBalance);
    }
    //what can we do to work with address outside our chain
    //Unit -testing a specific part of our code
    //Integration -testing our code work with other parts of code
    //Forked -testing on simulated real enviroment
    //staging -testing in a real environment that is not prod
}
