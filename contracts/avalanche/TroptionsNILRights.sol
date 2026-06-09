// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BridgePayload.sol";
import "./TroptionsSportsVRF.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Pausable} from "@openzeppelin/contracts/security/Pausable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title TroptionsNILRights
 * @notice Senior core contract for minting NIL bundles and executing performance-based payouts.
 * @dev Uses BridgePayload for unified cross-rail data. Consumes VRF seed for fair attributes.
 *      Requires valid LPS-1 hash for provenance (XXXIII/GMIIE). Emits payloads for CCIP/Automation.
 *      Direct stablecoin support. Production patterns: guards, NatSpec, custom errors.
 */
contract TroptionsNILRights is Ownable, Pausable, ReentrancyGuard {
    TroptionsSportsVRF public vrf;
    IERC20 public stablecoin;

    mapping(bytes32 => bool) public isMinted;
    mapping(bytes32 => uint256) public athletePayout;
    mapping(bytes32 => uint256) public eventPayoutPool;

    event NILMinted(bytes32 indexed assetId, address indexed athlete, uint256 amount, bytes32 lps1Hash);
    event NILPayoutExecuted(bytes32 indexed eventId, address indexed athlete, uint256 amount);
    event BridgePayloadEmitted(bytes32 indexed payloadHash, BridgePayload payload);

    error AlreadyMinted();
    error MissingLPS1Hash();
    error VRFNotFulfilled();
    error InvalidAmount();
    error InsufficientPool();

    constructor(address _vrf, address _stablecoin) Ownable(msg.sender) {
        vrf = TroptionsSportsVRF(_vrf);
        stablecoin = IERC20(_stablecoin);
    }

    function setVRF(address _vrf) external onlyOwner {
        vrf = TroptionsSportsVRF(_vrf);
    }

    function setStablecoin(address _stablecoin) external onlyOwner {
        stablecoin = IERC20(_stablecoin);
    }

    function mintNIL(BridgePayload calldata payload) external onlyOwner whenNotPaused nonReentrant {
        if (isMinted[payload.assetId]) revert AlreadyMinted();
        if (payload.lps1Hash == bytes32(0)) revert MissingLPS1Hash();
        if (vrf.eventRandomSeed(payload.eventId) == 0) revert VRFNotFulfilled();

        isMinted[payload.assetId] = true;
        eventPayoutPool[payload.eventId] += payload.amount;

        emit NILMinted(payload.assetId, payload.receiver, payload.amount, payload.lps1Hash);

        BridgePayload memory p = payload;
        p.action = "MINT_NIL";
        bytes32 h = BridgePayloadLib.hash(p);
        emit BridgePayloadEmitted(h, p);
    }

    function executePayout(bytes32 eventId, address athlete, uint256 amount) external onlyOwner whenNotPaused nonReentrant {
        if (amount == 0) revert InvalidAmount();
        if (eventPayoutPool[eventId] < amount) revert InsufficientPool();

        athletePayout[eventId] = amount;
        eventPayoutPool[eventId] -= amount;

        if (address(stablecoin) != address(0)) {
            stablecoin.transfer(athlete, amount);
        }

        emit NILPayoutExecuted(eventId, athlete, amount);

        BridgePayload memory p = BridgePayload({
            version: 1,
            timestamp: block.timestamp,
            sourceChainSelector: 0, // Avalanche selector
            destChainSelector: 0,   // e.g. Base
            assetId: keccak256(abi.encodePacked("NIL", eventId)),
            eventId: eventId,
            sender: address(this),
            receiver: athlete,
            amount: amount,
            action: "PAYOUT",
            data: "",
            lps1Hash: bytes32(0),
            gmiiSignature: bytes32(0)
        });
        bytes32 h = BridgePayloadLib.hash(p);
        emit BridgePayloadEmitted(h, p);
    }

    function getPayout(bytes32 eventId) external view returns (uint256) {
        return athletePayout[eventId];
    }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
