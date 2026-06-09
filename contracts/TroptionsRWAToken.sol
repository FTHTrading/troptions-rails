// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "./BridgePayload.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

/**
 * @title TroptionsRWAToken
 * @notice Institutional RWA/NIL-compliant ERC20 token with freezing, compliance gating, and BridgePayload provenance.
 * @dev Integrates with KYCCompliance, ProofVerifier, SettlementCore. Supports BridgePayload for cross-rail actions. Senior: NatSpec, roles, events.
 */
contract TroptionsRWAToken is ERC20, ERC20Burnable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant COMPLIANCE_ROLE = keccak256("COMPLIANCE_ROLE");

    mapping(address => bool) public frozen;

    event AssetFrozen(address indexed account, BridgePayload payload);
    event AssetUnfrozen(address indexed account);

    constructor(string memory name, string memory symbol) ERC20(name, symbol) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, msg.sender);
        _grantRole(COMPLIANCE_ROLE, msg.sender);
    }

    function mint(address to, uint256 amount, BridgePayload calldata payload) external onlyRole(MINTER_ROLE) {
        require(!frozen[to], "Account is frozen");
        _mint(to, amount);
        emit AssetFrozen(to, payload); // reuse for audit
    }

    function freeze(address account) external onlyRole(COMPLIANCE_ROLE) {
        frozen[account] = true;
        emit AssetFrozen(account, BridgePayload(0,0,0,0,0,0,address(0),address(0),0,"","",0,0,0,0)); // placeholder
    }

    function unfreeze(address account) external onlyRole(COMPLIANCE_ROLE) {
        frozen[account] = false;
        emit AssetUnfrozen(account);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal override {
        require(!frozen[from] && !frozen[to], "Account frozen");
        super._beforeTokenTransfer(from, to, amount);
    }
}
