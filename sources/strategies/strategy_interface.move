module akane::strategy_interface {
    use std::vector;
    
    struct StrategyInfo has store, copy, drop {
        name: vector<u8>,
        description: vector<u8>,
        allocations: vector<AllocationPair>,
        min_investment: u64,
        risk_level: u8 // Changed to u8 since risk levels are small
    }

    struct AllocationPair has store, copy, drop {
        token: u8,
        percentage: u8 // Changed to u8 since percentages are 0-100
    }

    // Removed redundant AllocationInput struct
    public fun create_allocation(token: u8, percentage: u8): AllocationPair {
        assert!(percentage <= 100, 0); // Basic validation
        AllocationPair { token, percentage }
    }

    public fun create_strategy_info(
        name: vector<u8>,
        description: vector<u8>,
        allocations: vector<AllocationPair>,
        min_investment: u64,
        risk_level: u8
    ): StrategyInfo {
        // Validate total allocation = 100%
        let total = 0u8;
        let i = 0;
        let len = vector::length(&allocations);
        while (i < len) {
            total = total + vector::borrow(&allocations, i).percentage;
            i = i + 1;
        };
        assert!(total == 100, 0);
        
        StrategyInfo {
            name,
            description,
            allocations,
            min_investment,
            risk_level
        }
    }

    // Simplified getters
    public fun get_name(info: &StrategyInfo): &vector<u8> { &info.name }
    public fun get_description(info: &StrategyInfo): &vector<u8> { &info.description }
    public fun get_allocations(info: &StrategyInfo): &vector<AllocationPair> { &info.allocations }
    public fun get_min_investment(info: &StrategyInfo): u64 { info.min_investment }
    public fun get_risk_level(info: &StrategyInfo): u8 { info.risk_level }
}
