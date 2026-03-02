#!/data/data/com.termux/files/usr/bin/python
import re
from pypdf import PdfReader

def parse_cv(file_stream):
    try:
        reader = PdfReader(file_stream)
        text = ""
        for page in reader.pages:
            text += page.extract_text() + "\n"
        email_match = re.search(r'[\w.+-]+@[\w-]+\.[\w.-]+', text)
        email = email_match.group(0) if email_match else None
        phone_match = re.search(r'(\+420|\+421) ?[0-9]{3} ?[0-9]{3} ?[0-9]{3}', text)
        phone = phone_match.group(0) if phone_match else None
        lines = [L.strip() for L in text.split('\n') if L.strip()]
        name = lines[0] if lines and len(lines[0].split()) <= 3 else "Unknown Candidate"
        return {"name": name, "email": email, "phone": phone}
    except Exception:
        return None
