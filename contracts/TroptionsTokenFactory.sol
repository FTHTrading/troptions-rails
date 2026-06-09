// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./TroptionsRWAToken.sol";
import "./BridgePayload.sol";

/**
 * @title TroptionsTokenFactory
 * @notice Factory for dynamic deployment of TroptionsRWAToken instances per asset (NIL, RWA).
 * @dev Uses BridgePayload assetId. Senior: NatSpec, events.
 */
contract TroptionsTokenFactory {
    address public owner;
    mapping(bytes32 => address) public deployedTokens;

    event TokenDeployed(bytes32 indexed assetId, address tokenAddress, string name, BridgePayload payload);

    constructor() {
        owner = msg.sender;
    }

    function deployRWAToken(
        bytes32 assetId,
        string calldata name,
        string calldata symbol,
        BridgePayload calldata payload
    ) external returns (address) {
        require(msg.sender == owner, "Not owner");
        require(deployedTokens[assetId] == address(0), "Token already deployed");

        TroptionsRWAToken newToken = new TroptionsRWAToken(name, symbol);
        deployedTokens[assetId] = address(newToken);

        emit TokenDeployed(assetId, address(newToken), name, payload);
        return address(newToken);
    }

    function getToken(bytes32 assetId) external view returns (address) {
        return deployedTokens[assetId];
    }
}
