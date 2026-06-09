// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/**
 * @title BridgePayload
 * @notice Unified cross-chain intent, stablecoin, and provenance standard for the Troptions 9-rail system.
 * @dev Used by VRF, NIL, CCIP, Automation, and all rail adapters (Solana, Sui, Stacks, Base, etc.).
 *      Includes fields for LPS-1 / XXXIII / GMIIE provenance (lps1Hash + gmiiSignature).
 *      This is the single source of truth for intent across Avalanche, Base, Solana, etc.
 * @custom:security-contact security@troptions.example
 */
struct BridgePayload {
    uint256 version;              // Protocol version for upgrades
    uint256 timestamp;            // Block timestamp at creation
    uint256 sourceChainId;        // e.g. 43114 (Avalanche)
    uint256 destinationChainId;   // e.g. 8453 (Base), 1 (ETH), Solana chain id etc.
    bytes32 assetId;              // keccak of stable or NIL asset (USDC, NIL bundle, etc.)
    bytes32 eventId;              // Unique event (sports match, NIL deal, etc.)
    address sender;
    address receiver;
    uint256 amount;               // Stablecoin or value amount
    uint256 fee;
    string action;                // "PAYOUT", "NIL_MINT", "NIL_PAYOUT", "CROSS_SETTLE" etc.
    bytes data;                   // abi.encode(randomOutcome, symbol, attributes...)
    bytes32 lps1Hash;             // LPS-1 / XXXIII / GMIIE provenance hash (critical for audit trail)
    bytes32 gmiiSignature;        // Signature or attestation from provenance system
}

library BridgePayloadLib {
    /**
     * @dev Hash the payload for uniqueness and verification (used in events and CCIP).
     */
    function hash(BridgePayload memory payload) internal pure returns (bytes32) {
        return keccak256(abi.encode(
            payload.version,
            payload.timestamp,
            payload.sourceChainId,
            payload.destinationChainId,
            payload.assetId,
            payload.eventId,
            payload.sender,
            payload.receiver,
            payload.amount,
            payload.fee,
            payload.action,
            payload.data,
            payload.lps1Hash,
            payload.gmiiSignature
        ));
    }
}
