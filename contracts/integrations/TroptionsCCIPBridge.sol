// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

 import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "../BridgePayload.sol";

/**
 * @title TroptionsCCIPBridge
 * @notice Senior production-grade Chainlink CCIP template for moving Troptions BridgePayloads across chains.
 * @dev Supports the full Troptions 9-rail vision (Avalanche VRF/NIL → Base, Solana, XRPL etc.).
 *      Whitelisted chains, native gas fees, payload encoding.
 *      Pausable + guards for safety. Extend with tokenAmounts for stable transfers if desired.
 */
contract TroptionsCCIPBridge is Ownable, Pausable, ReentrancyGuard {
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

    function sendMessage(uint64 destinationChainSelector, BridgePayload memory payload)
        external
        payable
        onlyOwner
        whenNotPaused
        nonReentrant
        returns (bytes32 messageId)
    {
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
        // In production: decode action and route to NIL, VRF, or rail-specific handler
        emit MessageSent(bytes32(0), 0, address(0), message.data);
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
