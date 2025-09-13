# Company Database Project (Oracle + PL/SQL + Flask)

This project implements the "Company Database" (ERD, DDL/DML, PL/SQL, views, and a minimal front-end).

## Contents
- `db/ddl/`: Tables and constraints
- `db/dml/`: Sample data
- `db/plsql/`: Procedures, functions, triggers
- `db/views/`: Views
- `data/csv/`: Example CSVs (optional)
- `docs/erd/`: ERD versions (Mermaid)
- `app/`: Minimal Flask app using `oracledb`
- `screenshots/`: Placeholder for app screenshots

## Prerequisites
- Oracle Database XE 18c/19c+ (or an accessible Oracle instance)
- Oracle user/schema (example: `COMPANY_APP`)
- Python 3.10+

## 1) Create/Reset Schema
Execute these scripts in order (in SQL*Plus/SQLcl/SQL Developer) connected as your application schema:

1. `@db/ddl/00_drop_all.sql` (optional during development)
2. `@db/ddl/01_tables.sql`
3. `@db/views/04_views.sql`
4. `@db/plsql/types.sql` (if any types are used)
5. `@db/plsql/functions.sql`
6. `@db/plsql/procedures.sql`
7. `@db/plsql/triggers.sql`
8. Seed data:
   - `@db/dml/01_seed_core.sql`
   - `@db/dml/02_seed_relationships.sql`
   - `@db/dml/03_seed_orders.sql`

## 2) Run Queries/Views (Examples)
- See `db/views/04_views.sql` and the demonstration queries at the end of each seed script.

## 3) Run the Flask App
```
cd app
python -m venv .venv
. .venv/Scripts/activate  # Windows PowerShell: .venv\Scripts\Activate.ps1
pip install -r requirements.txt

# Set environment variables (adjust for your Oracle instance)
$env:ORACLE_DSN = "localhost/XEPDB1"  # or HOST:PORT/SERVICE
$env:ORACLE_USER = "COMPANY_APP"
$env:ORACLE_PASSWORD = "your_password"

# Run
python app.pyimage.png
```
Open http://127.0.0.1:5000

Pages:
- `/employees`, `/projects`, `/works_on`, `/customers`, `/orders`
- `/orders/new` places an order via PL/SQL (`place_order_json`)

## Notes
- Names are singular (`employee`, `project`, ...). PKs are `table_name_id`.
- Some business rules are enforced via PL/SQL (e.g., one active manager per department, project location must belong to same department, salesperson must be in Sales).
- Sample data is small and easy to inspect. You can scale it up as needed.

## Import/Export
- Use CSVs in `data/csv/` or the seed scripts.
- You can export query results from SQL Developer as CSV for reporting.

## Troubleshooting
- If objects already exist, run `00_drop_all.sql` first.
- Ensure your Oracle client is installed/configured so `python-oracledb` can connect (thin mode usually works out-of-the-box). 
