module akane::crypto_strategy {
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    use akane::strategy_interface::{Self, StrategyInfo};
    use akane::constants;

    struct CryptoStrategy has key, store {
        id: UID,
        info: StrategyInfo
    }

    public fun initialize(_ctx: &mut TxContext): CryptoStrategy {
        let allocations = strategy_interface::create_allocations(vector[
            strategy_interface::create_allocation_input(constants::btc_token(), 60),
            strategy_interface::create_allocation_input(constants::eth_token(), 40)
        ]);

        CryptoStrategy {
            id: object::new(_ctx),
            info: strategy_interface::create_strategy_info(
                b"Crypto Strategy",
                b"A conservative strategy focusing on blue-chip cryptocurrencies with 60% BTC and 40% ETH allocation",
                allocations,
                constants::min_investment(),
                2 // Lower risk
            )
        }
    }

    public fun get_info(strategy: &CryptoStrategy): StrategyInfo {
        strategy.info
    }
}
