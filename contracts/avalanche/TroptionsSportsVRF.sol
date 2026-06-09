// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {ConfirmedOwner} from "@chainlink/contracts/src/v0.8/shared/access/ConfirmedOwner.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Import or inline the BridgePayload for cross-chain
struct BridgePayload {
    uint256 version;
    uint256 timestamp;
    uint256 sourceChainId;
    uint256 destinationChainId;
    bytes32 assetId;
    bytes32 eventId;
    address sender;
    address receiver;
    uint256 amount;
    uint256 fee;
    string action;
    bytes data;
    bytes32 lps1Hash;
    bytes32 gmiiSignature;
}

library BridgePayloadLib {
    function hash(BridgePayload memory payload) internal pure returns (bytes32) {
        return keccak256(abi.encode(
            payload.version,
            payload.timestamp,
            payload.sourceChainId,
            payload.destinationChainId,
            payload.assetId,
            payload.eventId,
            payload.sender,
            payload.receiver,
            payload.amount,
            payload.fee,
            payload.action,
            payload.data,
            payload.lps1Hash,
            payload.gmiiSignature
        ));
    }
}

/**
 * @title TroptionsSportsVRF
 * @notice Avalanche rail for sports VRF and NIL payouts
 * @dev Uses Chainlink VRF v2.5 for random sports outcomes. Integrates stablecoins and emits BridgePayload for cross-rail.
 * For Avalanche Fuji testnet or mainnet. Update coordinator address accordingly.
 */
contract TroptionsSportsVRF is VRFConsumerBaseV2Plus, ConfirmedOwner {
    // Avalanche VRF Coordinator (update for mainnet: check docs.chain.link)
    // Fuji: 0x5C210eF41CD1a72de73bF76eC39637bB0d3d7BEE (example, verify)
    address private immutable i_vrfCoordinator;

    uint256 public s_subscriptionId;
    bytes32 public s_keyHash = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae; // Avalanche keyhash example
    uint32 public callbackGasLimit = 100000;
    uint16 public requestConfirmations = 3;
    uint32 public numWords = 1;

    IERC20 public stablecoin; // e.g. USDC on Avalanche

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

    event RequestSent(uint256 requestId, uint32 numWords);
    event RequestFulfilled(uint256 requestId, uint256[] randomWords);
    event TicketIssued(address indexed user, uint256 eventId, uint256 randomOutcome, uint256 payout, string stablecoinSymbol);
    event BridgePayloadEmitted(bytes32 indexed payloadHash, BridgePayload payload);

    constructor(
        address vrfCoordinator,
        uint256 subscriptionId,
        address _stablecoin
    ) VRFConsumerBaseV2Plus(vrfCoordinator) ConfirmedOwner(msg.sender) {
        i_vrfCoordinator = vrfCoordinator;
        s_subscriptionId = subscriptionId;
        stablecoin = IERC20(_stablecoin);
    }

    function requestRandomWords(uint256 eventId, uint256 amount) external onlyOwner returns (uint256 requestId) {
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

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        require(s_requests[requestId].exists, "request not found");
        s_requests[requestId].fulfilled = true;
        s_requests[requestId].randomWords = randomWords;
        emit RequestFulfilled(requestId, randomWords);

        uint256 randomOutcome = randomWords[0] % 100;
        address requester = s_requests[requestId].requester;
        uint256 eventId = s_requests[requestId].eventId;
        uint256 amount = s_requests[requestId].amount;

        string memory stableSymbol = "USDC"; // or dynamic

        if (randomOutcome > 50) {
            // Payout in stablecoin
            require(stablecoin.transfer(requester, amount), "Transfer failed");
            emit TicketIssued(requester, eventId, randomOutcome, amount, stableSymbol);

            // Emit BridgePayload for cross-chain to other rails (e.g. to Base for liquidity, XRPL for trading)
            BridgePayload memory payload = BridgePayload({
                version: 1,
                timestamp: block.timestamp,
                sourceChainId: 43114, // Avalanche mainnet
                destinationChainId: 1, // e.g. Ethereum/Base for example
                assetId: keccak256(abi.encodePacked("NIL", eventId)),
                eventId: bytes32(eventId),
                sender: address(this),
                receiver: requester,
                amount: amount,
                fee: 0,
                action: "PAYOUT",
                data: abi.encode(randomOutcome, stableSymbol),
                lps1Hash: bytes32(0), // integrate with GMIIE
                gmiiSignature: bytes32(0)
            });
            bytes32 payloadHash = BridgePayloadLib.hash(payload);
            emit BridgePayloadEmitted(payloadHash, payload);
        }
    }

    function setStablecoin(address _stablecoin) external onlyOwner {
        stablecoin = IERC20(_stablecoin);
    }

    function withdrawStablecoin(uint256 amount) external onlyOwner {
        require(stablecoin.transfer(msg.sender, amount), "Withdraw failed");
    }
}
