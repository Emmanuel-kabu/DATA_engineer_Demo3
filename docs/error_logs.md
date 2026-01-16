# Error Logs — Usage

This short note explains how to test and query the `error_logs` feature added to the schema.

Files:
- `sql_scripts/inventory_schema_ddl.sql` — contains `error_logs` table and `log_error()` function.
- `sql_scripts/error_logs_demo.sql` — demo script to insert a test error and list recent logs.

Running the demo (PowerShell):

```powershell
psql -U inventory_user -d inventory_db -f .\sql_scripts\error_logs_demo.sql
```

Manual examples:

-- Insert an error manually using the helper
```sql
SELECT log_error('WARN', 'manual_test', 'Manual warning entry', '{"info":"manual"}'::jsonb);
```

-- Query recent errors
```sql
SELECT error_id, occurred_at, level, source, message, details
FROM error_logs
ORDER BY occurred_at DESC
LIMIT 50;
```

Notes:
- `details` is stored as `jsonb` and can hold structured diagnostic data.
- The `log_error()` function swallows exceptions during logging to avoid cascading failures.
