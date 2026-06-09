 # Real Contracts & System Integrations for Troptions Rails

This directory contains actual smart contract implementations for the 9 rails + cross-chain orchestration.

**Core Linked System (EVM focus, Avalanche + Base starter):**
- `BridgePayload.sol` (root): Unified cross-chain + stable + proof struct + hash lib. Used by VRF, NIL, CCIP, and planned for all rails.
- `avalanche/TroptionsSportsVRF.sol`: Chainlink VRF v2.5 for sports/NIL outcomes. Stablecoin payouts (USDC etc.). Emits BridgePayload. Exposes `eventRandomSeeds` + `getEventRandomSeed` for NIL + Automation consumers.
- `avalanche/TroptionsNILRights.sol`: Core NIL bundle minting + performance payouts. Consumes VRF seed for fair attributes. Records payouts, transfers stables, emits BridgePayload for cross-rail. Ready for Automation.
- `chainlink/TroptionsNILAutomation.sol`: Chainlink AutomationCompatible Keeper. Registers pending NIL events and calls `executePayout` when VRF seed is available.
- `integrations/TroptionsCCIPBridge.sol`: CCIP sender/receiver for BridgePayload messages (Avalanche <-> Base, and beyond).
- `base/TroptionsNILRightsBase.sol`: Base (OP Stack) version of the NIL rights logic. Same payload for seamless bridging. L2-optimized, AA/Paymaster friendly.

**Status (Honest & Color-Coded):**
- 🟢 LIVE / Operational ports: XRPL (issued stables/gateway), Solana (Anchor mints), Besu (permissioned), x402.
- 🔵 BUILT: Avalanche VRF + NILRights + BridgePayload + CCIP + Automation + Base NIL port. Stablecoin direct integration.
- 🟠 PARTIAL: Chainlink full stack (VRF + CCIP + Automation wired; more Functions/PoR coming).
- 🔴 PLANNED / Stubs: Full deep impls or ports for Stacks (Clarity sBTC), Sui (Move), Cosmos (CosmWasm + IBC), plus complete Golden Path E2E across all 9.

Other starters (in their rail dirs):
- solana/AnchorMintExample.rs (USDC/USDT mint + payload intent)
- sui/MoveExample.move
- stacks/ClarityExample.clar
- cosmos/CosmWasmExample.rs
- xrpl/XRPLGatewayExample.js (live RLUSD/USDT)
- besu/PermissionedExample.sol (PAXO/USDC private)
- stablecoins/ (wrappers and patterns)
- web3/ (IPFS pinning via Cloudflare for proofs + site)

All examples aim for compilable, security-starter quality with the shared BridgePayload for true multi-rail flows. Update addresses, keys, subs, and add tests before mainnet.

See DEVELOPER_GUIDE.md for build/deploy, and the professional site (docs/index.html) for architecture diagrams and investor view.

Proof: Public commits + the contracts themselves + integration in the Troptions professional site and Sovereign Orchestrator.