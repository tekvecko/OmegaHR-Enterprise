#!/data/data/com.termux/files/usr/bin/python
import sqlite3
import json
import os
import omega_config as cfg

def get_conn():
    return sqlite3.connect(cfg.DB_PATH)

def init_db():
    conn = get_conn()
    c = conn.cursor()
    c.execute('''CREATE TABLE IF NOT EXISTS candidates (token TEXT PRIMARY KEY, name TEXT, hr_data TEXT, status TEXT DEFAULT 'pending', full_name_mojeid TEXT, birthdate_mojeid TEXT, address_mojeid TEXT, bankid_sub TEXT, is_verified INTEGER DEFAULT 0, offboarding_status TEXT DEFAULT 'active', exit_date TEXT, mojeid_sub TEXT)''')
    c.execute('''CREATE TABLE IF NOT EXISTS assets (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, serial TEXT, type TEXT, owner_token TEXT, status TEXT DEFAULT 'available')''')
    c.execute('''CREATE TABLE IF NOT EXISTS requests (id INTEGER PRIMARY KEY AUTOINCREMENT, token TEXT, type TEXT, dates TEXT, reason TEXT, status TEXT DEFAULT 'pending')''')
    c.execute('''CREATE TABLE IF NOT EXISTS otps (code TEXT PRIMARY KEY, user_token TEXT, used INTEGER DEFAULT 0, created_at TEXT)''')
    c.execute('''CREATE TABLE IF NOT EXISTS notifications (id INTEGER PRIMARY KEY AUTOINCREMENT, target_token TEXT, message TEXT, type TEXT, is_read INTEGER DEFAULT 0, created_at TEXT)''')
    c.execute('''CREATE TABLE IF NOT EXISTS evaluations (id INTEGER PRIMARY KEY AUTOINCREMENT, user_token TEXT, rating INTEGER, note TEXT, date TEXT)''')
    conn.commit()
    conn.close()

def get_candidate(token):
    conn = get_conn()
    conn.row_factory = sqlite3.Row
    c = conn.cursor()
    c.execute("SELECT * FROM candidates WHERE token = ?", (token,))
    row = c.fetchone()
    conn.close()
    if row:
        d = dict(row)
        try:
            d['hr_data'] = json.loads(d['hr_data'])
        except Exception:
            d['hr_data'] = {}
        return d
    return None

def get_all():
    conn = get_conn()
    conn.row_factory = sqlite3.Row
    c = conn.cursor()
    c.execute("SELECT * FROM candidates")
    rows = c.fetchall()
    conn.close()
    return [dict(r) for r in rows]

def upsert_candidate(token, data):
    conn = get_conn()
    c = conn.cursor()
    c.execute("SELECT token FROM candidates WHERE token=?", (token,))
    if not c.fetchone():
        c.execute("INSERT INTO candidates (token, name, hr_data) VALUES (?, ?, ?)", (token, data['name'], json.dumps(data['hr_data'])))
    conn.commit()
    conn.close()

init_db()
