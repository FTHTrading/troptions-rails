// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BridgePayload.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title TroptionsFeeManager
 * @notice Dynamic fee manager for routes/payouts in the Troptions suite. Integrates with Orchestrator/Connector payloads.
 * @dev Base/premium bps, exemptions, calculate based on payload action/amount. Senior: NatSpec, guards, events with payload.
 */
contract TroptionsFeeManager is Ownable, Pausable {
    uint256 public baseFeeBps = 25;        // 0.25%
    uint256 public premiumFeeBps = 75;     // 0.75%

    mapping(address => bool) public feeExempt;

    event FeeCollected(address indexed user, uint256 amount, string reason, BridgePayload payload);

    function calculateFee(uint256 amount, bool isPremium) public view returns (uint256) {
        uint256 rate = isPremium ? premiumFeeBps : baseFeeBps;
        return (amount * rate) / 10_000;
    }

    function calculateFeeForPayload(BridgePayload calldata payload, bool isPremium) public view returns (uint256) {
        return calculateFee(payload.amount, isPremium);
    }

    function setBaseFee(uint256 newFeeBps) external onlyOwner {
        require(newFeeBps <= 200, "Fee too high");
        baseFeeBps = newFeeBps;
    }

    function exemptAddress(address user, bool exempt) external onlyOwner {
        feeExempt[user] = exempt;
    }

    function collectFee(address user, uint256 amount, string calldata reason, BridgePayload calldata payload) external onlyOwner whenNotPaused {
        if (!feeExempt[user]) {
            // In prod: transfer fees to treasury
            emit FeeCollected(user, amount, reason, payload);
        }
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
