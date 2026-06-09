**Troptions Senior-Level Contract Template Suite (Expanded - 33 Contracts & Tools)**

**Post Full System Audit (v0.1.0) Reconciliation**: Standardized on **33 senior-grade contracts, tools, and per-rail adapters/starters**. See main CONTRACT_TEMPLATES.md (root) and docs/SYSTEM_AUDIT_REPORT.md for details and canonical list.

Production-grade, audit-ready Solidity templates built specifically for the Troptions 9-rail sovereign multi-chain system (NIL rights, sports outcomes, stables, LPS-1 / XXXIII / GMIIE provenance, unified BridgePayload).

**Principles**
- Latest official Chainlink patterns (VRF v2.5 `VRFConsumerBaseV2Plus` + `VRFV2PlusClient`, CCIP `IRouterClient` + `Client`, Automation `AutomationCompatibleInterface`).
- OpenZeppelin security (ReentrancyGuard, Pausable, Ownable).
- Custom errors for gas efficiency.
- Full NatSpec + events for every important action.
- Direct stablecoin (USDT/USDC/RLUSD/PAXO +) integration in payloads and payouts.
- LPS-1 / XXXIII provenance hooks (`lps1Hash`, `gmiiSignature`) on mint/payout.
- Cross-rail ready: every key action emits a `BridgePayload` that CCIP / Wormhole / IBC can carry to Base, Solana, Sui, Stacks, Cosmos, XRPL, Besu.
- No copy-paste generic templates — everything is Troptions-specific (NIL bundles, sports VRF, Golden Path flows).

## Core Templates (EVM / Chainlink)

| File | Purpose | Key Features | Status |
|------|---------|--------------|--------|
| `BridgePayload.sol` | The single source of truth struct + hash lib | version, chains, assetId (stable/NIL), eventId, amount, action, lps1Hash + gmiiSignature, `BridgePayloadLib.hash` | 🟢 Core Standard |
| `avalanche/TroptionsSportsVRF.sol` | Sports / NIL randomness source | VRF v2.5, stable payouts, `eventRandomSeeds` + `getEventRandomSeed` for NIL/Automation, emits BridgePayload, Pausable + ReentrancyGuard | 🔵 Built & Enhanced |
| `avalanche/TroptionsNILRights.sol` | Core NIL mint + performance payout | Consumes VRF seed for fair attributes, `mintNILBundle(payload)`, `executePayout` (Automation trigger), stable transfer, strong LPS-1 require, BridgePayload emits on every action, guards | 🔵 Core (user-provided structure, senior hardened) |
| `chainlink/TroptionsAutomationKeeper.sol` | Chainlink Automation for payouts | `AutomationCompatibleInterface`, `registerForAutomation`, `checkUpkeep`/`performUpkeep`, configurable gas, Pausable, works directly with NILRights | 🔵 Built |
| `integrations/TroptionsCCIPBridge.sol` | Cross-chain payload mover | CCIP send/receive of full BridgePayload, whitelists, native fees, Pausable + Reentrancy, ready for NIL/VRF routing | 🔵 Built |
| `base/TroptionsNILRightsBase.sol` | Base (OP Stack) parity | Same payload interface, L2 friendly, AA/Paymaster notes, cross-emit back to Avalanche | 🔵 Port |

## Rail Adapters (BridgePayload Compatible for Full 9-Rail Composition)

- `solana/AnchorMintExample.rs` — `BridgePayload` struct + `mint_from_payload` (receive NIL payout or VRF intent from Avalanche, mint native stables).
- `sui/MoveExample.move` — `BridgePayload` + `execute_parallel` consuming seed + payload (high-volume parallel exec).
- `stacks/ClarityExample.clar` — Payload parsing + `settle-from-payload` for sBTC/USDC hybrid (NIL revenue settlement on Bitcoin L2).
- Other starters (Besu, Cosmos, XRPL, Chainlink consumer) in their dirs — all can produce/consume the same payload struct for unified flows.

## Usage (High-Level Golden Path Example)

1. Call `TroptionsSportsVRF.requestRandomWords(eventId, amount)` (owner or authorized).
2. Chainlink VRF fulfills → stores seed, may auto-payout ticket, emits BridgePayload.
3. `TroptionsNILRights.mintNILBundle(payload)` (after seed available, with valid `lps1Hash` from LPS-1/XXXIII system).
4. `TroptionsAutomationKeeper.registerForAutomation(eventId)`.
5. Chainlink Automation calls `performUpkeep` → `NILRights.executePayout(...)` (transfers stable, emits payout payload).
6. `TroptionsCCIPBridge.sendMessage(selector, payload)` moves the intent to Base NIL port or Solana mint or Stacks settle.

All components are designed to be dropped into the Sovereign Orchestrator / Composer Fast / E2E harness.

## Security & Audit Notes (Senior Practices)

- ReentrancyGuard on state-changing payout/mint paths.
- Pausable for emergency stops (owner only).
- Custom errors (AlreadyMinted, VRFNotFulfilled, MissingProvenance, etc.).
- Explicit require / revert with messages where custom errors not used.
- Stable transfers are "best effort" in starters — production should use a dedicated treasury/pull pattern or approved spenders.
- LPS-1 provenance is required on mint (extend with on-chain registry or oracle verification of the hash/signature for full XXXIII integration).
- Update all addresses (VRF coordinator, CCIP router, subId, keyHash, stable token) per network (Fuji/mainnet, Base, etc.).
- Add your own AccessControl roles, timelocks, or multi-sig for production.
- Test thoroughly with Chainlink local simulators, Foundry/Hardhat, and the Troptions E2E harness.
- These are templates — have them audited before mainnet value.

## Next / Integration Points

- Full Golden Path executable harness (orchestrator + these contracts).
- On-chain deployment scripts + .env placeholders (never commit keys).
- Expanded rail ports (full Stacks sBTC peg contract, Cosmos IBC packet handler, XRPL hook that understands payload.action).
- Web3 proof pinning of deployed addresses + events via Cloudflare IPFS (see contracts/web3/).
- Sovereign Orchestrator Python agent that calls these via RPC or 1-click.

See the main professional site (https://fthtrading.github.io/troptions-rails or /docs/index.html) for architecture diagrams, flow trees, investor costs, and 9-rail overview. See docs/SYSTEM_AUDIT_REPORT.md for post-audit details.

All code lives under `contracts/`. Build with Foundry (`forge build`) or Hardhat. Use latest OpenZeppelin and Chainlink contracts.

This suite turns the Troptions vision into real, composable, senior-grade infrastructure. 

© 2026 FTH Trading / UnyKorn — built for the full 9-rail empire.