// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BridgePayload.sol";
import "./TroptionsRailRegistry.sol";
import "./TroptionsRailConnector.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title TroptionsOrchestrator
 * @notice The Master Controller for Golden Path execution across rails using BridgePayload.
 * @dev Integrates RailRegistry for discovery, RailConnector for routing. Determines best rail, executes flows (NIL, stables, VRF). Senior: NatSpec, guards, events.
 */
contract TroptionsOrchestrator is Ownable, Pausable, ReentrancyGuard {
    TroptionsRailRegistry public registry;
    TroptionsRailConnector public connector;

    event GoldenPathExecuted(string action, bytes32 assetId, uint64 destinationChain, BridgePayload payload);

    constructor(address _registry, address _connector) Ownable(msg.sender) {
        registry = TroptionsRailRegistry(_registry);
        connector = TroptionsRailConnector(_connector);
    }

    function setRegistry(address _registry) external onlyOwner {
        registry = TroptionsRailRegistry(_registry);
    }

    function setConnector(address _connector) external onlyOwner {
        connector = TroptionsRailConnector(_connector);
    }

    /**
     * @notice Main entry point for the Golden Path
     */
    function executeGoldenPath(BridgePayload calldata payload) external onlyOwner whenNotPaused nonReentrant {
        string memory targetRail = _determineBestRail(payload.amount, payload.action);
        
        TroptionsRailRegistry.Rail memory rail = registry.getRail(targetRail);
        require(rail.active, "Target rail not active");

        // Route via Connector (ties to CCIP/Gateway etc.)
        connector.routePayload(payload, targetRail);

        emit GoldenPathExecuted(payload.action, payload.assetId, payload.destChainSelector, payload);
    }

    function _determineBestRail(uint256 amount, string memory action) internal pure returns (string memory) {
        if (keccak256(bytes(action)) == keccak256(bytes("HIGH_VALUE"))) {
            return "Stacks";        // Bitcoin secured
        } else if (amount < 1000) {
            return "Base";          // Cheap & fast
        } else {
            return "Avalanche";     // High throughput
        }
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
