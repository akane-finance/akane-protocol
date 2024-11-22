module akane::events {
	use sui::event;
	use sui::object::ID;
	
	struct InvestmentMade has copy, drop {
		investor: address,
		strategy_id: u64,
		amount: u64,
		timestamp: u64
	}

	struct WithdrawalMade has copy, drop {
		investor: address,
		amount: u64,
		profit: u64,
		fees_paid: u64,
		timestamp: u64
	}

	struct StrategyRegistered has copy, drop {
		strategy_id: u64,
		name: vector<u8>,
		timestamp: u64
	}

	struct FeeCollected has copy, drop {
		amount: u64,
		fee_type: u64,
		from: address,
		timestamp: u64
	}

	struct PriceUpdate has copy, drop {
		token_type: u64,
		price: u64,
		timestamp: u64
	}

	struct SwapEvent has copy, drop {
		pool_id: ID,
		coin_in_type: u64,
		coin_in_amount: u64,
		coin_out_type: u64,
		coin_out_amount: u64,
		timestamp: u64
	}

	public fun emit_investment(investor: address, strategy_id: u64, amount: u64, timestamp: u64) {
		event::emit(InvestmentMade {
			investor,
			strategy_id,
			amount,
			timestamp
		})
	}

	public fun emit_withdrawal(investor: address, amount: u64, profit: u64, fees_paid: u64, timestamp: u64) {
		event::emit(WithdrawalMade {
			investor,
			amount,
			profit,
			fees_paid,
			timestamp
		})
	}

	public fun emit_strategy_registered(strategy_id: u64, name: vector<u8>, timestamp: u64) {
		event::emit(StrategyRegistered {
			strategy_id,
			name,
			timestamp
		})
	}

	public fun emit_fee_collection(amount: u64, fee_type: u64, from: address, timestamp: u64) {
		event::emit(FeeCollected {
			amount,
			fee_type,
			from,
			timestamp
		})
	}

	public fun emit_price_update(token_type: u64, price: u64, timestamp: u64) {
		event::emit(PriceUpdate {
			token_type,
			price,
			timestamp
		})
	}

	public fun emit_swap(pool_id: ID, coin_in_type: u64, coin_in_amount: u64, coin_out_type: u64, coin_out_amount: u64, timestamp: u64) {
		event::emit(SwapEvent {
			pool_id,
			coin_in_type,
			coin_in_amount,
			coin_out_type,
			coin_out_amount,
			timestamp
		})