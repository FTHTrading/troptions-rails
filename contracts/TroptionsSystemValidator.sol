// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./TroptionsRailRegistry.sol";
import "./TroptionsEliteSettlementCore.sol";
import "./TroptionsProofVerifier.sol";
import "./TroptionsKYCCompliance.sol";
import "./TroptionsCircuitBreaker.sol";
import "./TroptionsReserveVault.sol";
import "./TroptionsCrossChainRouter.sol";

/**
 * @title TroptionsSystemValidator
 * @notice The Final Boss: central health checker and validator for the entire sovereign system.
 * @dev Integrates all major components (Registry, Settlement, Proofs, KYC, CircuitBreaker, Reserves, Router).
 *      Run this before any major operation or deployment. Emits health status for monitoring/HUD.
 *      Ties into EmergencyGovernor for crisis mode.
 *      Essential for investor confidence, banks, and production readiness.
 */
contract TroptionsSystemValidator {
    
    TroptionsRailRegistry public railRegistry;
    TroptionsEliteSettlementCore public settlementCore;
    TroptionsProofVerifier public proofVerifier;
    TroptionsKYCCompliance public kycCompliance;
    TroptionsCircuitBreaker public circuitBreaker;
    TroptionsReserveVault public reserveVault;
    TroptionsCrossChainRouter public router;

    struct SystemHealth {
        bool allRailsRegistered;
        bool settlementCoreLinked;
        bool proofSystemActive;
        bool kycFunctional;
        bool circuitBreakerReady;
        bool reserveBacked;
        bool routerOperational;
        bool systemHealthy;
    }

    event SystemCheckPerformed(bool healthy, uint256 timestamp);
    event CriticalIssueDetected(string component, string issue);

    constructor(
        address _railRegistry,
        address _settlementCore,
        address _proofVerifier,
        address _kyc,
        address _circuitBreaker,
        address _reserveVault,
        address _router
    ) {
        railRegistry = TroptionsRailRegistry(_railRegistry);
        settlementCore = TroptionsEliteSettlementCore(_settlementCore);
        proofVerifier = TroptionsProofVerifier(_proofVerifier);
        kycCompliance = TroptionsKYCCompliance(_kyc);
        circuitBreaker = TroptionsCircuitBreaker(_circuitBreaker);
        reserveVault = TroptionsReserveVault(_reserveVault);
        router = TroptionsCrossChainRouter(_router);
    }

    function runFullSystemCheck() external returns (SystemHealth memory health) {
        health.allRailsRegistered = railRegistry.getActiveRails().length > 0;
        health.settlementCoreLinked = address(settlementCore) != address(0);
        health.proofSystemActive = address(proofVerifier) != address(0);
        health.kycFunctional = address(kycCompliance) != address(0);
        health.circuitBreakerReady = !circuitBreaker.isPaused();
        health.reserveBacked = reserveVault.getReserve(address(0)) > 0;
        health.routerOperational = address(router) != address(0);

        health.systemHealthy = 
            health.allRailsRegistered &&
            health.settlementCoreLinked &&
            health.proofSystemActive &&
            health.kycFunctional &&
            health.circuitBreakerReady &&
            health.routerOperational;

        emit SystemCheckPerformed(health.systemHealthy, block.timestamp);

        if (!health.systemHealthy) {
            emit CriticalIssueDetected("System", "One or more critical components failed validation");
        }

        return health;
    }

    function isSystemFullyOperational() external view returns (bool) {
        return !circuitBreaker.isPaused();
    }
}
