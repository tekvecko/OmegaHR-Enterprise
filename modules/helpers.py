import uuid
def generate_mojeid():
    return f"ID-{str(uuid.uuid4())[:8].upper()}"

def format_salary(val):
    return "{:,} CZK".format(int(val)).replace(",", " ")
