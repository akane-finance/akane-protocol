module akane::investment_router {
    use std::vector;
    use sui::coin::{Self, Coin};
    use sui::sui::SUI;
    use sui::tx_context::{Self, TxContext};
    use sui::transfer;
    use sui::object::{Self, ID, UID};
    use akane::strategy_interface::{Self, StrategyInfo};
    use akane::strategy_registry;
    use akane::events;
    use akane::constants;
    
    struct RouterConfig has key {
        id: UID,
        pools: vector<ID>,
        fee_collector: address,
        paused: bool
    }

    // Error codes
    const ERR_PAUSED: u64 = 100;
    const ERR_INSUFFICIENT_POOLS: u64 = 101;
    const ERR_UNIMPLEMENTED_SWAP: u64 = 102;
    
    // Configuration constants
    const MAX_SLIPPAGE: u64 = 1000; // 10% max slippage

    // Public accessors
    public fun err_paused(): u64 { ERR_PAUSED }
    public fun max_slippage(): u64 { MAX_SLIPPAGE }
    public fun err_insufficient_pools(): u64 { ERR_INSUFFICIENT_POOLS }
    public fun err_unimplemented_swap(): u64 { ERR_UNIMPLEMENTED_SWAP }

    public fun initialize(
        pools: vector<ID>,
        fee_collector: address,
        ctx: &mut TxContext
    ) {
        assert!(vector::length(&pools) >= 2, err_insufficient_pools()); // At least 2 pools needed
        transfer::share_object(RouterConfig {
            id: object::new(ctx),
            pools,
            fee_collector,
            paused: false
        });
    }

    public entry fun invest(
        registry: &strategy_registry::StrategyRegistry,
        config: &RouterConfig,
        strategy_id: u8,
        payment: Coin<SUI>,
        slippage_tolerance: u64,
        ctx: &mut TxContext
    ) {
        // Core validations
        assert!(!config.paused, err_paused());
        assert!(slippage_tolerance <= max_slippage(), constants::err_slippage_too_high());
        
        let strategy = strategy_registry::get_strategy_info(registry, strategy_id);
        let amount = coin::value(&payment);
        assert!(amount >= strategy_interface::get_min_investment(strategy), 
            constants::err_insufficient_amount());

        // Process investment with fee collection
        let fee_amount = (amount * constants::initial_fee_percentage()) / constants::fee_denominator();
        let _investment_amount = amount - fee_amount;
        
        if (fee_amount > 0) {
            let fee_coin = coin::split(&mut payment, fee_amount, ctx);
            transfer::public_transfer(fee_coin, config.fee_collector);
        };

        // Execute strategy allocations and handle remaining payment
        let remaining_payment = process_allocations(config, strategy, payment, slippage_tolerance, ctx);
        if (coin::value(&remaining_payment) > 0) {
            transfer::public_transfer(remaining_payment, tx_context::sender(ctx));
        } else {
            coin::destroy_zero(remaining_payment);
        };
        
        events::emit_investment(
            tx_context::sender(ctx),
            strategy_id,
            amount,
            tx_context::epoch(ctx)
        );
    }

    public(friend) fun process_allocations(
        config: &RouterConfig,
        strategy: &StrategyInfo,
        payment: Coin<SUI>,
        slippage_tolerance: u64,
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
                execute_swap(
                    config,
                    strategy_interface::get_allocation_token(allocation),
                    coin_split,
                    slippage_tolerance,
                    ctx
                );
            };
            i = i + 1;
        };

        // Return remaining payment
        if (coin::value(&payment) > 0) {
            payment
        } else {
            coin::destroy_zero(payment);
            coin::zero(ctx)
        }
    }

    // Implementation specific swap logic for testing
    public(friend) fun execute_swap(
        config: &RouterConfig,
        _token: vector<u8>,
        payment: Coin<SUI>,
        _slippage: u64,
        ctx: &TxContext
    ) {
        let amount = coin::value(&payment);
        // For testing, we'll just emit the swap event and destroy the payment
        events::emit_swap(
            *vector::borrow(&config.pools, 0), // Use first pool
            0, // SUI type
            amount,
            1, // Target token type
            amount,
            tx_context::epoch(ctx)
        );
        coin::destroy_zero(payment);
    }
}
