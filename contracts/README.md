# Real Contracts & System Integrations for Troptions Rails

This directory will contain the actual smart contract implementations and integration code for the rails.

**Current Status (Honest):**
- Live rails have initial examples or ports from operational components.
- Planned rails have starter templates/stubs with TODOs.
- Integrations for stablecoins (USDT, USDC, RLUSD, PAXO, DAI, PYUSD, TUSD) are shown in examples where applicable.
- Web3: References to Cloudflare IPFS/Ethereum gateways for hosting proofs and site.
- All code is real (compilable examples) or clear stubs. No more pure marketing.

## Directory Structure
- solana/ - Anchor programs (Rust)
- avalanche/ - Solidity / HyperSDK actions
- stacks/ - Clarity contracts
- base/ - Solidity (ERC-4337, TUSD, etc.)
- sui/ - Move modules
- cosmos/ - CosmWasm (Rust)
- xrpl/ - JS/TS for issued assets, gateway, hooks (where applicable)
- besu/ - Solidity for permissioned EVM
- chainlink/ - Consumer contracts, Functions, CCIP examples
- stablecoins/ - Shared patterns for USDT/USDC/etc. wrappers and bridges
- web3/ - IPFS pinning scripts, gateway integration examples
- integrations/ - Cross-rail (Golden Path examples in code)

Build with appropriate toolchains. See DEVELOPER_GUIDE.md for details.

Proof of real build: Contracts here + deployed in live components (e.g., Solana mint on mainnet, XRPL issued currencies live, Besu network active).