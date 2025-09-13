-- Seed: Departments
INSERT INTO department (name) VALUES ('Sales');
INSERT INTO department (name) VALUES ('Engineering');
INSERT INTO department (name) VALUES ('HR');
INSERT INTO department (name) VALUES ('Finance');
INSERT INTO department (name) VALUES ('Operations');

-- Seed: Locations (each tied to one department)
INSERT INTO location (department_id, address_line, city, postcode, country) SELECT department_id, '1 Market St', 'London', 'EC1A 1AA', 'UK' FROM department WHERE name = 'Sales';
INSERT INTO location (department_id, address_line, city, postcode, country) SELECT department_id, '100 Tech Park', 'Manchester', 'M1 1AB', 'UK' FROM department WHERE name = 'Engineering';
INSERT INTO location (department_id, address_line, city, postcode, country) SELECT department_id, '22 People Rd', 'Liverpool', 'L1 1AC', 'UK' FROM department WHERE name = 'HR';
INSERT INTO location (department_id, address_line, city, postcode, country) SELECT department_id, '77 Money Ave', 'Leeds', 'LS1 1AD', 'UK' FROM department WHERE name = 'Finance';
INSERT INTO location (department_id, address_line, city, postcode, country) SELECT department_id, '50 Ops Way', 'Bristol', 'BS1 1AE', 'UK' FROM department WHERE name = 'Operations';

-- Seed: Products
INSERT INTO product (sku, name, unit_price) VALUES ('SKU-100', 'Gadget Basic', 19.99);
INSERT INTO product (sku, name, unit_price) VALUES ('SKU-200', 'Gadget Pro', 49.99);
INSERT INTO product (sku, name, unit_price) VALUES ('SKU-300', 'Widget Mini', 9.99);
INSERT INTO product (sku, name, unit_price) VALUES ('SKU-400', 'Widget Plus', 29.99);
INSERT INTO product (sku, name, unit_price) VALUES ('SKU-500', 'Thingamajig', 99.99);

-- Seed: Warehouses
INSERT INTO warehouse (name, address_line, city, postcode, country) VALUES ('WH-North', '1 Depot Rd', 'Leeds', 'LS2 2AA', 'UK');
INSERT INTO warehouse (name, address_line, city, postcode, country) VALUES ('WH-South', '2 Depot Rd', 'Bristol', 'BS2 2AB', 'UK');
INSERT INTO warehouse (name, address_line, city, postcode, country) VALUES ('WH-East', '3 Depot Rd', 'London', 'E1 1AB', 'UK');

-- Seed: Inventory
INSERT INTO inventory (warehouse_id, product_id, quantity)
SELECT w.warehouse_id, p.product_id, 100
FROM warehouse w CROSS JOIN product p
WHERE w.name IN ('WH-North', 'WH-South')
  AND p.sku IN ('SKU-100','SKU-200','SKU-300');

INSERT INTO inventory (warehouse_id, product_id, quantity)
SELECT w.warehouse_id, p.product_id, 50
FROM warehouse w CROSS JOIN product p
WHERE w.name = 'WH-East'
  AND p.sku IN ('SKU-400','SKU-500');

-- Seed: Employees (5+ including Salespeople)
INSERT INTO employee (ni_number, first_name, last_name, email, phone, salary, date_of_birth, start_date, department_id)
SELECT 'NI1001', 'Alice', 'Smith', 'alice.smith@example.com', '+441234567890', 55000, DATE '1990-03-12', SYSDATE-4000, d.department_id FROM department d WHERE d.name='Sales';
INSERT INTO employee (ni_number, first_name, last_name, email, phone, salary, date_of_birth, start_date, department_id)
SELECT 'NI1002', 'Bob', 'Jones', 'bob.jones@example.com', '+441234567891', 65000, DATE '1988-06-25', SYSDATE-3000, d.department_id FROM department d WHERE d.name='Engineering';
INSERT INTO employee (ni_number, first_name, last_name, email, phone, salary, date_of_birth, start_date, department_id)
SELECT 'NI1003', 'Carol', 'Green', 'carol.green@example.com', '+441234567892', 60000, DATE '1992-01-05', SYSDATE-2000, d.department_id FROM department d WHERE d.name='Sales';
INSERT INTO employee (ni_number, first_name, last_name, email, phone, salary, date_of_birth, start_date, department_id)
SELECT 'NI1004', 'Dan', 'Brown', 'dan.brown@example.com', '+441234567893', 45000, DATE '1995-11-15', SYSDATE-1500, d.department_id FROM department d WHERE d.name='HR';
INSERT INTO employee (ni_number, first_name, last_name, email, phone, salary, date_of_birth, start_date, department_id)
SELECT 'NI1005', 'Eve', 'White', 'eve.white@example.com', '+441234567894', 70000, DATE '1985-08-30', SYSDATE-3500, d.department_id FROM department d WHERE d.name='Operations';

-- Supervisors
UPDATE employee e SET supervisor_id = (SELECT employee_id FROM employee WHERE ni_number='NI1001') WHERE e.ni_number='NI1003';
UPDATE employee e SET supervisor_id = (SELECT employee_id FROM employee WHERE ni_number='NI1002') WHERE e.ni_number IN ('NI1004','NI1005');

-- Seed: Customers (must point to Sales employees)
INSERT INTO customer (name, email, phone, salesperson_id)
SELECT 'Acme Corp', 'contact@acme.example', '+44111111111', e.employee_id FROM employee e JOIN department d ON d.department_id=e.department_id WHERE d.name='Sales' AND e.ni_number='NI1001';
INSERT INTO customer (name, email, phone, salesperson_id)
SELECT 'Beta Ltd', 'hello@beta.example', '+44222222222', e.employee_id FROM employee e JOIN department d ON d.department_id=e.department_id WHERE d.name='Sales' AND e.ni_number='NI1003';

COMMIT; 