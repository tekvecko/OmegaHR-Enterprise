#!/data/data/com.termux/files/usr/bin/python
import sys

try:
    with open('omega_core.py', 'r', encoding='utf-8') as f:
        lines = f.readlines()
    
    print("👇--- ZACATEK FUNKCE GEN_PDF ---👇\n")
    capture = False
    for line in lines:
        if line.startswith('def gen_pdf'):
            capture = True
        elif capture and line.startswith('def '):
            break
            
        if capture:
            sys.stdout.write(line)
    print("\n👆--- KONEC FUNKCE GEN_PDF ---👆")
except Exception as e:
    print(f"Chyba při čtení: {e}")
