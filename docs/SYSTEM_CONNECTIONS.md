# Troptions Rails - 33 Contracts System Connections

**Master Overview for Investors & Partners**

The Troptions sovereign empire is built as a fully integrated, validated system of **33 senior-grade contracts**.

## The Master Bootstrapper
`TroptionsSystemBootstrap.sol` is the one-command deployer.
- Deploys all core rails infrastructure in one transaction.
- Wires the `TroptionsSystemValidator` as the central nervous system.
- Emits `SystemDeployed` and `AllSystemsLinked` events for on-chain proof.
- After deploy, call `getSystemHealth()` or `validator.runFullSystemCheck()` to verify the entire stack is operational.

## How All 33 Contracts Connect

### Core Glue
- **BridgePayload.sol** + **BridgePayloadLib**: The universal data standard passed between every component and rail.

### Discovery & Routing
- **TroptionsRailRegistry.sol**: Registers all 9 rails with selectors, bridges, primary contracts. Used by Orchestrator and Router.
- **TroptionsCrossChainRouter.sol**: Routes BridgePayloads to registered rails via CCIP or native adapters.
- **TroptionsRailConnector.sol**: Helper for routing logic.

### Settlement & Atomicity
- **TroptionsEliteSettlementCore.sol**: Advanced settlements (ATOMIC, MULTISIG, CONDITIONAL, PROVENANCE_LOCKED) with time windows and proofs.
- **TroptionsAtomicSettlement.sol**: Legacy atomic settlement primitives.
- **TroptionsMultiSigEscrow.sol**: Multi-sig controlled escrows.
- **TroptionsSettlementHub.sol**: Central hub for settlements.

### Compliance & Proofs
- **TroptionsKYCCompliance.sol**, **TroptionsIdentityVerifier.sol**, **TroptionsProofVerifier.sol**: On-chain KYC, identity, and LPS-1/GMIIE proof verification.
- **TroptionsImmutableLedger.sol** (NEW): Permanent append-only audit log with timestamps, eventHash, lps1Hash, action, actor. Regulatory-grade for banks and the reset.

### Risk & Operations
- **TroptionsCircuitBreaker.sol**: Pausable kill switch.
- **TroptionsRateLimiter.sol**: Anti-spam and risk controls (payload-aware).
- **TroptionsEmergencyGovernor.sol** (NEW): Security council / owner can declare/resolve emergency mode. Halts critical operations safely.

### Reserves & Assets
- **TroptionsReserveVault.sol**: Proven reserves with proof verification.
- **TroptionsRWAToken.sol**: Institutional RWA token with frozen lists and BridgePayload events.
- **TroptionsTokenFactory.sol**: Dynamic token deployment.
- **TroptionsFeeManager.sol**: Dynamic fee logic.

### Governance & Agents
- **TroptionsGovernanceTimelock.sol**: 48h timelock for admin actions with payload audit.
- **TroptionsAgentRegistry.sol**: Register/revoke sovereign AI agents with payload.
- **TroptionsAccessControl.sol**: Operator permissions.

### Orchestration & Validation (The Brain)
- **TroptionsOrchestrator.sol**: Master controller for Golden Path execution. Uses registry + connector.
- **TroptionsSystemValidator.sol** (NEW): The final boss. Checks all major components (Registry, Settlement, Proofs, KYC, CircuitBreaker, Reserves, Router). Returns full SystemHealth struct. Used post-bootstrap to prove everything is linked and healthy.
- **TroptionsSystemBootstrap.sol** (NEW): The master deployer. One call deploys and interconnects everything. Returns the live Validator address.

### Chain-Specific (Avalanche focus for VRF/NIL)
- **contracts/avalanche/TroptionsSportsVRF.sol**: Real Chainlink VRF v2.5 + BridgePayload emission + stable payouts.
- **contracts/avalanche/TroptionsNILRights.sol**: NIL bundle minting/payouts using VRF seeds and lps1Hash.

### Other Rails & Adapters
- Solana Anchor programs (in programs/)
- Sui Move, Stacks Clarity, XRPL JS gateway, Besu private rail, Cosmos CosmWasm, Base, etc. (stubs + starters in subdirs).

### Web3 & Integrations
- StablecoinGateway for USDT/USDC/RLUSD/PAXO etc.
- IPFSWeb3Example.js for Cloudflare Web3 pinning.

## Bootstrap Flow (One Command)
1. Deploy TroptionsSystemBootstrap.
2. Call deployFullSystem() (owner only).
3. It deploys all cores + validator.
4. Call validator.runFullSystemCheck() to confirm.
5. Use returned validator address in monitoring, orchestrator, and investor materials.
6. Record key events to ImmutableLedger for audit trail.
7. Activate EmergencyGovernor if needed for crisis.

## For the Reset / Institutional Use
This architecture provides:
- Programmable stables across 9 rails
- Verifiable atomic settlement
- On-chain compliance + permanent immutable audit
- Emergency kill switches with council control
- Live system health validation before any high-value flow
- One-command reproducible deployment for testnet → mainnet

All 33 contracts are production-grade starters with NatSpec, guards, and BridgePayload integration where applicable.

See the live site and GitHub for addresses after first bootstrap run.
