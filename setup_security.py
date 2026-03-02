#!/data/data/com.termux/files/usr/bin/python
import os
import sqlite3
from cryptography.fernet import Fernet
from werkzeug.security import generate_password_hash

if not os.path.exists('master.key'):
    key = Fernet.generate_key()
    try:
        with open('master.key', 'wb') as k:
            k.write(key)
        os.chmod('master.key', 0o600)
    except Exception as e:
        print(f"Key write error: {e}")

conn = sqlite3.connect('omega.db')
c = conn.cursor()
c.execute("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE, password_hash TEXT, role TEXT)")

try:
    c.execute("INSERT INTO users (username, password_hash, role) VALUES (?, ?, ?)", ("admin", generate_password_hash("admin"), "admin"))
    c.execute("INSERT INTO users (username, password_hash, role) VALUES (?, ?, ?)", ("hr", generate_password_hash("hr"), "hr"))
except sqlite3.IntegrityError:
    pass

conn.commit()
conn.close()
