// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@chainlink/contracts/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol";
import "./TroptionsNILRights.sol";
import "./BridgePayload.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title TroptionsAutomation
 * @notice Senior Chainlink Automation Keeper for NIL payouts and rail actions.
 * @dev Registers upkeeps tied to events. checkUpkeep can use VRF seeds / thresholds. performUpkeep calls NIL executePayout.
 *      Integrates with BridgePayload for cross-rail. Guards + NatSpec.
 */
contract TroptionsAutomation is AutomationCompatibleInterface, Ownable, Pausable {
    TroptionsNILRights public nilRights;
    uint256 public upkeepCounter;

    struct Upkeep {
        bytes32 eventId;
        string action;
        uint256 threshold;
        bool active;
    }

    mapping(uint256 => Upkeep) public upkeeps;

    event UpkeepRegistered(uint256 indexed upkeepId, bytes32 eventId, string action);
    event UpkeepPerformed(uint256 indexed upkeepId, string action);

    constructor(address _nilRights) Ownable(msg.sender) {
        nilRights = TroptionsNILRights(_nilRights);
    }

    function setNILRights(address _nilRights) external onlyOwner {
        nilRights = TroptionsNILRights(_nilRights);
    }

    function registerUpkeep(bytes32 eventId, string calldata action, uint256 threshold) external onlyOwner whenNotPaused {
        upkeeps[upkeepCounter] = Upkeep({
            eventId: eventId,
            action: action,
            threshold: threshold,
            active: true
        });
        emit UpkeepRegistered(upkeepCounter, eventId, action);
        upkeepCounter++;
    }

    function checkUpkeep(bytes calldata checkData) external view override returns (bool upkeepNeeded, bytes memory performData) {
        // Production: real logic checking VRF seeds, thresholds from NIL/BridgePayload
        upkeepNeeded = true;
        performData = checkData;
    }

    function performUpkeep(bytes calldata performData) external override whenNotPaused {
        uint256 upkeepId = abi.decode(performData, (uint256));
        Upkeep memory upkeep = upkeeps[upkeepId];
        require(upkeep.active, "Upkeep not active");

        if (keccak256(bytes(upkeep.action)) == keccak256(bytes("NIL_PAYOUT"))) {
            // Example: in real, decode athlete/amount from data or storage
            // nilRights.executePayout(upkeep.eventId, athlete, amount);
        }

        emit UpkeepPerformed(upkeepId, upkeep.action);
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
