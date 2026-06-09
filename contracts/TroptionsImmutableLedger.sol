// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/**
 * @title TroptionsImmutableLedger
 * @notice Permanent, on-chain audit log for all critical actions across the empire.
 * @dev Records events with timestamps, hashes, LPS-1 provenance, and actors.
 *      Immutable append-only ledger for compliance, banks, GMIIE, and regulatory proof.
 *      Ties directly into BridgePayload, proofs, and settlements.
 */
contract TroptionsImmutableLedger {
    struct Record {
        uint256 timestamp;
        bytes32 eventHash;
        bytes32 lps1Hash;
        string action;
        address actor;
    }

    Record[] public ledger;
    
    event ActionRecorded(bytes32 indexed eventHash, string action, address actor);

    function recordAction(
        bytes32 eventHash,
        string calldata action,
        bytes32 lps1Hash,
        address actor
    ) external {
        ledger.push(Record({
            timestamp: block.timestamp,
            eventHash: eventHash,
            lps1Hash: lps1Hash,
            action: action,
            actor: actor
        }));

        emit ActionRecorded(eventHash, action, actor);
    }

    function getRecord(uint256 index) external view returns (Record memory) {
        require(index < ledger.length, "Index out of bounds");
        return ledger[index];
    }

    function getLedgerLength() external view returns (uint256) {
        return ledger.length;
    }
}
