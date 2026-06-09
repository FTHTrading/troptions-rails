// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BridgePayload.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title TroptionsMultiSigEscrow
 * @notice Institutional Multi-Sig Escrow for high-value NIL, RWA, and stablecoin settlements.
 * @dev Requires multiple signers for release. Integrated with BridgePayload for provenance (lps1Hash). Senior: full NatSpec, Ownable, Pausable, ReentrancyGuard, events with payload.
 */
contract TroptionsMultiSigEscrow is Ownable, Pausable, ReentrancyGuard {
    struct Escrow {
        bytes32 escrowId;
        address[] signers;
        uint256 requiredSignatures;
        uint256 amount;
        uint256 createdAt;
        bool released;
        bytes32 lps1Hash;
    }

    mapping(bytes32 => Escrow) public escrows;
    mapping(bytes32 => mapping(address => bool)) public hasSigned;

    event EscrowCreated(bytes32 indexed escrowId, uint256 amount, BridgePayload payload);
    event EscrowSigned(bytes32 indexed escrowId, address signer);
    event EscrowReleased(bytes32 indexed escrowId);

    function createEscrow(
        address[] calldata signers,
        uint256 requiredSignatures,
        uint256 amount,
        bytes32 lps1Hash,
        BridgePayload calldata payload
    ) external whenNotPaused nonReentrant returns (bytes32 escrowId) {
        require(signers.length >= requiredSignatures && requiredSignatures > 0, "Invalid sig requirements");
        escrowId = keccak256(abi.encode(msg.sender, block.timestamp, payload.assetId));

        escrows[escrowId] = Escrow({
            escrowId: escrowId,
            signers: signers,
            requiredSignatures: requiredSignatures,
            amount: amount,
            createdAt: block.timestamp,
            released: false,
            lps1Hash: lps1Hash
        });

        emit EscrowCreated(escrowId, amount, payload);
        return escrowId;
    }

    function signEscrow(bytes32 escrowId) external whenNotPaused nonReentrant {
        Escrow storage e = escrows[escrowId];
        require(!e.released, "Already released");
        require(!hasSigned[escrowId][msg.sender], "Already signed");

        bool isSigner = false;
        for (uint256 i = 0; i < e.signers.length; i++) {
            if (e.signers[i] == msg.sender) {
                isSigner = true;
                break;
            }
        }
        require(isSigner, "Not a signer");

        hasSigned[escrowId][msg.sender] = true;
        emit EscrowSigned(escrowId, msg.sender);

        if (_countSignatures(escrowId) >= e.requiredSignatures) {
            e.released = true;
            emit EscrowReleased(escrowId);
        }
    }

    function _countSignatures(bytes32 escrowId) internal view returns (uint256) {
        uint256 count = 0;
        Escrow memory e = escrows[escrowId];
        for (uint256 i = 0; i < e.signers.length; i++) {
            if (hasSigned[escrowId][e.signers[i]]) count++;
        }
        return count;
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
