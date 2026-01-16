DROP TABLE IF EXISTS products CASCADE;

DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS inventory CASCADE;
DROP TABLE IF EXISTS order_items CASCADE;

 --Creating tables for inventory management system
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    shipping_address  TEXT
);

CREATE TABLE products (
    product_id SERIAL PRIMARY KEY,
    product_name VARCHAR(100) NOT NULL,
    product_category TEXT,
    price DECIMAL(10, 2) NOT NULL CHECK (price >= 0)
);  

CREATE TABLE inventory (
    inventory_id SERIAL PRIMARY KEY,
    product_id INT NOT NULL UNIQUE REFERENCES products(product_id) ON DELETE CASCADE,
    quantity_in_stock INT NOT NULL CHECK (quantity_in_stock >= 0),
    last_restocked TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES customers(customer_id) ON DELETE RESTRICT,
    order_date TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    total_order_amount DECIMAL(10, 2) NOT NULL CHECK (total_order_amount >= 0),
    order_status VARCHAR(50) NOT NULL DEFAULT 'Pending' CHECK (order_status IN ('Pending', 'Shipped', 'Delivered', 'Cancelled'))
);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INT NOT NULL REFERENCES products(product_id) ON DELETE RESTRICT,
    quantity INT NOT NULL CHECK (quantity > 0),
    item_price DECIMAL(10, 2) NOT NULL CHECK (item_price >= 0)
);

-- Indexes for performance optimization
CREATE INDEX idx_product_category ON products(product_category);
CREATE INDEX idx_order_date ON orders(order_date);
CREATE INDEX idx_customer_id ON orders(customer_id);
CREATE INDEX idx_inventory_product_id ON inventory(product_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_product_id ON order_items(product_id);

-- Simple error logging table and helper function
-- Use `log_error(level, source, message, details)` to record failures or diagnostics.
-- `details` is optional JSON (Postgres `jsonb`).

DROP TABLE IF EXISTS error_logs CASCADE;
CREATE TABLE error_logs (
    error_id SERIAL PRIMARY KEY,
    occurred_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
    level VARCHAR(20) NOT NULL DEFAULT 'ERROR',
    source VARCHAR(200),
    message TEXT NOT NULL,
    details JSONB
);

-- Helper function to insert error log entries. Silently ignores failures to avoid cascading errors.
CREATE OR REPLACE FUNCTION log_error(p_level VARCHAR DEFAULT 'ERROR', p_source VARCHAR DEFAULT NULL, p_message TEXT, p_details JSONB DEFAULT NULL)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO error_logs(level, source, message, details)
    VALUES (COALESCE(p_level, 'ERROR'), p_source, p_message, p_details);
EXCEPTION WHEN OTHERS THEN
    -- swallow any error so logging doesn't break application flow
    NULL;
END;
$$;

-- Example usage:
-- SELECT log_error('ERROR', 'inventory_service', 'Failed to update stock', '{"product_id": 123, "attempt": 1}'::jsonb);

