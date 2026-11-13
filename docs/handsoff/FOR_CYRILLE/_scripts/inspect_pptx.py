#!/usr/bin/env python3
"""Inspect PowerPoint file to see slide titles"""

from pptx import Presentation
import os

script_dir = os.path.dirname(os.path.abspath(__file__))
pptx_path = os.path.join(script_dir, '3_PRESENTATION.pptx')

print(f"Inspecting: {pptx_path}\n")
prs = Presentation(pptx_path)

print(f"Total slides: {len(prs.slides)}\n")

for i, slide in enumerate(prs.slides):
    title = "No title"
    if slide.shapes.title:
        title = slide.shapes.title.text
    
    print(f"Slide {i + 1}: {title}")
    
    # Also print text from first few shapes
    text_count = 0
    for shape in slide.shapes:
        if hasattr(shape, "text") and shape.text and text_count < 3:
            snippet = shape.text[:80].replace('\n', ' ')
            if snippet != title:
                print(f"  - {snippet}...")
                text_count += 1
    print()
