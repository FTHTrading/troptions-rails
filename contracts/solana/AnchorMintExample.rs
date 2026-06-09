// Real Solana Anchor program example for Troptions intake/minting (based on live mint console).
// This is a starter for the Solana rail. Compile with Anchor.

use anchor_lang::prelude::*;
use anchor_spl::token::{self, Token, Mint, TokenAccount};

declare_id!("Tropt11111111111111111111111111111111111111"); // Placeholder

#[program]
pub mod troptions_mint {
    use super::*;

    pub fn initialize(ctx: Context<Initialize>) -> Result<()> {
        Ok(())
    }

    pub fn mint(ctx: Context<MintToken>, amount: u64) -> Result<()> {
        // Stablecoin integration example: mint USDC-like
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
