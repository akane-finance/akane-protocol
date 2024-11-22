module sui_hedge_fund::gaming_strategy {
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    use sui_hedge_fund::strategy_interface::{Self, StrategyInfo, Allocation};
    use sui_hedge_fund::constants;
    use std::vector;

    struct GamingStrategy has key {
        id: UID,
        info: StrategyInfo
    }

    public fun initialize(ctx: &mut TxContext): GamingStrategy {
        let allocations = vector[
            Allocation { token_type: constants::ETH, target_percentage: 30 },
            Allocation { token_type: constants::AVAX, target_percentage: 25 },
            Allocation { token_type: constants::SOL, target_percentage: 25 },
            Allocation { token_type: constants::SUI, target_percentage: 20 }
        ];

        GamingStrategy {
            id: object::new(ctx),
            info: strategy_interface::create_strategy_info(
                b"Web3 Gaming Strategy",
                b"Multi-chain gaming portfolio with 30% ETH for established ecosystems, equal 25% allocations to AVAX and SOL for high-performance gaming chains, and 20% SUI for emerging gaming platforms",
                allocations,
                constants::MIN_INVESTMENT,
                4 // Higher risk due to gaming sector volatility
            )
        }
    }

    public fun get_info(strategy: &GamingStrategy): &StrategyInfo {
        &strategy.info
    }
}