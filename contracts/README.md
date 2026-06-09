 # Real Contracts & System Integrations for Troptions Rails

**Senior-Level Production-Grade Template Suite (Completed - Focused 6-7 Rails)**

See CONTRACT_TEMPLATES.md (root) for the full guide.

Core (pushed, senior hardened):
- BridgePayload.sol
- avalanche/TroptionsSportsVRF.sol
- avalanche/TroptionsNILRights.sol
- integrations/TroptionsCCIPBridge.sol
- chainlink/TroptionsAutomation.sol
- TroptionsAccessControl.sol
- TroptionsRailRegistry.sol (the brain for 9 rails, with selectors/active/bridge/primary)
- TroptionsStablecoinGateway.sol (USDT/USDC/RLUSD/PAXO+ bridging)
- TroptionsRailConnector.sol (ties Registry + Gateway + cores for routing payloads/stables)

All use BridgePayload (LPS-1, stables), guards, NatSpec. Practical focus per executive dashboard: XRPL/Solana/Base/Avalanche/Stacks/Chainlink + Bitcoin/Stellar.

Status: 🔵 BUILT (core suite + connector) | Adapters for others | Honest: Master focused rails first for revenue.

The activate.sh now references the full suite, registry, connector for 1-click with Sovereign Orchestrator.