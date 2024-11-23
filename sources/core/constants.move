// Previous constants.move had unnecessary getters
module akane::constants {
    // Token types - can be direct constants
    public const BTC: u8 = 1;
    public const ETH: u8 = 2;
    public const SOL: u8 = 3;
    public const SUI: u8 = 4;
    public const AVAX: u8 = 5;

    // Fee configuration
    public const INITIAL_FEE_PERCENTAGE: u64 = 5; // 0.5%
    public const PROFIT_FEE_PERCENTAGE: u64 = 5;  // 5%
    public const FEE_DENOMINATOR: u64 = 1000;
    public const PROFIT_FEE_DENOMINATOR: u64 = 100;

    // Minimum investments
    public const MIN_INVESTMENT: u64 = 100_000_000; // 100 SUI

    // Error codes
    public const ERR_UNAUTHORIZED: u64 = 1;
    public const ERR_INVALID_STRATEGY: u64 = 2;
    public const ERR_INSUFFICIENT_AMOUNT: u64 = 3;
    public const ERR_STRATEGY_EXISTS: u64 = 4;
    public const ERR_STRATEGY_NOT_FOUND: u64 = 5;
    public const ERR_INVALID_ALLOCATION: u64 = 6;
    public const ERR_SLIPPAGE_TOO_HIGH: u64 = 7;
}