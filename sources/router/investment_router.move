#[allow(lint(self_transfer))]
module akane::investment_router {
    use std::vector;
    
    use sui::object::{Self, UID};
    use sui::coin::{Self, Coin};
    use sui::balance::{Self};
    use sui::sui::SUI;
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::clock::Clock;
    use sui::bag::{Self, Bag};
    
    use cetus_clmm::pool::{Self, Pool};
    use cetus_clmm::config::GlobalConfig;
    
    use akane::tokens::{WBTC, WETH};
    use akane::strategy_interface::{Self, StrategyInfo};
    use akane::strategy_registry;
    use akane::events;
    use akane::constants;

    /// Stores all coins returned from investment
    struct InvestmentOutput has key, store {
        id: UID,
        coins: Bag
    }

    struct RouterConfig has key {
        id: UID,
        fee_collector: address,
        paused: bool
    }

    // Error codes
    const ERR_PAUSED: u64 = 100;
    const ERR_UNIMPLEMENTED_SWAP: u64 = 102;
    
    // Configuration constants
    const MAX_SLIPPAGE: u64 = 1000; // 10% max slippage

    public fun initialize(
        fee_collector: address,
        ctx: &mut TxContext
    ) {
        transfer::share_object(RouterConfig {
            id: object::new(ctx),
            fee_collector,
            paused: false
        });
    }

    public entry fun invest(
        registry: &strategy_registry::StrategyRegistry,
        config: &RouterConfig,
        btc_pool: &mut Pool<SUI, WBTC>,
        eth_pool: &mut Pool<SUI, WETH>,
        cetus_config: &GlobalConfig,
        clock: &Clock,
        strategy_id: u8,
        payment: Coin<SUI>,
        _slippage_tolerance: u64,
        ctx: &mut TxContext
    ) {
        // Core validations
        assert!(!config.paused, ERR_PAUSED);
        assert!(_slippage_tolerance <= MAX_SLIPPAGE, constants::err_slippage_too_high());
        
        let strategy = strategy_registry::get_strategy_info(registry, strategy_id);

        let amount = coin::value(&payment);
        assert!(amount >= strategy_interface::get_min_investment(strategy), 
            constants::err_insufficient_amount());

        // Process investment with fee collection
        let fee_amount = (amount * constants::initial_fee_percentage()) / constants::fee_denominator();
        
        if (fee_amount > 0) {
            let fee_coin = coin::split(&mut payment, fee_amount, ctx);
            transfer::public_transfer(fee_coin, config.fee_collector);
        };

        // Create output container
        let output = InvestmentOutput {
            id: object::new(ctx),
            coins: bag::new(ctx)
        };

        // Execute strategy allocations through Cetus pools
        let remaining_payment = process_allocations(
            &mut output,
            btc_pool,
            eth_pool,
            cetus_config,
            clock,
            strategy,
            payment,
            ctx
        );

        // Handle any remaining payment
        if (coin::value(&remaining_payment) > 0) {
            bag::add(&mut output.coins, b"SUI", remaining_payment);
        } else {
            coin::destroy_zero(remaining_payment);
        };
        
        transfer::transfer(output, tx_context::sender(ctx));
        
        events::emit_investment(
            tx_context::sender(ctx),
            strategy_id,
            amount,
            tx_context::epoch(ctx)
        );
    }

    fun process_allocations(
        output: &mut InvestmentOutput,
        btc_pool: &mut Pool<SUI, WBTC>,
        eth_pool: &mut Pool<SUI, WETH>,
        cetus_config: &GlobalConfig,
        clock: &Clock,
        strategy: &StrategyInfo,
        payment: Coin<SUI>,
        ctx: &mut TxContext
    ): Coin<SUI> {
        let allocations = strategy_interface::get_allocations(strategy);
        let total_amount = coin::value(&payment);
        let i = 0;
        let len = vector::length(&allocations);
        
        while (i < len) {
            let allocation = vector::borrow(&allocations, i);
            let amount = (total_amount * (strategy_interface::get_allocation_percentage(allocation) as u64)) / 100;
            
            if (amount > 0) {
                let coin_split = coin::split(&mut payment, amount, ctx);
                if (strategy_interface::get_allocation_token(allocation) == constants::btc_token()) {
                    let btc_coin = execute_btc_swap(
                        btc_pool,
                        cetus_config,
                        clock,
                        coin_split,
                        ctx
                    );
                    bag::add(&mut output.coins, b"BTC", btc_coin);
                } else if (strategy_interface::get_allocation_token(allocation) == constants::eth_token()) {
                    let eth_coin = execute_eth_swap(
                        eth_pool,
                        cetus_config,
                        clock,
                        coin_split,
                        ctx
                    );
                    bag::add(&mut output.coins, b"ETH", eth_coin);
                } else {
                    abort ERR_UNIMPLEMENTED_SWAP
                };
            };
            i = i + 1;
        };

        payment
    }

    fun execute_btc_swap(
        pool: &mut Pool<SUI, WBTC>,
        config: &GlobalConfig,
        clock: &Clock,
        payment: Coin<SUI>,
        ctx: &mut TxContext
    ): Coin<WBTC> {
        let amount = coin::value(&payment);
        let sqrt_price_limit = 0u128; // No price limit

        // Execute flash swap
        let (receive_sui, receive_btc, flash_receipt) = pool::flash_swap(
            config,
            pool,
            true, // a2b
            true, // by_amount_in
            amount,
            sqrt_price_limit,
            clock
        );

        // Pay for flash swap
        let (pay_sui, pay_btc) = (
            coin::into_balance(payment),
            balance::zero<WBTC>()
        );

        pool::repay_flash_swap(
            config,
            pool,
            pay_sui,
            pay_btc,
            flash_receipt
        );

        let final_coin = coin::from_balance(receive_btc, ctx);
        let coin_out_amount = coin::value(&final_coin);

        // Emit event for the swap
        events::emit_swap(
            object::id(pool),
            1u8, // coin_in_type
            amount,
            2u8, // coin_out_type
            coin_out_amount,
            tx_context::epoch(ctx)
        );
        
        // Clean up remaining SUI and return the BTC coin
        coin::destroy_zero(coin::from_balance(receive_sui, ctx));
        final_coin
    }

    fun execute_eth_swap(
        pool: &mut Pool<SUI, WETH>,
        config: &GlobalConfig,
        clock: &Clock,
        payment: Coin<SUI>,
        ctx: &mut TxContext
    ): Coin<WETH> {
        let amount = coin::value(&payment);
        let sqrt_price_limit = 0u128; // No price limit

        // Execute flash swap
        let (receive_sui, receive_eth, flash_receipt) = pool::flash_swap(
            config,
            pool,
            true, // a2b
            true, // by_amount_in
            amount,
            sqrt_price_limit,
            clock
        );

        // Pay for flash swap
        let (pay_sui, pay_eth) = (
            coin::into_balance(payment),
            balance::zero<WETH>()
        );

        pool::repay_flash_swap(
            config,
            pool,
            pay_sui,
            pay_eth,
            flash_receipt
        );

        let final_coin = coin::from_balance(receive_eth, ctx);
        let coin_out_amount = coin::value(&final_coin);

        // Emit event for the swap
        events::emit_swap(
            object::id(pool),
            1u8, // coin_in_type
            amount,
            3u8, // coin_out_type
            coin_out_amount,
            tx_context::epoch(ctx)
        );
        
        // Clean up remaining SUI and return the ETH coin
        coin::destroy_zero(coin::from_balance(receive_sui, ctx));
        final_coin
    }

    #[test_only]
    /// Initialize router for testing with default values
    public fun init_for_testing(fee_collector: address, ctx: &mut TxContext) {
        initialize(fee_collector, ctx)
    }
}