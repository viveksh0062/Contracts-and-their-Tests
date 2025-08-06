# 🔐 Smart Contract Practice Projects

This repository contains a curated set of intermediate-level Solidity smart contracts and their comprehensive test suites written in [Foundry](https://book.getfoundry.sh/). These projects were built to enhance practical understanding of secure contract development, patterns, and edge case handling in Ethereum.

---

## 📦 Contracts Overview

| Contract             | Description                                                                                                     |
| -------------------- | --------------------------------------------------------------------------------------------------------------- |
| **Vault**            | A simple deposit/withdraw contract with an owner-controlled sweep function. Includes reentrancy protection.     |
| **Allowance**        | Mimics a bank-like system where the owner can set withdrawal allowances for others.                             |
| **EtherSplitter**    | Distributes received Ether between recipients based on predefined percentage shares.                            |
| **MultiOwnerWallet** | A shared wallet that allows multiple owners with the ability to transfer ownership and withdraw funds.          |
| **SimpleEscrow**     | A basic escrow contract where a payer deposits funds, and only the trusted arbiter can release it to the payee. |
| **TimeLockedWallet** | A wallet that locks user funds until a future unlock time.                                                      |
| **TimeAuction**      | An auction system that allows time-based bidding with automatic winner selection and fund handling.             |

---

## 🧪 Testing

- Written using [Foundry](https://github.com/foundry-rs/foundry)
- All tests are deterministic and cover:
  - Positive flows (happy paths)
  - Negative flows (reverts and edge cases)
  - Gas estimation and state assertions

Run tests using:

```bash
forge test -vv
📁 Folder Structure
bash
Copy
Edit
.
├── src/
│   ├── Allowance.sol
│   ├── EtherSplitter.sol
│   ├── MultiOwnerWallet.sol
│   ├── SimpleEscrow.sol
│   ├── TimeAuction.sol
│   ├── TimeLockedWallet.sol
│   └── Vault.sol
├── test/
│   ├── Allowance.t.sol
│   ├── EtherSplitter.t.sol
│   ├── MultiOwnerWallet.t.sol
│   ├── SimpleEscrow.t.sol
│   ├── TimeAuction.t.sol
│   ├── TimeLockedWallet.t.sol
│   └── Vault.t.sol
⚒️ Built With
Solidity ^0.8.x

Foundry (forge)

OpenZeppelin Contracts

Solmate Utils

✅ Skills Practiced
Ownership and access control

Ether handling and security patterns (reentrancy, time locks)

Escrow systems

Auction logic

Multi-party wallets

Foundry test writing and cheatcodes

🙌 Acknowledgements
Inspired by practice tasks from:

Patrick Collins’ Foundry Course

Cyfrin Updraft

OpenZeppelin Patterns

📜 License
This project is licensed under the MIT License. Feel free to use, learn from, or build upon it.