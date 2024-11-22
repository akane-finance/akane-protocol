module akane::oracle {
    use sui::object::{Self, UID};
    use sui::table::{Self, Table};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use akane::events;

    struct PriceOracle has key {
        id: UID,
        prices: Table<u8, Price>,
        last_update: u64,
        owner: address
    }

    struct Price has store, drop {
        value: u64,
        decimals: u8,
        last_update: u64
    }

    struct OracleAdminCap has key, store {
        id: UID
    }

    public fun initialize(ctx: &mut TxContext): OracleAdminCap {
        let owner = tx_context::sender(ctx);
        
        let oracle = PriceOracle {
            id: object::new(ctx),
            prices: table::new(ctx),
            last_update: 0,
            owner
        };

        transfer::share_object(oracle);
        
        let admin_cap = OracleAdminCap {
            id: object::new(ctx)
        };
        
        admin_cap
    }

    public fun update_price(
        _cap: &OracleAdminCap,
        oracle: &mut PriceOracle,
        token_type: u8,
        new_price: u64,
        ctx: &mut TxContext
    ) {
        let timestamp = tx_context::epoch(ctx);
        
        let price = Price {
            value: new_price,
            decimals: 8,
            last_update: timestamp
        };

        if (table::contains(&oracle.prices, token_type)) {
            table::remove(&mut oracle.prices, token_type);
        };
        table::add(&mut oracle.prices, token_type, price);
        oracle.last_update = timestamp;

        events::emit_price_update(token_type, new_price, timestamp);
    }

    public fun get_price(oracle: &PriceOracle, token_type: u8): (u64, u8) {
        let price = table::borrow(&oracle.prices, token_type);
        (price.value, price.decimals)
    }
}