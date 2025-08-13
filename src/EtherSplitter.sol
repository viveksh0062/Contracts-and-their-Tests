// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract EtherSplitter {
    address[] public recipients;
    mapping(address => uint256) public shares; // in %
    uint256 public totalShares;

    constructor(address[] memory _recipients, uint256[] memory _shares) {
        require(_recipients.length == _shares.length, "Length mismatch");
        uint256 sum = 0;
        for (uint256 i = 0; i < _recipients.length; i++) {
            require(_shares[i] > 0, "Zero share not allowed");
            recipients.push(_recipients[i]);
            shares[_recipients[i]] = _shares[i];
            sum += _shares[i];
        }
        require(sum == 100, "Total shares must be 100%");
        totalShares = sum;
    }

    receive() external payable {
        distribute();
    }

    function distribute() public {
        uint256 balance = address(this).balance;
        require(balance > 0, "No funds to distribute");

        for (uint256 i = 0; i < recipients.length; i++) {
            address recipient = recipients[i];
            uint256 shareAmount = (balance * shares[recipient]) / 100;

            (bool sent,) = recipient.call{value: shareAmount}("");
            require(sent, "Transfer failed");
        }
    }

    function getRecipients() external view returns (address[] memory) {
        return recipients;
    }

    function getShare(address user) external view returns (uint256) {
        return shares[user];
    }
}
