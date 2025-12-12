# Inventory System — README

## Overview
This repository contains a small inventory management schema and sample queries for PostgreSQL. It includes:
- DDL: `sql_scripts/inventory_schema_ddl.sql` — table definitions and indexes
- DML: `sql_scripts/inventory_schema_dml.sql` — generated dummy data population (500+ rows per main table)
- Queries: `sql_scripts/inventory_queries.sql` — example analytics, views, and a stored procedure (review before running)

## Prerequisites
- PostgreSQL (recommended 12+)
- `psql` CLI available in PATH
- On Windows PowerShell

## Quick setup (PowerShell)
1. Create a PostgreSQL role and database (example uses `inventory_db`):

```powershell
# create DB and user using psql (run as postgres user or a superuser)
psql -U postgres -c "CREATE ROLE inventory_user WITH LOGIN PASSWORD 'strongpassword';"
psql -U postgres -c "CREATE DATABASE inventory_db OWNER inventory_user;"
```

2. Run the schema (DDL) to create tables and indexes:

```powershell
# run as the role that owns the DB (or postgres)
psql -U inventory_user -d inventory_db -f .\sql_scripts\inventory_schema_ddl.sql
```

3. Populate with dummy data (DML):

```powershell
# run the generated DML file
psql -U inventory_user -d inventory_db -f .\sql_scripts\inventory_schema_dml.sql
```

Notes:
- Do NOT use MySQL `USE` in PostgreSQL. Connect to the desired database with `-d` or `\c` in `psql`.
- The DML file uses PostgreSQL functions like `generate_series()` and `RANDOM()`.

## Verifying the data
You can run the quick counts to verify data loaded successfully:

```powershell
psql -U inventory_user -d inventory_db -c "SELECT COUNT(*) FROM customers;"
psql -U inventory_user -d inventory_db -c "SELECT COUNT(*) FROM products;"
psql -U inventory_user -d inventory_db -c "SELECT COUNT(*) FROM inventory;"
psql -U inventory_user -d inventory_db -c "SELECT COUNT(*) FROM orders;"
psql -U inventory_user -d inventory_db -c "SELECT COUNT(*) FROM order_items;"
```

Or run the verification query included at the end of `sql_scripts/inventory_schema_dml.sql`.

## Running example analytical queries
Run the queries in `sql_scripts/inventory_queries.sql` with:

```powershell
psql -U inventory_user -d inventory_db -f .\sql_scripts\inventory_queries.sql
```

## File locations
- `sql_scripts/inventory_schema_ddl.sql` — schema and indexes
- `sql_scripts/inventory_schema_dml.sql` — data population script (500+ records)
- `sql_scripts/inventory_queries.sql` — example queries and stored procedure (review/fix before use)
- `requirements.txt` — any Python/third-party requirements (if present)

## Next steps / Recommendations
- Review and correct the SQL in `inventory_queries.sql` to match the schema.
- Run the DDL first, then the DML.
- Use a dedicated DB user with limited privileges for testing.
- If you want, I can:
  - Fix `inventory_queries.sql` to match the schema.
  - Add a small script to run the setup automatically (PowerShell or Python).

---
README generated from repository SQL files on your machine. File: `README.md` in the repository root.
