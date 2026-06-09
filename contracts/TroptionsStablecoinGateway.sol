// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BridgePayload.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title TroptionsStablecoinGateway
 * @notice Senior gateway for bridging supported stables (USDT, USDC, RLUSD, PAXO +) using BridgePayload.
 * @dev Nonce replay protection, supported list, actual token transfers, payload emits for CCIP/Automation integration.
 *      Ties into RailRegistry for destination routing. LPS-1 provenance supported in payload.
 */
contract TroptionsStablecoinGateway is Ownable, Pausable, ReentrancyGuard {
    mapping(address => bool) public supportedStablecoins;
    mapping(bytes32 => bool) public processedNonces;

    event StablecoinBridged(bytes32 indexed nonce, address indexed token, uint256 amount, uint64 destinationChain, BridgePayload payload);
    event StablecoinSupported(address token, bool supported);

    function addSupportedStablecoin(address token) external onlyOwner {
        supportedStablecoins[token] = true;
        emit StablecoinSupported(token, true);
    }

    function removeSupportedStablecoin(address token) external onlyOwner {
        supportedStablecoins[token] = false;
        emit StablecoinSupported(token, false);
    }

    function bridgeStablecoin(
        BridgePayload calldata payload,
        bytes32 nonce,
        address token
    ) external whenNotPaused nonReentrant {
        require(!processedNonces[nonce], "Nonce already used");
        require(supportedStablecoins[token], "Unsupported stablecoin");
        require(payload.amount > 0, "Invalid amount");

        processedNonces[nonce] = true;

        // Actual transfer (assumes msg.sender approved or this contract holds; prod: use safeTransferFrom or escrow)
        IERC20(token).transferFrom(msg.sender, address(this), payload.amount); // or direct to bridge

        emit StablecoinBridged(nonce, token, payload.amount, payload.destChainSelector, payload);

        // In full system: forward payload to CCIPBridge or RailConnector for cross-rail
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
