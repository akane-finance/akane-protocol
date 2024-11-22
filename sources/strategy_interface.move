module sui_hedge_fund::strategy_interface {
    use sui::object::{Self, UID};
    use sui::tx_context::TxContext;
    use sui_hedge_fund::constants;
    use std::vector;

    struct StrategyInfo has store {
        name: vector<u8>,
        description: vector<u8>,
        allocations: vector<Allocation>,
        minimum_investment: u64,
        risk_level: u8, // 1-5, where 5 is highest risk
        enabled: bool
    }

    struct Allocation has store {
        token_type: u8,
        target_percentage: u8
    }

    struct AllocationResult has store {
        token_amounts: vector<TokenAmount>
    }

    struct TokenAmount has store {
        token_type: u8,
        amount: u64
    }

    public fun create_strategy_info(
        name: vector<u8>,
        description: vector<u8>,
        allocations: vector<Allocation>,
        minimum_investment: u64,
        risk_level: u8,
    ): StrategyInfo {
        // Validate allocations total to 100%
        let total_allocation = 0u8;
        let i = 0;
        let len = vector::length(&allocations);
        while (i < len) {
            let allocation = vector::borrow(&allocations, i);
            total_allocation = total_allocation + allocation.target_percentage;
            i = i + 1;
        };
        assert!(total_allocation == 100, constants::ERR_INVALID_ALLOCATION);

        StrategyInfo {
            name,
            description,
            allocations,
            minimum_investment,
            risk_level,
            enabled: true
        }
    }

    public fun calculate_allocations(
        info: &StrategyInfo,
        amount: u64
    ): AllocationResult {
        let token_amounts = vector::empty();
        let i = 0;
        let len = vector::length(&info.allocations);
        let remaining_amount = amount;
        
        while (i < len) {
            let allocation = vector::borrow(&info.allocations, i);
            let token_amount = if (i == len - 1) {
                remaining_amount
            } else {
                let alloc_amount = (amount * (allocation.target_percentage as u64)) / 100;
                remaining_amount = remaining_amount - alloc_amount;
                alloc_amount
            };

            vector::push_back(&mut token_amounts, TokenAmount {
                token_type: allocation.token_type,
                amount: token_amount
            });
            
            i = i + 1;
        };

        AllocationResult { token_amounts }
    }

    // Getter functions
    public fun get_name(info: &StrategyInfo): vector<u8> { info.name }
    public fun get_description(info: &StrategyInfo): vector<u8> { info.description }
    public fun get_allocations(info: &StrategyInfo): &vector<Allocation> { &info.allocations }
    public fun get_minimum_investment(info: &StrategyInfo): u64 { info.minimum_investment }
    public fun get_risk_level(info: &StrategyInfo): u8 { info.risk_level }
    public fun is_enabled(info: &StrategyInfo): bool { info.enabled }
    
    public fun disable_strategy(info: &mut StrategyInfo) {
        info.enabled = false;
    }

    public fun enable_strategy(info: &mut StrategyInfo) {
        info.enabled = true;
    }
}
