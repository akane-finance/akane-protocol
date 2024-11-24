#[test_only]
module akane::router_test_utils {
    use sui::test_scenario::{Self as test};
    use sui::tx_context::TxContext;
    
    use akane::investment_router;

    const TEST_FEE_COLLECTOR: address = @0xFEE;
    const TEST_SENDER: address = @0xA11CE;
    
    public fun setup_test_router(ctx: &mut TxContext) {
        investment_router::init_for_testing(TEST_FEE_COLLECTOR, ctx)
    }

    #[test]
    fun test_router_initialization() {
        let scenario = test::begin(TEST_SENDER);
        let test = &mut scenario;
        setup_test_router(test::ctx(test));
        test::end(scenario);
    }

    #[test]
    fun test_full_setup() {
        let scenario = test::begin(TEST_SENDER);
        let test = &mut scenario;

        // Initialize router
        setup_test_router(test::ctx(test));

        // Add additional setup verification here

        test::end(scenario);
    }
}