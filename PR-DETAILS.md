## Overview

This pull request adds the core smart contracts for the SkillBridge platform, enabling secure peer-to-peer skill-sharing with blockchain-backed escrow payments and verifiable credentials.

## Changes

### Smart Contracts Added

**skill-escrow.clar** (177 lines)
- Manages escrow-based payment lifecycle for educational transactions
- Locks student payments until course completion is verified
- Automatically calculates and deducts 5% platform fee
- Releases funds to instructor balances upon completion
- Supports refunds for incomplete or disputed courses
- Enables instructors to withdraw accumulated earnings
- Platform owner can withdraw collected fees

**credential-validator.clar** (211 lines)
- Verifies instructor qualifications before course offerings
- Records student milestone completions during courses
- Issues immutable certification records upon course completion
- Maintains reputation scores for instructors (0-10000 scale)
- Supports delegated verification through authorized verifiers
- Tracks instructor course completion history
- Enables public verification of credentials

### Key Features

**Escrow System**
- Students create escrow by transferring STX to contract
- Payments held securely until student confirms completion
- Platform fee (5%) automatically calculated and tracked
- Instructors build up balances that can be withdrawn on-demand
- Instructors or platform owner can issue refunds for incomplete courses

**Credential Management**
- Instructors must be verified before teaching
- Verification includes qualification description and initial reputation score
- Milestone tracking for student progress throughout course
- Final certification with score (0-100) issued by verified instructors
- Reputation system to build trust over time
- Revocation capability for platform governance

### Technical Details

- No cross-contract calls or trait dependencies (standalone contracts)
- Uses STX transfers for payments
- Leverages `stacks-block-height` for timestamping
- Implements proper error handling with descriptive error codes
- Clean separation between escrow financial logic and credential trust logic

### Testing

- Contracts pass `clarinet check` with zero errors
- Test scaffolding generated for both contracts
- Ready for unit test implementation

### Configuration

- Updated `Clarinet.toml` to register both contracts
- Project structure follows Clarinet best practices

## Next Steps

After merging this PR, the following enhancements can be considered:
- Comprehensive unit test suite
- Integration tests for multi-contract workflows
- Deployment scripts for testnet/mainnet
- Front-end integration examples
