**Troptions Rails - Honest Status (as of now)**

This repo contains the vision, documentation, and **initial implementations** for the Troptions multi-chain rails system.

**IMPORTANT: This is not all vaporware, but it is not fully built yet.** The executive summary at troptions.pages.dev/#executive is the most accurate view.

## Current Live / Operational Components (Real and Working)

- **XRPL (Gateway + Exchange OS)**: Live DEX, AMM, issued currencies, proof packets. Real trading and settlement.
- **Solana (Mint console + Intake)**: Live minting console, Anchor program examples for intake and token launches (troptionsmint.com).
- **Besu (permissioned EVM)**: Live for banking/CBDC/compliance rails. QBFT network with private tx.
- **x402 micropayments**: Operational system for AI-to-AI and micro payments.
- **Operator OS**: Dashboard and command surface for the ecosystem.
- **Provenance / GMIIE / XXXIII**: Live pulse, news, intelligence, and proof systems (blockchainfraud.org, etc.).
- **Legacy Vault (5-Proof)**: Operational estate protection and vault.
- **Cloudflare Integration**: API token verified and active. Used for Pages hosting, Web3 gateways (IPFS, Ethereum), Email Routing for agent mail, DNS, Workers. Existing Troptions Pages projects (e.g., troptions-unity-legacy-vault) demonstrate Web3 + stablecoin support in production.

## Partial / In Progress

- **Chainlink**: Partial integration (VRF/CCIP/Automation/PoR wired in some flows and envs, but not full cross-rail stack yet).

## Planned / Stub / Pipeline (Vision - Not Yet Built)

The full "9 Rails Empire" with deep implementations:
- Avalanche (HyperVM Subnet + sports capital + full NILRights)
- Stacks (sBTC peg + Clarity contracts for revenue/settlement)
- Base (OP Stack + ERC-4337 + TUSD + liquidity)
- Sui (Move parallel execution + sports_vrf)
- Cosmos IBC Hub (full zone + Hermes relayer + oracle consumer)

These have documentation, flow trees, and planned contracts, but the actual smart contract code, full bridge implementations, and end-to-end Golden Path across all 9 are still in development or stub.

**No complete smart contract suite exists in this repo yet for the full vision.** Real contracts will be added here as they are built (see contracts/ directory for starters).

## What This Repo Provides Today

- Honest documentation of live vs planned.
- Professional marketing/executive site (deployed on GitHub Pages + Cloudflare Web3 ready).
- Developer guide, flow trees (Mermaid), how it works.
- Cloudflare API + Web3 + Email Routing integration docs and examples (using verified token).
- Stablecoin integration patterns (USDT, USDC, RLUSD, PAXO, DAI, PYUSD, TUSD + wrappers) documented and partially wired in live components.
- 1-click activation scripts, GitHub Actions, deployment guides.
- Investor overview with realistic costs and proof of what *is* built.

## Roadmap to Real System

1. Add real contract code for each rail (starting with live ones, then planned).
2. Implement cross-rail bridges and full Golden Path in code (not just docs).
3. Full Chainlink stack integration across live rails.
4. Deploy real contracts to testnets/mainnets and update proofs.
5. Expand Web3 hosting (IPFS pinning of site + proofs via Cloudflare gateway; on-chain metadata via Ethereum gateway).

See `docs/DEVELOPER_GUIDE.md` for integration details, stablecoins, and Web3.

Live site: https://fthtrading.github.io/troptions-rails

Repo is the single source for vision + current reality + path to full 9-rail real system.

**This is the honest baseline. We are fixing the over-claim by adding real contracts and integrations below.**