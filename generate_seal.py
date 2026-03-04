from PIL import Image, ImageDraw, ImageFont
import os

# Vytvoření transparentního obrázku pro razítko
size = (300, 300)
image = Image.new("RGBA", size, (255, 255, 255, 0))
draw = ImageDraw.Draw(image)

# Kresba modrého kruhu (Seal Border)
border_color = (0, 98, 204, 180) # Omega Blue s průhledností
draw.ellipse([10, 10, 290, 290], outline=border_color, width=8)
draw.ellipse([25, 25, 275, 275], outline=border_color, width=2)

# Text uvnitř razítka (Jednoduchý font)
try:
    # Pokus o systémový font, jinak default
    text = "OMEGA\nPLATINUM\n2026"
    draw.text((150, 150), text, fill=border_color, anchor="mm", align="center")
except:
    draw.text((100, 140), "OMEGA SEAL", fill=border_color)

image.save("/data/data/com.termux/files/home/OmegaPlatinum_PROD/static/omega_seal.png")
print("✅ Digitální razítko bylo vygenerováno.")
