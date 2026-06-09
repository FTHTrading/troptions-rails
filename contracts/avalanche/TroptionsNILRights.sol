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
 * @notice Senior core template for NIL bundle minting and performance payouts.
 * @dev Consumes VRF seed from TroptionsSportsVRF for fair attributes/royalties.
 *      Requires LPS-1 provenance (lps1Hash). Emits BridgePayload on mint/payout for CCIP cross-rail.
 *      Direct stable integration. Ready for TroptionsAutomation.
 *      Pausable, ReentrancyGuard, full NatSpec.
 */
contract TroptionsNILRights is Ownable, Pausable, ReentrancyGuard {
    TroptionsSportsVRF public vrf;
    IERC20 public stablecoin;

    mapping(bytes32 => bool) public minted;
    mapping(bytes32 => uint256) public athletePayouts;
    mapping(bytes32 => uint256) public eventPayoutPool;

    event NILMinted(bytes32 indexed assetId, address indexed athlete, uint256 amount, uint256 attribute);
    event NILPayoutExecuted(bytes32 indexed eventId, address indexed athlete, uint256 amount, uint256 randomOutcome);
    event BridgePayloadEmitted(bytes32 indexed payloadHash, BridgePayload payload);

    constructor(address _vrf, address _stable) Ownable(msg.sender) {
        vrf = TroptionsSportsVRF(_vrf);
        stablecoin = IERC20(_stable);
    }

    function setVRF(address _vrf) external onlyOwner { vrf = TroptionsSportsVRF(_vrf); }
    function setStablecoin(address _stable) external onlyOwner { stablecoin = IERC20(_stable); }

    function mintNILBundle(BridgePayload calldata payload) external whenNotPaused nonReentrant {
        require(!minted[payload.assetId], "Already minted");
        require(payload.lps1Hash != bytes32(0), "Missing LPS-1 / XXXIII provenance");

        uint256 seed = vrf.eventRandomSeed(payload.eventId);
        require(seed != 0, "VRF not fulfilled");

        uint256 attribute = seed % 100;

        minted[payload.assetId] = true;
        eventPayoutPool[payload.eventId] += payload.amount;

        emit NILMinted(payload.assetId, payload.receiver, payload.amount, attribute);

        BridgePayload memory p = payload;
        p.action = "MINT_NIL";
        p.data = abi.encode(attribute);
        bytes32 h = BridgePayloadLib.hash(p);
        emit BridgePayloadEmitted(h, p);
    }

    function executePayout(bytes32 eventId, address athlete, uint256 amount) external whenNotPaused nonReentrant {
        require(amount > 0, "Invalid amount");
        require(eventPayoutPool[eventId] >= amount, "Insufficient pool");
        require(athletePayouts[eventId] == 0, "Already paid");

        athletePayouts[eventId] = amount;
        eventPayoutPool[eventId] -= amount;

        if (address(stablecoin) != address(0)) {
            stablecoin.transfer(athlete, amount); // prod: consider pull/treasury
        }

        uint256 outcome = vrf.eventRandomSeed(eventId);
        emit NILPayoutExecuted(eventId, athlete, amount, outcome);

        BridgePayload memory p = BridgePayload({
            version: 1,
            timestamp: block.timestamp,
            sourceChainSelector: 0, // Avalanche
            destChainSelector: 0,   // e.g. Base
            assetId: keccak256(abi.encodePacked("NIL", eventId)),
            eventId: eventId,
            sender: address(this),
            receiver: athlete,
            amount: amount,
            action: "PAYOUT",
            data: abi.encode(outcome),
            lps1Hash: bytes32(0),
            gmiiSignature: bytes32(0)
        });
        bytes32 h = BridgePayloadLib.hash(p);
        emit BridgePayloadEmitted(h, p);
    }

    function getPayout(bytes32 eventId) external view returns (uint256) { return athletePayouts[eventId]; }

    function pause() external onlyOwner { _pause(); }
    function unpause() external onlyOwner { _unpause(); }
}
