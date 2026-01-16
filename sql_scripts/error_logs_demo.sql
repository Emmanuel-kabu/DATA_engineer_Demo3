-- Demo script for error_logs
-- Run this after applying `inventory_schema_ddl.sql` so the `error_logs` table and `log_error()` function exist.

BEGIN;
-- Insert a test error log entry using the helper
SELECT log_error('ERROR', 'demo_script', 'Test error from demo script', '{"product_id": 123, "note": "test insert"}'::jsonb);
COMMIT;

-- Show the 10 most recent error logs
SELECT * FROM error_logs ORDER BY occurred_at DESC LIMIT 10;
