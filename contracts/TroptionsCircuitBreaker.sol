// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BridgePayload.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title TroptionsCircuitBreaker
 * @notice Emergency kill switch for the Troptions system. Per-rail or global pause for compliance/risk events.
 * @dev Integrates with BridgePayload for audit, ties to SettlementHub/Orchestrator. Senior: NatSpec, Ownable, events.
 */
contract TroptionsCircuitBreaker is Ownable, Pausable {
    bool public isPaused;
    uint256 public lastPausedAt;
    mapping(string => bool) public railPaused; // e.g. "avalanche", "xrpl"

    event CircuitActivated(uint256 timestamp, string rail);
    event CircuitDeactivated(uint256 timestamp, string rail);

    function activateCircuitBreaker(string calldata rail) external onlyOwner {
        isPaused = true;
        lastPausedAt = block.timestamp;
        if (bytes(rail).length > 0) railPaused[rail] = true;
        emit CircuitActivated(block.timestamp, rail);
    }

    function deactivateCircuitBreaker(string calldata rail) external onlyOwner {
        isPaused = false;
        if (bytes(rail).length > 0) railPaused[rail] = false;
        emit CircuitDeactivated(block.timestamp, rail);
    }

    function isSystemPaused() external view returns (bool) {
        return isPaused;
    }
}
