module akane::strategy_registry {
    use std::vector;
    use sui::object::{Self, UID};
    use sui::table::{Self, Table};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use akane::strategy_interface::{Self, StrategyInfo};
    use akane::events;
    use akane::constants;

    struct StrategyRegistry has key {
        id: UID,
        strategies: Table<u8, StrategyInfo>,
        strategy_count: u8,
        owner: address
    }

    struct RegistryCap has key {
        id: UID,
        registry_id: address
    }

    /// Initialize the strategy registry
    #[lint_allow(share_owned)]
    public entry fun initialize(ctx: &mut TxContext) {
        let owner = tx_context::sender(ctx);
        
        // Create registry
        let registry = StrategyRegistry {
            id: object::new(ctx),
            strategies: table::new(ctx),
            strategy_count: 0,
            owner
        };
        let registry_id = object::id_address(&registry);
        
        // Share registry
        transfer::share_object(registry);

        // Create and transfer cap with registry ID
        let cap = RegistryCap {
            id: object::new(ctx),
            registry_id
        };
        transfer::transfer(cap, owner);
    }

    /// Register a new gaming strategy
    public entry fun register_strategy(
        registry: &mut StrategyRegistry,
        cap: &RegistryCap,
        strategy_id: u8,
        ctx: &mut TxContext
    ) {
        // Verify cap matches registry and sender is owner
        assert!(cap.registry_id == object::id_address(registry), constants::err_unauthorized());
        assert!(tx_context::sender(ctx) == registry.owner, constants::err_unauthorized());
        assert!(!table::contains(&registry.strategies, strategy_id), constants::err_strategy_exists());
        
        let info = strategy_interface::create_strategy_info(
            b"Gaming Strategy",
            b"A high-risk strategy focusing on gaming and metaverse tokens",
            vector::empty(),
            constants::min_investment(),
            4
        );

        table::add(&mut registry.strategies, strategy_id, info);
        registry.strategy_count = registry.strategy_count + 1;

        events::emit_strategy_registered(
            strategy_id,
            strategy_interface::get_name(&info),
            tx_context::epoch(ctx)
        );
    }

    /// Register a new crypto strategy with BTC/ETH allocation
    public entry fun register_crypto_strategy(
        registry: &mut StrategyRegistry,
        cap: &RegistryCap,
        strategy_id: u8,
        btc_percentage: u8,
        eth_percentage: u8,
        ctx: &mut TxContext
    ) {
        // Verify cap matches registry and sender is owner
        assert!(cap.registry_id == object::id_address(registry), constants::err_unauthorized());
        assert!(tx_context::sender(ctx) == registry.owner, constants::err_unauthorized());
        assert!(!table::contains(&registry.strategies, strategy_id), constants::err_strategy_exists());
        assert!(btc_percentage + eth_percentage == 100, 1); // Percentages must add up to 100
        
        let allocations = vector::empty();
        vector::push_back(&mut allocations, strategy_interface::create_allocation(
            constants::btc_token(),
            btc_percentage
        ));
        vector::push_back(&mut allocations, strategy_interface::create_allocation(
            constants::eth_token(),
            eth_percentage
        ));

        let info = strategy_interface::create_strategy_info(
            b"Crypto Strategy",
            b"A conservative strategy focusing on blue-chip cryptocurrencies",
            allocations,
            constants::min_investment(),
            4
        );

        table::add(&mut registry.strategies, strategy_id, info);
        registry.strategy_count = registry.strategy_count + 1;

        events::emit_strategy_registered(
            strategy_id,
            strategy_interface::get_name(&info),
            tx_context::epoch(ctx)
        );
    }

    // Getters
    public fun get_strategy_count(registry: &StrategyRegistry): u8 {
        registry.strategy_count
    }

    public fun get_strategy_info(registry: &StrategyRegistry, id: u8): &StrategyInfo {
        assert!(table::contains(&registry.strategies, id), constants::err_strategy_not_found());
        table::borrow(&registry.strategies, id)
    }

    #[test_only]
    /// Get mutable reference to strategy info - only used in tests
    public fun get_strategy_info_mut(registry: &mut StrategyRegistry, id: u8): &mut StrategyInfo {
        assert!(table::contains(&registry.strategies, id), constants::err_strategy_not_found());
        table::borrow_mut(&mut registry.strategies, id)
    }
}