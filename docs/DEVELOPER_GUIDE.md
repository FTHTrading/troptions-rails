... [previous Cloudflare/Web3 section] ...

## Testing & CI

**Full Foundry + Security**
- `forge build` and `forge test` from contracts/ (or root with the provided foundry.toml).
- Dedicated: `.github/workflows/forge-test.yml` (dispatch or push).
- Main CI (`.github/workflows/ci.yml`): builds, tests, coverage (lcov), + Slither scan on core contracts (filters lib/tests, uploads report artifact).
- Run locally: `cd contracts && forge test -vv --gas-report`
- New tests live in `tests/Test*.t.sol` (BridgePayload hash, Timelock queue/execute/warp, AgentRegistry register/revoke). Expand for every new contract.
- Non-EVM: Anchor (cargo test in solana/ programs), Clarity (stacks CLI), Move (sui test), CosmWasm (cargo test).

**Security Scans**
- Slither in CI (medium+ findings block or flagged).
- Next: MythX / formal (Q3 post audit start).
- Always: NatSpec + guards + ReentrancyGuard on all senior templates.

## Deployment Scripts (Testnets + Main)

Core institutional + rail contracts use Foundry scripts.

```bash
# 1. Prep
cp .env.example .env   # FUJI_RPC, SEPOLIA_RPC, PRIVATE_KEY (test only), ETHERSCAN_KEY

# 2. Deploy key 5 (GovernanceTimelock, AgentRegistry, Router, SettlementHub, StablecoinGateway)
forge script scripts/DeployCore.s.sol --rpc-url $FUJI_RPC --broadcast --verify -vv

# 3. Capture addresses from console, update:
# - README.md (Snowtrace links)
# - scripts/e2e_golden_path.py env
# - investor proof section

# Example Fuji Snowtrace: https://testnet.snowtrace.io/address/0xYourTimelock
# Solscan for Solana program: solscan.io/account/YourProgram

See scripts/DeployCore.s.sol for the exact broadcast + logging. Extend for per-rail (Avalanche VRF subId wiring, XRPL gateway JS deploy, etc.).

## E2E Golden Path Harness

See docs/E2E_GOLDEN_PATH.md and `python3 scripts/e2e_golden_path.py --simulate`.
After first deploys, replace placeholders with real txs from Fuji + devnet. This is the live reference for banks/CBDC flows.

## Adding Real Contracts

See /contracts/ directory for starters. Port from live components (e.g., Solana Anchor from mint console, XRPL JS from live gateway, Besu Solidity from permissioned rail).

Implement full Golden Path in code, not just docs. Use stablecoin wrappers for USDT/USDC etc. across rails.

For Web3: Pin site/proofs to IPFS via gateway, use Ethereum gateway for on-chain attestations. Example in contracts/web3/.

Update this guide and proofs as real deployments happen.