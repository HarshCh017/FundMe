//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import "PriceConverter.sol";

// interface AggregatorV3Interface {
//     function decimals() external view returns (uint8);

//     function description() external view returns (string memory);

//     function version() external view returns (uint256);

//     function getRoundData(uint80 _roundId)
//         external
//         view
//         returns (
//             uint80 roundId,
//             int256 answer,
//             uint256 startedAt,
//             uint256 updatedAt,
//             uint80 answeredInRound
//         );

//     function latestRoundData()
//         external
//         view
//         returns (
//             uint80 roundId,
//             int256 answer,
//             uint256 startedAt,
//             uint256 updatedAt,
//             uint80 answeredInRound
//         );
// }

contract FundMe {
    using PriceConverter for uint256;

    uint256 public minimumUsd = 5e18;

    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    address public owner;

    constructor(){
        owner = msg.sender;
    }

    function fund() public payable {
       
        require( msg.value.getConversionRate() >= minimumUsd, "didn't send enough ETH");
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] = addressToAmountFunded[msg.sender]+msg.value;
    }

    function withdraw() public onlyOwner{
      

        //for loop
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        // reset the array
        funders = new address[](0);

        //withdraw the funds

        //transfer
        //payable (msg.sender).transfer(address(this).balance);

        //send
        //bool sendSuccess = payable(msg.sender).send(address(this).balance);
        //require(sendSuccess,"Send Failed");

        //call
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }
    modifier onlyOwner(){
        require(msg.sender == owner, "Sender is not owner!");
        _;
    }
    // what happens when some sends eth withot using fund function
    // then we can use recieve() or fallback()

    receive() external payable { 
        fund();
    }

    fallback() external payable {
        fund();
     }

}
