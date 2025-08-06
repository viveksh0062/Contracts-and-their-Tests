// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/SimpleEscrow.sol";

contract SimpleEscrowTest is Test {
    SimpleEscrow public escrow;
    address payer = address(0x1);
    address payee = address(0x2);
    address arbiter = address(0x3);

    receive() external payable {}

    function setUp() public {
        vm.deal(payer, 5 ether);
        vm.prank(payer);
        escrow = new SimpleEscrow{value: 2 ether}(payer, payee, arbiter);
    }

    function testOnlyArbiterCanApprove() public {
        vm.expectRevert("Only arbiter can approve");
        vm.prank(payer);
        escrow.approve();
    }

    function testPayeeReceivesFundsOnApproval() public {
        uint256 initialPayeeBal = payee.balance;

        vm.prank(arbiter);
        escrow.approve();

        assertEq(payee.balance, initialPayeeBal + 2 ether);
        assertTrue(escrow.isApproved());
    }

    function testCannotApproveTwice() public {
        vm.prank(arbiter);
        escrow.approve();

        vm.expectRevert("Already approved");
        vm.prank(arbiter);
        escrow.approve();
    }
}
