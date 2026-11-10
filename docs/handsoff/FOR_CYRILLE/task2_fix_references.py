"""
TASK 2: Fix APA7 references formatting in manuscript
"""
from docx import Document
from docx.shared import Inches, Pt
from docx.enum.text import WD_ALIGN_PARAGRAPH
import os

MANUSCRIPT = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'

doc = Document(MANUSCRIPT)
paragraphs = doc.paragraphs

# Find the References section heading
ref_start_idx = None
for i, para in enumerate(paragraphs):
    t = para.text.strip()
    if t.upper() in ('REFERENCES', 'REFERENCE'):
        # Make sure it looks like a heading (short, standalone)
        if len(t) < 30:
            ref_start_idx = i
            print(f"Found References heading at paragraph index {i}: '{para.text.strip()}'")
            break

if ref_start_idx is None:
    print("ERROR: Could not find References heading!")
    exit(1)

# Find the end of references section (APPENDIX or end of doc)
ref_end_idx = len(paragraphs)
for i in range(ref_start_idx + 1, len(paragraphs)):
    t = paragraphs[i].text.strip().upper()
    if t.startswith('APPENDIX') or t.startswith('CURRICULUM VITAE'):
        ref_end_idx = i
        print(f"References section ends at paragraph index {i}: '{paragraphs[i].text.strip()}'")
        break

print(f"References range: {ref_start_idx+1} to {ref_end_idx-1} ({ref_end_idx - ref_start_idx - 1} paragraphs)")

# Process reference paragraphs
reformatted_count = 0
merged_count = 0

# First pass: format individual paragraphs
i = ref_start_idx + 1
while i < ref_end_idx:
    para = paragraphs[i]
    text = para.text.strip()
    
    if text == '':
        # Skip blank paragraphs (separators)
        i += 1
        continue
    
    # Apply hanging indent formatting
    pf = para.paragraph_format
    pf.first_line_indent = -Inches(0.5)
    pf.left_indent = Inches(0.5)
    pf.alignment = WD_ALIGN_PARAGRAPH.LEFT
    pf.space_before = Pt(0)
    pf.space_after = Pt(0)
    
    # Format runs
    for run in para.runs:
        run.font.name = 'Tahoma'
        run.font.size = Pt(12)
    
    reformatted_count += 1
    i += 1

print(f"\nFormatted {reformatted_count} reference paragraphs")

# Second pass: merge URL/DOI continuation lines
# We need to work with the XML directly to remove paragraphs
# Collect paragraphs to merge (indices relative to full doc paragraph list)
paragraphs_to_merge = []

i = ref_start_idx + 1
while i < ref_end_idx - 1:
    para = paragraphs[i]
    next_para = paragraphs[i + 1]
    text = para.text.strip()
    next_text = next_para.text.strip()
    
    if text == '' or next_text == '':
        i += 1
        continue
    
    # Check if next paragraph is a continuation (URL, DOI, or Retrieved)
    if (next_text.startswith('http') or 
        next_text.startswith('doi') or 
        next_text.lower().startswith('retrieved') or
        next_text.startswith('https')):
        paragraphs_to_merge.append((i, i+1))
        print(f"  Will merge para {i} with para {i+1}")
        print(f"    Main: {text[:60]}...")
        print(f"    Continuation: {next_text[:60]}")
        i += 2  # skip both
    else:
        i += 1

# Apply merges - work from end to beginning to preserve indices
for main_idx, cont_idx in reversed(paragraphs_to_merge):
    main_para = paragraphs[main_idx]
    cont_para = paragraphs[cont_idx]
    
    # Append continuation text to main paragraph's last run (or add new run)
    cont_text = ' ' + cont_para.text.strip()
    if main_para.runs:
        main_para.runs[-1].text += cont_text
    else:
        run = main_para.add_run(cont_text)
        run.font.name = 'Tahoma'
        run.font.size = Pt(12)
    
    # Remove the continuation paragraph from XML
    cont_para._element.getparent().remove(cont_para._element)
    merged_count += 1

print(f"Merged {merged_count} continuation lines")

# Save
doc.save(MANUSCRIPT)
print(f"\nSaved: {MANUSCRIPT}")

size = os.path.getsize(MANUSCRIPT)
print(f"File size after save: {size:,} bytes")
if size < 100000:
    print("WARNING: File size suspiciously small!")
else:
    print("File size OK.")
