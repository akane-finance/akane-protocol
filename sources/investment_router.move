module akane::investment_router {
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

    const ERR_PAUSED: u64 = 100;
    const MAX_SLIPPAGE: u64 = 1000; // 10% max slippage

    public fun initialize(
        pools: vector<ID>,
        fee_collector: address,
        ctx: &mut TxContext
    ) {
        assert!(vector::length(&pools) >= 2, 0); // At least 2 pools needed
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
        assert!(!config.paused, ERR_PAUSED);
        assert!(slippage_tolerance <= MAX_SLIPPAGE, constants::ERR_SLIPPAGE_TOO_HIGH);
        
        let strategy = strategy_registry::get_strategy_info(registry, strategy_id);
        let amount = coin::value(&payment);
        assert!(amount >= strategy_interface::get_min_investment(strategy), 
            constants::ERR_INSUFFICIENT_AMOUNT);

        // Process investment with fee collection
        let fee_amount = (amount * constants::INITIAL_FEE_PERCENTAGE) / constants::FEE_DENOMINATOR;
        let investment_amount = amount - fee_amount;
        
        if (fee_amount > 0) {
            let fee_coin = coin::split(&mut payment, fee_amount, ctx);
            transfer::transfer(fee_coin, config.fee_collector);
        };

        // Execute strategy allocations
        process_allocations(config, strategy, payment, slippage_tolerance, ctx);
        
        events::emit_investment(
            tx_context::sender(ctx),
            strategy_id,
            amount,
            tx_context::epoch(ctx)
        );
    }

    fun process_allocations(
        config: &RouterConfig,
        strategy: &StrategyInfo,
        payment: Coin<SUI>,
        slippage_tolerance: u64,
        ctx: &mut TxContext
    ) {
        let allocations = strategy_interface::get_allocations(strategy);
        let total_amount = coin::value(&payment);
        let i = 0;
        let len = vector::length(&allocations);
        
        while (i < len) {
            let allocation = vector::borrow(&allocations, i);
            let amount = (total_amount * (allocation.percentage as u64)) / 100;
            
            if (amount > 0) {
                let coin_split = coin::split(&mut payment, amount, ctx);
                execute_swap(
                    config,
                    allocation.token,
                    coin_split,
                    slippage_tolerance,
                    ctx
                );
            };
            i = i + 1;
        };

        // Return dust if any
        if (coin::value(&payment) > 0) {
            transfer::transfer(payment, tx_context::sender(ctx));
        } else {
            coin::destroy_zero(payment);
        };
    }

    // Implementation specific swap logic would go here
    fun execute_swap(
        _config: &RouterConfig,
        _token: u8,
        _payment: Coin<SUI>,
        _slippage: u64,
        _ctx: &mut TxContext
    ) {
        // Implement actual swap logic
        abort 0
    }
}