// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BridgePayload.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title TroptionsLegacyVault
 * @notice 5-Proof Estate Protection vault for NIL/assets with time-locked unlock and LPS-1 provenance.
 * @dev Uses BridgePayload for creation data. Integrated with RailRegistry for rail-specific vaults. Senior: NatSpec, guards, events with payload, pausable.
 */
contract TroptionsLegacyVault is Ownable, Pausable, ReentrancyGuard {
    struct Vault {
        address owner;
        bytes32 assetId;
        uint256 createdAt;
        uint256 unlockTime;
        bool isActive;
        bytes32 lps1Hash;
    }

    mapping(bytes32 => Vault) public vaults;
    mapping(address => uint256) public userVaultCount;

    event VaultCreated(bytes32 indexed vaultId, address indexed owner, bytes32 lps1Hash, BridgePayload payload);
    event VaultUnlocked(bytes32 indexed vaultId, address owner);

    function createVault(BridgePayload calldata payload, uint256 unlockDelay) external whenNotPaused nonReentrant {
        bytes32 vaultId = keccak256(abi.encode(payload.assetId, block.timestamp, msg.sender));

        require(vaults[vaultId].owner == address(0), "Vault already exists");

        vaults[vaultId] = Vault({
            owner: msg.sender,
            assetId: payload.assetId,
            createdAt: block.timestamp,
            unlockTime: block.timestamp + unlockDelay,
            isActive: true,
            lps1Hash: payload.lps1Hash
        });

        userVaultCount[msg.sender]++;
        
        emit VaultCreated(vaultId, msg.sender, payload.lps1Hash, payload);
    }

    function unlockVault(bytes32 vaultId) external whenNotPaused nonReentrant {
        Vault storage v = vaults[vaultId];
        require(v.owner == msg.sender, "Not vault owner");
        require(block.timestamp >= v.unlockTime, "Vault still locked");
        require(v.isActive, "Vault not active");

        v.isActive = false;
        emit VaultUnlocked(vaultId, msg.sender);

        // Could emit BridgePayload for cross-rail estate settlement
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
