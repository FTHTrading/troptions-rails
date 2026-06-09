// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import "../contracts/TroptionsSystemBootstrap.sol";

/**
 * @notice Final bootstrap script: deploys and interconnects the entire 31-contract Troptions system.
 * Usage (Fuji example):
 *   export FUJI_RPC=...
 *   export PRIVATE_KEY=0x...
 *   export SECURITY_COUNCIL=0xYourCouncil
 *   forge script scripts/SystemBootstrap.s.sol --rpc-url $FUJI_RPC --broadcast --verify -vv
 *
 * After: run `SystemValidator.runFullSystemCheck()` to verify health.
 * Update README with returned Validator address for investors.
 */
contract SystemBootstrap is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        address securityCouncil = vm.envAddress("SECURITY_COUNCIL");
        address initialRouterCCIP = address(0); // fill with real CCIP router on target chain

        vm.startBroadcast(pk);

        TroptionsSystemBootstrap bootstrapper = new TroptionsSystemBootstrap();
        address validator = bootstrapper.bootstrap(securityCouncil, initialRouterCCIP);

        console2.log("=== TROPTIONS SYSTEM BOOTSTRAPPED ===");
        console2.log("SystemValidator:", validator);
        console2.log("Run full health check on the Validator for production readiness.");
        console2.log("EmergencyGovernor and ImmutableLedger also deployed and wired.");

        vm.stopBroadcast();
    }
}
