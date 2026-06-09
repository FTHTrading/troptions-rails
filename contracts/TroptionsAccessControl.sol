// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/**
 * @title TroptionsAccessControl
 * @notice Senior access control for rail operators and ownership in the Troptions suite.
 * @dev Used by RailRegistry, NIL, VRF, CCIP, Automation. Simple but extensible (can upgrade to AccessControl).
 */
contract TroptionsAccessControl {
    address public owner;
    mapping(address => bool) public railOperators;

    event OperatorAdded(address indexed operator);
    event OperatorRemoved(address indexed operator);
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addRailOperator(address operator) external onlyOwner {
        railOperators[operator] = true;
        emit OperatorAdded(operator);
    }

    function removeRailOperator(address operator) external onlyOwner {
        railOperators[operator] = false;
        emit OperatorRemoved(operator);
    }

    function transferOwnership(address newOwner) external onlyOwner {
        require(newOwner != address(0), "New owner is zero address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function isOperator(address account) external view returns (bool) {
        return railOperators[account];
    }
}
