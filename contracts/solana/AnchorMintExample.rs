// Real Solana Anchor program example for Troptions intake/minting (based on live mint console).
// BridgePayload compatible: this rail can receive cross-chain intents (from Avalanche VRF/NIL via Wormhole or CCIP bridge) and mint using the unified payload (stables + event + proofs).

use anchor_lang::prelude::*;
use anchor_spl::token::{self, Token, Mint, TokenAccount};

declare_id!("Tropt11111111111111111111111111111111111111"); // Placeholder

// Mirror of the EVM BridgePayload for cross-system flows (amount is the stable/USDC value, action can be NIL_PAYOUT etc.)
#[derive(AnchorSerialize, AnchorDeserialize, Clone)]
pub struct BridgePayload {
    pub version: u64,
    pub timestamp: u64,
    pub source_chain_id: u64,
    pub destination_chain_id: u64,
    pub asset_id: [u8; 32],
    pub event_id: [u8; 32],
    pub sender: [u8; 32],
    pub receiver: Pubkey,
    pub amount: u64,
    pub fee: u64,
    pub action: String,
    pub data: Vec<u8>,
    pub lps1_hash: [u8; 32],
    pub gmii_signature: [u8; 32],
}

#[program]
pub mod troptions_mint {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        Ok(())
    }

    /// Mint using a cross-chain BridgePayload (e.g. from Avalanche NIL payout or VRF outcome).
    /// Integrates native USDC/USDT on Solana.
    pub fn mint_from_payload(ctx: Context<MintToken>, payload: BridgePayload, amount: u64) -> Result<()> {
        require!(payload.amount == amount, "Payload amount mismatch");
        // Stablecoin integration example: mint or transfer USDC-like based on payload.action
        token::mint_to(
            CpiContext::new(
                ctx.accounts.token_program.to_account_info(),
                token::MintTo {
                    mint: ctx.accounts.mint.to_account_info(),
                    to: ctx.accounts.to.to_account_info(),
                    authority: ctx.accounts.authority.to_account_info(),
                },
            ),
            amount,
        )?;
        // TODO: verify lps1_hash / gmii_signature against GMIIE or oracle in full version
        Ok(())
    }

    pub fn mint(ctx: Context<MintToken>, amount: u64) -> Result<()> {
        token::mint_to(
            CpiContext::new(
                ctx.accounts.token_program.to_account_info(),
                token::MintTo {
                    mint: ctx.accounts.mint.to_account_info(),
                    to: ctx.accounts.to.to_account_info(),
                    authority: ctx.accounts.authority.to_account_info(),
                },
            ),
            amount,
        )?;
        Ok(())
    }
}

#[derive(Accounts)]
pub struct Initialize<'info> {
    #[account(init, payer = user, space = 8 + 8)]
    pub counter: Account<'info, Counter>,
    #[account(mut)]
    pub user: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct MintToken<'info> {
    #[account(mut)]
    pub mint: Account<'info, Mint>,
    #[account(mut)]
    pub to: Account<'info, TokenAccount>,
    pub authority: Signer<'info>,
    pub token_program: Program<'info, Token>,
}

#[account]
pub struct Counter {
    pub count: u64,
}
