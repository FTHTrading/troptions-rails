# Changelog

All notable changes to Troptions Rails.

## [v0.1.0] - 2026-06 (Post Full System Audit)
### Added
- Full system audit report (docs/SYSTEM_AUDIT_REPORT.md) with findings, verified items, and prioritized roadmap.
- Post-audit section in professional site + updated metrics/language.
- 2 new explicit stablecoin wrappers (contracts/stablecoins/USDCWrapper.sol, RLUSDWrapper.sol) with BridgePayload emission + guards.
- Improved TroptionsSystemValidator.sol (more components wired, better health logic, payload support notes, enhanced NatSpec/events).
- Enhanced E2E harness (scripts/e2e_golden_path.py): tx hash capture prompts, sample payload output, verification step guidance.
- Enhanced deploy-all.sh with more post-deploy validator/hash capture reminders.
- Canonical 33 contract breakdown in CONTRACT_TEMPLATES (reconciled from 29/33 variance).

### Changed
- Reconciled all references to **33 senior-grade contracts & tools** (core + governance + Avalanche + per-rail adapters + Web3).
- Aligned status language for honesty/consistency (🟢 LIVE / 🔵 BUILT (starters/adapters) / 🟠 PARTIAL) across README, site, CONTRACT_TEMPLATES, local inventory/9-chains MDs, and docs.
- Updated gap closure, investor, and honest assessment sections with audit notes.
- Site badges and rails text cleaned (no broken classes; consistent labels).
- docs/CONTRACT_TEMPLATES.md and contracts/README.md synced to expanded 33 list + audit note.

### Fixed
- Previous presentation inconsistencies and "planned" soft language in main claims.
- E2E placeholders and instructions clarified for real testnet execution post-deploy.

### Verified
- 30+ .sol present (including avalanche/ VRF + NIL, governance Bootstrap/Validator etc).
- Scripts (deploy + e2e) executable in structure.
- Site live with audit banner.
- CI workflows and basic tests present.

See GitHub releases for the tag. Continue per audit roadmap (deploys + hashes next, tests/audits, depth).