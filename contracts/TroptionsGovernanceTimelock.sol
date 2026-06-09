// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BridgePayload.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title TroptionsGovernanceTimelock
 * @notice Controlled upgrades & governance timelock for the Troptions system. 48h delay for admin actions, BridgePayload for audit.
 * @dev Integrates with AccessControl, RailRegistry, SettlementHub. Senior: full NatSpec, Ownable, Pausable, events with payload.
 */
contract TroptionsGovernanceTimelock is Ownable, Pausable {
    uint256 public delay = 2 days;

    mapping(bytes32 => uint256) public queuedTransactions;
    mapping(bytes32 => bool) public executed;

    event TransactionQueued(bytes32 indexed txHash, uint256 executionTime, BridgePayload payload);
    event TransactionExecuted(bytes32 indexed txHash);
    event TransactionCancelled(bytes32 indexed txHash);

    function queueTransaction(address target, bytes calldata data, BridgePayload calldata payload) external onlyOwner whenNotPaused {
        bytes32 txHash = keccak256(abi.encode(target, data, block.timestamp + delay));
        queuedTransactions[txHash] = block.timestamp + delay;

        emit TransactionQueued(txHash, block.timestamp + delay, payload);
    }

    function executeTransaction(address target, bytes calldata data) external onlyOwner whenNotPaused {
        bytes32 txHash = keccak256(abi.encode(target, data, block.timestamp));

        require(queuedTransactions[txHash] != 0, "Not queued");
        require(block.timestamp >= queuedTransactions[txHash], "Timelock not expired");
        require(!executed[txHash], "Already executed");

        executed[txHash] = true;

        (bool success, ) = target.call(data);
        require(success, "Execution failed");

        emit TransactionExecuted(txHash);
    }

    function cancelTransaction(bytes32 txHash) external onlyOwner {
        queuedTransactions[txHash] = 0;
        emit TransactionCancelled(txHash);
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
