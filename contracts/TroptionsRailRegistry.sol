// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./TroptionsAccessControl.sol";
import "./BridgePayload.sol";

/**
 * @title TroptionsRailRegistry
 * @notice The brain of the Troptions 9-rail system. Registers and manages active rails with their chain selectors, bridge and primary contracts.
 * @dev Uses TroptionsAccessControl for operator permissions. Supports BridgePayload for rail metadata. Focus on practical core rails (XRPL, Solana, Base, Avalanche, Stacks, Chainlink + Bitcoin/Stellar).
 *      Senior: Full NatSpec, events, guards via modifier, pausable patterns if extended.
 */
contract TroptionsRailRegistry {
    TroptionsAccessControl public accessControl;

    struct Rail {
        string name;
        uint64 chainSelector;
        bool active;
        address bridgeContract;
        address primaryContract;
    }

    mapping(string => Rail) public rails;
    string[] public railNames;

    event RailAdded(string name, uint64 chainSelector, address bridgeContract, address primaryContract);
    event RailActivated(string name, bool status);
    event RailUpdated(string name, BridgePayload metadata); // Optional for payload-based updates

    modifier onlyOperator() {
        require(accessControl.isOperator(msg.sender) || msg.sender == accessControl.owner(), "Not authorized operator");
        _;
    }

    constructor(address _accessControl) {
        accessControl = TroptionsAccessControl(_accessControl);
    }

    function addRail(
        string calldata name,
        uint64 chainSelector,
        address bridgeContract,
        address primaryContract
    ) external onlyOperator {
        require(bytes(name).length > 0, "Name required");
        rails[name] = Rail({
            name: name,
            chainSelector: chainSelector,
            active: false,
            bridgeContract: bridgeContract,
            primaryContract: primaryContract
        });
        railNames.push(name);
        emit RailAdded(name, chainSelector, bridgeContract, primaryContract);
    }

    function toggleRail(string calldata name, bool status) external onlyOperator {
        require(bytes(rails[name].name).length > 0, "Rail does not exist");
        rails[name].active = status;
        emit RailActivated(name, status);
    }

    function updateRailMetadata(string calldata name, BridgePayload calldata metadata) external onlyOperator {
        // Example: Use payload to update additional data if needed
        emit RailUpdated(name, metadata);
    }

    function getActiveRails() external view returns (string[] memory) {
        uint256 count = 0;
        for (uint256 i = 0; i < railNames.length; i++) {
            if (rails[railNames[i]].active) count++;
        }
        string[] memory active = new string[](count);
        uint256 j = 0;
        for (uint256 i = 0; i < railNames.length; i++) {
            string memory r = railNames[i];
            if (rails[r].active) {
                active[j] = r;
                j++;
            }
        }
        return active;
    }

    function getRail(string calldata name) external view returns (Rail memory) {
        return rails[name];
    }
}
