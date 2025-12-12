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
--This procedure performs the transactional logic to process a new order for a single product. It:
--Accepts customer_id, product_id, quantity.
--Checks inventory.
 --If sufficient: deducts inventory, creates an orders row and order_items row, calculates total.

-- PostgreSQL function
CREATE OR REPLACE FUNCTION process_new_order(p_customer_id INT, p_product_id INT, p_quantity INT)
RETURNS TABLE (result TEXT, new_order_id INT) AS $$
DECLARE
v_stock INT;
v_price DECIMAL(10,2);
v_order_id INT;
BEGIN
IF p_quantity <= 0 THEN
RAISE EXCEPTION 'Quantity must be positive';
END IF;


-- Check product exists and get price
SELECT price INTO v_price FROM products WHERE product_id = p_product_id;
IF NOT FOUND THEN
RAISE EXCEPTION 'Product with id % not found', p_product_id;
END IF;


-- Lock the inventory row to prevent race conditions
SELECT quantity_on_hand INTO v_stock FROM inventory WHERE product_id = p_product_id FOR UPDATE;
IF NOT FOUND THEN
RAISE EXCEPTION 'Inventory record for product % not found', p_product_id;
END IF;


IF v_stock < p_quantity THEN
RAISE EXCEPTION 'Insufficient stock for product %: available %, requested %', p_product_id, v_stock, p_quantity;
END IF;


-- Deduct inventory
UPDATE inventory SET quantity_on_hand = quantity_on_hand - p_quantity WHERE product_id = p_product_id;


-- Create order
INSERT INTO orders (customer_id, order_date, total_amount, order_status)
VALUES (p_customer_id, now(), 0, 'Pending')
RETURNING order_id INTO v_order_id;


-- Create order item
INSERT INTO order_items (order_id, product_id, quantity, price_at_purchase)
VALUES (v_order_id, p_product_id, p_quantity, v_price);

-- Update order total
UPDATE orders
SET total_order_amount = (SELECT SUM(quantity * price_at_purchase) FROM order_items WHERE order_id = v_order_id)
WHERE order_id = v_order_id;
RETURN QUERY SELECT 'Order processed successfully', v_order_id;
END;