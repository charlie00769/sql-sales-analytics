"""
STEP 3: RUN ALL QUERIES AND SEE RESULTS
Run:  python run_queries.py            (all files)
      python run_queries.py 03         (only files starting with 03)
"""
import glob
import sqlite3
import sys

prefix = sys.argv[1] if len(sys.argv) > 1 else ""
conn = sqlite3.connect("ecommerce.db")

for path in sorted(glob.glob(f"queries/{prefix}*.sql")):
    print("=" * 70)
    print(path)
    print("=" * 70)
    text = open(path).read()
    # split on semicolons; skip blocks that have no SQL
    for block in text.split(";"):
        lines = [l for l in block.strip().splitlines()]
        sql = "\n".join(l for l in lines if not l.strip().startswith("--")).strip()
        if not sql:
            continue
        title = next((l for l in lines if l.strip().startswith("-- Q")), "")
        if title:
            print(f"\n{title.strip()}")
        cur = conn.execute(sql)
        if cur.description:
            cols = [d[0] for d in cur.description]
            rows = cur.fetchall()
            print(" | ".join(cols))
            for r in rows[:15]:
                print(" | ".join(str(x) for x in r))
conn.commit()
