// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./TroptionsRailRegistry.sol";
import "./TroptionsEliteSettlementCore.sol";
import "./TroptionsProofVerifier.sol";
import "./TroptionsKYCCompliance.sol";
import "./TroptionsCircuitBreaker.sol";
import "./TroptionsReserveVault.sol";
import "./TroptionsCrossChainRouter.sol";
import "./TroptionsSystemValidator.sol";
import "./TroptionsEmergencyGovernor.sol";
import "./TroptionsImmutableLedger.sol";

/**
 * @title TroptionsSystemBootstrap
 * @notice One-shot deployment and wiring contract for the full sovereign system.
 * @dev Deploys and interconnects the core components + the new Validator, EmergencyGovernor, and ImmutableLedger.
 *      Run via Foundry script for testnet/mainnet. Exposes the SystemValidator for health checks.
 *      Perfect for investors and production setup.
 */
contract TroptionsSystemBootstrap {
    TroptionsRailRegistry public railRegistry;
    TroptionsEliteSettlementCore public settlementCore;
    TroptionsProofVerifier public proofVerifier;
    TroptionsKYCCompliance public kycCompliance;
    TroptionsCircuitBreaker public circuitBreaker;
    TroptionsReserveVault public reserveVault;
    TroptionsCrossChainRouter public router;
    TroptionsSystemValidator public systemValidator;
    TroptionsEmergencyGovernor public emergencyGovernor;
    TroptionsImmutableLedger public immutableLedger;

    event SystemBootstrapped(address indexed validator, address indexed emergencyGovernor, address indexed ledger);

    function bootstrap(
        address initialSecurityCouncil,
        address initialRouterCCIP
    ) external returns (address) {
        // Deploy core components (simplified - in real use pass existing or full deploy logic)
        railRegistry = new TroptionsRailRegistry(address(0)); // wire access later
        settlementCore = new TroptionsEliteSettlementCore();
        proofVerifier = new TroptionsProofVerifier();
        kycCompliance = new TroptionsKYCCompliance();
        circuitBreaker = new TroptionsCircuitBreaker();
        reserveVault = new TroptionsReserveVault();
        router = new TroptionsCrossChainRouter(initialRouterCCIP);

        // New governance & assurance layer
        emergencyGovernor = new TroptionsEmergencyGovernor(initialSecurityCouncil);
        immutableLedger = new TroptionsImmutableLedger();

        // The master validator wiring everything
        systemValidator = new TroptionsSystemValidator(
            address(railRegistry),
            address(settlementCore),
            address(proofVerifier),
            address(kycCompliance),
            address(circuitBreaker),
            address(reserveVault),
            address(router)
        );

        emit SystemBootstrapped(address(systemValidator), address(emergencyGovernor), address(immutableLedger));

        return address(systemValidator);
    }
}
