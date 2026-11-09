#!/usr/bin/env python3
"""Convert SUS_Computation_Table.html to PNG"""

from html2image import Html2Image
import os

# Get the directory where this script is located
script_dir = os.path.dirname(os.path.abspath(__file__))

# Initialize Html2Image
hti = Html2Image(output_path=script_dir)

# Read the HTML file
html_file = os.path.join(script_dir, 'SUS_Computation_Table.html')
with open(html_file, 'r', encoding='utf-8') as f:
    html_content = f.read()

# Convert to PNG
output_file = 'Figure_3.11_SUS_Computation_Table.png'
print(f"Converting {html_file} to {output_file}...")

hti.screenshot(
    html_str=html_content,
    save_as=output_file,
    size=(950, 1100)  # Width x Height to capture the full table
)

print(f"✅ Successfully created {output_file}")
