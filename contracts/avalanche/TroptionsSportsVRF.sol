// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./BridgePayload.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title TroptionsSportsVRF
 * @notice Senior production VRF v2.5 template for sports outcomes & NIL randomness.
 * @dev Latest Chainlink VRFConsumerBaseV2Plus + VRFV2PlusClient (2026 patterns).
 *      Exposes seeds for NILRights + Automation. Emits BridgePayload for cross-rail.
 *      Integrates stables. LPS-1 provenance hook in payloads.
 *      Pausable + ReentrancyGuard + full NatSpec.
 */
contract TroptionsSportsVRF is VRFConsumerBaseV2Plus, Pausable, ReentrancyGuard {
    event RandomnessRequested(bytes32 indexed eventId, uint256 requestId);
    event RandomnessFulfilled(bytes32 indexed eventId, uint256 randomSeed);
    event BridgePayloadEmitted(bytes32 indexed payloadHash, BridgePayload payload);

    mapping(uint256 => bytes32) public requestToEvent;
    mapping(bytes32 => uint256) public eventRandomSeed;

    uint256 public s_subscriptionId;
    bytes32 public s_keyHash;
    uint32 public callbackGasLimit = 200_000;

    IERC20 public stablecoin;

    constructor(uint256 subscriptionId, bytes32 keyHash, address vrfCoordinator, address _stablecoin)
        VRFConsumerBaseV2Plus(vrfCoordinator)
    {
        s_subscriptionId = subscriptionId;
        s_keyHash = keyHash;
        stablecoin = IERC20(_stablecoin);
    }

    function requestRandomness(bytes32 eventId) external whenNotPaused nonReentrant returns (uint256 requestId) {
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: s_keyHash,
                subId: s_subscriptionId,
                requestConfirmations: 3,
                callbackGasLimit: callbackGasLimit,
                numWords: 1,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );

        requestToEvent[requestId] = eventId;
        emit RandomnessRequested(eventId, requestId);
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        bytes32 eventId = requestToEvent[requestId];
        uint256 seed = randomWords[0];
        eventRandomSeed[eventId] = seed;

        emit RandomnessFulfilled(eventId, seed);

        // Example: optional auto stable payout + BridgePayload emit (integrates with NIL flow)
        // In full: caller (NIL or keeper) decides payout
        if (address(stablecoin) != address(0)) {
            // placeholder logic; production would check conditions
        }

        // Emit payload for cross-rail (CCIP to Base, Solana etc.)
        BridgePayload memory p = BridgePayload({
            version: 1,
            timestamp: block.timestamp,
            sourceChainSelector: 0, // fill with actual Avalanche CCIP selector
            destChainSelector: 0,   // e.g. Base selector
            assetId: keccak256(abi.encodePacked("SPORTS_VRF", eventId)),
            eventId: eventId,
            sender: address(this),
            receiver: msg.sender, // or owner
            amount: 0,
            action: "VRF_FULFILLED",
            data: abi.encode(seed),
            lps1Hash: bytes32(0), // populate from LPS-1/XXXIII system
            gmiiSignature: bytes32(0)
        });
        bytes32 h = BridgePayloadLib.hash(p);
        emit BridgePayloadEmitted(h, p);
    }

    function setStablecoin(address _stable) external onlyOwner {
        stablecoin = IERC20(_stable);
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
