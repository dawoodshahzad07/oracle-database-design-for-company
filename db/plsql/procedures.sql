-- Procedure: assign_department_manager
-- Ensures only one active manager per department by closing any open assignment.
CREATE OR REPLACE PROCEDURE assign_department_manager (
  p_department_id IN department.department_id%TYPE,
  p_employee_id   IN employee.employee_id%TYPE,
  p_start_date    IN DATE
) AS
  v_exists NUMBER;
BEGIN
  -- Validate employee exists and belongs to department
  SELECT COUNT(*) INTO v_exists
  FROM employee e
  WHERE e.employee_id = p_employee_id
    AND e.department_id = p_department_id;

  IF v_exists = 0 THEN
    RAISE_APPLICATION_ERROR(-20001, 'Employee must belong to the department to be assigned as manager.');
  END IF;

  -- Close existing open manager assignment (if any)
  UPDATE department_manager dm
  SET end_date = CASE WHEN p_start_date IS NOT NULL THEN p_start_date - 1 ELSE SYSDATE END
  WHERE dm.department_id = p_department_id
    AND dm.end_date IS NULL;

  -- Insert new history row
  INSERT INTO department_manager (department_id, employee_id, start_date, end_date)
  VALUES (p_department_id, p_employee_id, NVL(p_start_date, TRUNC(SYSDATE)), NULL);
END;
/

-- Procedure: place_order_json
-- Creates an order with items parsed from a JSON array: [{"product_id":1, "quantity":2}, ...]
-- Validates and allocates inventory across warehouses using row locks.
CREATE OR REPLACE PROCEDURE place_order_json (
  p_customer_id IN customer.customer_id%TYPE,
  p_items_json  IN CLOB,
  o_order_id    OUT sales_order.order_id%TYPE
) AS
  v_customer_exists NUMBER;
  v_items_count     NUMBER;
BEGIN
  -- Basic validations
  SELECT COUNT(*) INTO v_customer_exists FROM customer WHERE customer_id = p_customer_id;
  IF v_customer_exists = 0 THEN
    RAISE_APPLICATION_ERROR(-20010, 'Customer does not exist.');
  END IF;

  -- Validate JSON has at least one item
  SELECT COUNT(*) INTO v_items_count
  FROM JSON_TABLE(p_items_json, '$[*]'
    COLUMNS (
      product_id NUMBER PATH '$.product_id',
      quantity   NUMBER PATH '$.quantity'
    ));

  IF v_items_count = 0 THEN
    RAISE_APPLICATION_ERROR(-20011, 'Order must contain at least one item.');
  END IF;

  -- Create order
  INSERT INTO sales_order (customer_id, order_date) VALUES (p_customer_id, SYSDATE)
  RETURNING order_id INTO o_order_id;

  -- Insert order items with current unit_price
  INSERT INTO order_item (order_id, product_id, quantity, unit_price)
  SELECT o_order_id, jt.product_id, jt.quantity, p.unit_price
  FROM JSON_TABLE(p_items_json, '$[*]'
    COLUMNS (
      product_id NUMBER PATH '$.product_id',
      quantity   NUMBER PATH '$.quantity'
    )) jt
  JOIN product p ON p.product_id = jt.product_id;

  -- Allocation: for each item, decrement inventory across warehouses (most-stocked first)
  DECLARE
    CURSOR c_items IS
      SELECT product_id, quantity
      FROM JSON_TABLE(p_items_json, '$[*]'
        COLUMNS (
          product_id NUMBER PATH '$.product_id',
          quantity   NUMBER PATH '$.quantity'
        ));

    CURSOR c_inv (p_prod_id NUMBER) IS
      SELECT warehouse_id, product_id, quantity
      FROM inventory
      WHERE product_id = p_prod_id
      ORDER BY quantity DESC;

    v_needed   NUMBER;
    v_wh_id    inventory.warehouse_id%TYPE;
    v_prod_id  inventory.product_id%TYPE;
    v_qty      inventory.quantity%TYPE;
  BEGIN
    FOR it IN c_items LOOP
      v_needed := it.quantity;

      -- Lock all inventory rows for this product to prevent race conditions
      FOR inv_row IN (
        SELECT warehouse_id, product_id, quantity
        FROM inventory
        WHERE product_id = it.product_id
        FOR UPDATE
      ) LOOP
        NULL; -- Row lock acquired
      END LOOP;

      -- Allocate from warehouses in descending quantity order
      FOR inv IN c_inv(it.product_id) LOOP
        EXIT WHEN v_needed <= 0;

        v_wh_id := inv.warehouse_id;
        v_prod_id := inv.product_id;
        v_qty := inv.quantity;

        IF v_qty <= 0 THEN
          CONTINUE;
        END IF;

        IF v_qty >= v_needed THEN
          -- Deduct needed and finish
          UPDATE inventory SET quantity = quantity - v_needed
          WHERE warehouse_id = v_wh_id AND product_id = v_prod_id;
          v_needed := 0;
        ELSE
          -- Take all from this warehouse and continue
          UPDATE inventory SET quantity = 0
          WHERE warehouse_id = v_wh_id AND product_id = v_prod_id;
          v_needed := v_needed - v_qty;
        END IF;
      END LOOP;

      IF v_needed > 0 THEN
        RAISE_APPLICATION_ERROR(-20012, 'Insufficient inventory for product_id=' || it.product_id);
      END IF;
    END LOOP;
  END;

  COMMIT;
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    RAISE;
END;
/ 