// SPDX-License-Identifier: MIT
// programs/troptions/src/lib.rs
// Senior Anchor program for Solana rail - NIL rights and stablecoin integration.
// Compatible with BridgePayload via account data for cross-chain with EVM (Avalanche, Base, etc.).

use anchor_lang::prelude::*;
use anchor_spl::token::{self, Token, Mint, TokenAccount};

declare_id!("Tropt11111111111111111111111111111111111111");

#[program]
pub mod troptions {
    use super::*;

    pub fn mint_nil(
        ctx: Context<MintNIL>,
        asset_id: [u8; 32],
        amount: u64,
        lps1_hash: [u8; 32],
        payload_data: Option<[u8; 32]>,
    ) -> Result<()> {
        let nil_account = &mut ctx.accounts.nil_account;
        nil_account.asset_id = asset_id;
        nil_account.athlete = ctx.accounts.athlete.key();
        nil_account.amount = amount;
        nil_account.lps1_hash = lps1_hash;
        nil_account.claimed = false;
        nil_account.payload_data = payload_data;
        
        // Example: mint stable (USDC-like) if needed
        // token::mint_to(...)
        
        Ok(())
    }

    pub fn claim_payout(ctx: Context<ClaimPayout>, asset_id: [u8; 32]) -> Result<u64> {
        let nil_account = &mut ctx.accounts.nil_account;
        require!(nil_account.athlete == ctx.accounts.athlete.key(), ErrorCode::Unauthorized);
        require!(!nil_account.claimed, ErrorCode::AlreadyClaimed);
        
        nil_account.claimed = true;
        
        Ok(nil_account.amount)
    }
}

#[derive(Accounts)]
pub struct MintNIL<'info> {
    #[account(init, payer = athlete, space = 8 + 32 + 32 + 8 + 32 + 1 + 32)]
    pub nil_account: Account<'info, NILAccount>,
    #[account(mut)]
    pub athlete: Signer<'info>,
    pub system_program: Program<'info, System>,
}

#[derive(Accounts)]
pub struct ClaimPayout<'info> {
    #[account(mut, has_one = athlete)]
    pub nil_account: Account<'info, NILAccount>,
    pub athlete: Signer<'info>,
}

#[account]
pub struct NILAccount {
    pub asset_id: [u8; 32],
    pub athlete: Pubkey,
    pub amount: u64,
    pub lps1_hash: [u8; 32],
    pub claimed: bool,
    pub payload_data: Option<[u8; 32]>,
}

#[error_code]
pub enum ErrorCode {
    #[msg("Unauthorized")]
    Unauthorized,
    #[msg("Already claimed")]
    AlreadyClaimed,
}
