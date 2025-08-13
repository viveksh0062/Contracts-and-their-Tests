// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "lib/solmate/src/utils/ReentrancyGuard.sol";

contract AllowanceWallet is ReentrancyGuard {
    address public owner;
    mapping(address => uint256) public allowance;

    event AllowanceSet(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);
    event Recieved(address indexed sender, uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {
        emit Recieved(msg.sender, msg.value);
    }

    function setAllowance(address user, uint256 amount) external onlyOwner {
        allowance[user] = amount;
        emit AllowanceSet(user, amount);
    }

    function withdraw(uint256 amount) external nonReentrant {
        require(allowance[msg.sender] >= amount, "Exceeds allowance");
        require(address(this).balance >= amount, "Insufficient wallet balance");

        allowance[msg.sender] -= amount;

        (bool sent,) = msg.sender.call{value: amount}("");
        require(sent, "Withdraw failed");

        emit Withdrawn(msg.sender, amount);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
