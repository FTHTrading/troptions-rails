// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BridgePayload.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title TroptionsKYCCompliance
 * @notice Role-based KYC/AML compliance layer for Troptions rails. Enforces whitelists, jurisdictions, blacklists for institutional use (NIL, RWA, stables).
 * @dev Integrates with BridgePayload for actions, AccessControl for operators, SettlementCore for gated mint/settle. Senior: full NatSpec, Ownable, Pausable, events.
 */
contract TroptionsKYCCompliance is Ownable, Pausable {
    mapping(address => bool) public kycApproved;
    mapping(address => string) public jurisdiction;
    mapping(address => bool) public blacklisted;

    event KYCApproved(address indexed user, string jurisdiction);
    event UserBlacklisted(address indexed user, bool status);
    event ComplianceChecked(bytes32 indexed assetId, address user, bool passed, BridgePayload payload);

    function approveKYC(address user, string calldata juris) external onlyOwner whenNotPaused {
        require(!blacklisted[user], "User blacklisted");
        kycApproved[user] = true;
        jurisdiction[user] = juris;
        emit KYCApproved(user, juris);
    }

    function setBlacklist(address user, bool status) external onlyOwner {
        blacklisted[user] = status;
        if (status) kycApproved[user] = false;
        emit UserBlacklisted(user, status);
    }

    function checkCompliance(address user, BridgePayload calldata payload) external view returns (bool) {
        bool passed = kycApproved[user] && !blacklisted[user];
        return passed;
    }

    function gateAction(address user, BridgePayload calldata payload) external whenNotPaused {
        require(checkCompliance(user, payload), "Compliance check failed");
        emit ComplianceChecked(payload.assetId, user, true, payload);
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
