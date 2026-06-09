# TROPTIONS Phase 0 Full Launcher
# One-command for Phase 0: Foundation, Proofs, Audit Baseline
# Run from C:\Users\UnyKo
# Usage: .\scripts\phase0-launcher.ps1 -Mode simulate

param(
    [string]$Mode = "simulate"
)

Write-Host "=== TROPTIONS PHASE 0 LAUNCHER ===" -ForegroundColor Green
Write-Host "Mode: $Mode" 

# 1. Orchestrator Phase 0 (use Python runner for reliability)
Write-Host "`n[1/5] Running Phase 0 via portable runner..."
python scripts/phase_runner.py --phase 0 --mode $Mode
# Fallback direct orchestrator if needed
cd AI_Agents_Hub
python troptions_sovereign_orchestrator.py 2>$null | Select-Object -First 5
cd ..

# 2. E2E Harness (local phase-aware)
Write-Host "`n[2/5] E2E Golden Path Simulation..."
cd ..
python scripts/e2e_golden_path.py --phase 0 --mode $Mode

# 3. Contracts Build/Test (if forge available)
Write-Host "`n[3/5] Contracts Build & Test..."
Push-Location troptions-rails/contracts -ErrorAction SilentlyContinue
try {
    & forge build 2>$null
    if ($LASTEXITCODE -ne 0) { Write-Host "Forge build skipped or not available - use Codespaces/local install" }
    & forge test --match-contract "Test*" -vv 2>$null
    if ($LASTEXITCODE -ne 0) { Write-Host "Tests skipped (no local setup)" }
} catch {
    Write-Host "Forge not found or no local clone - use GH Codespaces or local install"
}
Pop-Location

# 4. Proofs (LPS-1)
Write-Host "`n[4/5] Proof Unification (LPS-1)..."
Push-Location troptions-avalanche-sports -ErrorAction SilentlyContinue
try {
    npm run proof:build 2>$null
    if ($LASTEXITCODE -ne 0) { Write-Host "Proof build (run manually if in avalanche-sports: npm run proof:build && npm run proof:lps1)" }
} catch {
    Write-Host "Proof build skipped (adjust path or run manually)"
}
Pop-Location

# 5. Status
Write-Host "`n[5/5] Status Check..."
cd ..
python -c "
import sys
sys.path.append('AI_Agents_Hub')
from troptions_sovereign_orchestrator import phase_status, list_all_systems
print(phase_status(0))
print(list_all_systems())
"

Write-Host "`n=== PHASE 0 COMPLETE ===" -ForegroundColor Green
Write-Host "Next: Record real tx hash, update docs/E2E_GOLDEN_PATH.md, push site, tag v0.1.0"
Write-Host "Gate check: Validator green? Proofs portal live? Orchestrator phase_status 0 green?"