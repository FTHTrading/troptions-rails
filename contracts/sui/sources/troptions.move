// SPDX-License-Identifier: MIT
// sources/troptions.move
// Senior Sui Move module for parallel execution rail - NIL rights with BridgePayload compatibility.

module troptions::nil_rights {
    use sui::object::{Self, UID};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::event;
    use sui::coin::{Self, Coin};

    struct NILRights has key {
        id: UID,
        asset_id: vector<u8>,
        athlete: address,
        amount: u64,
        lps1_hash: vector<u8>,
        claimed: bool,
        payload_data: Option<vector<u8>>,
    }

    struct NILMinted has copy, drop {
        asset_id: vector<u8>,
        athlete: address,
        amount: u64,
    }

    public entry fun mint_nil(
        asset_id: vector<u8>,
        athlete: address,
        amount: u64,
        lps1_hash: vector<u8>,
        payload_data: Option<vector<u8>>,
        ctx: &mut TxContext
    ) {
        let nil = NILRights {
            id: object::new(ctx),
            asset_id,
            athlete,
            amount,
            lps1_hash,
            claimed: false,
            payload_data,
        };
        transfer::transfer(nil, athlete);
        event::emit(NILMinted { asset_id, athlete, amount });
    }

    public entry fun claim_payout(nil: &mut NILRights, ctx: &mut TxContext) {
        assert!(nil.athlete == tx_context::sender(ctx), 0);
        assert!(!nil.claimed, 1);
        nil.claimed = true;
        // Transfer amount logic (e.g. coin split)
    }
}
