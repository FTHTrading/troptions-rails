#!/bin/bash
# TROPTIONS RAILS - Master One-Command Deployment Script
# Deploys the full 33-contract system using TroptionsSystemBootstrap
# Run from repo root after setting env vars

set -e

echo "🚀 TROPTIONS RAILS - Full Empire Bootstrap"

echo "Checking environment..."
if [ -z "$FUJI_RPC" ] || [ -z "$PRIVATE_KEY" ] || [ -z "$SECURITY_COUNCIL" ]; then
  echo "Error: Set FUJI_RPC, PRIVATE_KEY, SECURITY_COUNCIL env vars"
  exit 1
fi

# Optional: For CCIP router on target chain
INITIAL_CCIP_ROUTER=${INITIAL_CCIP_ROUTER:-0x0000000000000000000000000000000000000000}

echo "Deploying full system on Fuji (Avalanche testnet)..."

forge script scripts/SystemBootstrap.s.sol \
  --rpc-url $FUJI_RPC \
  --broadcast \
  --verify \
  -vv \
  --sig "run()" \
  -- \
  $SECURITY_COUNCIL \
  $INITIAL_CCIP_ROUTER

echo "✅ Deployment complete. Check the returned SystemValidator address."
echo "Run: cast call <VALIDATOR_ADDRESS> 'isSystemFullyOperational()(bool)' --rpc-url $FUJI_RPC"
echo "Update README and investor site with live addresses."
echo "For mainnet: change RPC and add --chain mainnet flags carefully."
