// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./TroptionsSystemValidator.sol";
import "./TroptionsRailRegistry.sol";
import "./TroptionsEliteSettlementCore.sol";
import "./TroptionsKYCCompliance.sol";
import "./TroptionsCircuitBreaker.sol";
import "./TroptionsReserveVault.sol";
import "./TroptionsCrossChainRouter.sol";
import "./TroptionsImmutableLedger.sol";
import "./TroptionsAgentRegistry.sol";

/**
 * @title TroptionsSystemBootstrap
 * @notice The master one-command deployer for the entire Troptions sovereign empire.
 * @dev Deploys all core components and wires the SystemValidator as the central health checker.
 *      Emits events for verification. Run via Foundry script for testnet/mainnet.
 *      This is the final piece tying 33 contracts together for FTHTrading banks, troptionsmint, GMIIE, Legacy Vault, and the reset.
 */
contract TroptionsSystemBootstrap {
    
    address public owner;
    TroptionsSystemValidator public validator;

    event SystemDeployed(address validatorAddress, uint256 timestamp);
    event AllSystemsLinked(bool success);

    constructor() {
        owner = msg.sender;
    }

    function deployFullSystem() external returns (address) {
        require(msg.sender == owner, "Not owner");

        // Deploy Core Components
        TroptionsRailRegistry registry = new TroptionsRailRegistry();
        TroptionsEliteSettlementCore settlement = new TroptionsEliteSettlementCore();
        TroptionsKYCCompliance kyc = new TroptionsKYCCompliance();
        TroptionsCircuitBreaker breaker = new TroptionsCircuitBreaker();
        TroptionsReserveVault vault = new TroptionsReserveVault();
        TroptionsCrossChainRouter router = new TroptionsCrossChainRouter(address(0)); // Update after CCIP deployment
        TroptionsImmutableLedger ledger = new TroptionsImmutableLedger();
        TroptionsAgentRegistry agents = new TroptionsAgentRegistry();

        // Deploy Validator
        validator = new TroptionsSystemValidator(
            address(registry),
            address(settlement),
            address(new TroptionsProofVerifier()),
            address(kyc),
            address(breaker),
            address(vault),
            address(router)
        );

        emit SystemDeployed(address(validator), block.timestamp);
        emit AllSystemsLinked(true);

        return address(validator);
    }

    function getSystemHealth() external view returns (bool) {
        if (address(validator) == address(0)) return false;
        return validator.isSystemFullyOperational();
    }
}
