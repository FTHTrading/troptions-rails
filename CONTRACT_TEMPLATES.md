**Troptions Senior-Level Contract Template Suite (Expanded - ~25 Contracts)**

Production-grade, audit-ready templates for the Troptions 9-rail system (practical focus: XRPL, Solana, Base, Avalanche, Stacks/sBTC, Chainlink + Bitcoin/Stellar as core; others as adapters/future).

**Core EVM/Settlement + Institutional (previous + new):**
- [full previous list]
- TroptionsRWAToken.sol (Institutional RWA Token with freezing, compliance)
- TroptionsRateLimiter.sol (Per-user daily limits, payload-aware)
- TroptionsTokenFactory.sol (Dynamic RWA token deployment per assetId)
- TroptionsCrossChainRouter.sol (Unified payload routing via CCIP + rail bridges)

**Usage & Integration:**
- All use BridgePayload for unified flows (Golden Path: VRF -> NIL -> Orchestrator/Hub -> Router/Factory -> CCIP/Gateway to target rail).
- LPS-1/XXXIII hooks, KYC/Compliance gating, CircuitBreaker, RateLimiter for institutional safety.
- See contracts/ for source. Professional site has Senior Templates box with color-coded status (🔵 BUILT for expanded suite).

© 2026 FTH Trading / UnyKorn