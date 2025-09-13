from flask import Flask, render_template, request, redirect, url_for, flash
import json
from db import db_cursor

app = Flask(__name__)
app.secret_key = "dev-secret"  # replace in production


@app.route("/")
def index():
    return redirect(url_for("employees"))


@app.route("/employees")
def employees():
    with db_cursor() as cur:
        cur.execute(
            """
            SELECT e.employee_id, e.first_name, e.last_name, d.name AS department_name,
                   fn_employee_total_hours(e.employee_id) AS total_hours
            FROM employee e
            JOIN department d ON d.department_id = e.department_id
            ORDER BY e.employee_id
            """
        )
        rows = cur.fetchall()
        cols = [d[0].lower() for d in cur.description]
    return render_template("employees.html", rows=rows, cols=cols)


@app.route("/projects")
def projects():
    with db_cursor() as cur:
        cur.execute(
            """
            SELECT p.project_id, p.name, d.name AS department_name, l.city AS location_city,
                   p.start_date, p.end_date
            FROM project p
            JOIN department d ON d.department_id = p.department_id
            JOIN location l ON l.location_id = p.location_id
            ORDER BY p.project_id
            """
        )
        rows = cur.fetchall()
        cols = [d[0].lower() for d in cur.description]
    return render_template("projects.html", rows=rows, cols=cols)


@app.route("/works_on")
def works_on():
    with db_cursor() as cur:
        cur.execute(
            """
            SELECT e.first_name || ' ' || e.last_name AS employee,
                   p.name AS project,
                   w.hours_per_week
            FROM works_on w
            JOIN employee e ON e.employee_id = w.employee_id
            JOIN project p ON p.project_id = w.project_id
            ORDER BY e.employee_id, p.project_id
            """
        )
        rows = cur.fetchall()
        cols = [d[0].lower() for d in cur.description]
    return render_template("works_on.html", rows=rows, cols=cols)


@app.route("/customers")
def customers():
    with db_cursor() as cur:
        cur.execute(
            """
            SELECT c.customer_id, c.name AS customer_name, c.email, c.phone,
                   e.first_name || ' ' || e.last_name AS salesperson
            FROM customer c
            JOIN employee e ON e.employee_id = c.salesperson_id
            ORDER BY c.customer_id
            """
        )
        rows = cur.fetchall()
        cols = [d[0].lower() for d in cur.description]
    return render_template("customers.html", rows=rows, cols=cols)


@app.route("/orders")
def orders():
    with db_cursor() as cur:
        cur.execute(
            """
            SELECT so.order_id, so.order_date, c.name AS customer_name,
                   NVL(SUM(oi.quantity * oi.unit_price), 0) AS total_amount
            FROM sales_order so
            JOIN customer c ON c.customer_id = so.customer_id
            LEFT JOIN order_item oi ON oi.order_id = so.order_id
            GROUP BY so.order_id, so.order_date, c.name
            ORDER BY so.order_id DESC
            """
        )
        rows = cur.fetchall()
        cols = [d[0].lower() for d in cur.description]
    return render_template("orders.html", rows=rows, cols=cols)


@app.route("/orders/new", methods=["GET", "POST"])
def order_new():
    with db_cursor() as cur:
        # Fetch customers and products for the form
        cur.execute("SELECT customer_id, name FROM customer ORDER BY name")
        customers = cur.fetchall()
        cur.execute("SELECT product_id, sku, name FROM product ORDER BY sku")
        products = cur.fetchall()

    if request.method == "POST":
        customer_id = request.form.get("customer_id")
        items = []
        product_ids = request.form.getlist("product_id")
        quantities = request.form.getlist("quantity")
        for pid, qty in zip(product_ids, quantities):
            if pid and qty:
                try:
                    items.append({"product_id": int(pid), "quantity": float(qty)})
                except ValueError:
                    pass
        if not customer_id or not items:
            flash("Please select a customer and at least one item.", "error")
            return render_template("order_new.html", customers=customers, products=products)

        # Call PL/SQL to place order
        items_json = json.dumps(items)
        with db_cursor() as cur:
            try:
                order_id_var = cur.var(int)
                cur.callproc("place_order_json", [int(customer_id), items_json, order_id_var])
                new_order_id = order_id_var.getvalue()
                flash(f"Order {new_order_id} created successfully.", "success")
                return redirect(url_for("orders"))
            except Exception as ex:
                flash(str(ex), "error")
                return render_template("order_new.html", customers=customers, products=products)

    return render_template("order_new.html", customers=customers, products=products)


if __name__ == "__main__":
    app.run(debug=True) 