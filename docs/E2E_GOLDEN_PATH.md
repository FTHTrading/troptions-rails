 # E2E Golden Path Demo Harness

**Status**: Stub for full executable demo. Real testnet txs to be added post-deploy (see contracts for ABIs/scripts).

## Example FIFA NIL Flow (14+ Steps)

1. User initiates on troptionsmint.com (Solana intake).
2. Solana Anchor creates BridgePayload (USDC amount, eventId, lps1Hash from GMIIE).
3. Bridge (Wormhole/CCIP) to Avalanche.
4. Avalanche VRF (TroptionsSportsVRF) requestRandomWords(eventId, amount).
5. Chainlink fulfills -> seed stored, optional ticket payout in USDC.
6. NILRights.mintNILBundle(payload) using seed for attribute, record pool.
7. AutomationKeeper registers and performs payout (USDC transfer, BridgePayload emit).
8. Cross to Base/XRPL via Router/CCIP for liquidity/settlement.
9. Stacks sBTC leg for Bitcoin anchor (Clarity claim).
10. Sui parallel exec or Cosmos IBC coordination.
11. XRPL AMM trade/issued currency settlement.
12. Besu private compliance leg (PAXO).
13. Proof aggregation (GMIIE/XXXIII).
14. Revenue split to athlete + FTH (via LegacyVault).

## Placeholder Testnet Hashes (update with real after deploy)
- Solana devnet: [solscan.io placeholder]
- Avalanche Fuji: [snowtrace.io placeholder]
- XRPL testnet: [testnet.xrpl.org placeholder]

## Simple Orchestrator Harness (Python pseudo, using web3.py/anchorpy)
```python
# pseudo for Sovereign Orchestrator
payload = BridgePayload(version=1, ... )  # from GMIIE
solana_mint(payload)  # Anchor call
avax_vrf = TroptionsSportsVRF.deployed()
request_id = avax_vrf.requestRandomWords(event_id, amount)
# wait fulfill
nil = TroptionsNILRights.deployed()
nil.mintNILBundle(payload)
# automation or direct payout
print("Golden Path step complete - tx: ", tx_hash)
```

See contracts/ for full ABIs and .github for CI. Full live demo post testnet deploys.