-- Place sample orders using PL/SQL JSON API
DECLARE
  v_order_id NUMBER;
BEGIN
  -- Order for Acme Corp: 2x SKU-100, 1x SKU-200
  place_order_json(
    p_customer_id => (SELECT customer_id FROM customer WHERE name='Acme Corp'),
    p_items_json  => '[{"product_id": ' || (SELECT product_id FROM product WHERE sku='SKU-100') || ', "quantity": 2},
                      {"product_id": ' || (SELECT product_id FROM product WHERE sku='SKU-200') || ', "quantity": 1}]',
    o_order_id    => v_order_id
  );

  -- Order for Beta Ltd: 5x SKU-300
  place_order_json(
    p_customer_id => (SELECT customer_id FROM customer WHERE name='Beta Ltd'),
    p_items_json  => '[{"product_id": ' || (SELECT product_id FROM product WHERE sku='SKU-300') || ', "quantity": 5}]',
    o_order_id    => v_order_id
  );
END;
/

-- Quick checks
SELECT * FROM vw_customer_sales_summary ORDER BY total_revenue DESC;
SELECT * FROM vw_employee_project_hours ORDER BY employee_id; 