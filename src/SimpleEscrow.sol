// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SimpleEscrow {
    address public payer;
    address public payee;
    address public arbiter;
    bool public isApproved;

    constructor(address _payer, address _payee, address _arbiter) payable {
        require(msg.value > 0, "Must send eth");
        payer = _payer;
        payee = _payee;
        arbiter = _arbiter;
    }

    function approve() external {
        require(msg.sender == arbiter, "Only arbiter can approve");
        require(!isApproved, "Already approved");

        isApproved = true;

        (bool sent,) = payee.call{value: address(this).balance}("");
        require(sent, "Transfer failed");
    }
}
