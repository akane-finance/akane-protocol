module akane::gaming_strategy {
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    use akane::strategy_interface::{Self, StrategyInfo};
    use akane::constants;

    struct GamingStrategy has key {
        id: UID,
        info: StrategyInfo
    }

    public fun initialize(ctx: &mut TxContext): GamingStrategy {
        let allocations = vector[
            strategy_interface::create_allocation(constants::eth_token(), 30),
            strategy_interface::create_allocation(constants::sol_token(), 40),
            strategy_interface::create_allocation(constants::sui_token(), 30)
        ];

        GamingStrategy {
            id: object::new(ctx),
            info: strategy_interface::create_strategy_info(
                b"Gaming Strategy",
                b"A high-risk strategy focusing on gaming and metaverse tokens",
                allocations,
                constants::min_investment(),
                4 // Higher risk
            )
        }
    }

    public fun get_info(strategy: &GamingStrategy): &StrategyInfo {
        &strategy.info
    }
}
