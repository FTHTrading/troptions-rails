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
