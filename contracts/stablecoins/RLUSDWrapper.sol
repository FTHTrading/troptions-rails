// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "../BridgePayload.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title RLUSDWrapper
 * @notice Explicit stable wrapper for RLUSD (XRPL primary) with BridgePayload (post-audit).
 */
contract RLUSDWrapper is Ownable, Pausable, ReentrancyGuard {
    IERC20 public immutable rlusd;
    event StableWrapped(BridgePayload payload, uint256 amount);

    constructor(address _rlusd) {
        rlusd = IERC20(_rlusd);
    }

    function wrapAndEmit(BridgePayload memory p, uint256 amount) external whenNotPaused nonReentrant {
        require(rlusd.transferFrom(msg.sender, address(this), amount), "transfer failed");
        emit StableWrapped(p, amount);
    }
}