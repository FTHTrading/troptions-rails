// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

// BridgePayload standard (shared for all rails + stables + proofs)
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

contract TroptionsCCIPBridge is Ownable {
    IRouterClient private immutable i_router;

    mapping(uint64 => bool) public whitelistedChains;

    event MessageSent(
        bytes32 indexed messageId,
        uint64 indexed destinationChainSelector,
        address receiver,
        bytes data
    );

    constructor(address router) Ownable(msg.sender) {
        i_router = IRouterClient(router);
    }

    function whitelistChain(uint64 _destinationChainSelector) external onlyOwner {
        whitelistedChains[_destinationChainSelector] = true;
    }

    function sendMessage(
        uint64 destinationChainSelector,
        BridgePayload memory payload
    ) external payable onlyOwner returns (bytes32 messageId) {
        require(whitelistedChains[destinationChainSelector], "Destination chain not whitelisted");

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(address(this)),
            data: abi.encode(payload),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 200000})
            ),
            feeToken: address(0)
        });

        uint256 fees = i_router.getFee(destinationChainSelector, message);
        require(msg.value >= fees, "Insufficient fee");

        messageId = i_router.ccipSend{value: fees}(destinationChainSelector, message);

        emit MessageSent(messageId, destinationChainSelector, address(this), abi.encode(payload));
        return messageId;
    }

    function ccipReceive(Client.Any2EVMMessage memory message) external {
        BridgePayload memory payload = abi.decode(message.data, (BridgePayload));
        emit MessageSent(bytes32(0), 0, address(0), message.data);
    }
}