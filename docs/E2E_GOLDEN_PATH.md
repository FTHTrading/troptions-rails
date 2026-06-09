 # E2E Golden Path Demo Harness

**Status**: Executable harness added (scripts/e2e_golden_path.py + Foundry deploy script). Real testnet tx hashes to be captured on first Fuji/Sepolia + Solana devnet runs post this (see Deploy section).

## 14+ Step FIFA NIL / Sports Capital Flow (Golden Path)

1. User initiates on troptionsmint.com (Solana intake).
2. Solana Anchor creates BridgePayload (USDC amount, eventId, lps1Hash from GMIIE).
3. Bridge (Wormhole/CCIP) to Avalanche.
4. Avalanche VRF (TroptionsSportsVRF) requestRandomness(eventId, amount).
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

## Executable Harness

```bash
# Local simulation (no keys needed)
python3 scripts/e2e_golden_path.py --simulate

# Single step after you have deployed VRF on Fuji
python3 scripts/e2e_golden_path.py --step 4 --event FIFA_NIL_2026_Q3

# Deploy key contracts first (Fuji example)
# export FUJI_RPC=https://api.avax-test.network/ext/bc/C/rpc
# export PRIVATE_KEY=0x...
forge script scripts/DeployCore.s.sol --rpc-url $FUJI_RPC --broadcast --verify -vv

# Then capture real hashes from Snowtrace + paste below + into README
```

## Placeholder / Example Testnet Hashes (update with real after first runs)
- Solana devnet (Anchor create payload): solscan.io/tx/PLACEHOLDER_YOUR_TX
- Avalanche Fuji (VRF request + fulfill + NIL payout): testnet.snowtrace.io/tx/PLACEHOLDER_YOUR_TX
- XRPL testnet (settlement/AMM): testnet.xrpl.org/transactions/PLACEHOLDER

See scripts/e2e_golden_path.py for the full runnable Python (generates payload hash locally, prints exact cast/forge commands for real txs). Run in Codespaces or Sovereign Orchestrator for full multi-rail sims.

Once real hashes collected, this becomes the live reference for FTHTrading banks, Solana minting, GMIIE orchestration, and institutional flows.