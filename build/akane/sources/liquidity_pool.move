module akane::liquidity_pool {
    use sui::object::{Self, UID};
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use std::u64;
    use sui::event;

    // Error constants
    const ERR_SLIPPAGE_TOO_HIGH: u64 = 10;
    const ERR_INSUFFICIENT_AMOUNT: u64 = 11;
    
    const FEE_NUMERATOR: u64 = 3;
    const FEE_DENOMINATOR: u64 = 1000; // 0.3% fee
    const MINIMUM_LIQUIDITY: u64 = 1000;
    const PRECISION: u64 = 1_000_000;

    struct LiquidityPool<phantom CoinTypeA, phantom CoinTypeB> has key, store {
        id: UID,
        coin_a: Balance<CoinTypeA>,
        coin_b: Balance<CoinTypeB>,
        lp_supply: u64,
        last_price_a: u64,
        last_price_b: u64,
        last_block: u64
    }

    // Event structs
    struct AddLiquidityEvent has copy, drop {
        amount_a: u64,
        amount_b: u64,
        liquidity: u64
    }

    struct SwapEvent has copy, drop {
        pool_id: address,
        token_in: u64,
        amount_in: u64,
        token_out: u64,
        amount_out: u64,
        timestamp: u64
    }

    struct LPToken<phantom CoinTypeA, phantom CoinTypeB> has key, store {
        id: UID,
        amount: u64
    }

    public fun create_pool<CoinTypeA, CoinTypeB>(ctx: &mut TxContext) {
        let pool = LiquidityPool<CoinTypeA, CoinTypeB> {
            id: object::new(ctx),
            coin_a: balance::zero(),
            coin_b: balance::zero(),
            lp_supply: 0,
            last_price_a: 0,
            last_price_b: 0,
            last_block: tx_context::epoch(ctx)
        };
        
        transfer::share_object(pool);
    }

    public fun add_liquidity<CoinTypeA, CoinTypeB>(
        pool: &mut LiquidityPool<CoinTypeA, CoinTypeB>,
        coin_a: Coin<CoinTypeA>,
        coin_b: Coin<CoinTypeB>,
        ctx: &mut TxContext
    ): LPToken<CoinTypeA, CoinTypeB> {
        let amount_a = coin::value(&coin_a);
        let amount_b = coin::value(&coin_b);
        
        let balance_a = coin::into_balance(coin_a);
        let balance_b = coin::into_balance(coin_b);

        let lp_tokens = if (pool.lp_supply == 0) {
            let initial_lp_tokens = u64::sqrt(amount_a * amount_b);
            assert!(initial_lp_tokens > MINIMUM_LIQUIDITY, ERR_INSUFFICIENT_AMOUNT);
            
            pool.lp_supply = initial_lp_tokens;
            initial_lp_tokens - MINIMUM_LIQUIDITY
        } else {
            let reserve_a = balance::value(&pool.coin_a);
            let reserve_b = balance::value(&pool.coin_b);
            
            let lp_amount = u64::min(
                (amount_a * pool.lp_supply) / reserve_a,
                (amount_b * pool.lp_supply) / reserve_b
            );
            
            pool.lp_supply = pool.lp_supply + lp_amount;
            lp_amount
        };

        balance::join(&mut pool.coin_a, balance_a);
        balance::join(&mut pool.coin_b, balance_b);

        // Emit event directly in the module
        event::emit(AddLiquidityEvent {
            amount_a,
            amount_b,
            liquidity: lp_tokens
        });

        LPToken<CoinTypeA, CoinTypeB> {
            id: object::new(ctx),
            amount: lp_tokens
        }
    }

    public fun swap<CoinTypeA, CoinTypeB>(
        pool: &mut LiquidityPool<CoinTypeA, CoinTypeB>,
        coin_in: Coin<CoinTypeA>,
        min_amount_out: u64,
        ctx: &mut TxContext
    ): Coin<CoinTypeB> {
        let amount_in = coin::value(&coin_in);
        let reserve_in = balance::value(&pool.coin_a);
        let reserve_out = balance::value(&pool.coin_b);

        let amount_in_with_fee = amount_in * (FEE_DENOMINATOR - FEE_NUMERATOR);
        let numerator = amount_in_with_fee * reserve_out;
        let denominator = (reserve_in * FEE_DENOMINATOR) + amount_in_with_fee;
        let amount_out = numerator / denominator;

        assert!(amount_out >= min_amount_out, ERR_SLIPPAGE_TOO_HIGH);

        balance::join(&mut pool.coin_a, coin::into_balance(coin_in));
        let out_balance = balance::split(&mut pool.coin_b, amount_out);

        pool.last_price_a = (reserve_out * PRECISION) / reserve_in;
        pool.last_price_b = (reserve_in * PRECISION) / reserve_out;
        pool.last_block = tx_context::epoch(ctx);

        event::emit(SwapEvent {
            pool_id: object::id_to_address(&object::uid_to_inner(&pool.id)),
            token_in: 1, // TODO: implement proper coin type tracking
            amount_in,
            token_out: 2, // TODO: implement proper coin type tracking
            amount_out,
            timestamp: tx_context::epoch(ctx)
        });

        coin::from_balance(out_balance, ctx)
    }

    public fun get_reserves<CoinTypeA, CoinTypeB>(
        pool: &LiquidityPool<CoinTypeA, CoinTypeB>
    ): (u64, u64) {
        (balance::value(&pool.coin_a), balance::value(&pool.coin_b))
    }

    public fun get_amount_out<CoinTypeA, CoinTypeB>(
        pool: &LiquidityPool<CoinTypeA, CoinTypeB>,
        amount_in: u64
    ): u64 {
        let reserve_in = balance::value(&pool.coin_a);
        let reserve_out = balance::value(&pool.coin_b);

        let amount_in_with_fee = amount_in * (FEE_DENOMINATOR - FEE_NUMERATOR);
        let numerator = amount_in_with_fee * reserve_out;
        let denominator = (reserve_in * FEE_DENOMINATOR) + amount_in_with_fee;
        
        numerator / denominator
    }
}