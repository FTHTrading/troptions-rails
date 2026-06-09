**Troptions Senior-Level Contract Template Suite (Batch 1 - Core EVM/Chainlink)**

Updated with user's latest BridgePayload (uint64 CCIP selectors).

Core files now in repo:
- BridgePayload.sol (foundation)
- avalanche/TroptionsSportsVRF.sol (fixed + senior: guards, NatSpec, stable, payload emits)
- avalanche/TroptionsNILRights.sol (mint/payout core)
- integrations/TroptionsCCIPBridge.sol
- chainlink/TroptionsAutomation.sol (Keeper)

See contracts/ for full polished code with LPS-1, stables, cross-rail design for 9 systems.

Continue building the rest of the suite + non-EVM adapters as needed.