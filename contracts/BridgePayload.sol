// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/**
 * @title BridgePayload
 * @notice Unified payload used across ALL Troptions rails (9-rail empire).
 * @dev Foundation for cross-chain (CCIP selectors), stables, NILs, sports VRF, LPS-1/XXXIII/GMIIE provenance.
 *      Senior template: simple, hashable, extensible.
 */
struct BridgePayload {
    uint256 version;
    uint256 timestamp;
    uint64  sourceChainSelector;   // CCIP-style (e.g. Avalanche selector)
    uint64  destChainSelector;     // Target (Base, Solana via bridge, etc.)

    bytes32 assetId;               // Stable or NIL identifier (keccak)
    bytes32 eventId;
    address sender;
    address receiver;

    uint256 amount;
    string  action;                // "MINT_NIL", "PAYOUT", "TRANSFER", etc.
    bytes   data;

    bytes32 lps1Hash;              // XXXIII / LPS-1 provenance
    bytes32 gmiiSignature;
}

library BridgePayloadLib {
    function hash(BridgePayload memory p) internal pure returns (bytes32) {
        return keccak256(abi.encode(p));
    }
}
