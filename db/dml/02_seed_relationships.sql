-- Seed: Projects (each in a department and at a location of the same department)
INSERT INTO project (department_id, location_id, name, start_date)
SELECT d.department_id, l.location_id, 'Sales CRM Upgrade', DATE '2023-01-01'
FROM department d JOIN location l ON l.department_id = d.department_id
WHERE d.name='Sales' AND l.city='London';

INSERT INTO project (department_id, location_id, name, start_date)
SELECT d.department_id, l.location_id, 'Platform Refactor', DATE '2023-06-01'
FROM department d JOIN location l ON l.department_id = d.department_id
WHERE d.name='Engineering' AND l.city='Manchester';

INSERT INTO project (department_id, location_id, name, start_date)
SELECT d.department_id, l.location_id, 'HR Policy Review', DATE '2023-02-15'
FROM department d JOIN location l ON l.department_id = d.department_id
WHERE d.name='HR' AND l.city='Liverpool';

-- Seed: Department Managers
DECLARE
  v_sales_id department.department_id%TYPE;
  v_eng_id   department.department_id%TYPE;
  v_ops_id   department.department_id%TYPE;
  v_emp_sales_mgr employee.employee_id%TYPE;
  v_emp_eng_mgr   employee.employee_id%TYPE;
BEGIN
  SELECT department_id INTO v_sales_id FROM department WHERE name='Sales';
  SELECT department_id INTO v_eng_id   FROM department WHERE name='Engineering';
  SELECT department_id INTO v_ops_id   FROM department WHERE name='Operations';

  SELECT employee_id INTO v_emp_sales_mgr FROM employee WHERE ni_number='NI1001';
  SELECT employee_id INTO v_emp_eng_mgr   FROM employee WHERE ni_number='NI1002';

  assign_department_manager(v_sales_id, v_emp_sales_mgr, DATE '2022-01-01');
  assign_department_manager(v_eng_id,   v_emp_eng_mgr,   DATE '2021-05-01');
END;
/

-- Seed: Works_On
INSERT INTO works_on (employee_id, project_id, hours_per_week)
SELECT e.employee_id, p.project_id, 20
FROM employee e, project p
WHERE e.ni_number='NI1001' AND p.name='Sales CRM Upgrade';

INSERT INTO works_on (employee_id, project_id, hours_per_week)
SELECT e.employee_id, p.project_id, 25
FROM employee e, project p
WHERE e.ni_number='NI1003' AND p.name='Sales CRM Upgrade';

INSERT INTO works_on (employee_id, project_id, hours_per_week)
SELECT e.employee_id, p.project_id, 30
FROM employee e, project p
WHERE e.ni_number='NI1002' AND p.name='Platform Refactor';

-- Seed: Dependents
INSERT INTO dependent (employee_id, first_name, date_of_birth, relationship)
SELECT e.employee_id, 'Milo', DATE '2016-04-10', 'Child' FROM employee e WHERE e.ni_number='NI1002';
INSERT INTO dependent (employee_id, first_name, date_of_birth, relationship)
SELECT e.employee_id, 'Riley', DATE '2018-09-02', 'Child' FROM employee e WHERE e.ni_number='NI1005';

COMMIT; 