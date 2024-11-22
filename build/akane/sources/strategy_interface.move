module akane::strategy_interface {
    use std::vector;
    
    struct StrategyInfo has store, copy, drop {
        name: vector<u8>,
        description: vector<u8>,
        allocations: vector<AllocationPair>,
        min_investment: u64,
        risk_level: u64
    }

    struct AllocationPair has store, copy, drop {
        token: u8,
        percentage: u64
    }

    struct AllocationInput has copy, drop {
        token: u8,
        percentage: u64
    }

    public fun create_allocation(token: u8, percentage: u64): AllocationPair {
        AllocationPair {
            token,
            percentage
        }
    }

    public fun create_allocation_input(token: u8, percentage: u64): AllocationInput {
        AllocationInput {
            token,
            percentage
        }
    }

    public fun create_allocations(inputs: vector<AllocationInput>): vector<AllocationPair> {
        let allocations = vector::empty();
        let i = 0;
        let len = vector::length(&inputs);
        
        while (i < len) {
            let input = vector::remove(&mut inputs, 0);
            vector::push_back(&mut allocations, AllocationPair { 
                token: input.token, 
                percentage: input.percentage 
            });
            i = i + 1;
        };
        
        allocations
    }



    public fun create_strategy_info(
        name: vector<u8>,
        description: vector<u8>,
        allocations: vector<AllocationPair>,
        min_investment: u64,
        risk_level: u64
    ): StrategyInfo {
        StrategyInfo {
            name,
            description,
            allocations,
            min_investment,
            risk_level
        }
    }

    public fun destroy_strategy_info(info: StrategyInfo) {
        let StrategyInfo { name: _, description: _, allocations: _, min_investment: _, risk_level: _ } = info;
    }

    // Getters
    public fun get_name(info: &StrategyInfo): vector<u8> { *&info.name }
    public fun get_description(info: &StrategyInfo): vector<u8> { *&info.description }
    public fun get_allocations(info: &StrategyInfo): vector<AllocationPair> { *&info.allocations }
    public fun get_min_investment(info: &StrategyInfo): u64 { info.min_investment }
    public fun get_risk_level(info: &StrategyInfo): u64 { info.risk_level }
}

