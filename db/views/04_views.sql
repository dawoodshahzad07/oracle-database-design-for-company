-- Employee projects and hours (with per-employee total)
CREATE OR REPLACE VIEW vw_employee_project_hours AS
SELECT
  e.employee_id,
  e.first_name,
  e.last_name,
  p.project_id,
  p.name AS project_name,
  w.hours_per_week,
  SUM(w.hours_per_week) OVER (PARTITION BY e.employee_id) AS total_hours_per_employee
FROM works_on w
JOIN employee e ON e.employee_id = w.employee_id
JOIN project p ON p.project_id = w.project_id;

-- Department manager tenure (current and historical)
CREATE OR REPLACE VIEW vw_department_manager_tenure AS
SELECT
  d.department_id,
  d.name AS department_name,
  e.employee_id,
  e.first_name,
  e.last_name,
  dm.start_date,
  dm.end_date,
  (NVL(dm.end_date, TRUNC(SYSDATE)) - dm.start_date) AS tenure_days
FROM department_manager dm
JOIN department d ON d.department_id = dm.department_id
JOIN employee e ON e.employee_id = dm.employee_id;

-- Customer sales summary (orders, revenue, salesperson)
CREATE OR REPLACE VIEW vw_customer_sales_summary AS
SELECT
  c.customer_id,
  c.name AS customer_name,
  e.employee_id AS salesperson_id,
  e.first_name AS salesperson_first_name,
  e.last_name  AS salesperson_last_name,
  COUNT(DISTINCT so.order_id) AS num_orders,
  NVL(SUM(oi.quantity * oi.unit_price), 0) AS total_revenue
FROM customer c
LEFT JOIN employee e ON e.employee_id = c.salesperson_id
LEFT JOIN sales_order so ON so.customer_id = c.customer_id
LEFT JOIN order_item oi ON oi.order_id = so.order_id
GROUP BY c.customer_id, c.name, e.employee_id, e.first_name, e.last_name;

-- Inventory by warehouse with product
CREATE OR REPLACE VIEW vw_inventory_by_warehouse AS
SELECT
  w.warehouse_id,
  w.name AS warehouse_name,
  p.product_id,
  p.sku,
  p.name AS product_name,
  i.quantity
FROM inventory i
JOIN warehouse w ON w.warehouse_id = i.warehouse_id
JOIN product p ON p.product_id = i.product_id; 