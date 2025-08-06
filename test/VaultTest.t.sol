// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/Vault.sol";

contract VaultTest is Test {
    Vault public vault;
    address user = address(0x1);
    address owner;

    // Allow this contract to receive ETH (needed for sweep tests)
    receive() external payable {}

    function setUp() public {
        vault = new Vault();
        owner = address(this);
        vm.deal(user, 10 ether);
    }

    function testDepositIncreasesUserBalance() public {
        vm.prank(user);
        vault.deposit{value: 2 ether}();

        assertEq(
            vault.balances(user),
            2 ether,
            "Deposit did not update balance"
        );
    }

    function testWithdrawDecreasesUserBalance() public {
        vm.prank(user);
        vault.deposit{value: 3 ether}();

        vm.prank(user);
        vault.withdraw(1 ether);

        assertEq(
            vault.balances(user),
            2 ether,
            "Withdraw did not decrease balance"
        );
    }

    function testWithdrawFailsWhenInsufficientBalance() public {
        vm.prank(user);
        vault.deposit{value: 1 ether}();

        vm.expectRevert("Insufficient balance");
        vm.prank(user);
        vault.withdraw(2 ether);
    }

    function testCannotDepositZero() public {
        vm.expectRevert("Zero deposit");
        vm.prank(user);
        vault.deposit{value: 0}();
    }

    function testOnlyOwnerCanSweep() public {
        // First, let user deposit some ETH so vault has balance
        vm.prank(user);
        vault.deposit{value: 2 ether}();

        // Non-owner should fail
        vm.expectRevert("Not owner");
        vm.prank(user);
        vault.sweepFunds(user);

        // Owner should succeed
        uint256 balanceBefore = address(this).balance;

        vault.sweepFunds(address(this));

        uint256 balanceAfter = address(this).balance;
        assertGt(
            balanceAfter,
            balanceBefore,
            "Sweep did not send funds to owner"
        );
    }
}
