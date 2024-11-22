module sui_hedge_fund::strategy_registry {
    use sui::object::{Self, UID};
    use sui::table::{Self, Table};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui_hedge_fund::strategy_interface::StrategyInfo;
    use sui_hedge_fund::events;
    use sui_hedge_fund::constants;

    struct StrategyRegistry has key {
        id: UID,
        strategies: Table<u8, StrategyInfo>,
        strategy_count: u8,
        owner: address
    }

    struct RegistryCap has key, store {
        id: UID
    }

    public fun initialize(ctx: &mut TxContext) {
        let owner = tx_context::sender(ctx);
        
        let registry = StrategyRegistry {
            id: object::new(ctx),
            strategies: table::new(ctx),
            strategy_count: 0,
            owner
        };

        let cap = RegistryCap {
            id: object::new(ctx)
        };

        transfer::transfer(cap, owner);
        transfer::share_object(registry);
    }

    public fun register_strategy(
        registry: &mut StrategyRegistry,
        _cap: &RegistryCap,
        info: StrategyInfo,
        ctx: &mut TxContext
    ): u8 {
        assert!(tx_context::sender(ctx) == registry.owner, constants::ERR_UNAUTHORIZED);
        
        let strategy_id = registry.strategy_count + 1;
        assert!(!table::contains(&registry.strategies, strategy_id), constants::ERR_STRATEGY_EXISTS);
        
        table::add(&mut registry.strategies, strategy_id, info);
        registry.strategy_count = strategy_id;

        events::emit_strategy_registered(
            strategy_id,
            strategy_interface::get_name(&info),
            tx_context::epoch(ctx)
        );
        
        strategy_id
    }

    public fun get_strategy_info(
        registry: &StrategyRegistry,
        strategy_id: u8
    ): &StrategyInfo {
        assert!(table::contains(&registry.strategies, strategy_id), constants::ERR_STRATEGY_NOT_FOUND);
        table::borrow(&registry.strategies, strategy_id)
    }

    public fun get_strategy_count(registry: &StrategyRegistry): u8 {
        registry.strategy_count
    }

    public fun remove_strategy(
        registry: &mut StrategyRegistry,
        _cap: &RegistryCap,
        strategy_id: u8,
        ctx: &mut TxContext
    ) {
        assert!(tx_context::sender(ctx) == registry.owner, constants::ERR_UNAUTHORIZED);
        assert!(table::contains(&registry.strategies, strategy_id), constants::ERR_STRATEGY_NOT_FOUND);
        table::remove(&mut registry.strategies, strategy_id);
    }

    public fun update_strategy(
        registry: &mut StrategyRegistry,
        _cap: &RegistryCap,
        strategy_id: u8,
        new_info: StrategyInfo,
        ctx: &mut TxContext
    ) {
        assert!(tx_context::sender(ctx) == registry.owner, constants::ERR_UNAUTHORIZED);
        assert!(table::contains(&registry.strategies, strategy_id), constants::ERR_STRATEGY_NOT_FOUND);
        table::remove(&mut registry.strategies, strategy_id);
        table::add(&mut registry.strategies, strategy_id, new_info);
    }
}