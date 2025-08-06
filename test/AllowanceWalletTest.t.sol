// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/AllowanceWallet.sol";

contract AllowanceWalletTest is Test {
    AllowanceWallet public wallet;
    address user = address(0x1);
    address owner;

    // Allow test contract to recieve eth if needed
    receive() external payable {}

    function setUp() public {
        wallet = new AllowanceWallet();
        owner = address(this);

        // Fund the contract with some eth
        vm.deal(address(wallet), 10 ether);
    }

    function testOwnerCanSetAllowance() public {
        wallet.setAllowance(user, 2 ether);
        assertEq(wallet.allowance(user), 2 ether);
    }

    function testOnlyOwnerCanSetAllowance() public {
        vm.expectRevert("Not owner");
        vm.prank(user);
        wallet.setAllowance(user, 1 ether);
    }

    function testUserCanWithdrawUptoAllowance() public {
        wallet.setAllowance(user, 3 ether);

        vm.prank(user);
        wallet.withdraw(2 ether);

        assertEq(wallet.allowance(user), 1 ether);
    }

    function testCannotWithdrawMoreThanAllowance() public {
        wallet.setAllowance(user, 1 ether);

        vm.expectRevert("Exceeds allowance");
        vm.prank(user);
        wallet.withdraw(2 ether);
    }

    function testCannotWithdrawMoreThanWalletBalance() public {
        // Drain contract first
        wallet.setAllowance(user, 11 ether);

        vm.expectRevert("Insufficient wallet balance");
        vm.prank(user);
        wallet.withdraw(11 ether);
    }
}
