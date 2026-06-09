// Web3 / IPFS integration example using Cloudflare gateways.
// For hosting site, proofs, docs in decentralized way.

async function pinToIPFSViaCloudflare(content) {
    // Use CLOUDFLARE_IPFS_GATEWAY or API
    const cid = 'bafy...'; // after pin
    console.log(`Site/proof available at: https://${cid}.ipfs.cf-ipfs.com/`);
    // Ethereum gateway for on-chain metadata
    return cid;
}

module.exports = { pinToIPFSViaCloudflare };
