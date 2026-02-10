-- test.sql
-- Demo script for ProcessNewOrder_JSON + error logging
-- Prereqs:
--   1) Run sql_scripts/inventory_schema_ddl.sql
--   2) Run sql_scripts/inventory_schema_dml.sql (or otherwise load customers/products/inventory)
--   3) Run sql_scripts/inventory_queries.sql (creates ProcessNewOrder_JSON)

-- 1) Happy path: create an order for an existing customer with a couple of items
BEGIN;
SELECT *
FROM ProcessNewOrder_JSON(
    '{
      "customer_id": 1,
      "items": [
        {"product_id": 1, "quantity": 1},
        {"product_id": 2, "quantity": 1}
      ]
    }'::jsonb
);
COMMIT;

-- 2) Failure path: non-existent customer (should return FAILED and log into error_logs)
BEGIN;
SELECT *
FROM ProcessNewOrder_JSON(
    '{
      "customer_id": 999999,
      "items": [
        {"product_id": 1, "quantity": 1}
      ]
    }'::jsonb
);
COMMIT;

-- 3) Show the most recent error logs (you should see the failure above)
SELECT error_id, occurred_at, level, source, message, details
FROM error_logs
ORDER BY occurred_at DESC
LIMIT 10;
