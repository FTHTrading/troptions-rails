// Base (OP Stack) Solidity example for liquidity/ERC-4337 rail.
// Real ERC-20 + Paymaster style for TUSD/USDC.

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TroptionsBaseToken is ERC20 {
    constructor() ERC20("TroptionsBase", "TBASE") {}

    function mint(address to, uint256 amount) public {
        // Stablecoin integration: USDC/TUSD like
        _mint(to, amount);
    }

    // ERC-4337 Paymaster stub for gas abstraction
    function validatePaymasterUserOp(...) external pure returns (bytes memory, uint256) {
        return ("", 0);
    }
}
