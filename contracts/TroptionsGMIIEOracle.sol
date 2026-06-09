// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BridgePayload.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title TroptionsGMIIEOracle
 * @notice GMIIE Intelligence + XXXIII Integration oracle for event scores/provenance feeding NIL/VRF/Orchestrator.
 * @dev Senior: NatSpec, Ownable/Pausable, BridgePayload in submits, verified flags, events. Integrates with NILRights for payout intelligence.
 */
contract TroptionsGMIIEOracle is Ownable, Pausable {
    mapping(bytes32 => uint256) public eventScore;
    mapping(bytes32 => bool) public verified;
    mapping(bytes32 => bytes32) public eventLps1Hash;

    event IntelligenceUpdated(bytes32 indexed eventId, uint256 score, bytes32 lps1Hash, BridgePayload payload);

    function submitIntelligence(
        bytes32 eventId, 
        uint256 score, 
        bytes32 lps1Hash,
        BridgePayload calldata payload
    ) external onlyOwner whenNotPaused {
        eventScore[eventId] = score;
        verified[eventId] = true;
        eventLps1Hash[eventId] = lps1Hash;

        emit IntelligenceUpdated(eventId, score, lps1Hash, payload);
    }

    function getEventScore(bytes32 eventId) external view returns (uint256) {
        require(verified[eventId], "Intelligence not verified");
        return eventScore[eventId];
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
