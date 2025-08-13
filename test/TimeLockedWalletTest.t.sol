// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/TimeLockedWallet.sol";

contract TimeLockedWalletTest is Test {
    TimeLockedWallet public wallet;
    address user = address(0x1);
    address owner;

    function setUp() public {
        wallet = new TimeLockedWallet();
        owner = address(this);
        vm.deal(user, 10 ether);
    }

    function testDepositCreatesEntry() public {
        vm.prank(user);
        wallet.deposit{value: 2 ether}(1 days);

        TimeLockedWallet.Deposit[] memory userDeposits = wallet.getDeposits(user);
        assertEq(userDeposits.length, 1);
        assertEq(userDeposits[0].amount, 2 ether);
    }

    function testCannotWithrawBeforeUnlock() public {
        vm.prank(user);
        wallet.deposit{value: 1 ether}(3 days);

        vm.expectRevert("Too early");
        vm.prank(user);
        wallet.withdraw(0);
    }

    function testWithdrawAfterTime() public {
        vm.prank(user);
        wallet.deposit{value: 1 ether}(2 days);

        vm.warp(block.timestamp + 2 days);
        vm.prank(user);
        wallet.withdraw(0);

        TimeLockedWallet.Deposit[] memory userDeposits = wallet.getDeposits(user);
        assertTrue(userDeposits[0].withdrawn);
    }

    function testBlacklistBlocksDeposit() public {
        wallet.blacklist(user);

        vm.expectRevert("Blacklisted");
        vm.prank(user);
        wallet.deposit{value: 1 ether}(1 days);
    }

    function testBlacklistBlocksWithdraw() public {
        vm.prank(user);
        wallet.deposit{value: 1 ether}(1 days);

        vm.warp(block.timestamp + 1 days);
        wallet.blacklist(user);

        vm.expectRevert("Blacklisted");
        vm.prank(user);
        wallet.withdraw(0);
    }
}
