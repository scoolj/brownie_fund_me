 // SPDX-License-Identifier: MIT

pragma solidity ^0.6.6;

// import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";

import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
import "@chainlink/contracts/src/v0.6/vendor/SafeMathChainlink.sol";

 
contract FundMe {

    using SafeMathChainlink for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;
    address public owner;
    AggregatorV3Interface  public priceFeed;
    

    constructor(address _priceFeed) public {
        priceFeed = AggregatorV3Interface(_priceFeed);
        owner = msg.sender;
    }

    function fund() public payable {
        // $50
        uint256 mimimumUSD = 50 * 10 ** 18; 
        require(getCoversionRate(msg.value) >= mimimumUSD, " You need to spend more ETh!");
        addressToAmountFunded[msg.sender] += msg.value;
        funders.push(msg.sender);
    }


    function getVersion() public view returns (uint256){

        // AggregatorV3Interface priceFeed = AggregatorV3Interface(0xA39434A63A52E749F02807ae27335515BA4b07F7);
        return priceFeed.version();

    }

    function getPrice() public view returns(uint256){
       
        (, int256 answer,,,) =  priceFeed.latestRoundData();
        return uint256(answer);
    }


    function getCoversionRate(uint256 ethAmount) public view returns (uint256){
        uint256 ethPrice = getPrice();
        uint256 ethAmountInUsd = (ethPrice * ethAmount)/ 1000000000000000000;
        return ethAmountInUsd;
    }
    
function getEnteranceFee() public view returns (uint256){
    // minimumUSD
    uint256 minimumUSD = 50* 10**18;
    uint256 price = getPrice();
    uint256 precision =  1 * 10**18;
    return (minimumUSD * precision)/ price;
    
}

modifier onlyOwner{
        require(msg.sender == owner );
        _;
    }

    function withdraw() payable onlyOwner public {
        // require(msg.sender == owner);
        msg.sender.transfer(address(this).balance);

        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

        funders = new address[](0);
    }

 

}