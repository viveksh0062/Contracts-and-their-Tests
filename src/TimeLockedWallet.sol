// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

contract TimeLockedWallet {
    address public owner;

    struct Deposit {
        uint256 amount;
        uint256 unlockTime;
        bool withdrawn;
    }

    mapping(address => Deposit[]) public deposits;
    mapping(address => bool) public isBlacklisted;

    event Deposited(address indexed user, uint256 amount, uint256 unlockTime);
    event Withdrawn(address indexed user, uint256 amount);
    event Blacklisted(address indexed user);
    event RemovedFromBlacklist(address indexed user);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    modifier notBlacklisted() {
        require(!isBlacklisted[msg.sender], "Blacklisted");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function deposit(uint256 lockDuration) external payable notBlacklisted {
        require(msg.value > 0, "Zero deposit");
        uint256 unlock = block.timestamp + lockDuration;
        deposits[msg.sender].push(Deposit(msg.value, unlock, false));
        emit Deposited(msg.sender, msg.value, unlock);
    }

    function withdraw(uint256 index) external notBlacklisted {
        Deposit storage userDeposit = deposits[msg.sender][index];
        require(!userDeposit.withdrawn, "Already withdrawn");
        require(block.timestamp >= userDeposit.unlockTime, "Too early");
        userDeposit.withdrawn = true;

        (bool sent,) = msg.sender.call{value: userDeposit.amount}("");
        require(sent, "Transfer failed");

        emit Withdrawn(msg.sender, userDeposit.amount);
    }

    function blacklist(address user) external onlyOwner {
        isBlacklisted[user] = true;
        emit Blacklisted(user);
    }

    function removeFromBlacklist(address user) external onlyOwner {
        isBlacklisted[user] = false;
        emit RemovedFromBlacklist(user);
    }

    function getDeposits(address user) external view returns (Deposit[] memory) {
        return deposits[user];
    }
}
