// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BridgePayload.sol";
import "./TroptionsCCIPBridge.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title TroptionsCrossChainRouter
 * @notice Unified router for BridgePayload across all rails using CCIP and registered bridges.
 * @dev Ties to RailRegistry, SettlementHub, RateLimiter. Senior: NatSpec, guards, events.
 */
contract TroptionsCrossChainRouter is Ownable, Pausable {
    TroptionsCCIPBridge public ccipBridge;
    mapping(uint64 => address) public railBridges;

    event RoutedToRail(uint64 indexed destChain, bytes32 indexed assetId, BridgePayload payload);

    constructor(address _ccipBridge) {
        ccipBridge = TroptionsCCIPBridge(_ccipBridge);
    }

    function registerRail(uint64 chainSelector, address bridgeContract) external onlyOwner {
        railBridges[chainSelector] = bridgeContract;
    }

    function routePayload(BridgePayload calldata payload) external whenNotPaused {
        address targetBridge = railBridges[payload.destChainSelector];
        require(targetBridge != address(0), "Rail not registered");

        ccipBridge.sendPayload(
            payload.destChainSelector,
            targetBridge,
            payload,
            address(0),
            0
        );

        emit RoutedToRail(payload.destChainSelector, payload.assetId, payload);
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
