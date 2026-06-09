// Chainlink integration example (partial - VRF/CCIP/Automation/PoR).
// Real consumer for oracles across rails.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";

contract ChainlinkConsumer {
    VRFCoordinatorV2Interface COORDINATOR;

    uint64 s_subscriptionId;
    bytes32 keyHash;

    function requestRandomWords() external returns (uint256 requestId) {
        // VRF for sports outcomes, stablecoin randomness
        requestId = COORDINATOR.requestRandomWords(
            keyHash,
            s_subscriptionId,
            3,
            200000,
            1
        );
        return requestId;
    }

    // CCIP / Automation stubs for cross-rail stablecoin messages
}
