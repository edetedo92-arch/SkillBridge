# SkillBridge

**SkillBridge** is a peer-to-peer skill-sharing platform built on the Stacks blockchain using Clarity smart contracts. It enables secure, trust-minimized exchanges between learners and instructors through escrow-based payments and verifiable credentials.

## Overview

SkillBridge addresses the trust gap in peer-to-peer education by leveraging blockchain technology to ensure:

- **Payment Security**: Student funds are held in escrow until course completion is verified
- **Credential Verification**: Immutable records of instructor qualifications and student achievements
- **Fair Compensation**: Automatic fund release to instructors upon milestone completion, minus transparent platform fees

## Architecture

The platform consists of two core smart contracts:

### 1. Skill Escrow Contract (`skill-escrow`)

Manages the financial lifecycle of educational transactions:

- Accepts and locks student payments in escrow
- Tracks course progress and completion status
- Releases funds to instructors upon verified completion
- Deducts platform fees from instructor payouts
- Handles refunds for incomplete or disputed courses

### 2. Credential Validator Contract (`credential-validator`)

Provides trust infrastructure through verifiable credentials:

- Validates instructor qualifications before course offerings
- Records student milestone completions
- Issues immutable certification records upon course completion
- Maintains reputation scores for instructors
- Enables public verification of credentials without revealing sensitive data

## Use Cases

- **Micro-courses**: Short, focused learning modules with immediate verification
- **One-on-one tutoring**: Direct instructor-student relationships with escrow protection
- **Skill certification**: Blockchain-backed proof of competency
- **Portfolio building**: Verifiable teaching and learning history

## Technology Stack

- **Blockchain**: Stacks
- **Smart Contract Language**: Clarity
- **Development Tool**: Clarinet
- **Network**: Bitcoin-secured via Stacks

## Getting Started

### Prerequisites

- [Clarinet](https://github.com/hirosystems/clarinet) 3.4.0 or higher
- Node.js (for testing)

### Installation

```bash
# Clone the repository
git clone https://github.com/edetedo92-arch/SkillBridge.git

# Navigate to project directory
cd SkillBridge

# Install dependencies
npm install
```

### Testing

```bash
# Check contract syntax
clarinet check

# Run test suite
npm test
```

## Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues for bugs and feature requests.

## License

MIT License - see LICENSE file for details

## Security

Smart contracts handling financial transactions should be thoroughly audited before mainnet deployment. This is an educational project and has not undergone professional security review.

## Contact

For questions or collaboration inquiries, please open an issue on GitHub.
