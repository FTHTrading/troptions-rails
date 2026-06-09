// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BridgePayload.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title TroptionsIdentityVerifier
 * @notice On-chain identity verifier for Troptions (ERC-3643 style claims or custom). Verifies proofs for NIL/RWA eligibility.
 * @dev Ties to KYCCompliance, BridgePayload for provenance. Senior: NatSpec, Ownable, Pausable, events.
 */
contract TroptionsIdentityVerifier is Ownable, Pausable {
    mapping(bytes32 => bool) public verifiedClaims;
    mapping(address => bytes32) public userIdentityHash;

    event IdentityVerified(address indexed user, bytes32 claimHash, BridgePayload payload);
    event ClaimRevoked(bytes32 indexed claimHash);

    function verifyIdentity(address user, bytes32 claimHash, BridgePayload calldata payload) external onlyOwner whenNotPaused {
        verifiedClaims[claimHash] = true;
        userIdentityHash[user] = claimHash;
        emit IdentityVerified(user, claimHash, payload);
    }

    function revokeClaim(bytes32 claimHash) external onlyOwner {
        verifiedClaims[claimHash] = false;
        emit ClaimRevoked(claimHash);
    }

    function isIdentityValid(address user, bytes32 claimHash) external view returns (bool) {
        return verifiedClaims[claimHash] && userIdentityHash[user] == claimHash;
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
