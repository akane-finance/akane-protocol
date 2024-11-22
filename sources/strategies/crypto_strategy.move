module sui_hedge_fund::crypto_strategy {
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    use sui_hedge_fund::strategy_interface::{Self, StrategyInfo, Allocation};
    use sui_hedge_fund::constants;

    struct CryptoStrategy has key {
        id: UID,
        info: StrategyInfo
    }

    public fun initialize(ctx: &mut TxContext): CryptoStrategy {
        let allocations = vector[
            Allocation { token_type: constants::BTC, target_percentage: 60 },
            Allocation { token_type: constants::ETH, target_percentage: 40 }
        ];

        CryptoStrategy {
            id: object::new(ctx),
            info: strategy_interface::create_strategy_info(
                b"Crypto Strategy",
                b"A conservative strategy focusing on blue-chip cryptocurrencies with 60% BTC and 40% ETH allocation",
                allocations,
                constants::MIN_INVESTMENT,
                2 // Lower risk
            )
        }
    }

    public fun get_info(strategy: &CryptoStrategy): &StrategyInfo {
        &strategy.info
    }
}
