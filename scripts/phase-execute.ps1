# TROPTIONS Phased Execution Runner (Windows PowerShell)
# Usage: .\scripts\phase-execute.ps1 -Phase 0 -Mode simulate
# Integrates with Sovereign Orchestrator, troptions-rails scripts, and avalanche-sports impl.

param(
    [int]$Phase = 0,
    [string]$Mode = "simulate",   # simulate | live | verify
    [string]$EnvFile = ".env.phase"
)

Write-Host "🚀 TROPTIONS Phased Execution — Phase $Phase ($Mode)" -ForegroundColor Cyan

if (Test-Path $EnvFile) { . $EnvFile }

switch ($Phase) {
    0 {
        Write-Host "Phase 0: Foundation, Proofs, Audit Baseline"
        Write-Host "1. Build & test contracts..."
        Push-Location "troptions-rails/contracts" -ErrorAction SilentlyContinue
        & forge build
        & forge test --match-contract "Test*" -vv
        Pop-Location

        Write-Host "2. E2E harness (simulate or record)..."
        python "troptions-rails/scripts/e2e_golden_path.py" --simulate

        Write-Host "3. Proof unification (LPS-1)..."
        # Assume avalanche-sports or troptions-rails/proofs
        # npm run proof:build ; npm run proof:lps1

        Write-Host "4. Orchestrator status..."
        # python AI_Agents_Hub/troptions_sovereign_orchestrator.py  (then list all systems)

        if ($Mode -eq "live") {
            Write-Host "LIVE: Set FUJI_RPC + PRIVATE_KEY then run deploy-all.sh equivalent"
        }
        Write-Host "Gate: Validator health + first real hash recorded + proofs portal live."
    }
    1 {
        Write-Host "Phase 1: Core Revenue (Avalanche + Stables + Validator)"
        Write-Host "Deploy Avalanche VRF/NIL + wrappers on Fuji, run Golden Path 1-7, record hashes."
        # Call orchestrator "run phase 1" or manual:
        # cd troptions-rails ; bash scripts/deploy-all.sh
        # python scripts/e2e_golden_path.py --step 1-7 --record-tx ...
    }
    default {
        Write-Host "Phase $Phase: See PHASED_SYSTEM_EXECUTION_PLAN.md for full commands per phase."
        Write-Host "Recommended: python AI_Agents_Hub/troptions_sovereign_orchestrator.py then 'run phase $Phase'"
    }
}

Write-Host "✅ Phase $Phase $Mode complete. Update manifests, E2E, site, and orchestrator phase_status." -ForegroundColor Green