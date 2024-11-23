module akane::gaming_strategy {
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    use sui::transfer;
    use akane::strategy_interface::{Self, StrategyInfo};
    use akane::constants;

    struct GamingStrategy has key {
        id: UID,
        info: StrategyInfo
    }

    #[lint_allow(share_owned)]
    public entry fun initialize(ctx: &mut TxContext) {
        // Create allocations
        let allocations = vector[
            strategy_interface::create_allocation(constants::eth_token(), 30),
            strategy_interface::create_allocation(constants::sol_token(), 40),
            strategy_interface::create_allocation(constants::sui_token(), 30)
        ];

        // Create and share strategy
        let strategy = GamingStrategy {
            id: object::new(ctx),
            info: strategy_interface::create_strategy_info(
                b"Gaming Strategy",
                b"A high-risk strategy focusing on gaming and metaverse tokens",
                allocations,
                constants::min_investment(),
                4 // Higher risk
            )
        };
        
        transfer::share_object(strategy);
    }

    public fun get_info(strategy: &GamingStrategy): &StrategyInfo {
        &strategy.info
    }
}