module akane::tokens {
    use sui::object::{Self, UID};
    use sui::coin::{Self, Coin};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;

    // Wrapped token types - adding necessary traits for Coin
    struct WBTC has drop, store {}
    struct WETH has drop, store {}
    struct WSOL has drop, store {}
    struct WAVAX has drop, store {}

    // Token capabilities
    struct TokenCap has key, store {
        id: UID,
        token_type: u8
    }

    public fun mint_wbtc(ctx: &mut TxContext): Coin<WBTC> {
        coin::zero<WBTC>(ctx)
    }

    public fun mint_weth(ctx: &mut TxContext): Coin<WETH> {
        coin::zero<WETH>(ctx)
    }

    public fun mint_wsol(ctx: &mut TxContext): Coin<WSOL> {
        coin::zero<WSOL>(ctx)
    }

    public fun mint_wavax(ctx: &mut TxContext): Coin<WAVAX> {
        coin::zero<WAVAX>(ctx)
    }

    // Wrapper functions for wrapping native tokens
    public fun wrap_btc(coin_in: Coin<WBTC>, ctx: &mut TxContext): TokenCap {
        let token_cap = TokenCap {
            id: object::new(ctx),
            token_type: 1
        };
        transfer::public_transfer(coin_in, tx_context::sender(ctx));
        token_cap
    }

    public fun wrap_eth(coin_in: Coin<WETH>, ctx: &mut TxContext): TokenCap {
        let token_cap = TokenCap {
            id: object::new(ctx),
            token_type: 2
        };
        transfer::public_transfer(coin_in, tx_context::sender(ctx));
        token_cap
    }

    public fun wrap_sol(coin_in: Coin<WSOL>, ctx: &mut TxContext): TokenCap {
        let token_cap = TokenCap {
            id: object::new(ctx),
            token_type: 3
        };
        transfer::public_transfer(coin_in, tx_context::sender(ctx));
        token_cap
    }

    public fun wrap_avax(coin_in: Coin<WAVAX>, ctx: &mut TxContext): TokenCap {
        let token_cap = TokenCap {
            id: object::new(ctx),
            token_type: 5
        };
        transfer::public_transfer(coin_in, tx_context::sender(ctx));
        token_cap
    }
}