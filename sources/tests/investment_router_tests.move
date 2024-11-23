#[test_only]
module akane::investment_router_tests {
    use sui::coin;
    use sui::sui::SUI;
    use sui::test_scenario::{Self as test, Scenario, next_tx, ctx};
    use sui::object::{Self, ID};
    use std::vector;
    use akane::investment_router;
    use akane::strategy_registry::{Self, StrategyRegistry};
    use akane::strategy_interface;
    use akane::constants;

    const TEST_SENDER: address = @0xA11CE;
    const FEE_COLLECTOR: address = @0xFEE;
    
    // Error codes for tests
    const ERR_INVALID_STATE: u64 = 1;

    fun test_scenario(): Scenario {
        test::begin(TEST_SENDER)
    }

    #[test]
    fun test_investment_flow() {
        let scenario = test_scenario();
        
        // Setup: Initialize registry and router
        let test = &mut scenario;
        {
            strategy_registry::initialize(ctx(test));
            
            // Create mock pools
            let pools = vector::empty<ID>();
            vector::push_back(&mut pools, object::id_from_address(@0xCAFE));
            vector::push_back(&mut pools, object::id_from_address(@0xBEEF));
            
            investment_router::initialize(pools, FEE_COLLECTOR, ctx(test));
        };

        // Register a strategy
        next_tx(test, TEST_SENDER);
        {
            let registry = test::take_shared<StrategyRegistry>(test);
            let cap = test::take_from_sender<strategy_registry::RegistryCap>(test);
            
            strategy_registry::register_strategy(&mut registry, &cap, 1, ctx(test));
            
            test::return_to_sender(test, cap);
            test::return_shared(registry);
        };

        // Make an investment
        next_tx(test, TEST_SENDER);
        {
            let registry = test::take_shared<StrategyRegistry>(test);
            let config = test::take_shared<investment_router::RouterConfig>(test);
            
            // Create test payment
            let payment = coin::mint_for_testing<SUI>(2_000_000, ctx(test));
            
            investment_router::invest(
                &registry,
                &config,
                1, // strategy_id
                payment,
                500, // 5% slippage
                ctx(test)
            );
            
            test::return_shared(registry);
            test::return_shared(config);
        };

        // Verify the investment state
        next_tx(test, TEST_SENDER);
        {
            let registry = test::take_shared<StrategyRegistry>(test);
            
            // Verify strategy count
            assert!(strategy_registry::get_strategy_count(&registry) == 1, ERR_INVALID_STATE);
            
            // Verify strategy details
            let strategy = strategy_registry::get_strategy_info(&registry, 1);
            assert!(strategy_interface::get_min_investment(strategy) == constants::min_investment(), ERR_INVALID_STATE);
            
            test::return_shared(registry);
        };
        
        test::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = 4, location = akane::investment_router)]
    fun test_investment_insufficient_amount() {
        let scenario = test_scenario();
        
        // Setup
        let test = &mut scenario;
        {
            strategy_registry::initialize(ctx(test));
            let pools = vector::empty<ID>();
            vector::push_back(&mut pools, object::id_from_address(@0xCAFE));
            vector::push_back(&mut pools, object::id_from_address(@0xBEEF));
            investment_router::initialize(pools, FEE_COLLECTOR, ctx(test));
        };

        // Register strategy
        next_tx(test, TEST_SENDER);
        {
            let registry = test::take_shared<StrategyRegistry>(test);
            let cap = test::take_from_sender<strategy_registry::RegistryCap>(test);
            strategy_registry::register_strategy(&mut registry, &cap, 1, ctx(test));
            test::return_to_sender(test, cap);
            test::return_shared(registry);
        };

        // Try investment with insufficient amount
        next_tx(test, TEST_SENDER);
        {
            let registry = test::take_shared<StrategyRegistry>(test);
            let config = test::take_shared<investment_router::RouterConfig>(test);
            
            let payment = coin::mint_for_testing<SUI>(100_000, ctx(test)); // Less than MIN_INVESTMENT
            
            investment_router::invest(
                &registry,
                &config,
                1,
                payment,
                500,
                ctx(test)
            );
            
            test::return_shared(registry);
            test::return_shared(config);
        };
        
        test::end(scenario);
    }
}