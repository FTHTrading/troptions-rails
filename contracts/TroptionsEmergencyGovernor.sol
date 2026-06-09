// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/**
 * @title TroptionsEmergencyGovernor
 * @notice Emergency pause and crisis mode controller for the entire Troptions system.
 * @dev Allows security council or owner to declare/resolve emergency mode.
 *      Used by CircuitBreaker, Router, Settlement, etc. to halt operations safely.
 *      Critical for institutional/CBDC risk management and the reset.
 */
contract TroptionsEmergencyGovernor {
    address public owner;
    address public securityCouncil;
    
    bool public emergencyMode;
    uint256 public emergencyActivatedAt;

    event EmergencyDeclared(string reason);
    event EmergencyResolved(string reason);

    modifier onlyEmergencyCouncil() {
        require(msg.sender == securityCouncil || msg.sender == owner, "Not authorized");
        _;
    }

    constructor(address _securityCouncil) {
        owner = msg.sender;
        securityCouncil = _securityCouncil;
    }

    function declareEmergency(string calldata reason) external onlyEmergencyCouncil {
        emergencyMode = true;
        emergencyActivatedAt = block.timestamp;
        emit EmergencyDeclared(reason);
    }

    function resolveEmergency(string calldata reason) external onlyEmergencyCouncil {
        emergencyMode = false;
        emit EmergencyResolved(reason);
    }

    function isInEmergencyMode() external view returns (bool) {
        return emergencyMode;
    }
}
