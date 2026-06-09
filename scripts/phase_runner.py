#!/usr/bin/env python3
"""
TROPTIONS Phase Runner
Portable Python launcher for phased execution.
Run from root: python scripts/phase_runner.py --phase 0 --mode simulate

Integrates with AI_Agents_Hub orchestrator, troptions projects.
"""

import sys
import os
import subprocess
import argparse
from pathlib import Path

ROOT = Path(__file__).parent.parent.resolve()
AI_HUB = ROOT / "AI_Agents_Hub"
AVALANCHE = ROOT / "troptions-avalanche-sports"
RAILS = ROOT / "troptions-rails"  # may be reference only

def run_cmd(cmd, cwd=None, shell=True):
    print(f"  > {cmd}")
    try:
        res = subprocess.run(cmd, cwd=cwd or ROOT, shell=shell, capture_output=True, text=True, timeout=120)
        out = (res.stdout or "") + (res.stderr or "")
        print(out[:2000] if out else "(no output)")
        return out
    except Exception as e:
        print(f"  Error: {e}")
        return str(e)

def run_phase0(mode="simulate"):
    print("=== PHASE 0: Foundation, Proofs, Audit Baseline ===")
    print(f"Mode: {mode}")

    # 1. Orchestrator
    print("\n[1/5] Orchestrator Phase 0...")
    os.chdir(AI_HUB)
    try:
        # Try direct call
        sys.path.insert(0, str(AI_HUB))
        from troptions_sovereign_orchestrator import run_phase, phase_status, list_all_systems
        print(run_phase(0, mode))
        print(phase_status(0))
        print(list_all_systems())
    except Exception as e:
        print(f"Direct import failed ({e}), falling back to subprocess...")
        run_cmd(f"python troptions_sovereign_orchestrator.py", cwd=AI_HUB)
    os.chdir(ROOT)

    # 2. E2E
    print("\n[2/5] E2E Golden Path...")
    e2e = RAILS / "scripts" / "e2e_golden_path.py"
    if e2e.exists():
        run_cmd(f"python {e2e} --simulate")
    else:
        print("  E2E script not in local troptions-rails (use GH or clone). See plan for commands.")

    # 3. Contracts (forge)
    print("\n[3/5] Contracts build/test...")
    contracts_dir = RAILS / "contracts"
    if contracts_dir.exists():
        run_cmd("forge build", cwd=contracts_dir)
        run_cmd('forge test --match-contract "Test*" -vv', cwd=contracts_dir)
    else:
        print("  No local troptions-rails clone. Use: forge in Codespaces or local setup per plan.")

    # 4. Proofs
    print("\n[4/5] Proofs (LPS-1)...")
    if AVALANCHE.exists():
        run_cmd("npm run proof:build", cwd=AVALANCHE)
        run_cmd("npm run proof:lps1", cwd=AVALANCHE)
    else:
        print("  avalanche-sports not found at expected path.")

    # 5. Status
    print("\n[5/5] Final Status...")
    try:
        sys.path.insert(0, str(AI_HUB))
        from troptions_sovereign_orchestrator import phase_status, list_all_systems
        print(phase_status(0))
        print(list_all_systems())
    except Exception as e:
        print(f"Status import error: {e}")

    print("\n=== PHASE 0 COMPLETE ===")
    print("Gates: Validator health, real tx hash in E2E, proofs portal, orchestrator green.")
    print("Next: Update E2E docs with hashes, push site, tag release, move to Phase 1.")

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--phase", type=int, default=0)
    parser.add_argument("--mode", default="simulate")
    args = parser.parse_args()

    if args.phase == 0:
        run_phase0(args.mode)
    else:
        print(f"Phase {args.phase} not fully implemented in runner yet. See PHASED_SYSTEM_EXECUTION_PLAN.md")
        print("Use orchestrator: run phase N")

if __name__ == "__main__":
    main()