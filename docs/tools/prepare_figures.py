"""
Map all screenshots from docs/handsoff/screenshots to the 8 required figures.
Copy them to docs/handsoff/FOR_CYRILLE/FIGURES/ with clean names.
"""
import os, shutil
from PIL import Image

screenshots_dir = 'docs/handsoff/screenshots'
output_dir = 'docs/handsoff/FOR_CYRILLE/FIGURES'
os.makedirs(output_dir, exist_ok=True)

# Map based on visual inspection and timestamps
figure_mapping = {
    # 3.4 - Login and Demo Mode Screen (with "Try Demo" button visible)
    'Screenshot_2026-11-09-09-40-07-439_com.lucidframe.smartspend_app.jpg': 'Figure_3.4_Login_Demo_Mode.jpg',
    
    # 3.5 - Home Dashboard (FHS ring + Peso visible)
    'Screenshot_2026-11-09-09-40-44-731_com.lucidframe.smartspend_app.jpg': 'Figure_3.5_Home_Dashboard.jpg',
    
    # 3.6 - Expense Logging Through Peso Chat (need to find the Peso chat screen)
    'Screenshot_2026-11-09-09-49-01-006_com.lucidframe.smartspend_app.jpg': 'Figure_3.6_Peso_Chat_Expense_Logging.jpg',
    
    # 3.7 - Receipt Scanning and Batch Screenshot Import (batch import with GCash screenshots)
    'Screenshot_2026-11-09-09-48-19-244_com.lucidframe.smartspend_app.jpg': 'Figure_3.7_Batch_Import_GCash.jpg',
    
    # 3.8 - Financial Health Score Breakdown (FHS details screen)
    'Screenshot_2026-11-09-09-44-21-448_com.lucidframe.smartspend_app.jpg': 'Figure_3.8_FHS_Breakdown.jpg',
    
    # 3.9 - Budgets, Safe-to-Spend, and Savings Goals
    'Screenshot_2026-11-09-09-44-11-026_com.lucidframe.smartspend_app.jpg': 'Figure_3.9_Budgets_Savings_Goals.jpg',
    
    # 3.10 - Local AI Mode Setup (Settings screen with Local AI section)
    'Screenshot_2026-11-09-09-52-23-802_com.lucidframe.smartspend_app.jpg': 'Figure_3.10_Local_AI_Setup.jpg',
}

print("Copying and renaming figures...")
for src_name, dest_name in figure_mapping.items():
    src_path = os.path.join(screenshots_dir, src_name)
    dest_path = os.path.join(output_dir, dest_name)
    
    if os.path.exists(src_path):
        # Copy and optionally resize if too large
        img = Image.open(src_path)
        width, height = img.size
        
        # If width > 1200px, scale down to 1200px width (for Word insertion)
        if width > 1200:
            new_width = 1200
            new_height = int(height * (new_width / width))
            img = img.resize((new_width, new_height), Image.LANCZOS)
            print(f"  Resized {src_name} from {width}x{height} to {new_width}x{new_height}")
        
        img.save(dest_path, quality=90, optimize=True)
        print(f"✓ {dest_name}")
    else:
        print(f"✗ MISSING: {src_name}")

print(f"\nFigures saved to: {output_dir}")
print("\nStill need to create Figure 3.11 (SUS Computation Table)")
