module akane::tokens {
    use sui::object::UID;
    use sui::object;
    use sui::coin;
    use sui::tx_context::TxContext;

    // Wrapped token types - adding necessary traits for Coin
    struct WBTC has drop, store {}
    struct WETH has drop, store {}
    struct WSOL has drop, store {}
    struct WAVAX has drop, store {}

    // Token capabilities - removed drop ability since UID doesn't support it
    struct TokenCap has key, store {
        id: UID,
        token_type: u8
    }

    public fun mint_wbtc(ctx: &mut TxContext): coin::Coin<WBTC> {
        coin::zero<WBTC>(ctx)
    }

    public fun mint_weth(ctx: &mut TxContext): coin::Coin<WETH> {
        coin::zero<WETH>(ctx)
    }

    public fun mint_wsol(ctx: &mut TxContext): coin::Coin<WSOL> {
        coin::zero<WSOL>(ctx)
    }

    public fun mint_wavax(ctx: &mut TxContext): coin::Coin<WAVAX> {
        coin::zero<WAVAX>(ctx)
    }

    // Wrapper functions for wrapping native tokens
    public fun wrap_btc(coin_in: coin::Coin<WBTC>, ctx: &mut TxContext): (TokenCap, coin::Coin<WBTC>) {
        let token_cap = TokenCap {
            id: object::new(ctx),
            token_type: 1
        };
        (token_cap, coin_in)
    }

    public fun wrap_eth(coin_in: coin::Coin<WETH>, ctx: &mut TxContext): (TokenCap, coin::Coin<WETH>) {
        let token_cap = TokenCap {
            id: object::new(ctx),
            token_type: 2
        };
        (token_cap, coin_in)
    }

    public fun wrap_sol(coin_in: coin::Coin<WSOL>, ctx: &mut TxContext): (TokenCap, coin::Coin<WSOL>) {
        let token_cap = TokenCap {
            id: object::new(ctx),
            token_type: 3
        };
        (token_cap, coin_in)
    }

    public fun wrap_avax(coin_in: coin::Coin<WAVAX>, ctx: &mut TxContext): (TokenCap, coin::Coin<WAVAX>) {
        let token_cap = TokenCap {
            id: object::new(ctx),
            token_type: 5
        };
        (token_cap, coin_in)
    }

}