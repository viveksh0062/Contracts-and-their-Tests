// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "lib/solmate/src/utils/ReentrancyGuard.sol";

contract Vault is ReentrancyGuard {
    address public owner;
    mapping(address => uint256) public balances;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    function deposit() external payable {
        require(msg.value > 0, "Zero deposit");
        balances[msg.sender] += msg.value;
    }

    function withdraw(uint256 amount) external nonReentrant {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        (bool sent, ) = msg.sender.call{value: amount}("");
        require(sent, "Transfer failed");
    }

    function sweepFunds(address to) external onlyOwner {
        uint256 amount = address(this).balance;
        (bool sent, ) = to.call{value: amount}("");
        require(sent, "Sweep failed");
    }
}
