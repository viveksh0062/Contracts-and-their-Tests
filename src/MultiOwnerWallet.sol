// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MultiOwnerWallet {
    address[] public owners;
    uint256 public requiredApprovals;

    struct TransferRequest {
        address to;
        uint256 amount;
        uint256 approvals;
        bool sent;
        mapping(address => bool) approvedBy;
    }

    TransferRequest[] public transfers;

    modifier onlyOwner() {
        bool isOwner = false;
        for (uint i = 0; i < owners.length; i++) {
            if (msg.sender == owners[i]) {
                isOwner = true;
                break;
            }
        }
        require(isOwner, "Not an owner");
        _;
    }

    constructor(address[] memory _owners, uint256 _requiredApprovals) payable {
        require(_owners.length >= _requiredApprovals, "Invalid approval");
        owners = _owners;
        requiredApprovals = _requiredApprovals;
    }

    receive() external payable {}

    function createTransfer(address _to, uint256 _amount) external onlyOwner {
        transfers.push();
        TransferRequest storage t = transfers[transfers.length - 1];
        t.to = _to;
        t.amount = _amount;
        t.approvals = 0;
        t.sent = false;
    }

    function approveTransfer(uint256 index) external onlyOwner {
        TransferRequest storage t = transfers[index];
        require(!t.sent, "Already sent");
        require(!t.approvedBy[msg.sender], "Already approved");

        t.approvedBy[msg.sender] = true;
        t.approvals++;

        if (t.approvals >= requiredApprovals) {
            t.sent = true;
            (bool success, ) = t.to.call{value: t.amount}("");
            require(success, "Transfer failed");
        }
    }

    function getTransfer(
        uint256 index
    )
        external
        view
        returns (address to, uint256 amount, uint256 approvals, bool sent)
    {
        TransferRequest storage t = transfers[index];
        return (t.to, t.amount, t.approvals, t.sent);
    }

    function getTransferCount() external view returns (uint256) {
        return transfers.length;
    }
}
