# How It All Works

This document explains the complete Troptions sovereign multi-chain system at a technical level.

## Core Philosophy

Troptions is not just "another multi-chain project". It is a **sovereign empire** with:
- 9 production-grade rails
- A single data contract (BridgePayload)
- A canonical end-to-end flow (Golden Path)
- Full offline/GPU-accelerated orchestration
- Cryptographic proof at every layer

## The 9 Rails in Detail

(See the color-coded table in README.md for status.)

Each rail has dedicated agents, contracts/modules, and activation flags in the Rails Registry.

## BridgePayload - The Universal Glue

```json
{
  "intent": "claim_nil_payout",
  "source_chain": "solana",
  "target_chains": ["avalanche", "stacks"],
  "payload": { ... },
  "attestations": [
    { "type": "chainlink_vrf", "proof": "..." },
    { "type": "wormhole_vaa", "proof": "..." }
  ],
  "metadata": {
    "nil_rights": "...",
    "revenue_split": { ... }
  }
}
```

This structure is understood by every rail.

## Golden Path (The 14+ Step Flow)

Detailed in the main README sequence diagram.

The flow is designed so that any rail can be activated or bypassed via the Registry flags without breaking the overall system.

## Orchestration Layers

1. **1-Click Layer** (activate.sh + Codespaces + devcontainer)
2. **Agent Army Layer** (per-rail agents + central scheduler)
3. **Sovereign Orchestrator** (LLM-driven, runs donkai sims, generates IaC)
4. **Composer Fast** (parallel autonomous builders for all rails)
5. **Proof & Attestation Layer** (IPFS + Cloudflare + GMIIE)

## Cross-Chain Wiring Details

- **Solana ↔ Avalanche/Base**: Wormhole + Teleporter
- **Cosmos as Hub**: Hermes IBC relayer + troptions-cosmos-hub config
- **Chainlink**: Universal VRF, CCIP messaging, keepers, PoR
- **Bitcoin Anchor**: Stacks sBTC + XRPL for trading

All paths are exercised in the E2E harness and optimized by donkai evolutionary agents.

## Sovereign Command Center

The brain lives in the AI_Agents_Hub (troptions_sovereign_orchestrator.py).

It understands natural language commands and drives the entire empire offline using your local GPU.

For full details see the Sovereign Command Center documentation.