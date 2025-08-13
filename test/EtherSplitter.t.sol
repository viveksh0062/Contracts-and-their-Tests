// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/EtherSplitter.sol";

contract EtherSplitterTest is Test {
    EtherSplitter public splitter;
    address alice = address(0x1);
    address bob = address(0x2);
    address carol = address(0x3);

    receive() external payable {}

    function setUp() public {
        address[] memory recipients = new address[](3);
        recipients[0] = alice;
        recipients[1] = bob;
        recipients[2] = carol;

        uint256[] memory shares = new uint256[](3);
        shares[0] = 50; // Alice: 50%
        shares[1] = 30; // Bob: 30%
        shares[2] = 20; // Carol: 20%

        splitter = new EtherSplitter(recipients, shares);

        vm.deal(address(this), 10 ether);
    }

    function testDistributeEtherCorrectly() public {
        uint256 amount = 2 ether;

        // Send ETH to trigger receive()
        (bool success,) = address(splitter).call{value: amount}("");
        require(success, "Transfer failed");

        assertEq(alice.balance, 1 ether); // 50%
        assertEq(bob.balance, 0.6 ether); // 30%
        assertEq(carol.balance, 0.4 ether); // 20%
    }

    function testOnlyDistributesWhenBalancePresent() public {
        vm.expectRevert("No funds to distribute");
        splitter.distribute();
    }

    function testConstructorFailsOnWrongShares() public {
        address[] memory rec = new address[](2);
        uint256[] memory badShares = new uint256[](2);
        rec[0] = alice;
        rec[1] = bob;

        badShares[0] = 60;
        badShares[1] = 50;

        vm.expectRevert("Total shares must be 100%");
        new EtherSplitter(rec, badShares);
    }

    function testZeroSharedNotAllowed() public {
        address[] memory rec = new address[](2);
        uint256[] memory badShares = new uint256[](2);
        rec[0] = alice;
        rec[1] = bob;

        badShares[0] = 100;
        badShares[1] = 0;

        vm.expectRevert("Zero share not allowed");
        new EtherSplitter(rec, badShares);
    }
}
