// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "forge-std/Test.sol";
import "contracts/TroptionsAgentRegistry.sol";
import "contracts/BridgePayload.sol";

contract TestAgentRegistry is Test {
    TroptionsAgentRegistry reg;

    function setUp() public {
        reg = new TroptionsAgentRegistry();
    }

    function testRegisterAndCheck() public {
        bytes32 id = keccak256("agent-1");
        address agent = address(0xA11CE);
        BridgePayload memory p;
        reg.registerAgent(id, agent, p);
        assertTrue(reg.isAgentAuthorized(agent));
        assertEq(reg.agentById(id), agent);
    }

    function testRevoke() public {
        bytes32 id = keccak256("agent-2");
        address agent = address(0xB0B);
        BridgePayload memory p;
        reg.registerAgent(id, agent, p);
        reg.revokeAgent(id);
        assertFalse(reg.isAgentAuthorized(agent));
    }
}
