// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

struct BridgePayload {
    uint256 version;
    uint256 timestamp;
    uint256 sourceChainId;
    uint256 destinationChainId;
    bytes32 assetId;
    bytes32 eventId;
    address sender;
    address receiver;
    uint256 amount;
    uint256 fee;
    string action;
    bytes data;
    bytes32 lps1Hash;
    bytes32 gmiiSignature;
}

library BridgePayloadLib {
    function hash(BridgePayload memory p) internal pure returns (bytes32) {
        return keccak256(abi.encode(p.version, p.timestamp, p.sourceChainId, p.destinationChainId, p.assetId, p.eventId, p.sender, p.receiver, p.amount, p.fee, p.action, p.data, p.lps1Hash, p.gmiiSignature));
    }
}