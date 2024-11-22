module sui_hedge_fund::constants {
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
}