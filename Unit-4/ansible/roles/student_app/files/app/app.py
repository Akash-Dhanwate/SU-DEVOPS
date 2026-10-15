import os, sqlite3
from flask import Flask, jsonify, request

DB_PATH = os.environ.get("DB_PATH", "students.db")
app = Flask(__name__)

def db():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    with db() as c:
        c.execute("CREATE TABLE IF NOT EXISTS students (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL, course TEXT NOT NULL)")
        c.execute("CREATE TABLE IF NOT EXISTS marks (id INTEGER PRIMARY KEY AUTOINCREMENT, student_id INTEGER NOT NULL, subject TEXT NOT NULL, marks INTEGER NOT NULL)")
        if c.execute("SELECT COUNT(*) FROM students").fetchone()[0] == 0:
            c.executemany("INSERT INTO students (name, course) VALUES (?, ?)",
                          [("Asha Patil", "B.Tech IT"), ("Rohan Mehta", "B.Tech CSE")])

@app.get("/api/health")
def health():
    return jsonify(status="UP")

@app.get("/api/students")
def list_students():
    with db() as c:
        rows = c.execute("SELECT * FROM students").fetchall()
    return jsonify([dict(r) for r in rows])

@app.post("/api/students")
def add_student():
    d = request.get_json(force=True)
    with db() as c:
        cur = c.execute("INSERT INTO students (name, course) VALUES (?, ?)", (d["name"], d["course"]))
    return jsonify(id=cur.lastrowid), 201

@app.get("/api/marks")
def list_marks():
    with db() as c:
        rows = c.execute("SELECT * FROM marks").fetchall()
    return jsonify([dict(r) for r in rows])

@app.post("/api/marks")
def add_marks():
    d = request.get_json(force=True)
    with db() as c:
        cur = c.execute("INSERT INTO marks (student_id, subject, marks) VALUES (?, ?, ?)",
                        (d["student_id"], d["subject"], d["marks"]))
    return jsonify(id=cur.lastrowid, status="success"), 201

init_db()
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))
