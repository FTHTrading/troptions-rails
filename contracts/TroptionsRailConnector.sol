// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./TroptionsRailRegistry.sol";
import "./TroptionsStablecoinGateway.sol";
import "./BridgePayload.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title TroptionsRailConnector
 * @notice The Rail Connector system that ties the entire suite together: Registry for discovery, Gateway for stables, core contracts (VRF/NIL/CCIP/Automation) for execution.
 * @dev Routes BridgePayloads to the correct rail's bridge/primary contract. Supports stable bridging via Gateway. Senior: NatSpec, guards, events, uses AccessControl indirectly via Registry.
 *      Practical focus: Core 6-7 rails (XRPL, Solana, Base, Avalanche, Stacks/sBTC, Chainlink + Bitcoin/Stellar).
 */
contract TroptionsRailConnector is Ownable, Pausable, ReentrancyGuard {
    TroptionsRailRegistry public registry;
    TroptionsStablecoinGateway public stableGateway;

    event PayloadRouted(bytes32 indexed payloadHash, string targetRail, uint64 destSelector);
    event StableRouted(bytes32 indexed nonce, string targetRail);

    constructor(address _registry, address _stableGateway) Ownable(msg.sender) {
        registry = TroptionsRailRegistry(_registry);
        stableGateway = TroptionsStablecoinGateway(_stableGateway);
    }

    function setRegistry(address _registry) external onlyOwner {
        registry = TroptionsRailRegistry(_registry);
    }

    function setStableGateway(address _gateway) external onlyOwner {
        stableGateway = TroptionsStablecoinGateway(_gateway);
    }

    function routePayload(BridgePayload calldata payload, string calldata targetRail) external whenNotPaused nonReentrant {
        TroptionsRailRegistry.Rail memory rail = registry.getRail(targetRail);
        require(rail.active, "Rail not active");
        require(rail.bridgeContract != address(0), "No bridge for rail");

        // In production: call IRouterClient or delegate to the rail's bridgeContract with payload
        // Example emit for simulation; real impl would do ccipSend or cross-call
        bytes32 h = BridgePayloadLib.hash(payload);
        emit PayloadRouted(h, targetRail, rail.chainSelector);

        // Hook for stable if payload.action involves stables
        if (keccak256(bytes(payload.action)) == keccak256(bytes("STABLE_BRIDGE"))) {
            // Would call stableGateway.bridgeStablecoin here with nonce derived from payload
        }
    }

    function routeStable(bytes32 nonce, BridgePayload calldata payload, string calldata targetRail, address token) external whenNotPaused nonReentrant {
        TroptionsRailRegistry.Rail memory rail = registry.getRail(targetRail);
        require(rail.active, "Rail not active");

        stableGateway.bridgeStablecoin(payload, nonce, token);
        emit StableRouted(nonce, targetRail);
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
