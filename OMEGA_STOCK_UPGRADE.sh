#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "📦 Integruji Asset Stock Modul..."

# Upravíme omega_core.py pro výpočet skladu
sed -i "s/employees = query_db(\"SELECT \* FROM candidates WHERE status != 'TERMINATED'\")/employees = query_db(\"SELECT * FROM candidates WHERE status != 'TERMINATED'\")\n    stock = query_db(\"SELECT name, count(*) as count FROM assets WHERE owner_token IS NULL GROUP BY name\")/" omega_core.py

# Upravíme return render_template, aby posílal stock
sed -i "s/return render_template('index.html', employees=employees, count=len(employees), asset_map=asset_map)/return render_template('index.html', employees=employees, count=len(employees), asset_map=asset_map, stock=stock)/" omega_core.py

echo "✅ Jádro aktualizováno."
