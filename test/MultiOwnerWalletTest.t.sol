// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/MultiOwnerWallet.sol";

contract MultiOwnerWalletTest is Test {
    MultiOwnerWallet public wallet;
    address owner1 = address(0x1);
    address owner2 = address(0x2);
    address owner3 = address(0x3);
    address recipient = address(0x99);

    receive() external payable {}

    function setUp() public {
        address[] memory owners = new address[](3);
        owners[0] = owner1;
        owners[1] = owner2;
        owners[2] = owner3;

        wallet = new MultiOwnerWallet{value: 10 ether}(owners, 2);
        vm.deal(owner1, 1 ether);
        vm.deal(owner2, 1 ether);
        vm.deal(owner3, 1 ether);
    }

    function testOnlyOwnerCanCreateTransfer() public {
        vm.expectRevert("Not an owner");
        wallet.createTransfer(recipient, 1 ether);
    }

    function testTransferApprovalAndExecution() public {
        // Owner1 creates transfer
        vm.prank(owner1);
        wallet.createTransfer(recipient, 2 ether);

        // Approve with Owner1
        vm.prank(owner1);
        wallet.approveTransfer(0);

        // Not enough approvals yet, should not send
        (, , uint256 approvals1, bool sent1) = wallet.getTransfer(0);
        assertEq(approvals1, 1);
        assertFalse(sent1);

        // Approve with owner2
        vm.prank(owner2);
        wallet.approveTransfer(0);

        // Now it should send
        (, , uint256 approvals2, bool sent2) = wallet.getTransfer(0);
        assertEq(approvals2, 2);
        assertTrue(sent2);
    }

    function testCannotApproveTwice() public {
        vm.prank(owner1);
        wallet.createTransfer(recipient, 1 ether);

        vm.prank(owner1);
        wallet.approveTransfer(0);

        vm.expectRevert("Already approved");
        vm.prank(owner1);
        wallet.approveTransfer(0);
    }
}
