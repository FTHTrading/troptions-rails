// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BridgePayload.sol";

/**
 * @title TroptionsRateLimiter
 * @notice Per-user daily rate limiter for anti-spam and risk control on settlements, mints, routes.
 * @dev Payload-aware for action/amount based limiting. Senior: NatSpec, events.
 */
contract TroptionsRateLimiter {
    struct Limit {
        uint256 lastReset;
        uint256 currentUsage;
        uint256 maxPerDay;
    }

    mapping(address => Limit) public userLimits;
    uint256 public constant DAY = 86400;

    event RateLimitExceeded(address indexed user, uint256 attemptedAmount, BridgePayload payload);

    function consume(address user, uint256 amount, BridgePayload calldata payload) external returns (bool) {
        Limit storage limit = userLimits[user];

        if (block.timestamp - limit.lastReset >= DAY) {
            limit.currentUsage = 0;
            limit.lastReset = block.timestamp;
        }

        if (limit.currentUsage + amount > limit.maxPerDay) {
            emit RateLimitExceeded(user, amount, payload);
            return false;
        }

        limit.currentUsage += amount;
        return true;
    }

    function setUserLimit(address user, uint256 maxPerDay) external {
        userLimits[user].maxPerDay = maxPerDay;
    }
}
