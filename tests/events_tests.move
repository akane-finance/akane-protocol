
#[test_only]
module akane::events_tests {
	use sui::test_scenario::{Self as test, Scenario};
	use sui::test_utils::assert_events_emit;
	use sui::object::ID;
	use akane::events::{Self, InvestmentMade, WithdrawalMade, StrategyRegistered, FeeCollected, PriceUpdate, SwapEvent};
	use std::vector;

	const TEST_ADMIN: address = @0xA11CE;
	const TEST_INVESTOR: address = @0xB0B;

	#[test]
	fun test_investment_event() {
		let scenario = test::begin(TEST_ADMIN);
		
		// Test investment event emission
		test::next_tx(&mut scenario, TEST_INVESTOR);
		{
			let timestamp = 1000;
			events::emit_investment(TEST_INVESTOR, 1, 1000, timestamp);
			
			assert_events_emit!(
				InvestmentMade {
					investor: TEST_INVESTOR,
					strategy_id: 1,
					amount: 1000,
					timestamp
				}
			);
		};
		test::end(scenario);
	}

	#[test]
	fun test_withdrawal_event() {
		let scenario = test::begin(TEST_ADMIN);
		
		test::next_tx(&mut scenario, TEST_INVESTOR);
		{
			let timestamp = 1000;
			events::emit_withdrawal(TEST_INVESTOR, 1000, 100, 10, timestamp);
			
			assert_events_emit!(
				WithdrawalMade {
					investor: TEST_INVESTOR,
					amount: 1000,
					profit: 100,
					fees_paid: 10,
					timestamp
				}
			);
		};
		test::end(scenario);
	}

	#[test]
	fun test_strategy_registration_event() {
		let scenario = test::begin(TEST_ADMIN);
		
		test::next_tx(&mut scenario, TEST_ADMIN);
		{
			let timestamp = 1000;
			let strategy_name = b"Test Strategy";
			events::emit_strategy_registered(1, strategy_name, timestamp);
			
			assert_events_emit!(
				StrategyRegistered {
					strategy_id: 1,
					name: strategy_name,
					timestamp
				}
			);
		};
		test::end(scenario);
	}

	#[test]
	fun test_fee_collection_event() {
		let scenario = test::begin(TEST_ADMIN);
		
		test::next_tx(&mut scenario, TEST_ADMIN);
		{
			let timestamp = 1000;
			events::emit_fee_collection(100, 1, TEST_INVESTOR, timestamp);
			
			assert_events_emit!(
				FeeCollected {
					amount: 100,
					fee_type: 1,
					from: TEST_INVESTOR,
					timestamp
				}
			);
		};
		test::end(scenario);
	}

	#[test]
	fun test_price_update_event() {
		let scenario = test::begin(TEST_ADMIN);
		
		test::next_tx(&mut scenario, TEST_ADMIN);
		{
			let timestamp = 1000;
			events::emit_price_update(1, 50000, timestamp);
			
			assert_events_emit!(
				PriceUpdate {
					token_type: 1,
					price: 50000,
					timestamp
				}
			);
		};
		test::end(scenario);
	}

	#[test]
	fun test_swap_event() {
		let scenario = test::begin(TEST_ADMIN);
		
		test::next_tx(&mut scenario, TEST_ADMIN);
		{
			let timestamp = 1000;
			let pool_id = ID::new(@0x123);
			events::emit_swap(pool_id, 1, 1000, 2, 500, timestamp);
			
			assert_events_emit!(
				SwapEvent {
					pool_id,
					coin_in_type: 1,
					coin_in_amount: 1000,
					coin_out_type: 2,
					coin_out_amount: 500,
					timestamp
				}
			);
		};
		test::end(scenario);
	}
}