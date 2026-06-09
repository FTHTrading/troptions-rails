// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

// Base (OP Stack) adapted version of the core NIL rights contract.
// Same BridgePayload standard for seamless cross-chain with Avalanche VRF source via CCIP.
// Lighter for L2 (lower gas). Can be used with ERC-4337 Account Abstraction / Paymaster for gasless athlete claims.

import "../BridgePayload.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IVRFSource {
    function getEventRandomSeed(bytes32 eventId) external view returns (uint256);
}

contract TroptionsNILRightsBase is Ownable {
    IVRFSource public vrfSource; // Could be the Avalanche VRF projected via CCIP or a Base mirror
    IERC20 public stablecoin; // e.g. USDC on Base

    mapping(bytes32 => bool) public minted;
    mapping(bytes32 => uint256) public athletePayouts;

    event NILMinted(bytes32 indexed assetId, address indexed athlete, uint256 amount);
    event NILPayoutExecuted(bytes32 indexed eventId, address indexed athlete, uint256 amount);
    event BridgePayloadEmitted(bytes32 indexed payloadHash, BridgePayload payload);

    constructor(address _vrfSource, address _stablecoin) Ownable(msg.sender) {
        vrfSource = IVRFSource(_vrfSource);
        stablecoin = IERC20(_stablecoin);
    }

    function setVRFSource(address _vrfSource) external onlyOwner {
        vrfSource = IVRFSource(_vrfSource);
    }

    function mintNILBundle(BridgePayload calldata payload) external {
        require(!minted[payload.assetId], "Already minted");
        require(payload.lps1Hash != bytes32(0), "Missing provenance");

        uint256 seed = vrfSource.getEventRandomSeed(payload.eventId);
        require(seed != 0, "VRF seed not available (cross-chain pending)");

        uint256 attribute = seed % 100;
        minted[payload.assetId] = true;

        emit NILMinted(payload.assetId, payload.receiver, payload.amount);

        // Emit payload so CCIP or other can sync back to Avalanche provenance or to XRPL etc.
        BridgePayload memory p = payload;
        p.action = "NIL_MINT_BASE";
        p.data = abi.encode(attribute);
        bytes32 h = BridgePayloadLib.hash(p);
        emit BridgePayloadEmitted(h, p);
    }

    function executePayout(bytes32 eventId, address athlete, uint256 amount) external {
        require(amount > 0, "Invalid amount");
        athletePayouts[eventId] = amount;

        if (address(stablecoin) != address(0)) {
            try stablecoin.transfer(athlete, amount) {} catch {}
        }

        emit NILPayoutExecuted(eventId, athlete, amount);

        BridgePayload memory p = BridgePayload({
            version: 1,
            timestamp: block.timestamp,
            sourceChainId: 8453, // Base
            destinationChainId: 43114, // back to Avalanche or elsewhere
            assetId: keccak256(abi.encodePacked("NIL", eventId)),
            eventId: eventId,
            sender: address(this),
            receiver: athlete,
            amount: amount,
            fee: 0,
            action: "NIL_PAYOUT_BASE",
            data: "",
            lps1Hash: bytes32(0),
            gmiiSignature: bytes32(0)
        });
        bytes32 h = BridgePayloadLib.hash(p);
        emit BridgePayloadEmitted(h, p);
    }

    function getPayout(bytes32 eventId) external view returns (uint256) {
        return athletePayouts[eventId];
    }
}
