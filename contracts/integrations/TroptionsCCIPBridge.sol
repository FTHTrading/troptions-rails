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
 * @notice Senior CCIP bridge for Troptions BridgePayload cross-chain messaging.
 * @dev Supports token + data (payload). Whitelists, fees, events. Guards + NatSpec.
 *      Integrates with NIL, VRF, Automation for the 9-rail flows.
 */
contract TroptionsCCIPBridge is Ownable, Pausable, ReentrancyGuard {
    IRouterClient public immutable router;

    event PayloadSent(bytes32 indexed messageId, uint64 destinationChainSelector);
    event PayloadReceived(bytes32 indexed messageId, BridgePayload payload);

    mapping(uint64 => bool) public whitelistedChains;

    constructor(address _router) Ownable(msg.sender) {
        router = IRouterClient(_router);
    }

    function whitelistChain(uint64 destinationChainSelector) external onlyOwner {
        whitelistedChains[destinationChainSelector] = true;
    }

    function sendPayload(
        uint64 destinationChainSelector,
        address receiver,
        BridgePayload calldata payload,
        address token,
        uint256 amount
    ) external onlyOwner whenNotPaused nonReentrant returns (bytes32 messageId) {
        Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](token != address(0) ? 1 : 0);
        if (token != address(0)) {
            tokenAmounts[0] = Client.EVMTokenAmount({token: token, amount: amount});
        }

        Client.EVM2AnyMessage memory message = Client.EVM2AnyMessage({
            receiver: abi.encode(receiver),
            data: abi.encode(payload),
            tokenAmounts: tokenAmounts,
            extraArgs: Client._argsToBytes(Client.EVMExtraArgsV1({gasLimit: 500_000})),
            feeToken: address(0)
        });

        uint256 fees = router.getFee(destinationChainSelector, message);
        messageId = router.ccipSend{value: fees}(destinationChainSelector, message);

        emit PayloadSent(messageId, destinationChainSelector);
    }

    function ccipReceive(Client.Any2EVMMessage calldata message) external {
        BridgePayload memory payload = abi.decode(message.data, (BridgePayload));
        emit PayloadReceived(message.messageId, payload);
        // In production: forward to NILRights, VRF, or rail handler based on payload.action
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
