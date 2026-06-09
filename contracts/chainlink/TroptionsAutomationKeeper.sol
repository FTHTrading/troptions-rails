// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

 import "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";
import "../avalanche/TroptionsNILRights.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";

/**
 * @title TroptionsAutomationKeeper
 * @notice Senior Chainlink Automation template for triggering NIL performance payouts.
 * @dev Implements AutomationCompatibleInterface (checkUpkeep / performUpkeep).
 *      Can be registered with Chainlink Automation UI / API.
 *      Works with the core TroptionsNILRights after VRF seed is available.
 *      Configurable, pausable, ownable for production management.
 * @custom:security-contact security@troptions.example
 */
contract TroptionsAutomationKeeper is AutomationCompatibleInterface, Ownable, Pausable {
    TroptionsNILRights public nilRights;

    // Simple pending registry (prod would use a more scalable queue or log-based discovery)
    mapping(bytes32 => bool) public pendingPayouts;

    uint256 public maxPerformGas = 500000; // Configurable

    event UpkeepPerformed(bytes32 indexed eventId, address athlete, uint256 amount);
    event EventRegistered(bytes32 indexed eventId);

    constructor(address _nilRights) Ownable(msg.sender) {
        nilRights = TroptionsNILRights(_nilRights);
    }

    function setNILRights(address _nilRights) external onlyOwner {
        nilRights = TroptionsNILRights(_nilRights);
    }

    function setMaxPerformGas(uint256 _gas) external onlyOwner {
        maxPerformGas = _gas;
    }

    function registerForAutomation(bytes32 eventId) external whenNotPaused {
        pendingPayouts[eventId] = true;
        emit EventRegistered(eventId);
    }

    function checkUpkeep(bytes calldata checkData)
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        // Off-chain keeper logic (or custom checkData) supplies the candidate eventId + athlete + amount.
        // In production this can scan recent NILMinted + VRF fulfilled events.
        // For this template we return false by default; real registration feeds performData.
        upkeepNeeded = false;
        performData = checkData; // echo for keeper to construct
    }

    function performUpkeep(bytes calldata performData)
        external
        override
        whenNotPaused
    {
        (bytes32 eventId, address athlete, uint256 amount) = abi.decode(performData, (bytes32, address, uint256));

        require(pendingPayouts[eventId], "Not registered");

        nilRights.executePayout(eventId, athlete, amount);

        pendingPayouts[eventId] = false;
        emit UpkeepPerformed(eventId, athlete, amount);
    }

    function encodePerformData(bytes32 eventId, address athlete, uint256 amount)
        external
        pure
        returns (bytes memory)
    {
        return abi.encode(eventId, athlete, amount);
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
