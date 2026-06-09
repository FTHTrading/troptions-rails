... [previous content] ...

## Cloudflare API Integration (Full API, Web3, Agent Mail)

The Troptions system uses Cloudflare as the primary infrastructure layer for hosting, Web3 decentralized access, and agent communications. The provided API token (cfut_...) has been verified as active with broad permissions including web3, worker, pages, dns, logs, etc.

### Setup
- Add the token as GitHub secret `CF_API_TOKEN` (or local env var).
- Token verified via API: `https://api.cloudflare.com/client/v4/user/tokens/verify` returns valid.

### Full Cloudflare API Usage
Use the API for DNS management, Pages deploys, Workers for custom API endpoints, etc.

Example (PowerShell):
```
$headers = @{ "Authorization" = "Bearer $env:CF_API_TOKEN"; "Content-Type" = "application/json" }
Invoke-RestMethod -Uri "https://api.cloudflare.com/client/v4/user/tokens/verify" -Headers $headers
```

Example curl for zones (adapt for troptions domains):
```
curl "https://api.cloudflare.com/client/v4/zones" -H "Authorization: Bearer $CF_API_TOKEN"
```

### Web3 Integration
Cloudflare Web3 gateways for decentralized hosting of proofs and the professional site:
- IPFS Gateway: Use CLOUDFLARE_IPFS_GATEWAY env (already in existing Troptions Pages projects).
- Ethereum Gateway for on-chain verification.
- Host static assets (site, docs, proofs) on IPFS via Cloudflare for censorship resistance and Web3 provability.

Existing projects (e.g., troptions-unity-legacy-vault) already use these for Troptions assets.

### Agent Mail (Email Routing for Agents)
Use Cloudflare Email Routing to set up agent-specific email addresses for notifications from the Sovereign Orchestrator, Composer, or per-rail agents.

- On a troptions domain (e.g., via zones API), create routing rules to forward agent@domain to webhooks or email inboxes.
- Integrate with the orchestrator for email alerts on deployments, sims, or alerts.
- API example to list routing:
  Use /client/v4/zones/{zone_id}/email/routing

This enables "agent mail" for the multi-agent system (e.g., alerts from donkai sims or army starts).

### Deploying the Professional Site to Cloudflare Pages
- Use Pages API or dashboard to deploy the website/index.html as a static site.
- GitHub Action example for CI deploy (add as .github/workflows/deploy-cloudflare.yml):
```
name: Deploy to Cloudflare Pages
on: [push]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v4
    - name: Deploy
      uses: cloudflare/wrangler-action@v3
      with:
        apiToken: ${{ secrets.CF_API_TOKEN }}
        command: pages deploy website --project-name=troptions-rails-professional-site
```

This replaces or augments Vercel deployment for full Cloudflare integration (free tier covers hosting, custom domains, Web3).

### Integration into Troptions Rails System
- The professional site and docs are hosted via Cloudflare for reliability and Web3 access.
- Orchestrator can call Cloudflare API for dynamic deployments or email.
- Proofs and assets served via Web3 gateways for decentralized verification.
- Agent mail for system notifications.

See existing Troptions Pages projects (troptions-unity-legacy-vault, etc.) for live examples using the same account and Web3 configs.

All setup is documented here and in the repo for provability.