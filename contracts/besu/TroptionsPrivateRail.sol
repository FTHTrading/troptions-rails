// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BridgePayload.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title TroptionsPrivateRail
 * @notice Permissioned EVM rail for Hyperledger Besu - private assets, NIL, stables for authorized orgs/banks.
 * @dev Integrates BridgePayload for cross-rail (e.g. from Avalanche NIL). Senior: NatSpec, Ownable, Pausable, events.
 */
contract TroptionsPrivateRail is Ownable, Pausable {
    mapping(bytes32 => bool) public verifiedAssets;
    mapping(address => bool) public authorizedOrgs;

    event PrivateAssetMinted(bytes32 indexed assetId, address indexed recipient, uint256 amount, BridgePayload payload);

    function mintPrivateAsset(bytes32 assetId, address recipient, uint256 amount, BridgePayload calldata payload) external whenNotPaused {
        require(authorizedOrgs[msg.sender], "Not authorized organization");
        require(!verifiedAssets[assetId], "Asset already minted");

        verifiedAssets[assetId] = true;
        emit PrivateAssetMinted(assetId, recipient, amount, payload);
    }

    function authorizeOrg(address org) external onlyOwner {
        authorizedOrgs[org] = true;
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
