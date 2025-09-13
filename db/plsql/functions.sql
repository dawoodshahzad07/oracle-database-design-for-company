-- Function: fn_employee_total_hours
CREATE OR REPLACE FUNCTION fn_employee_total_hours (
  p_employee_id IN employee.employee_id%TYPE
) RETURN NUMBER IS
  v_total NUMBER;
BEGIN
  SELECT NVL(SUM(w.hours_per_week), 0) INTO v_total
  FROM works_on w
  WHERE w.employee_id = p_employee_id;
  RETURN v_total;
END;
/

-- Function: fn_department_headcount
CREATE OR REPLACE FUNCTION fn_department_headcount (
  p_department_id IN department.department_id%TYPE
) RETURN NUMBER IS
  v_count NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_count
  FROM employee e
  WHERE e.department_id = p_department_id
    AND e.leaving_date IS NULL;
  RETURN v_count;
END;
/ 