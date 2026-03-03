from omega_core import app
print("\n📋 SEZNAM AKTIVNÍCH CEST V SYSTÉMU:")
for rule in app.url_map.iter_rules():
    print(f" -> {rule.endpoint}: {rule.rule} [{', '.join(rule.methods)}]")
