// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/TimeAuction.sol";

contract TimeAuctionTest is Test {
    TimeAuction public auction;
    address payable seller = payable(address(0x123)); // new seller
    address bidder1 = address(0x1);
    address bidder2 = address(0x2);

    function setUp() public {
        vm.deal(seller, 0); // zero balance before
        vm.prank(seller);
        auction = new TimeAuction(1 hours);

        vm.deal(bidder1, 5 ether);
        vm.deal(bidder2, 5 ether);
    }

    function testInitialValues() public {
        assertEq(auction.highestBid(), 0);
        assertEq(auction.ended(), false);
    }

    function testBidWorks() public {
        vm.prank(bidder1);
        auction.bid{value: 1 ether}();

        assertEq(auction.highestBid(), 1 ether);
        assertEq(auction.highestBidder(), bidder1);
    }

    function testHigherBidRefundsPrevious() public {
        vm.prank(bidder1);
        auction.bid{value: 1 ether}();

        vm.prank(bidder2);
        auction.bid{value: 2 ether}();

        assertEq(auction.highestBid(), 2 ether);
        assertEq(auction.highestBidder(), bidder2);
        assertEq(auction.pendingReturns(bidder1), 1 ether);
    }

    function testLowerBidReverts() public {
        vm.prank(bidder1);
        auction.bid{value: 1 ether}();

        vm.expectRevert("Bid too low");
        vm.prank(bidder2);
        auction.bid{value: 0.5 ether}();
    }

    function testWithdrawRefunds() public {
        vm.prank(bidder1);
        auction.bid{value: 1 ether}();

        vm.prank(bidder2);
        auction.bid{value: 2 ether}();

        vm.prank(bidder1);
        auction.withdraw();

        assertEq(bidder1.balance, 5 ether); // full refund
    }

    function testEndAuctionTransfersToSeller() public {
        vm.prank(bidder1);
        auction.bid{value: 3 ether}();

        // Travel forward in time
        vm.warp(block.timestamp + 2 hours);

        uint256 balBefore = seller.balance;

        vm.prank(seller); // auction.endAuction must be called by same seller
        auction.endAuction();

        uint256 balAfter = seller.balance;

        assertEq(balAfter, balBefore + 3 ether);
        assertTrue(auction.ended());
    }

    function testCannotEndBeforeTime() public {
        vm.expectRevert("Auction not ended yet");
        auction.endAuction();
    }

    function testCannotBidAfterAuctionEnded() public {
        vm.prank(bidder1);
        auction.bid{value: 1 ether}();

        vm.warp(block.timestamp + 2 hours);
        auction.endAuction();

        vm.expectRevert("Auction already ended");
        vm.prank(bidder2);
        auction.bid{value: 2 ether}();
    }
}
