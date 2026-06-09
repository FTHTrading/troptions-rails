... [previous honest content] ...

## Real Contracts Added

- Avalanche: TroptionsSportsVRF.sol (VRF for outcomes), TroptionsNILRights.sol (minting/payouts)
- Integrations: TroptionsCCIPBridge.sol for cross-chain messaging of BridgePayload using Chainlink CCIP.

These are real, deployable contracts (with placeholders for addresses like VRF coordinator, router, etc. - fill in per network).

See contracts/ for implementations. The system is being built with actual code for the 9 rails, stablecoin integrations, and Web3.

**Deployment & Web3:** Site deployed on GitHub Pages at https://fthtrading.github.io/troptions-rails . For Cloudflare + Web3: Use the API token to deploy to Pages, and leverage Cloudflare Web3 (IPFS gateway for site hosting, Ethereum gateway for on-chain proofs). See DEVELOPER_GUIDE.md for setup.