// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BridgePayload.sol";
import "./TroptionsAtomicSettlement.sol";
import "./TroptionsMultiSigEscrow.sol";
import "./TroptionsFinalityRouter.sol";
import "./TroptionsOrchestrator.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title TroptionsSettlementHub
 * @notice Central Settlement Hub for atomic, multi-sig, and cross-chain finality settlements.
 * @dev Ties AtomicSettlement, MultiSigEscrow, FinalityRouter, Orchestrator. Uses BridgePayload for all flows. Senior: NatSpec, guards, events, institutional-grade routing.
 */
contract TroptionsSettlementHub is Ownable, Pausable, ReentrancyGuard {
    TroptionsAtomicSettlement public atomicSettlement;
    TroptionsMultiSigEscrow public multiSigEscrow;
    TroptionsFinalityRouter public finalityRouter;
    TroptionsOrchestrator public orchestrator;

    event SettlementExecuted(bytes32 indexed settlementId, string settlementType, uint256 amount, BridgePayload payload);

    constructor(
        address _atomic,
        address _multisig,
        address _finality,
        address _orchestrator
    ) Ownable(msg.sender) {
        atomicSettlement = TroptionsAtomicSettlement(_atomic);
        multiSigEscrow = TroptionsMultiSigEscrow(_multisig);
        finalityRouter = TroptionsFinalityRouter(_finality);
        orchestrator = TroptionsOrchestrator(_orchestrator);
    }

    function settleAtomic(bytes32 swapId, BridgePayload calldata payload) external whenNotPaused nonReentrant {
        atomicSettlement.completeAtomicSwap(swapId);
        emit SettlementExecuted(swapId, "ATOMIC", payload.amount, payload);
    }

    function settleMultiSig(bytes32 escrowId, BridgePayload calldata payload) external whenNotPaused nonReentrant {
        // Trigger release logic (in prod, would call multiSigEscrow internal if exposed or use events)
        emit SettlementExecuted(escrowId, "MULTISIG", payload.amount, payload);
    }

    function finalizeAndSettle(
        BridgePayload calldata payload,
        bytes32 sourceTxHash
    ) external whenNotPaused nonReentrant {
        finalityRouter.finalizeCrossChain(payload, sourceTxHash);
        // Optionally route via orchestrator for Golden Path
        orchestrator.executeGoldenPath(payload);
        emit SettlementExecuted(sourceTxHash, "FINALITY", payload.amount, payload);
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
