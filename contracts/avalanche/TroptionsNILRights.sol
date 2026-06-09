// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "../BridgePayload.sol";
import "./TroptionsSportsVRF.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title TroptionsNILRights
 * @notice Core NIL minting and performance-based payout contract.
 * Links to TroptionsSportsVRF for verified randomness (fair attributes/royalties).
 * Emits BridgePayload for cross-chain settlement (CCIP, Base, XRPL, etc).
 * Designed to be triggered/observed by Chainlink Automation (see TroptionsNILAutomation).
 * Integrates stables for actual payouts.
 */
contract TroptionsNILRights is Ownable {
    TroptionsSportsVRF public vrf;
    IERC20 public stablecoin;

    mapping(bytes32 => bool) public minted;
    mapping(bytes32 => uint256) public athletePayouts;
    mapping(bytes32 => uint256) public eventPayoutPool;

    event NILMinted(bytes32 indexed assetId, address indexed athlete, uint256 amount, uint256 attribute);
    event NILPayoutExecuted(bytes32 indexed eventId, address indexed athlete, uint256 amount, uint256 randomOutcome);
    event BridgePayloadEmitted(bytes32 indexed payloadHash, BridgePayload payload);

    constructor(address _vrfAddress, address _stablecoin) Ownable(msg.sender) {
        vrf = TroptionsSportsVRF(_vrfAddress);
        stablecoin = IERC20(_stablecoin);
    }

    function setVRF(address _vrfAddress) external onlyOwner {
        vrf = TroptionsSportsVRF(_vrfAddress);
    }

    function setStablecoin(address _stablecoin) external onlyOwner {
        stablecoin = IERC20(_stablecoin);
    }

    /**
     * @notice Mint NIL bundle using verified randomness from VRF (called after VRF fulfillment).
     * Uses seed for fair attribute/royalty distribution.
     */
    function mintNILBundle(BridgePayload calldata payload) external {
        require(!minted[payload.assetId], "Already minted");
        require(payload.lps1Hash != bytes32(0), "Missing LPS-1 provenance");

        uint256 seed = vrf.getEventRandomSeed(payload.eventId);
        require(seed != 0, "VRF not fulfilled yet");

        // Use VRF seed to fairly distribute attributes/royalties (e.g. 0-99 tiers)
        uint256 randomAttribute = seed % 100;

        minted[payload.assetId] = true;
        eventPayoutPool[payload.eventId] += payload.amount;

        emit NILMinted(payload.assetId, payload.receiver, payload.amount, randomAttribute);

        // Emit for cross-chain visibility (e.g. Base liquidity, XRPL trading leg)
        BridgePayload memory emitPayload = payload; // copy
        emitPayload.action = "NIL_MINT";
        emitPayload.data = abi.encode(randomAttribute);
        bytes32 payloadHash = BridgePayloadLib.hash(emitPayload);
        emit BridgePayloadEmitted(payloadHash, emitPayload);
    }

    /**
     * @notice Execute performance-based payout (intended to be called by Automation Keeper
     * after VRF outcome is known, or by authorized claim).
     */
    function executePayout(bytes32 eventId, address athlete, uint256 amount) external {
        require(amount > 0, "Invalid amount");
        require(eventPayoutPool[eventId] >= amount, "Insufficient pool");
        require(!athletePayouts[eventId] , "Payout already executed"); // simplistic single payout per event for starter

        athletePayouts[eventId] = amount;
        eventPayoutPool[eventId] -= amount;

        // Actual stable payout (fund this contract or approve upstream)
        if (address(stablecoin) != address(0)) {
            // Best effort; in prod use pull or treasury pattern
            try stablecoin.transfer(athlete, amount) {} catch {}
        }

        uint256 outcome = vrf.getEventRandomSeed(eventId); // for event

        emit NILPayoutExecuted(eventId, athlete, amount, outcome);

        // Cross-chain payload for settlement on other rails
        BridgePayload memory payload = BridgePayload({
            version: 1,
            timestamp: block.timestamp,
            sourceChainId: 43114, // Avalanche
            destinationChainId: 8453, // Base example; CCIP can route further
            assetId: keccak256(abi.encodePacked("NIL", eventId)),
            eventId: eventId,
            sender: address(this),
            receiver: athlete,
            amount: amount,
            fee: 0,
            action: "NIL_PAYOUT",
            data: abi.encode(outcome),
            lps1Hash: bytes32(0),
            gmiiSignature: bytes32(0)
        });
        bytes32 payloadHash = BridgePayloadLib.hash(payload);
        emit BridgePayloadEmitted(payloadHash, payload);
    }

    function getPayout(bytes32 eventId) external view returns (uint256) {
        return athletePayouts[eventId];
    }

    function getPool(bytes32 eventId) external view returns (uint256) {
        return eventPayoutPool[eventId];
    }
}
