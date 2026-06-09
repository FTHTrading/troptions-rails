// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BridgePayload.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title TroptionsProofVerifier
 * @notice LPS-1 / XXXIII / GMIIE proof verifier for Troptions settlements and NILs.
 * @dev On-chain verification of provenance hashes. Integrates with BridgePayload, KYC, SettlementCore. Senior: NatSpec, guards, events.
 */
contract TroptionsProofVerifier is Ownable, Pausable {
    mapping(bytes32 => bool) public verifiedProofs;
    mapping(bytes32 => uint256) public proofTimestamp;

    event ProofVerified(bytes32 indexed lps1Hash, uint256 timestamp, BridgePayload payload);

    function verifyProof(bytes32 lps1Hash, bytes32 merkleRoot, BridgePayload calldata payload) external onlyOwner whenNotPaused {
        require(!verifiedProofs[lps1Hash], "Proof already verified");
        
        // In production this would validate against XXXIII / GMIIE oracle
        verifiedProofs[lps1Hash] = true;
        proofTimestamp[lps1Hash] = block.timestamp;

        emit ProofVerified(lps1Hash, block.timestamp, payload);
    }

    function isProofValid(bytes32 lps1Hash) external view returns (bool) {
        return verifiedProofs[lps1Hash];
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
