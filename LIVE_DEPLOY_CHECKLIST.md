# TROPTIONS Live Deploy & Real Hash Capture Checklist (Post Phase 5 100% SIM)

**Goal**: Move from SIM 100% to verifiable live testnet hashes on Fuji (Avalanche), Solana devnet, XRPL test, etc. Update E2E, site, reports with real txs. Then v0.1.0.

## Prerequisites (one-time)
- .env with FUJI_RPC=https://api.avax-test.network/ext/bc/C/rpc , PRIVATE_KEY (funded test AVAX), SOLANA_RPC etc.
- Foundry installed (forge), Node for ts scripts, Avalanche CLI or Hardhat if needed.
- Cloudflare wrangler auth done for os.troptionsmint.com (if re-deploying worker).
- Clone or Codespace on FTHTrading/troptions-rails + troptions-avalanche-sports.

## Step-by-Step (use with E2E harness)
1. **Prepare & Simulate First**
   ```bash
   python Scripts/e2e_golden_path.py --phase 5 --mode simulate --event "FIRST_LIVE_FUJI_001" --amount 50000
   ```
   Note the simulated TX patterns (0xFujiCCIP..., solana_sig_...).

2. **Deploy Core Contracts (Avalanche Fuji focus for Phase 1/5 core)**
   - cd troptions-avalanche-sports/contracts
   - forge build
   - forge script script/Deploy.s.sol --rpc-url $FUJI_RPC --broadcast --verify (or use existing avalanche-sports/scripts/...)
   - Capture: VRF address, NILRights address, CCIPBridge, etc.
   - Example expected: Snowtrace testnet tx for deploy ~ "0xDEPLOY..."

3. **Run Golden Path Steps Live (or one-by-one)**
   - Use existing: node scripts/fifa-nil-golden-path.ts or powershell equivalents.
   - Or manual cast send for VRF request, then fulfill (Chainlink keepers or manual).
   - For each key step, capture the real tx hash.

4. **Record Hashes into Harness (new E2E feature)**
   ```bash
   python Scripts/e2e_golden_path.py --record-tx 0xREAL_FUJI_VRF_TX_HASH_HERE --record-step 4
   python Scripts/e2e_golden_path.py --record-tx 0xREAL_NIL_MINT_HASH --record-step 6
   # Repeat for payout (step 7), Solana intake (step 1), XRPL if crossed, etc.
   ```
   This prints ready snippets. Manually update:
   - Scripts/e2e_golden_path.py (hardcode or extend manifest)
   - PHASE5_100_PERCENT_REPORT.md (add "Live Hashes" section)
   - troptions-pro-site-polished.html (add to "Live Hashes" table)
   - Then re-push site + docs.

   To generate the table rows for the site:
   ```bash
   python Scripts/e2e_golden_path.py --print-snippet
   ```
   Paste the output into the site table.

5. **Update & Verify**
   - Re-run full: python Scripts/e2e_golden_path.py --phase 5 --mode simulate (now mixes real if you patched)
   - Run orchestrator: python AI_Agents_Hub/troptions_sovereign_orchestrator.py → "get all systems 100%"
   - Update site locally (copy polished to your clone docs/index.html), commit & push.
   - Optional: Pin proofs, deploy updated Cloudflare worker with new status.
   - GH Pages will show new "Live Hashes" with real Snowtrace/Solscan links.

6. **Cross-Rail & Bryan Email Test**
   - Trigger a Web3 agent email to agent@troptionsmint.com (after CF Email Routing set).
   - Confirm it hits Worker → orchestrator → x402 settle.
   - Extend to Solana or XRPL leg for full 14-step.

## Example Real Hash Targets (update these)
- Fuji VRF request: https://testnet.snowtrace.io/tx/0x...
- NIL mint + payout: https://testnet.snowtrace.io/tx/0x...
- Solana program interaction: https://solscan.io/tx/...
- XRPL tx: https://testnet.xrpl.org/transactions/...

## Success Gates for "First Live Hash"
- At least 3 real txs from different steps/chains recorded.
- E2E output updated with real links (no more "Simulated TX").
- Site investor/proof section shows "LIVE on Fuji: [link]" instead of pending.
- Validator health check passes on deployed addresses (cast call ... runFullSystemCheck).
- Bryan vertical update email processed end-to-end.

## Rollback / Safety
- Use test keys only.
- Pause contracts if needed (Pausable in VRF/NIL).
- All changes go through the Timelock/Governance once Phase 4+.

Run this after every major testnet deploy. Feed hashes back here ("paste the txs") and I'll update the polished site, reports, and E2E in one shot + re-push.

**Current State**: SIM 100% complete with beautiful executable harness. First real Fuji hash = the bridge to production 100%.

© 2026 FTH / UnyKorn — Troptions. Ready for hashes.