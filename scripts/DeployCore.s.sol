// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Script.sol";
import "contracts/TroptionsGovernanceTimelock.sol";
import "contracts/TroptionsAgentRegistry.sol";
import "contracts/TroptionsCrossChainRouter.sol";
import "contracts/TroptionsSettlementHub.sol";
import "contracts/TroptionsStablecoinGateway.sol";

/**
 * @notice Core institutional contracts deploy script (Fuji / Sepolia / Besu test).
 * Usage (example Fuji):
 *   export FUJI_RPC=... 
 *   export PRIVATE_KEY=0x...
 *   forge script scripts/DeployCore.s.sol --rpc-url $FUJI_RPC --broadcast --verify -vv
 *
 * Update README + investor with returned addresses + Snowtrace links.
 */
contract DeployCore is Script {
    function run() external {
        uint256 pk = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(pk);

        TroptionsGovernanceTimelock timelock = new TroptionsGovernanceTimelock();
        console2.log("Timelock:", address(timelock));

        TroptionsAgentRegistry registry = new TroptionsAgentRegistry();
        console2.log("AgentRegistry:", address(registry));

        // Router + Hub + Gateway (stubs ready for real config post)
        TroptionsCrossChainRouter router = new TroptionsCrossChainRouter();
        console2.log("CrossChainRouter:", address(router));

        TroptionsSettlementHub hub = new TroptionsSettlementHub();
        console2.log("SettlementHub:", address(hub));

        TroptionsStablecoinGateway gateway = new TroptionsStablecoinGateway();
        console2.log("StablecoinGateway:", address(gateway));

        // TODO: wire owner, register rails, set CCIP router addr etc.
        // After: forge script ... --sig "setRouter(address)" ...

        vm.stopBroadcast();

        console2.log("\n=== DEPLOY COMPLETE ===");
        console2.log("Update README with Snowtrace/Solscan links for these addresses.");
        console2.log("Next: run E2E harness + add real testnet hashes.");
    }
}
