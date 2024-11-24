#[test_only]
module akane::investment_router_tests {
    use std::debug;
    use std::vector;
    
    use sui::test_scenario::{Self as test, Scenario, next_tx, ctx};
    use sui::clock;
    
    use akane::investment_router::{Self, RouterConfig};
    use akane::strategy_registry::{Self, StrategyRegistry, RegistryCap};
    use akane::strategy_interface;
    use akane::constants;

    // Test addresses
    const TEST_SENDER: address = @0xA11CE;
    const FEE_COLLECTOR: address = @0xFEE;

    // Test constants
    const EXPECTED_RISK_LEVEL: u8 = 4;
    const BTC_ALLOCATION: u8 = 60;
    const ETH_ALLOCATION: u8 = 40;

    fun setup_scenario(): Scenario {
        let scenario = test::begin(TEST_SENDER);
        let test = &mut scenario;
        
        // Initialize core components
        {
            strategy_registry::initialize(ctx(test));
            investment_router::initialize(FEE_COLLECTOR, ctx(test));
        };

        // Set up crypto strategy
        next_tx(test, TEST_SENDER);
        {
            let registry = test::take_shared<StrategyRegistry>(test);
            let cap = test::take_from_sender<RegistryCap>(test);
            
            strategy_registry::register_crypto_strategy(
                &mut registry,
                &cap,
                1, // strategy_id
                BTC_ALLOCATION,
                ETH_ALLOCATION,
                ctx(test)
            );
            
            test::return_to_sender(test, cap);
            test::return_shared(registry);
        };

        scenario
    }

    #[test]
    fun test_crypto_strategy_setup() {
        let scenario = setup_scenario();
        let test = &mut scenario;

        // Verify strategy setup
        next_tx(test, TEST_SENDER);
        {
            let registry = test::take_shared<StrategyRegistry>(test);
            let config = test::take_shared<RouterConfig>(test);
            
            let test_clock = clock::create_for_testing(ctx(test));
            clock::set_for_testing(&mut test_clock, 1000);

            // Verify strategy details
            let strategy = strategy_registry::get_strategy_info(&registry, 1);
            let allocations = strategy_interface::get_allocations(strategy);
            
            debug::print(&b"Strategy allocations:");
            debug::print(&allocations);

            // Verify allocations length
            assert!(vector::length(&allocations) == 2, 0);

            // Verify allocation tokens and percentages
            let first_allocation = vector::borrow(&allocations, 0);
            let second_allocation = vector::borrow(&allocations, 1);

            assert!(
                strategy_interface::get_allocation_token(first_allocation) == constants::btc_token() &&
                strategy_interface::get_allocation_token(second_allocation) == constants::eth_token(),
                1
            );

            assert!(
                strategy_interface::get_allocation_percentage(first_allocation) == BTC_ALLOCATION &&
                strategy_interface::get_allocation_percentage(second_allocation) == ETH_ALLOCATION,
                2
            );

            // Verify strategy risk level
            let risk_level = strategy_interface::get_risk_level(strategy);
            debug::print(&b"Strategy risk level:");
            debug::print(&risk_level);
            assert!(risk_level == EXPECTED_RISK_LEVEL, 3);

            // Clean up
            clock::destroy_for_testing(test_clock);
            
            test::return_shared(registry);
            test::return_shared(config);
        };

        test::end(scenario);
    }
}