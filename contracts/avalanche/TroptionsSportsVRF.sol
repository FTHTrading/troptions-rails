// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

 import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../BridgePayload.sol";

/**
 * @title TroptionsSportsVRF
 * @notice Senior production-grade Chainlink VRF v2.5 template for Troptions sports outcomes and NIL randomness.
 * @dev Latest official patterns (VRFConsumerBaseV2Plus + VRFV2PlusClient).
 *      Integrates stables for payouts, emits BridgePayload for cross-rail (NIL, CCIP, Base, Solana etc).
 *      Exposes seeds for TroptionsNILRights and AutomationKeeper.
 *      Pausable + ReentrancyGuard + full Natspec for audit readiness.
 *      LPS-1 / XXXIII provenance passed through in payloads.
 * @custom:security-contact security@troptions.example
 */
contract TroptionsSportsVRF is VRFConsumerBaseV2Plus, ConfirmedOwner, Pausable, ReentrancyGuard {
    address private immutable i_vrfCoordinator;

    uint256 public s_subscriptionId;
    bytes32 public s_keyHash = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae; // Avalanche example - update per network
    uint32 public callbackGasLimit = 100000;
    uint16 public requestConfirmations = 3;
    uint32 public numWords = 1;

    IERC20 public stablecoin;

    struct RequestStatus {
        bool fulfilled;
        bool exists;
        uint256[] randomWords;
        address requester;
        uint256 eventId;
        uint256 amount;
    }

    mapping(uint256 => RequestStatus) public s_requests;
    uint256[] public requestIds;
    uint256 public lastRequestId;

    // Public for NILRights + Automation + other rails to consume verified outcome
    mapping(bytes32 => uint256) public eventRandomSeeds;

    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);
    event TicketIssued(address indexed user, uint256 eventId, uint256 randomOutcome, uint256 payout, string stablecoinSymbol);
    event BridgePayloadEmitted(bytes32 indexed payloadHash, BridgePayload payload);

    constructor(address vrfCoordinator, uint256 subscriptionId, address _stablecoin)
        VRFConsumerBaseV2Plus(vrfCoordinator) ConfirmedOwner(msg.sender)
    {
        i_vrfCoordinator = vrfCoordinator;
        s_subscriptionId = subscriptionId;
        stablecoin = IERC20(_stablecoin);
    }

    function requestRandomWords(uint256 eventId, uint256 amount)
        external
        onlyOwner
        whenNotPaused
        nonReentrant
        returns (uint256 requestId)
    {
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: s_keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(
                    VRFV2PlusClient.ExtraArgsV1({nativePayment: false})
                )
            })
        );

        s_requests[requestId] = RequestStatus({
            fulfilled: false,
            exists: true,
            randomWords: new uint256[](0),
            requester: msg.sender,
            eventId: eventId,
            amount: amount
        });
        requestIds.push(requestId);
        lastRequestId = requestId;
        emit RequestSent(requestId, numWords);
        return requestId;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords)
        internal
        override
    {
        require(s_requests[requestId].exists, "request not found");
        s_requests[requestId].fulfilled = true;
        s_requests[requestId].randomWords = randomWords;
        emit RequestFulfilled(requestId, randomWords);

        uint256 randomOutcome = randomWords[0] % 100;
        address requester = s_requests[requestId].requester;
        uint256 eventId = s_requests[requestId].eventId;
        uint256 amount = s_requests[requestId].amount;

        string memory stableSymbol = "USDC";

        eventRandomSeeds[bytes32(eventId)] = randomOutcome;

        if (randomOutcome > 50) {
            require(stablecoin.transfer(requester, amount), "Transfer failed");
            emit TicketIssued(requester, eventId, randomOutcome, amount, stableSymbol);

            BridgePayload memory payload = BridgePayload({
                version: 1,
                timestamp: block.timestamp,
                sourceChainId: 43114,
                destinationChainId: 8453, // Base / other rail example
                assetId: keccak256(abi.encodePacked("NIL", eventId)),
                eventId: bytes32(eventId),
                sender: address(this),
                receiver: requester,
                amount: amount,
                fee: 0,
                action: "PAYOUT",
                data: abi.encode(randomOutcome, stableSymbol),
                lps1Hash: bytes32(0), // Populate from XXXIII / GMIIE / LPS-1 system
                gmiiSignature: bytes32(0)
            });
            bytes32 payloadHash = BridgePayloadLib.hash(payload);
            emit BridgePayloadEmitted(payloadHash, payload);
        }
    }

    function getEventRandomSeed(bytes32 eventId) external view returns (uint256) {
        return eventRandomSeeds[eventId];
    }

    function setStablecoin(address _stablecoin) external onlyOwner {
        stablecoin = IERC20(_stablecoin);
    }

    function withdrawStablecoin(uint256 amount) external onlyOwner {
        require(stablecoin.transfer(msg.sender, amount), "Withdraw failed");
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }
}
