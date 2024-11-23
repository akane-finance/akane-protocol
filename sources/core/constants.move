module akane::constants {
    // Error codes
    const ERR_UNAUTHORIZED: u64 = 1;
    const ERR_STRATEGY_EXISTS: u64 = 2;
    const ERR_STRATEGY_NOT_FOUND: u64 = 3;
    const ERR_INSUFFICIENT_AMOUNT: u64 = 4;
    const ERR_SLIPPAGE_TOO_HIGH: u64 = 5;

    // Public accessors for error codes
    public fun err_unauthorized(): u64 { ERR_UNAUTHORIZED }
    public fun err_strategy_exists(): u64 { ERR_STRATEGY_EXISTS }
    public fun err_strategy_not_found(): u64 { ERR_STRATEGY_NOT_FOUND }
    public fun err_insufficient_amount(): u64 { ERR_INSUFFICIENT_AMOUNT }
    public fun err_slippage_too_high(): u64 { ERR_SLIPPAGE_TOO_HIGH }

    // Configuration constants
    const MIN_INVESTMENT: u64 = 1_000_000; // 1 SUI
    const INITIAL_FEE_PERCENTAGE: u64 = 100; // 1%
    const FEE_DENOMINATOR: u64 = 10_000;

    // Public accessors for configuration constants
    public fun min_investment(): u64 { MIN_INVESTMENT }
    public fun initial_fee_percentage(): u64 { INITIAL_FEE_PERCENTAGE }
    public fun fee_denominator(): u64 { FEE_DENOMINATOR }

    // Token identifiers
    public fun btc_token(): vector<u8> {
        b"BTC"
    }

    public fun eth_token(): vector<u8> {
        b"ETH"
    }

    public fun sol_token(): vector<u8> {
        b"SOL"
    }

    public fun avax_token(): vector<u8> {
        b"AVAX"
    }

    public fun sui_token(): vector<u8> {
        b"SUI"
    }
}
