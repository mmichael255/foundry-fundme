// Get funds from users
// Withdraw funds
// Set a minimum funding value in USD

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

//constant, immutable

error notOwner();

contract FundMe {
    //return uint256
    using PriceConverter for uint256;

    uint256 public constant minimumUsd = 5e18;
    address[] private s_funders;
    mapping(address funder => uint256 amountFunded)
        public s_addressToamountFunded;

    address private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address ss_priceFeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(
            ss_priceFeed //0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
    }

    function fund() public payable {
        // Allow users to send $
        // Have a minimum $ sent
        require(
            msg.value.getConversionRate(s_priceFeed) > minimumUsd,
            "didnt send enough eth"
        );
        s_funders.push(msg.sender);
        s_addressToamountFunded[msg.sender] =
            s_addressToamountFunded[msg.sender] +
            msg.value;
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            s_addressToamountFunded[s_funders[funderIndex]] = 0;
            s_funders = new address[](0);
        }
        // //transfer throws erro (msg.sender is address type; cast to payable address type)
        // payable (msg.sender).transfer(address(this).balance);
        // //send
        // bool sendSuccess = payable (msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // //call
        (bool callSuccess, bytes memory dataReturned) = payable(msg.sender)
            .call{value: address(this).balance}("");
        require(callSuccess, "call failed");
    }

    function withdrawButCheaper() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for (
            uint256 funderIndex = 0;
            funderIndex < fundersLength;
            funderIndex++
        ) {
            s_addressToamountFunded[s_funders[funderIndex]] = 0;
        }
        s_funders = new address[](0);
        // //transfer throws erro (msg.sender is address type; cast to payable address type)
        // payable (msg.sender).transfer(address(this).balance);
        // //send
        // bool sendSuccess = payable (msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");
        // //call
        (bool callSuccess, bytes memory dataReturned) = payable(msg.sender)
            .call{value: address(this).balance}("");
        require(callSuccess, "call failed");
    }

    modifier onlyOwner() {
        //require(msg.sender == i_owner);
        if (msg.sender != i_owner) {
            revert notOwner();
        }
        _;
    }

    // what if someone sends this contract eth without calling fundme function
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function getAddressToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToamountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }

    //Enums
    //Events
    //Try/Catch
    //Function Selectors
    //abi.encode / decode
    //Hashing
    //Yul / Assumbly
}
