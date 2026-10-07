import sqlite3, csv, os
os.makedirs("csv_export", exist_ok=True)
conn = sqlite3.connect("ecommerce.db")
for t in ["customers", "products", "orders", "order_items"]:
    cur = conn.execute(f"SELECT * FROM {t}")
    with open(f"csv_export/{t}.csv", "w", newline="") as f:
        w = csv.writer(f)
        w.writerow([d[0] for d in cur.description])
        w.writerows(cur.fetchall())
    print(t, "exported")