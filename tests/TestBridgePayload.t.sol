// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "contracts/BridgePayload.sol";

contract TestBridgePayload is Test {
    function testHashDeterministic() public pure {
        BridgePayload memory p = BridgePayload({
            version: 1,
            timestamp: 1234567890,
            sourceChainSelector: 1,
            destChainSelector: 2,
            assetId: keccak256("USDC"),
            eventId: keccak256("EVT1"),
            sender: address(0x1),
            receiver: address(0x2),
            amount: 1000,
            action: "PAYOUT",
            data: "",
            lps1Hash: bytes32(0),
            gmiiSignature: bytes32(0)
        });
        bytes32 h1 = BridgePayloadLib.hash(p);
        bytes32 h2 = BridgePayloadLib.hash(p);
        assertEq(h1, h2, "Hash must be deterministic");
    }

    function testHashChangesWithData() public pure {
        BridgePayload memory p1 = BridgePayload(1, block.timestamp, 1, 2, bytes32(0), bytes32(0), address(0), address(0), 0, "", "", bytes32(0), bytes32(0));
        BridgePayload memory p2 = p1;
        p2.amount = 999;
        assertTrue(BridgePayloadLib.hash(p1) != BridgePayloadLib.hash(p2));
    }
}
