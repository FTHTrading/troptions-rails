# Phase 1: Core Revenue Rail (Avalanche + Stables + Validator live)
# Run after Phase 0 gates.
# Usage: .\scripts\phase-1-core-revenue.ps1

Write-Host "Phase 1 Execution - Avalanche VRF/NIL + Stables + E2E 1-7" -ForegroundColor Blue

# Assume envs loaded or set
if (Test-Path ".env.phase") { . .\.env.phase }

Write-Host "1. Launch army for Avalanche focus..."
# python AI_Agents_Hub\troptions_sovereign_orchestrator.py  (in separate shell: start multi chain army)

Write-Host "2. Deploy core on Fuji (troptions-rails)..."
Push-Location "troptions-rails"
# bash scripts/deploy-all.sh   # or equivalent PowerShell: forge script ...
Write-Host "Run manually: forge script scripts/SystemBootstrap.s.sol --rpc-url $FUJI_RPC --broadcast --verify -vv -- $SECURITY_COUNCIL $INITIAL_CCIP_ROUTER"
Pop-Location

Write-Host "3. Run Golden Path Phase 1 subset and record txs..."
python "troptions-rails/scripts/e2e_golden_path.py" --step 1-7 --record-tx "PASTE_YOUR_TX_HERE"

Write-Host "4. Update proofs for Phase 1..."
# npm from avalanche-sports or equivalent

Write-Host "5. Verify: cast call <VALIDATOR> 'runFullSystemCheck()' , check E2E doc, site badges, orchestrator phase_status 1"

Write-Host "Gate for Phase 1: Real Fuji hashes in E2E, stables payouts demoed, validator green, site updated."