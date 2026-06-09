... [include previous content with added Web3 section] ...

## Professional Shareable Site

A polished, self-contained website (Tailwind + Mermaid diagrams) is included in `website/index.html` and deployed to GitHub Pages for easy sharing.

**Live Site:** https://fthtrading.github.io/troptions-rails

It covers:
- The 9 rails
- How it all works + flow trees
- Brand boost & impact
- What can now be done
- 1-click activation
- Investor costs and proof

**Web3 Setup:** The site and proofs are integrated with Cloudflare's Web3 gateways for IPFS and Ethereum (as configured in ecosystem Pages projects with env vars like CLOUDFLARE_IPFS_GATEWAY, ETHEREUM_GATEWAY). This enables decentralized, Web3-accessible hosting of the professional site, documentation, and cryptographic proofs for full provability and censorship resistance. To mirror the site to Web3, use the Cloudflare IPFS gateway with the content CID or deploy via the verified API token. See DEVELOPER_GUIDE.md for details on using the gateways with the Cloudflare API token.

**Deploy & share:** The site is deployed on GitHub Pages (source: main /docs). For Cloudflare Pages + Web3, use the verified API token and Wrangler as documented. The site can also be pinned to IPFS for Web3 access.

The site is also available in the repo at /docs/index.html (for Pages) and /website/index.html.

... [rest of previous content] ...