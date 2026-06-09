// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import "./../avalanche/TroptionsNILRights.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title TroptionsAutomation
 * @notice Senior Chainlink Automation Keeper template for NIL performance payouts.
 * @dev Integrates with TroptionsNILRights. Register events post-mint/VRF, perform triggers payout.
 *      Configurable, pausable, production patterns.
 */
contract TroptionsAutomation is AutomationCompatibleInterface, Ownable, Pausable {
    TroptionsNILRights public nilRights;
    mapping(bytes32 => bool) public pending;

    event UpkeepPerformed(bytes32 indexed eventId, address athlete, uint256 amount);

    constructor(address _nil) Ownable(msg.sender) {
        nilRights = TroptionsNILRights(_nil);
    }

    function setNILRights(address _nil) external onlyOwner { nilRights = TroptionsNILRights(_nil); }

    function register(bytes32 eventId) external whenNotPaused {
        pending[eventId] = true;
    }

    function checkUpkeep(bytes calldata /* data */) external view override returns (bool upkeepNeeded, bytes memory performData) {
        // Off-chain logic or checkData feeds specific event. Placeholder for template.
        upkeepNeeded = false;
        performData = "";
    }

    function performUpkeep(bytes calldata performData) external override whenNotPaused {
        (bytes32 eventId, address athlete, uint256 amount) = abi.decode(performData, (bytes32, address, uint256));
        require(pending[eventId], "Not pending");

        nilRights.executePayout(eventId, athlete, amount);
        pending[eventId] = false;
        emit UpkeepPerformed(eventId, athlete, amount);
    }

    function encodeData(bytes32 eventId, address athlete, uint256 amount) external pure returns (bytes memory) {
        return abi.encode(eventId, athlete, amount);
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
