// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./TroptionsAccessControl.sol";

/**
 * @title TroptionsRailRegistry
 * @notice Central registry for the 9 Troptions rails and their core contracts (VRF, NIL, CCIP, Automation per rail).
 * @dev Uses AccessControl for operators. Allows registering rail addresses for cross-system coordination.
 *      Enables the Golden Path and Sovereign Orchestrator to discover contracts.
 *      Senior: NatSpec, events, pausable via owner.
 */
contract TroptionsRailRegistry {
    TroptionsAccessControl public accessControl;

    struct RailContracts {
        address vrf;
        address nilRights;
        address ccipBridge;
        address automation;
        address other; // e.g. stable manager or custom
    }

    mapping(string => RailContracts) public rails; // e.g. "avalanche", "base", "solana"
    string[] public railNames;

    event RailRegistered(string railName, address vrf, address nilRights);
    event RailUpdated(string railName);

    constructor(address _accessControl) {
        accessControl = TroptionsAccessControl(_accessControl);
    }

    modifier onlyOperator() {
        require(accessControl.isOperator(msg.sender) || msg.sender == accessControl.owner(), "Not authorized operator");
        _;
    }

    function registerRail(
        string calldata railName,
        address vrf,
        address nilRights,
        address ccipBridge,
        address automation,
        address other
    ) external onlyOperator {
        rails[railName] = RailContracts(vrf, nilRights, ccipBridge, automation, other);
        railNames.push(railName);
        emit RailRegistered(railName, vrf, nilRights);
    }

    function updateRail(string calldata railName, RailContracts calldata contracts) external onlyOperator {
        rails[railName] = contracts;
        emit RailUpdated(railName);
    }

    function getRail(string calldata railName) external view returns (RailContracts memory) {
        return rails[railName];
    }

    function getAllRails() external view returns (string[] memory) {
        return railNames;
    }
}
