# Troptions Rails Developer Guide

This guide provides technical details for developers integrating with or building on Troptions Rails.

## Overview of the System

Troptions Rails provides a unified multi-chain infrastructure with 9 production rails, BridgePayload standard, Golden Path flows, and AI-driven orchestration.

Key components for developers:
- **Rails Registry**: Central configuration for activation and endpoints.
- **BridgePayload**: Standardized JSON structure for cross-chain intents, attestations, and metadata.
- **E2E Harness**: For testing integrations in mock or live mode.
- **Sovereign Orchestrator & Composer**: For deploying and managing integrations.

## Stablecoin Integrations (Direct into the System)

Troptions Rails natively supports major stablecoins as first-class assets across all rails for liquidity, payments, settlements, and revenue flows. These are integrated directly via the Parallel Stablecoin Engine, BridgePayload fields, and per-rail modules.

### Supported Stablecoins

- **USDT (Tether)**: Widely supported on Solana, Avalanche, XRPL, Base, and bridged to others. Used for high-volume transfers and collateral.
- **USDC (Circle)**: Primary on Base (OP Stack), Solana, Sui. Integrated with Paymaster for gasless UX and ERC-4337.
- **RLUSD (Ripple USD)**: Native on XRPL, bridged via CCIP/Wormhole to other rails. Ideal for institutional and cross-border settlements.
- **PAXO / PAX (Paxos)**: Supported on Ethereum L2s (Base), Besu (permissioned), and Solana. Used for compliant, regulated stable value.
- **Other Important Stablecoins**:
  - DAI (MakerDAO): Decentralized, integrated on Base, Avalanche, and via Chainlink PoR.
  - PYUSD (PayPal USD): On Solana and Base for consumer payments.
  - TUSD (TrueUSD): Existing support expanded to all rails.
  - Additional: FRAX, sUSD, and custom Troptions-wrapped variants via the engine.

### How Stablecoins Are Integrated Directly

1. **BridgePayload Support**:
   Every payload can specify stablecoin type, amount, issuer, and peg status.
   ```json
   {
     "stablecoin": {
       "symbol": "USDC",
       "amount": "1000000",
       "issuer": "Circle",
       "chain": "base",
       "peg_proof": "chainlink_por"
     }
   }
   ```

2. **Parallel Stablecoin Engine**:
   - Mint/burn/wrap across rails.
   - Atomic swaps (e.g., USDT on Solana to USDC on Base).
   - Revenue splits in chosen stablecoin.
   - Gas abstraction using stablecoins on supported L2s (Base, etc.).

3. **Per-Rail Integrations**:
   - **Solana**: Anchor programs for USDC/USDT transfers and PDA accounts.
   - **Avalanche**: HyperSDK modules for high-speed USDT settlements in sports flows.
   - **Stacks**: Clarity contracts for sBTC + USDC hybrid settlements.
   - **Base**: ERC-20 support + Paymaster for USDC gas payments.
   - **Sui**: Move objects for parallel USDC/USDT processing.
   - **Cosmos IBC**: ICS-20 for stablecoin transfers via Hermes hub.
   - **XRPL**: Native issued currencies for RLUSD and USDT on DEX/AMM.
   - **Besu**: Permissioned ERC-20 for PAXO/regulated stables with compliance hooks.
   - **Chainlink**: CCIP for secure stablecoin messaging; PoR for on-chain reserves verification.

4. **Golden Path Examples with Stablecoins**:
   In the FIFA NIL flow, payments and payouts can be denominated in USDC (on Base for liquidity) or RLUSD (on XRPL for trading), with automatic conversion via the engine.

5. **Developer APIs & SDKs**:
   - Use the Rails Registry to discover stablecoin endpoints per chain.
   - BridgePayload builder libraries (Python/TS examples in the orchestrator).
   - Test via E2E Harness with mock stables.

## Building Integrations

### Step 1: Define in Rails Registry
Add your integration to the central registry (JSON in repo or on-chain).

### Step 2: Implement BridgePayload Handlers
Each rail must handle stablecoin fields in payloads.

### Step 3: Add to Golden Path
Extend the 14+ step flow with stablecoin legs.

### Step 4: Test & Prove
Run in harness; generate proofs for IPFS/Cloudflare.

### Step 5: Orchestrate
Use Composer Fast or the Sovereign Orchestrator for deployment.

## Advanced Topics
- Cross-stablecoin arbitrage via Chainlink Automation.
- Compliance: Use Besu for regulated stables (PAXO, RLUSD).
- Oracle integration: Chainlink for price feeds and PoR on all stables.

## Resources
- Full inventory: See main README and professional site.
- Flow diagrams: docs/FLOW_TREES.md
- Source: troptions-avalanche-sports for contract examples.

For questions or contributions, open an issue or PR.