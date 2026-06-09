// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import "./../avalanche/TroptionsNILRights.sol";

/**
 * @title TroptionsNILAutomation
 * @notice Chainlink Automation compatible Keeper for NIL payouts.
 * Checks for fulfilled VRF seeds on pending NIL events and triggers executePayout.
 * This is the "performance-based payout (triggered by Chainlink Automation)" piece.
 * Deploy on Avalanche (or target chain), register with Chainlink Automation.
 */
contract TroptionsNILAutomation is AutomationCompatibleInterface {
    TroptionsNILRights public nilRights;
    // Simple registry of events that have rights minted and are awaiting payout trigger
    mapping(bytes32 => bool) public pendingPayouts;

    event UpkeepPerformed(bytes32 indexed eventId, address athlete, uint256 amount);

    constructor(address _nilRights) {
        nilRights = TroptionsNILRights(_nilRights);
    }

    function setNILRights(address _nilRights) external {
        // In prod add onlyOwner or governance
        nilRights = TroptionsNILRights(_nilRights);
    }

    /**
     * @notice Register an event for automated payout (call after mintNILBundle or from VRF callback hook).
     */
    function registerForAutomation(bytes32 eventId) external {
        pendingPayouts[eventId] = true;
    }

    function checkUpkeep(bytes calldata /* checkData */) external view override returns (bool upkeepNeeded, bytes memory performData) {
        // In a real impl this would iterate a list or use an index of pending events.
        // For starter/demo we expose a simple flag; prod would use a queue or event log scan.
        // Keeper nodes can be configured with custom checkData containing candidate eventId.
        // Here we return a placeholder; real registration would feed specific eventIds.
        // Simplified: assume caller/keeper logic supplies the event via performData construction off-chain.
        upkeepNeeded = false; // off-chain keeper logic decides based on VRF fulfillment + pendingPayouts
        performData = bytes("");
    }

    function performUpkeep(bytes calldata performData) external override {
        // Expected performData = abi.encode(eventId, athlete, amount)
        (bytes32 eventId, address athlete, uint256 amount) = abi.decode(performData, (bytes32, address, uint256));

        require(pendingPayouts[eventId], "Not registered for automation");

        // The NIL contract will verify VRF seed internally via getEventRandomSeed
        nilRights.executePayout(eventId, athlete, amount);

        pendingPayouts[eventId] = false;
        emit UpkeepPerformed(eventId, athlete, amount);
    }

    // Convenience for off-chain keeper registration simulation
    function encodePerformData(bytes32 eventId, address athlete, uint256 amount) external pure returns (bytes memory) {
        return abi.encode(eventId, athlete, amount);
    }
}
