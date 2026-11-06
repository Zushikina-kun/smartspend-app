"""
Prepare clean logo files for the certificates.
- Upscale the Lorma banner (321x80) to 4x using Lanczos for clean print quality
- Verify CCSE seal and City seal
"""
from PIL import Image
import os

os.makedirs('docs/tools/extracted_images/logos', exist_ok=True)

# 1. Lorma banner — upscale 4x with Lanczos (high quality)
banner = Image.open('docs/tools/extracted_images/logos/habss_ref_p3_img0.png')
print(f'Lorma banner original: {banner.size} {banner.mode}')

# The banner has black background (corner pixel was 0,0,0)
# Convert to RGBA and make black transparent, then add white bg
banner_rgba = banner.convert('RGBA')
data = banner_rgba.getdata()
new_data = []
for item in data:
    # Make very dark pixels transparent
    if item[0] < 15 and item[1] < 15 and item[2] < 15:
        new_data.append((255, 255, 255, 255))  # replace black with white
    else:
        new_data.append(item)
banner_rgba.putdata(new_data)

# Now upscale 4x
w, h = banner_rgba.size
banner_big = banner_rgba.resize((w*4, h*4), Image.LANCZOS)
# Paste onto white background
bg = Image.new('RGB', banner_big.size, (255, 255, 255))
bg.paste(banner_big, mask=banner_big.split()[3])
bg.save('docs/tools/extracted_images/logos/lorma_banner_clean.png', 'PNG')
size = os.path.getsize('docs/tools/extracted_images/logos/lorma_banner_clean.png')
print(f'Lorma banner cleaned & upscaled: {bg.size}, {size//1024}KB')

# Check corner
check = Image.open('docs/tools/extracted_images/logos/lorma_banner_clean.png')
print(f'Corner pixel: {check.getpixel((5,5))} (should be ~255,255,255)')

# 2. CCSE seal check
ccse = Image.open('docs/tools/extracted_images/logos/habss_ref_p3_img1.jpeg')
print(f'CCSE: {ccse.size} {ccse.mode}, corner: {ccse.getpixel((5,5))}')

# 3. City seal check
city = Image.open('docs/tools/extracted_images/logos/seal_sanfernando.png')
print(f'City: {city.size} {city.mode}, corner: {city.getpixel((5,5))}')
