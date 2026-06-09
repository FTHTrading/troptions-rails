// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

// Assume BridgePayload is in same dir or import
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

contract TroptionsNILRights is VRFConsumerBaseV2Plus, Ownable {
    event NILRightsMinted(address indexed user, uint256 amount, bytes32 eventId);
    event NILPayoutClaimed(address indexed user, uint256 amount, bytes32 eventId, uint256 randomOutcome);
    event BridgePayloadEmitted(bytes32 indexed payloadHash, BridgePayload payload);

    mapping(address => uint256) public nilRightsBalance;
    mapping(bytes32 => uint256) public eventPayoutPool;
    mapping(uint256 => bytes32) public requestIdToEventId;
    mapping(bytes32 => bool) public eventFulfilled;

    IERC20 public stablecoin; // e.g. USDC on Avalanche
    uint256 public s_subscriptionId;
    bytes32 public s_keyHash;
    uint32 public callbackGasLimit = 200000;
    uint16 public requestConfirmations = 3;
    uint32 public numWords = 1;

    constructor(address vrfCoordinator, uint256 subscriptionId, bytes32 keyHash, address _stablecoin)
        VRFConsumerBaseV2Plus(vrfCoordinator)
        Ownable(msg.sender)
    {
        s_subscriptionId = subscriptionId;
        s_keyHash = keyHash;
        stablecoin = IERC20(_stablecoin);
    }

    function setStablecoin(address _stablecoin) external onlyOwner {
        stablecoin = IERC20(_stablecoin);
    }

    function mintNILRights(address user, uint256 amount, bytes32 eventId) external onlyOwner {
        nilRightsBalance[user] += amount;
        eventPayoutPool[eventId] += amount;
        emit NILRightsMinted(user, amount, eventId);
    }

    function requestPayout(bytes32 eventId, uint256 amount) external {
        require(nilRightsBalance[msg.sender] >= amount, "Insufficient NIL rights");
        require(eventPayoutPool[eventId] >= amount, "Insufficient pool");

        uint256 requestId = s_vrfCoordinator.requestRandomWords(
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

        requestIdToEventId[requestId] = eventId;
        // Store amount somehow, for simplicity assume from balance
        nilRightsBalance[msg.sender] -= amount; // lock
        eventPayoutPool[eventId] -= amount;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        bytes32 eventId = requestIdToEventId[requestId];
        uint256 randomOutcome = randomWords[0] % 100;
        uint256 payoutAmount = eventPayoutPool[eventId]; // or stored

        if (randomOutcome > 50) {
            // Payout
            require(stablecoin.transfer(msg.sender, payoutAmount), "Payout failed");
            emit NILPayoutClaimed(msg.sender, payoutAmount, eventId, randomOutcome);
        } else {
            // No payout, perhaps burn or return
            eventPayoutPool[eventId] += payoutAmount; // return to pool
        }

        // Emit BridgePayload for cross-chain (e.g. to Base for liquidity, XRPL for trading)
        BridgePayload memory payload = BridgePayload({
            version: 1,
            timestamp: block.timestamp,
            sourceChainId: 43114, // Avalanche
            destinationChainId: 8453, // Base example
            assetId: keccak256(abi.encodePacked("NIL", eventId)),
            eventId: eventId,
            sender: address(this),
            receiver: msg.sender,
            amount: payoutAmount,
            fee: 0,
            action: randomOutcome > 50 ? "PAYOUT" : "NO_PAYOUT",
            data: abi.encode(randomOutcome),
            lps1Hash: bytes32(0),
            gmiiSignature: bytes32(0)
        });
        bytes32 payloadHash = BridgePayloadLib.hash(payload);
        emit BridgePayloadEmitted(payloadHash, payload);

        delete requestIdToEventId[requestId];
    }

    // Admin functions
    function withdrawStablecoin(uint256 amount) external onlyOwner {
        require(stablecoin.transfer(msg.sender, amount), "Withdraw failed");
    }
}
