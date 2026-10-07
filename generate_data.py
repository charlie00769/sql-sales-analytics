"""
STEP 2: BUILD THE DATABASE
Run:  python generate_data.py
Creates ecommerce.db (SQLite) with SYNTHETIC data. Nothing here is real company data.
Seed is fixed, so everyone gets the same numbers.
"""
import random
import sqlite3
from datetime import date, timedelta

random.seed(42)
conn = sqlite3.connect("ecommerce.db")
conn.executescript(open("schema.sql").read())

CITIES = ["Mumbai", "Pune", "Chennai", "Delhi", "Bengaluru", "Hyderabad"]
FIRST = ["Aarav","Vivaan","Aditya","Ishaan","Riya","Ananya","Diya","Kavya","Rohan","Sneha",
         "Arjun","Neha","Karan","Pooja","Rahul","Meera","Siddharth","Tanvi","Yash","Isha"]
LAST = ["Sharma","Patil","Iyer","Reddy","Mehta","Nair","Gupta","Joshi","Kulkarni","Singh"]

CATALOG = {
    "Electronics": [("Wireless Earbuds", 1999), ("Smart Watch", 3499), ("Power Bank", 1299),
                    ("Bluetooth Speaker", 2199), ("USB-C Cable", 399), ("Webcam", 2499),
                    ("Mechanical Keyboard", 3299), ("Gaming Mouse", 1499)],
    "Fashion":     [("Running Shoes", 2999), ("Denim Jacket", 2499), ("Cotton T-Shirt", 599),
                    ("Backpack", 1499), ("Sunglasses", 999), ("Hoodie", 1799),
                    ("Formal Shirt", 1299), ("Sneakers", 2599)],
    "Home":        [("Table Lamp", 899), ("Water Bottle", 449), ("Bedsheet Set", 1599),
                    ("Wall Clock", 699), ("Storage Box", 549), ("Coffee Mug Set", 799),
                    ("Desk Organizer", 499), ("Air Fryer", 4999)],
    "Books":       [("Python Basics", 499), ("Data Science Handbook", 799), ("SQL in 10 Minutes", 399),
                    ("Statistics Made Easy", 599), ("Deep Learning Guide", 999), ("Atomic Habits", 449),
                    ("Algorithms Illustrated", 699), ("Clean Code", 899)],
    "Sports":      [("Yoga Mat", 799), ("Dumbbell Set", 2499), ("Football", 899),
                    ("Cricket Bat", 1999), ("Skipping Rope", 249), ("Badminton Racket", 1299),
                    ("Gym Gloves", 449), ("Resistance Bands", 599)],
}

# products
products = []
pid = 1
for cat, items in CATALOG.items():
    for name, price in items:
        products.append((pid, name, cat, price))
        pid += 1
conn.executemany("INSERT INTO products VALUES (?,?,?,?)", products)

# customers (500), signup dates through 2025
start = date(2025, 1, 1)
customers = []
for cid in range(1, 501):
    name = f"{random.choice(FIRST)} {random.choice(LAST)}"
    city = random.choices(CITIES, weights=[25, 20, 12, 18, 15, 10])[0]
    signup = start + timedelta(days=random.randint(0, 300))
    customers.append((cid, name, city, signup.isoformat()))
conn.executemany("INSERT INTO customers VALUES (?,?,?,?)", customers)

# orders: only customers who have signed up can order. ~80% of customers order at all.
active = random.sample(customers, 400)
orders, items = [], []
oid, iid = 1, 1
end = date(2025, 12, 31)
for cid, _, _, signup in active:
    signup_d = date.fromisoformat(signup)
    n_orders = random.choices([1, 2, 3, 4, 5, 6, 8], weights=[30, 25, 18, 12, 8, 5, 2])[0]
    for _ in range(n_orders):
        span = (end - signup_d).days
        if span <= 0:
            continue
        od = signup_d + timedelta(days=random.randint(0, span))
        status = random.choices(["Delivered", "Cancelled", "Returned"], weights=[88, 7, 5])[0]
        orders.append((oid, cid, od.isoformat(), status))
        for _ in range(random.choices([1, 2, 3], weights=[60, 28, 12])[0]):
            p = random.choice(products)
            items.append((iid, oid, p[0], random.choices([1, 2, 3], weights=[75, 18, 7])[0], p[3]))
            iid += 1
        oid += 1

conn.executemany("INSERT INTO orders VALUES (?,?,?,?)", orders)
conn.executemany("INSERT INTO order_items VALUES (?,?,?,?,?)", items)
conn.commit()

for t in ["customers", "products", "orders", "order_items"]:
    n = conn.execute(f"SELECT COUNT(*) FROM {t}").fetchone()[0]
    print(f"{t:12s} {n:6d} rows")
conn.close()
