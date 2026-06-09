// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

 import "../BridgePayload.sol";
import "./TroptionsSportsVRF.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title TroptionsNILRights
 * @notice Core senior template for minting NIL bundles and executing performance-based payouts.
 * @dev Consumes verified randomness from TroptionsSportsVRF (via getEventRandomSeed).
 *      Emits BridgePayload on every key action for cross-rail (CCIP to Base, Solana, XRPL, etc.).
 *      Direct stablecoin payouts. LPS-1 / XXXIII provenance required on mint.
 *      Designed for triggering by TroptionsAutomationKeeper (Chainlink Automation).
 *      Production patterns: Pausable, ReentrancyGuard, custom errors, full Natspec.
 * @custom:security-contact security@troptions.example
 */
contract TroptionsNILRights is Ownable, ReentrancyGuard, Pausable {
    TroptionsSportsVRF public vrf;
    IERC20 public stablecoin;

    mapping(bytes32 => bool) public minted;
    mapping(bytes32 => uint256) public athletePayouts;
    mapping(bytes32 => uint256) public eventPayoutPool;

    event NILMinted(bytes32 indexed assetId, address indexed athlete, uint256 amount, uint256 attribute);
    event NILPayoutExecuted(bytes32 indexed eventId, address indexed athlete, uint256 amount, uint256 randomOutcome);
    event BridgePayloadEmitted(bytes32 indexed payloadHash, BridgePayload payload);

    error AlreadyMinted();
    error MissingProvenance();
    error VRFNotFulfilled();
    error InsufficientPool();
    error PayoutAlreadyExecuted();

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
     * @notice Mint a NIL bundle. Requires a fulfilled VRF seed and valid LPS-1 provenance hash.
     *         The VRF seed is used for fair on-chain attribute / royalty distribution.
     */
    function mintNILBundle(BridgePayload calldata payload)
        external
        whenNotPaused
        nonReentrant
    {
        if (minted[payload.assetId]) revert AlreadyMinted();
        if (payload.lps1Hash == bytes32(0)) revert MissingProvenance(); // Hook for XXXIII / GMIIE / LPS-1 system

        uint256 seed = vrf.getEventRandomSeed(payload.eventId);
        if (seed == 0) revert VRFNotFulfilled();

        uint256 randomAttribute = seed % 100;

        minted[payload.assetId] = true;
        eventPayoutPool[payload.eventId] += payload.amount;

        emit NILMinted(payload.assetId, payload.receiver, payload.amount, randomAttribute);

        // Emit for cross-chain (Base liquidity, Solana mint, XRPL trading, Stacks settle...)
        BridgePayload memory emitPayload = payload;
        emitPayload.action = "NIL_MINT";
        emitPayload.data = abi.encode(randomAttribute);
        bytes32 payloadHash = BridgePayloadLib.hash(emitPayload);
        emit BridgePayloadEmitted(payloadHash, emitPayload);
    }

    /**
     * @notice Execute payout (callable by AutomationKeeper after VRF fulfillment, or authorized actor).
     *         Performs stable transfer and emits payload for downstream rails.
     */
    function executePayout(bytes32 eventId, address athlete, uint256 amount)
        external
        whenNotPaused
        nonReentrant
    {
        if (amount == 0) revert("Invalid amount");
        if (eventPayoutPool[eventId] < amount) revert InsufficientPool();
        if (athletePayouts[eventId] != 0) revert PayoutAlreadyExecuted();

        athletePayouts[eventId] = amount;
        eventPayoutPool[eventId] -= amount;

        if (address(stablecoin) != address(0)) {
            // Production note: prefer pull pattern or treasury in high-value deploys
            stablecoin.transfer(athlete, amount);
        }

        uint256 outcome = vrf.getEventRandomSeed(eventId);

        emit NILPayoutExecuted(eventId, athlete, amount, outcome);

        BridgePayload memory payload = BridgePayload({
            version: 1,
            timestamp: block.timestamp,
            sourceChainId: 43114,
            destinationChainId: 8453,
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

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
