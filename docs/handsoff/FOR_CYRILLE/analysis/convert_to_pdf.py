#!/usr/bin/env python3
"""
Convert the fixed manuscript DOCX to PDF
This uses docx2pdf which requires Microsoft Word to be installed on Windows
"""

import sys
import os

try:
    from docx2pdf import convert
    
    docx_path = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
    pdf_path = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx.pdf'
    
    print(f"Converting DOCX to PDF...")
    print(f"  Source: {docx_path}")
    print(f"  Target: {pdf_path}")
    
    if not os.path.exists(docx_path):
        print(f"✗ Error: Source file not found!")
        sys.exit(1)
    
    # Convert
    convert(docx_path, pdf_path)
    
    # Check if PDF was created
    if os.path.exists(pdf_path):
        pdf_size = os.path.getsize(pdf_path) / (1024 * 1024)  # MB
        print(f"\n✓ PDF generated successfully!")
        print(f"  Size: {pdf_size:.2f} MB")
    else:
        print(f"\n✗ Error: PDF file was not created")
        sys.exit(1)
        
except ImportError:
    print("Installing docx2pdf package...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "docx2pdf"])
    print("\nPackage installed. Please run this script again.")
    sys.exit(0)
except Exception as e:
    print(f"\n✗ Error during conversion: {e}")
    print("\nNote: docx2pdf requires Microsoft Word to be installed on Windows.")
    print("Alternative: Open the DOCX file in Word and use 'File > Save As > PDF'")
    sys.exit(1)
