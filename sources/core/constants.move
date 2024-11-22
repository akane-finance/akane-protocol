module akane::constants {
    // Token types
    const BTC: u8 = 1;
    const ETH: u8 = 2;
    const SOL: u8 = 3;
    const SUI: u8 = 4;
    const AVAX: u8 = 5;

    // Fee configuration
    const INITIAL_FEE_PERCENTAGE: u64 = 5; // 0.5% = 5/1000
    const PROFIT_FEE_PERCENTAGE: u64 = 5;  // 5%
    const FEE_DENOMINATOR: u64 = 1000;     // Using 1000 for 0.1% precision
    const PROFIT_FEE_DENOMINATOR: u64 = 100;

    // Minimum investments
    const MIN_INVESTMENT: u64 = 100_000_000; // 100 SUI

    // Error codes
    const ERR_UNAUTHORIZED: u64 = 1;
    const ERR_INVALID_STRATEGY: u64 = 2;
    const ERR_INSUFFICIENT_AMOUNT: u64 = 3;
    const ERR_STRATEGY_EXISTS: u64 = 4;
    const ERR_STRATEGY_NOT_FOUND: u64 = 5;
    const ERR_INVALID_ALLOCATION: u64 = 6;
    const ERR_PAUSED: u64 = 7;
    const ERR_NO_INVESTMENT_FOUND: u64 = 8;
    const ERR_INVALID_AMOUNT: u64 = 9;
    const ERR_SLIPPAGE_TOO_HIGH: u64 = 10;

    // Public getters for token types
    public fun btc_token(): u8 { BTC }
    public fun eth_token(): u8 { ETH }
    public fun sol_token(): u8 { SOL }
    public fun sui_token(): u8 { SUI }
    public fun avax_token(): u8 { AVAX }

    // Public getters for fee configuration
    public fun initial_fee_percentage(): u64 { INITIAL_FEE_PERCENTAGE }
    public fun profit_fee_percentage(): u64 { PROFIT_FEE_PERCENTAGE }
    public fun fee_denominator(): u64 { FEE_DENOMINATOR }
    public fun profit_fee_denominator(): u64 { PROFIT_FEE_DENOMINATOR }

    // Public getter for minimum investment
    public fun min_investment(): u64 { MIN_INVESTMENT }

    // Public getters for error codes
    public fun err_unauthorized(): u64 { ERR_UNAUTHORIZED }
    public fun err_invalid_strategy(): u64 { ERR_INVALID_STRATEGY }
    public fun err_insufficient_amount(): u64 { ERR_INSUFFICIENT_AMOUNT }
    public fun err_strategy_exists(): u64 { ERR_STRATEGY_EXISTS }
    public fun err_strategy_not_found(): u64 { ERR_STRATEGY_NOT_FOUND }
    public fun err_invalid_allocation(): u64 { ERR_INVALID_ALLOCATION }
    public fun err_paused(): u64 { ERR_PAUSED }
    public fun err_no_investment_found(): u64 { ERR_NO_INVESTMENT_FOUND }
    public fun err_invalid_amount(): u64 { ERR_INVALID_AMOUNT }
    public fun err_slippage_too_high(): u64 { ERR_SLIPPAGE_TOO_HIGH }
}