-- Prevent employee from supervising themselves
CREATE OR REPLACE TRIGGER trg_employee_supervisor_self
BEFORE INSERT OR UPDATE OF supervisor_id ON employee
FOR EACH ROW
BEGIN
  IF :NEW.supervisor_id IS NOT NULL AND :NEW.supervisor_id = :NEW.employee_id THEN
    RAISE_APPLICATION_ERROR(-20020, 'An employee cannot supervise themselves.');
  END IF;
END;
/

-- Ensure salesperson belongs to the Sales department
CREATE OR REPLACE TRIGGER trg_customer_salesperson_sales_dept
BEFORE INSERT OR UPDATE OF salesperson_id ON customer
FOR EACH ROW
DECLARE
  v_is_sales NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_is_sales
  FROM employee e
  JOIN department d ON d.department_id = e.department_id
  WHERE e.employee_id = :NEW.salesperson_id
    AND UPPER(d.name) = 'SALES';

  IF v_is_sales = 0 THEN
    RAISE_APPLICATION_ERROR(-20021, 'Salesperson must belong to the Sales department.');
  END IF;
END;
/

-- Ensure project location belongs to the same department controlling the project
CREATE OR REPLACE TRIGGER trg_project_location_same_dept
BEFORE INSERT OR UPDATE OF department_id, location_id ON project
FOR EACH ROW
DECLARE
  v_loc_dept_id location.department_id%TYPE;
BEGIN
  SELECT l.department_id INTO v_loc_dept_id FROM location l WHERE l.location_id = :NEW.location_id;
  IF v_loc_dept_id <> :NEW.department_id THEN
    RAISE_APPLICATION_ERROR(-20022, 'Project location must belong to the same department as the project.');
  END IF;
END;
/ 