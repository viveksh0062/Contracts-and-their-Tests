// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract TimeAuction {
    address public seller;
    uint256 public endTime;

    address public highestBidder;
    uint256 public highestBid;

    bool public ended;

    constructor(uint256 _durationInSeconds) {
        seller = msg.sender;
        endTime = block.timestamp + _durationInSeconds;
    }

    mapping(address => uint256) public pendingReturns;

    event BidPlaced(address indexed bider, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);

    function bid() external payable {
        require(block.timestamp < endTime, "Auction already ended");
        require(msg.value > highestBid, "Bid too low");

        if (highestBid > 0) {
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;

        emit BidPlaced(msg.sender, msg.value);
    }

    function withdraw() external {
        uint256 amount = pendingReturns[msg.sender];
        require(amount > 0, "Nothing to withdraw");

        pendingReturns[msg.sender] = 0;

        (bool sent,) = msg.sender.call{value: amount}("");
        require(sent, "Withdraw failed");
    }

    function endAuction() external {
        require(block.timestamp >= endTime, "Auction not ended yet");
        require(!ended, "Auction already ended");

        ended = true;

        (bool sent,) = seller.call{value: highestBid}("");
        require(sent, "Transfer to seller failed");

        emit AuctionEnded(highestBidder, highestBid);
    }
}
