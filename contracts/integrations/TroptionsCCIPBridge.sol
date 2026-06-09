// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "./BridgePayload.sol";

/**
 * @title TroptionsCCIPBridge
 * @notice Senior CCIP template for Troptions BridgePayload cross-chain messaging.
 * @dev Uses latest IRouterClient + Client patterns. Supports the full 9-rail vision.
 *      Whitelists, native gas, payload passthrough. Guards + NatSpec.
 */
contract TroptionsCCIPBridge is Ownable, Pausable, ReentrancyGuard {
    IRouterClient private immutable i_router;

    mapping(uint64 => bool) public whitelistedChains;

    event MessageSent(bytes32 indexed messageId, uint64 indexed destSelector, bytes data);

    constructor(address router) Ownable(msg.sender) {
        i_router = IRouterClient(router);
    }

    function whitelistChain(uint64 selector) external onlyOwner {
        whitelistedChains[selector] = true;
    }

    function sendMessage(uint64 destSelector, BridgePayload memory payload)
        external
        payable
        whenNotPaused
        nonReentrant
        onlyOwner
        returns (bytes32 messageId)
    {
        require(whitelistedChains[destSelector], "Chain not whitelisted");

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(address(this)),
            data: abi.encode(payload),
            tokenAmounts: new Client.EVMTokenAmount[](0),
            extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: 200000})),
            feeToken: address(0)
        });

        uint256 fees = i_router.getFee(destSelector, message);
        require(msg.value >= fees, "Insufficient fee");

        messageId = i_router.ccipSend{value: fees}(destSelector, message);
        emit MessageSent(messageId, destSelector, abi.encode(payload));
        return messageId;
    }

    function ccipReceive(Client.Any2EVMMessage memory message) external {
        BridgePayload memory payload = abi.decode(message.data, (BridgePayload));
        // Route based on payload.action (e.g. to NIL contract)
        emit MessageSent(bytes32(0), 0, message.data);
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
