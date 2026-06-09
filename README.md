... [previous content with stablecoins etc.] ...

## Major Integrations & Tools

- **Unified BridgePayload** — Cross-chain standard.
- **Golden Path** — 14+ step verified flows.
- **E2E Harness** — Mock + live testing.
- **Chainlink Full Stack** — VRF, CCIP, Automation, PoR.
- **Proof System** — IPFS + Cloudflare + LPS-1 + GMIIE.
- **Legacy Vault 5-Proof**.
- **Parallel Stablecoin Engine** — Direct support for major stablecoins and assets: USDT, USDC, RLUSD, PAXO, DAI, PYUSD, TUSD + more.
- **Cloudflare API & Infrastructure** — Full API access for hosting (Pages), Web3 gateways (IPFS/Ethereum for proofs and decentralized site access), Email Routing for agent mail/notifications. Used for deploying the professional site, managing DNS for troptions domains, and agent communications in the Sovereign Orchestrator. Token verified active with web3/worker/pages permissions. Integrated into deployment and agent system.

## Deployment

... [previous] ...

### Cloudflare Deployment (Primary for Professional Site and Web3)
- Use Cloudflare Pages for the professional site (website/index.html) via API or Wrangler (free tier).
- Web3: Serve via Cloudflare IPFS gateway for decentralized, provable hosting of the site, docs, and proofs (CLOUDFLARE_IPFS_GATEWAY in env).
- Agent Mail: Set up Email Routing on troptions zones for agent@ notifications from the multi-agent system.
- GitHub Action uses CF_API_TOKEN secret for automated deploys.
- Example in DEVELOPER_GUIDE.md and workflows.

See the professional site for live integration highlights.

## Developer Documentation

... [previous] ...
- Cloudflare API, Web3, Email Routing for agents (full section in DEVELOPER_GUIDE.md).

...