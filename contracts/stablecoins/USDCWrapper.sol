// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "../BridgePayload.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title USDCWrapper
 * @notice Explicit stable wrapper for USDC with BridgePayload emission (post-audit expansion).
 * @dev Direct integration for Golden Path payouts, NIL, VRF. Extend for approvals/treasury.
 */
contract USDCWrapper is Ownable, Pausable, ReentrancyGuard {
    IERC20 public immutable usdc;
    event StableWrapped(BridgePayload payload, uint256 amount);
    event StableUnwrapped(BridgePayload payload, uint256 amount);

    constructor(address _usdc) {
        usdc = IERC20(_usdc);
    }

    function wrapAndEmit(BridgePayload memory p, uint256 amount) external whenNotPaused nonReentrant {
        require(usdc.transferFrom(msg.sender, address(this), amount), "transfer failed");
        // In production: mint wrapper token or credit
        emit StableWrapped(p, amount);
    }

    function unwrapAndEmit(BridgePayload memory p, uint256 amount, address to) external whenNotPaused nonReentrant {
        require(usdc.transfer(to, amount), "unwrap transfer failed");
        emit StableUnwrapped(p, amount);
    }
}