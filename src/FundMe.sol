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
    address[] public funders;
    mapping(address funder => uint256 amountFunded)
        public addressToamountFunded;

    address public immutable i_owner;
    AggregatorV3Interface private priceFeed;

    constructor(address s_priceFeed) {
        i_owner = msg.sender;
        priceFeed = AggregatorV3Interface(
            s_priceFeed //0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
    }

    function fund() public payable {
        // Allow users to send $
        // Have a minimum $ sent
        require(
            msg.value.getConversionRate(priceFeed) > minimumUsd,
            "didnt send enough eth"
        );
        funders.push(msg.sender);
        addressToamountFunded[msg.sender] =
            addressToamountFunded[msg.sender] +
            msg.value;
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < funders.length;
            funderIndex++
        ) {
            addressToamountFunded[funders[funderIndex]] = 0;
            funders = new address[](0);

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
        return priceFeed.version();
    }

    //Enums
    //Events
    //Try/Catch
    //Function Selectors
    //abi.encode / decode
    //Hashing
    //Yul / Assumbly
}
