"""Crop LormaLogo.jpg tightly and save as clean PNG."""
from PIL import Image, ImageChops
import os

# Open the clean Lorma logo
img = Image.open('assets/LormaLogo.jpg').convert('RGB')
print(f'Original: {img.size}')

# Auto-crop white borders using getbbox on inverted image
bg = Image.new('RGB', img.size, (255, 255, 255))
diff = ImageChops.difference(img, bg)
bbox = diff.getbbox()
print(f'Crop bbox: {bbox}')

# Add small padding
pad = 20
x1 = max(0, bbox[0] - pad)
y1 = max(0, bbox[1] - pad)
x2 = min(img.width, bbox[2] + pad)
y2 = min(img.height, bbox[3] + pad)

cropped = img.crop((x1, y1, x2, y2))
print(f'Cropped: {cropped.size}')

out = 'docs/tools/extracted_images/logos/lorma_cropped.png'
cropped.save(out, 'PNG')
print(f'Saved: {out} ({os.path.getsize(out)//1024}KB)')
print(f'Corner pixel: {cropped.getpixel((5,5))}')
