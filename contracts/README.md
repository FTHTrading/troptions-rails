 # Real Contracts & System Integrations for Troptions Rails

**Senior-Level Production-Grade Template Suite** (see CONTRACT_TEMPLATES.md at root for the complete guide).

This directory contains actual smart contract implementations for the 9 rails + cross-chain orchestration, built as clean, audit-ready templates using the latest official Chainlink patterns + OpenZeppelin.

## Core Linked Senior Templates
- BridgePayload.sol (the unifying standard with LPS-1/XXXIII provenance fields)
- avalanche/TroptionsSportsVRF.sol (VRF v2.5 + stable payouts + public seed exposure for NIL/Automation + BridgePayload emits + Pausable/Reentrancy)
- avalanche/TroptionsNILRights.sol (core mint bundle + performance payout, consumes VRF seed, strong provenance require, stable execution, emits for cross-rail, guards)
- chainlink/TroptionsAutomationKeeper.sol (AutomationCompatible for triggering NIL payouts post-VRF)
- integrations/TroptionsCCIPBridge.sol (CCIP for BridgePayload cross-chain, guards)
- base/TroptionsNILRightsBase.sol (Base OP Stack parity version)

All use the shared BridgePayload, direct stables, full Natspec, custom errors, and are ready for the Golden Path across rails.

## All 9 Rails Compatibility
Starters/adapters in solana/, sui/, stacks/, besu/, cosmos/, xrpl/, etc. now include BridgePayload mirrors or parsing so a NIL payout or VRF outcome on Avalanche can trigger actions on any rail (mint on Solana, parallel on Sui, sBTC settle on Stacks, etc.).

**Current Status (Honest):**
- 🟢 LIVE / ports from operational: XRPL, Solana, Besu, x402, Cloudflare Web3.
- 🔵 BUILT (senior templates): Avalanche VRF + NILRights + Automation + CCIP + BridgePayload + Base port + rail adapters for Solana/Sui/Stacks.
- 🟠 PARTIAL: Full Chainlink stack and deep non-EVM.
- 🔴 PLANNED: Complete E2E harness in code, on-chain deploys of the suite, more rail depth (Stacks peg, Cosmos IBC packet, XRPL hook).

See the professional site for diagrams and the CONTRACT_TEMPLATES.md for usage, security notes, and how the suite enables the full 9-rail empire. Proof of real build is the public code + commits.