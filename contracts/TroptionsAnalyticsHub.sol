// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BridgePayload.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title TroptionsAnalyticsHub
 * @notice Institutional Reporting & Analytics for settlements, mints, payouts across rails.
 * @dev Aggregates stats per event/asset with BridgePayload context. Ties to ReserveVault, SettlementHub. Senior: full NatSpec, Ownable, Pausable, events.
 */
contract TroptionsAnalyticsHub is Ownable, Pausable {
    struct EventStats {
        uint256 totalMinted;
        uint256 totalPayouts;
        uint256 activeUsers;
        uint256 lastUpdated;
    }

    mapping(bytes32 => EventStats) public stats;
    
    event StatsUpdated(bytes32 indexed eventId, uint256 totalMinted, uint256 totalPayouts, BridgePayload payload);

    function updateStats(
        bytes32 eventId,
        uint256 minted,
        uint256 payouts,
        BridgePayload calldata payload
    ) external onlyOwner whenNotPaused {
        EventStats storage s = stats[eventId];
        
        s.totalMinted += minted;
        s.totalPayouts += payouts;
        s.activeUsers += 1;
        s.lastUpdated = block.timestamp;

        emit StatsUpdated(eventId, s.totalMinted, s.totalPayouts, payload);
    }

    function getEventStats(bytes32 eventId) external view returns (EventStats memory) {
        return stats[eventId];
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
