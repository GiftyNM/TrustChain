# TrustChain - Decentralized Trust Scoring System

TrustChain is a decentralized trust scoring system built on the Stacks blockchain. It enables cross-platform reputation tracking, allowing users to build and maintain credibility scores that can be utilized across various integrated services and platforms.

## 🌟 Features

- **Decentralized Trust Scoring**: Build reputation through peer evaluations
- **Cross-Platform Integration**: Connect multiple services to leverage unified trust scores
- **Stake-Based Security**: Requires collateral to submit evaluations, preventing spam
- **Verification System**: Admin-controlled account verification for enhanced credibility
- **Transparent Scoring**: All evaluations and scores are recorded on-chain
- **Scalable Architecture**: Designed to support multiple platform integrations

## 🏗️ Architecture

### Core Components

1. **Account Records**: Store user trust scores, evaluation counts, and verification status
2. **Trust Evaluations**: Record individual peer-to-peer trust assessments
3. **Service Connectors**: Manage integrations with external platforms and services

### Trust Scoring Algorithm

- Users start with a neutral trust score of 5,000 (out of 10,000)
- New evaluations are weighted against existing scores using a moving average
- Scores range from 1-10, scaled to 1,000-10,000 internally
- Final scores can be retrieved as percentages (0-100%)

## 🚀 Getting Started

### Prerequisites

- Stacks wallet (Hiro Wallet, Xverse, etc.)
- Minimum 1 STX for submitting evaluations
- Access to Stacks testnet or mainnet

### Installation

1. Deploy the contract to Stacks blockchain
2. Call `register-account` to join the trust network
3. Start building your reputation by receiving evaluations from other users

## 📊 API Reference

### Public Functions

#### `register-account()`
Registers a new user account in the trust system.
- **Returns**: `(ok true)` on success
- **Errors**: `ERR_ACCESS_DENIED` if already registered

#### `submit-evaluation(evaluated, score, evaluation-type)`
Submit a trust evaluation for another user.
- **Parameters**:
  - `evaluated`: Principal of the account being evaluated
  - `score`: Trust score (1-10)
  - `evaluation-type`: Category of evaluation (max 50 chars)
- **Requirements**: Minimum 1 STX collateral
- **Returns**: `(ok true)` on success

#### `verify-account(account)`
Verify an account (admin only).
- **Parameters**: `account` - Principal to verify
- **Access**: System admin only
- **Returns**: `(ok true)` on success

#### `register-service(service, service-admin, modifier)`
Register a new service integration (admin only).
- **Parameters**:
  - `service`: Service name (max 50 chars)
  - `service-admin`: Principal of service administrator
  - `modifier`: Score weight modifier
- **Access**: System admin only

### Read-Only Functions

#### `get-account-record(account)`
Retrieve complete account information including trust score and statistics.

#### `get-evaluation(evaluator, evaluated)`
Get details of a specific evaluation between two users.

#### `get-trust-percentage(account)`
Get trust score as a percentage (0-100).

#### `is-account-verified(account)`
Check if an account has verified status.

## 🔒 Security Features

- **Self-Evaluation Prevention**: Users cannot evaluate themselves
- **Duplicate Protection**: Only one evaluation allowed per evaluator-evaluated pair
- **Collateral Requirements**: Minimum stake required to submit evaluations
- **Access Controls**: Admin-only functions for verification and service management

## 🌐 Integration Guide

TrustChain is designed to integrate with various platforms and services. Platform administrators can:

1. Register their service through the `register-service` function
2. Query user trust scores via read-only functions
3. Implement trust-based features using the unified scoring system

### Example Integrations

- **E-commerce Platforms**: Seller/buyer reputation
- **Social Networks**: Content credibility scoring
- **Freelance Marketplaces**: Service provider ratings
- **DeFi Protocols**: Borrower creditworthiness

## 📈 Roadmap

- [ ] Multi-category evaluation system
- [ ] Reputation decay mechanism
- [ ] Advanced analytics dashboard
- [ ] Mobile SDK for easy integration
- [ ] Governance token for community management

## 🤝 Contributing

We welcome contributions to TrustChain! Please feel free to submit issues, feature requests, or pull requests.
