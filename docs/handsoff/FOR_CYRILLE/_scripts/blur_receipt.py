"""
Blur personal data in Figure 3.7 receipt scan.
Blurs the extracted text overlay at the bottom of the image.
"""
from PIL import Image, ImageFilter, ImageDraw
import shutil

IMG = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\FIGURES\Figure_3.7_Batch_Import_GCash.jpg'
OUT = IMG  # overwrite in place (original backed up)

# Backup first
shutil.copy(IMG, IMG + '.original.bak')

img = Image.open(IMG)
w, h = img.size
print(f'Image size: {w}x{h}')

# The extracted text box occupies roughly the bottom 45% of the image
# (from the screenshots it appears around y=55% to y=93% of height)
blur_top    = int(h * 0.52)   # start of text overlay region
blur_bottom = int(h * 0.93)   # end of text overlay region
blur_left   = int(w * 0.03)
blur_right  = int(w * 0.97)

# Crop the region to blur
region = img.crop((blur_left, blur_top, blur_right, blur_bottom))

# Apply heavy gaussian blur
blurred = region.filter(ImageFilter.GaussianBlur(radius=18))

# Also add a semi-transparent rectangle to make it look intentionally redacted
draw_img = img.copy()
draw_img.paste(blurred, (blur_left, blur_top))

# Add a dark semi-opaque overlay for the name fields specifically
# (the most sensitive part: "Received from: DI RECTO, BRIX A." area)
overlay = Image.new('RGBA', img.size, (0, 0, 0, 0))
draw = ImageDraw.Draw(overlay)
# Draw redaction bars over the name lines (~y 58-70% of height)
for y_start_pct, y_end_pct in [(0.57, 0.63), (0.63, 0.68)]:
    y1 = int(h * y_start_pct)
    y2 = int(h * y_end_pct)
    draw.rectangle([(int(w*0.03), y1), (int(w*0.97), y2)],
                   fill=(30, 30, 30, 200))

# Composite
if img.mode != 'RGBA':
    base = draw_img.convert('RGBA')
else:
    base = draw_img
result = Image.alpha_composite(base, overlay).convert('RGB')

result.save(OUT, quality=92)
print(f'Saved blurred image to: {OUT}')
print('Personal data regions blurred/redacted.')
