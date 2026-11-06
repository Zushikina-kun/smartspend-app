"""
Prepare clean logo files for the certificates.
- Convert LormaLogo.jpg to PNG with explicit white background
- Verify CCSE seal and City seal are clean
"""
from PIL import Image
import os

os.makedirs('docs/tools/extracted_images/logos', exist_ok=True)

# 1. Lorma logo — convert JPEG to PNG with white background
img = Image.open('assets/LormaLogo.jpg').convert('RGBA')
# Paste onto explicit white background
bg = Image.new('RGBA', img.size, (255, 255, 255, 255))
bg.paste(img, mask=img.split()[3] if img.mode == 'RGBA' else None)
final = bg.convert('RGB')
out = 'docs/tools/extracted_images/logos/lorma_clean.png'
final.save(out, 'PNG', optimize=True)
print(f'Lorma logo: {img.size} -> saved {out} ({os.path.getsize(out)//1024}KB)')

# Verify corner pixel
check = Image.open(out)
px = check.getpixel((5, 5))
print(f'  Corner pixel: {px} (should be ~255,255,255)')

# 2. CCSE seal — it's a JPEG, check it
img2 = Image.open('docs/tools/extracted_images/logos/habss_ref_p3_img1.jpeg')
px2 = img2.getpixel((5, 5))
print(f'CCSE seal: {img2.size} {img2.mode}, corner pixel: {px2}')

# 3. City seal
img3 = Image.open('docs/tools/extracted_images/logos/seal_sanfernando.png')
px3 = img3.getpixel((5, 5))
print(f'City seal: {img3.size} {img3.mode}, corner pixel: {px3}')
