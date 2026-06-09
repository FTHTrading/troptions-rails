// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BridgePayload.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title TroptionsAgentRegistry
 * @notice Sovereign AI Agent Management for orchestrator/agents calling rails. Authorized agents for secure multi-agent ops.
 * @dev Integrates with Sovereign Orchestrator, BridgePayload for agent actions, AccessControl. Senior: full NatSpec, Ownable, Pausable, events.
 */
contract TroptionsAgentRegistry is Ownable, Pausable {
    mapping(address => bool) public authorizedAgents;
    mapping(bytes32 => address) public agentById;

    event AgentRegistered(bytes32 indexed agentId, address agentAddress, BridgePayload payload);
    event AgentRevoked(bytes32 indexed agentId);

    function registerAgent(bytes32 agentId, address agentAddress, BridgePayload calldata payload) external onlyOwner whenNotPaused {
        authorizedAgents[agentAddress] = true;
        agentById[agentId] = agentAddress;
        
        emit AgentRegistered(agentId, agentAddress, payload);
    }

    function revokeAgent(bytes32 agentId) external onlyOwner {
        address agent = agentById[agentId];
        authorizedAgents[agent] = false;
        
        emit AgentRevoked(agentId);
    }

    function isAgentAuthorized(address agent) external view returns (bool) {
        return authorizedAgents[agent];
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
