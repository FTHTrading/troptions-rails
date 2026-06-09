// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import "./BridgePayload.sol";

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
            receiver: abi.encode(address(this)), // or specific receiver on dest chain
            data: abi.encode(payload),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: Client._argsToBytes(
                Client.EVMExtraArgsV1({gasLimit: 200000})
            ),
            feeToken: address(0) // native gas
        });

        uint256 fees = i_router.getFee(destinationChainSelector, message);
        require(msg.value >= fees, "Insufficient fee");

        messageId = i_router.ccipSend{value: fees}(destinationChainSelector, message);

        emit MessageSent(messageId, destinationChainSelector, address(this), abi.encode(payload));
        return messageId;
    }

    // Receive function for CCIP messages from other chains
    function ccipReceive(Client.Any2EVMMessage memory message) external {
        // Decode payload and process, e.g., update state or emit event
        BridgePayload memory payload = abi.decode(message.data, (BridgePayload));
        // Process the payload, e.g., mint on this chain, etc.
        // For demo, emit
        emit MessageSent(bytes32(0), 0, address(0), message.data); // placeholder
    }
}