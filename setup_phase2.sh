#!/data/data/com.termux/files/usr/bin/bash
set -e

cd /data/data/com.termux/files/home/OmegaPlatinum_PROD

echo "📄 1/4 Vytvářím přísnou podnikovou šablonu NDA (Dohoda o mlčenlivosti)..."
cat > nda_template.txt << 'TEMPLATE_EOF'
DOHODA O MLČENLIVOSTI A OCHRANĚ DŮVĚRNÝCH INFORMACÍ (NDA)
uzavřená ve smyslu § 1746 odst. 2 a § 2985 zákona č. 89/2012 Sb., občanský zákoník

I. Smluvní strany

1. Poskytovatel: {company_name}
   se sídlem: {company_address}
   (dále jen "Poskytovatel") a

2. Příjemce: {name}
   Datum narození: {birthdate}
   bytem: {address}
   (dále jen "Příjemce")

II. Předmět dohody

1. Poskytovatel zpřístupní Příjemci v souvislosti s výkonem jeho pracovní činnosti ({position}) určité důvěrné informace, obchodní tajemství, strategické plány, klientská data, zdrojové kódy a interní procesy (dále společně jen "Důvěrné informace").
2. Důvěrnými informacemi jsou veškeré informace, které nejsou běžně veřejně dostupné a mají pro Poskytovatele skutečnou nebo potenciální konkurenční či hospodářskou hodnotu.

III. Závazek mlčenlivosti a ochrany

1. Příjemce se výslovně zavazuje zachovávat o všech Důvěrných informacích naprostou mlčenlivost.
2. Příjemce nesmí Důvěrné informace použít pro svůj vlastní prospěch, pro prospěch třetích stran, ani je jakýmkoli způsobem reprodukovat, šířit či sdělovat nepovolaným osobám.
3. Tento závazek mlčenlivosti trvá po celou dobu trvání spolupráce a dále po dobu 5 let od jejího ukončení.

IV. Smluvní pokuta a náhrada škody

1. V případě porušení povinnosti mlčenlivosti je Příjemce povinen uhradit Poskytovateli smluvní pokutu ve výši 100 000 Kč za každé jednotlivé porušení.
2. Zaplacením smluvní pokuty není dotčen nárok Poskytovatele na náhradu škody v plné výši.

V. Závěrečná ustanovení

1. Tato dohoda nabývá platnosti a účinnosti dnem jejího podpisu.

V ___________________ dne {date}

________________________               ________________________
Poskytovatel                           Příjemce
TEMPLATE_EOF

echo "💻 2/4 Vytvářím šablonu Předávacího protokolu (Svěřený majetek)..."
cat > handover_template.txt << 'TEMPLATE_EOF'
PŘEDÁVACÍ PROTOKOL O SVĚŘENÍ FIREMNÍHO MAJETKU
dle § 255 a násl. zákona č. 262/2006 Sb., zákoník práce

I. Smluvní strany

1. Zaměstnavatel: {company_name}
   (dále jen "Zaměstnavatel") a

2. Zaměstnanec: {name}
   Pozice: {position}
   (dále jen "Zaměstnanec")

II. Předmět předání

Zaměstnavatel tímto předává a Zaměstnanec fyzicky přebírá do svého výlučného osobního užívání pro účely plnění pracovních úkolů následující majetek Zaměstnavatele:

1. Výpočetní technika (Notebook)
   Typ / Model: Firemní standard (bude specifikováno IT oddělením v interním systému)
   Příslušenství: Napájecí adaptér, brašna/pouzdro.

2. Mobilní zařízení a komunikace
   Typ / Model: Firemní smartphone
   SIM karta s přiděleným telefonním číslem a datovým tarifem.

3. Přístupové a identifikační prostředky
   Elektronický přístupový čip / karta do budovy Zaměstnavatele.
   Fyzické klíče (pokud byly vydány pro konkrétní kancelář).

III. Prohlášení a odpovědnost Zaměstnance

1. Zaměstnanec potvrzuje, že výše uvedený majetek převzal ve stavu způsobilém k řádnému užívání a neshledal na něm žádné zjevné vady či poškození.
2. Zaměstnanec se zavazuje pečovat o svěřený majetek s péčí řádného hospodáře, chránit jej před poškozením, ztrátou, odcizením či zničením.
3. Zaměstnanec bere na vědomí, že odpovídá za ztrátu svěřených předmětů ve smyslu § 255 Zákoníku práce. V případě ztráty či úmyslného poškození je povinen nahradit škodu v plné výši.
4. Zaměstnanec se zavazuje vrátit veškerý svěřený majetek neprodleně při ukončení pracovního poměru, nebo kdykoli na výzvu Zaměstnavatele.

V ___________________ dne {date}

________________________               ________________________
Předal (Za Zaměstnavatele)             Převzal (Zaměstnanec)
TEMPLATE_EOF

echo "⚙️ 3/4 Aplikuji mikro-záplaty do jádra a uživatelského rozhraní..."
cat > patch_phase2.py << 'PY_EOF'
import os

# 1. Úprava omega_core.py pro generování nových typů PDF
with open('omega_core.py', 'r', encoding='utf-8') as f:
    core = f.read()

old_t_logic = '''        if type == 'contract':
            t_file = "dpp_template.txt" if c_type == 'dpp' else "contract_template.txt"
        else:
            t_file = "termination_template.txt"'''

new_t_logic = '''        if type == 'contract':
            t_file = "dpp_template.txt" if c_type == 'dpp' else "contract_template.txt"
        elif type == 'nda':
            t_file = "nda_template.txt"
        elif type == 'handover':
            t_file = "handover_template.txt"
        else:
            t_file = "termination_template.txt"'''

if "elif type == 'nda':" not in core:
    core = core.replace(old_t_logic, new_t_logic)

# 2. Úprava routy /candidate/<token> pro automatické generování NDA a Protokolu
old_detail_logic = '''    c['term_filename'] = f"termination_{token}.pdf"'''

new_detail_logic = '''    c['term_filename'] = f"termination_{token}.pdf"
    
    c['nda_filename'] = f"nda_{token}.pdf"
    if not os.path.exists(os.path.join(cfg.CONTRACTS_DIR, c['nda_filename'])): gen_pdf(token, 'nda')
        
    c['handover_filename'] = f"handover_{token}.pdf"
    if not os.path.exists(os.path.join(cfg.CONTRACTS_DIR, c['handover_filename'])): gen_pdf(token, 'handover')'''

if "c['nda_filename']" not in core:
    core = core.replace(old_detail_logic, new_detail_logic)

with open('omega_core.py', 'w', encoding='utf-8') as f:
    f.write(core)

# 3. Úprava templates/candidate_detail.html pro zobrazení tlačítek ke stažení
with open('templates/candidate_detail.html', 'r', encoding='utf-8') as f:
    html = f.read()

old_html_block = "{% if c.offboarding_status == 'terminated' %}"

new_html_block = """
    <div class="flex justify-between items-center mb-3 p-3 bg-gray-50 rounded-xl">
        <div class="flex items-center gap-3">
            <i class="ri-lock-fill text-brand-gold text-xl"></i>
            <span class="text-sm font-bold text-gray-700">NDA (Mlčenlivost)</span>
        </div>
        <a href="/download/{{ c.nda_filename }}" class="text-brand-gold hover:text-brand-dark transition"><i class="ri-download-cloud-2-line text-xl"></i></a>
    </div>
    
    <div class="flex justify-between items-center mb-3 p-3 bg-gray-50 rounded-xl">
        <div class="flex items-center gap-3">
            <i class="ri-macbook-line text-blue-500 text-xl"></i>
            <span class="text-sm font-bold text-gray-700">Předávací protokol (HW)</span>
        </div>
        <a href="/download/{{ c.handover_filename }}" class="text-blue-500 hover:text-brand-dark transition"><i class="ri-download-cloud-2-line text-xl"></i></a>
    </div>

    {% if c.offboarding_status == 'terminated' %}
"""

if "NDA (Mlčenlivost)" not in html:
    html = html.replace(old_html_block, new_html_block)
    with open('templates/candidate_detail.html', 'w', encoding='utf-8') as f:
        f.write(html)

print("   ✅ Záplaty úspěšně aplikovány.")
PY_EOF

python patch_phase2.py
rm patch_phase2.py

echo "🚀 4/4 Mažu starou mezipaměť a restartuji systém..."
rm -f contract_*.pdf
rm -f dpp_*.pdf
pkill -f python || true
./start.sh
