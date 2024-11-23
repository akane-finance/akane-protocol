
    module akane::strategy_interface {
        use std::vector;

        struct AllocationInput has copy, drop, store {
            token: vector<u8>,
            percentage: u8
        }

        struct Allocation has copy, drop, store {
            token: vector<u8>,
            percentage: u8
        }

        struct StrategyInfo has copy, drop, store {
            name: vector<u8>,
            description: vector<u8>,
            allocations: vector<Allocation>,
            min_investment: u64,
            risk_level: u8
        }

        // === Allocation Input Functions ===
        public fun create_allocation(token: vector<u8>, percentage: u8): Allocation {
            Allocation {
                token,
                percentage
            }
        }

        public fun create_allocation_input(token: vector<u8>, percentage: u8): AllocationInput {
            AllocationInput {
                token,
                percentage
            }
        }

        public fun create_allocations(inputs: vector<AllocationInput>): vector<Allocation> {
            let allocations = vector::empty<Allocation>();
            let i = 0;
            let len = vector::length(&inputs);
            
            while (i < len) {
                let input = vector::borrow(&inputs, i);
                vector::push_back(&mut allocations, Allocation {
                    token: input.token,
                    percentage: input.percentage
                });
                i = i + 1;
            };
            
            allocations
        }

        // === Strategy Info Creation ===
        public fun create_strategy_info(
            name: vector<u8>,
            description: vector<u8>,
            allocations: vector<Allocation>,
            min_investment: u64,
            risk_level: u8
        ): StrategyInfo {
            StrategyInfo {
                name,
                description,
                allocations,
                min_investment,
                risk_level
            }
        }

        // === Getters ===
        public fun get_allocations(info: &StrategyInfo): vector<Allocation> {
            info.allocations
        }

        public fun get_min_investment(info: &StrategyInfo): u64 {
            info.min_investment
        }

        public fun get_allocation_token(allocation: &Allocation): vector<u8> {
            allocation.token
        }

        public fun get_allocation_percentage(allocation: &Allocation): u8 {
            allocation.percentage
        }

        public fun get_risk_level(info: &StrategyInfo): u8 {
            info.risk_level
        }

        public fun get_name(info: &StrategyInfo): vector<u8> {
            info.name
        }

        public fun get_description(info: &StrategyInfo): vector<u8> {
            info.description
        }
    }

