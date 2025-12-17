-- Total revenue from all shipped or delivered orders
SELECT COALESCE(SUM(total_order_amount),0) AS total_revenue
FROM orders
WHERE order_status IN ('Shipped','Delivered');

-- Top 10 customers by total spending
SELECT c.customer_id, c.full_name, SUM(o.total_order_amount) AS total_spent
FROM customers c
JOIN orders o ON o.customer_id = c.customer_id
WHERE o.order_status IN ('Shipped','Delivered')
GROUP BY c.customer_id, c.full_name
ORDER BY total_spent DESC
LIMIT 10;


-- Best selling products by Quantity sold(top 5)
SELECT p.product_id, p.product_name, SUM(oi.quantity) AS total_quantity_sold
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status IN ('Shipped','Delivered')
GROUP BY p.product_id, p.product_name
ORDER BY total_quantity_sold DESC
LIMIT 5;


-- Analytical queries (window functions)
-- Revenue ranking of products within their categories
WITH product_revenue AS (
SELECT p.product_id, p.product_name, p.product_category, SUM(oi.quantity * oi.item_price) AS revenue
FROM products p
JOIN order_items oi ON oi.product_id = p.product_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status IN ('Shipped','Delivered')
GROUP BY p.product_id, p.product_name, p.product_category
)
SELECT
product_id,
product_name,
product_category,
revenue,
RANK() OVER (PARTITION BY product_category ORDER BY revenue DESC) AS revenue_rank_within_category
FROM product_revenue
ORDER BY product_category, revenue_rank_within_category;


-- Customer order frequency( previous order date alongside current order date)
SELECT
customer_id,
order_id,
order_date AS current_order_date,
LAG(order_date) OVER (PARTITION BY customer_id ORDER BY order_date) AS previous_order_date
FROM orders
ORDER BY customer_id, order_date;


-- Performance optimization- views and stored procedures
-- CustomerSalesSummary view
CREATE OR REPLACE VIEW customer_sales_summary AS
SELECT
c.customer_id,
c.full_name,
c.email,
COALESCE(SUM(o.total_order_amount),0) AS total_spent,
COUNT(o.order_id) FILTER (WHERE o.order_status IN ('Shipped','Delivered')) AS completed_orders_count
FROM customers c
LEFT JOIN orders o ON o.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name, c.email;


-- Example usage:
SELECT * FROM customer_sales_summary ORDER BY total_spent DESC LIMIT 10;


-- Stored Procedure: ProcessNewOrder
--This procedure performs the transactional logic to process a new order for a multiple products. It:
--Accepts customer_id, product_id, quantity.
--Checks inventory.
 --If sufficient: deducts inventory, creates an orders row and order_items row, calculates total.
CREATE OR REPLACE FUNCTION ProcessNewOrder_JSON(
    p_order JSONB
)
RETURNS TABLE (
    status TEXT,
    order_id INT,
    details JSONB
)
AS $proc$
DECLARE
    v_customer_id INT;
    v_order_id INT;
    v_item JSONB;
    v_product_id INT;
    v_quantity INT;
    v_price NUMERIC(10,2);
    v_stock INT;
    v_detail_list JSONB := '[]'::JSONB;
BEGIN
    -- Extract customer ID
    v_customer_id := (p_order->>'customer_id')::INT;

    IF v_customer_id IS NULL THEN
        RAISE EXCEPTION 'customer_id is required in the JSON input';
    END IF;

    -- Create new order (empty for now)
    INSERT INTO orders (customer_id, order_date, total_order_amount, order_status)
    VALUES (v_customer_id, now(), 0, 'Pending')
    RETURNING orders.order_id INTO v_order_id;

    -- Loop through all order items
    FOR v_item IN SELECT jsonb_array_elements(p_order->'items')
    LOOP
        v_product_id := (v_item->>'product_id')::INT;
        v_quantity   := (v_item->>'quantity')::INT;

        IF v_quantity <= 0 THEN
            RAISE EXCEPTION 'Quantity must be positive for product %', v_product_id;
        END IF;

        -- Get product price
        SELECT price INTO v_price
        FROM products
        WHERE product_id = v_product_id;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Product % not found', v_product_id;
        END IF;

        -- Stock check
        SELECT quantity_on_hand INTO v_stock
        FROM inventory
        WHERE product_id = v_product_id
        FOR UPDATE;

        IF v_stock < v_quantity THEN
            RAISE EXCEPTION 'Insufficient stock for product %: available %, requested %',
                v_product_id, v_stock, v_quantity;
        END IF;

        -- Deduct stock
        UPDATE inventory
        SET quantity_on_hand = quantity_on_hand - v_quantity
        WHERE product_id = v_product_id;

        -- Insert order item
        INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase)
        VALUES (v_order_id, v_product_id, v_quantity, v_price);

        -- Append details to JSON list
        v_detail_list := v_detail_list || jsonb_build_array(
            jsonb_build_object(
                'product_id', v_product_id,
                'quantity', v_quantity,
                'price', v_price,
                'status', 'added'
            )
        );
    END LOOP;

    -- Recalculate total order amount
    UPDATE orders
    SET total_amount = (
        SELECT COALESCE(SUM(quantity * item_price), 0)
        FROM order_items
        WHERE order_id = v_order_id
    )
    WHERE order_id = v_order_id;

    RETURN QUERY SELECT
        'Order processed successfully'::TEXT AS status,
        v_order_id AS order_id,
        v_detail_list AS details;

END;
$proc$ LANGUAGE plpgsql;

