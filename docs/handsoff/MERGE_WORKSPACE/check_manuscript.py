from docx import Document
import sys

doc = Document(r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx')

# Extract all text
full_text = '\n'.join([para.text for para in doc.paragraphs])

# Critical checks
print('=== CRITICAL CHECKS ===')
print(f'Raposas mentioned: {"Raposas" in full_text}')
print(f'Mendez mentioned: {"Mendez" in full_text}')
print(f'SUS 61.83: {"61.83" in full_text}')
print(f'Grade D present: {"Grade D" in full_text or "grade of D" in full_text}')
print(f'Grade C present: {"Grade C" in full_text}')
print(f'PENDING tags: {"[PENDING]" in full_text or "PENDING" in full_text}')
print(f'Interview mentions: {full_text.lower().count("interview")}')
print(f'Survey mentions: {full_text.lower().count("survey")}')
print(f'10 parents present: {"10" in full_text and "parent" in full_text.lower()}')
print(f'20 young prof present: {"20" in full_text and "young professional" in full_text.lower()}')
print(f'Standard deviation 17.58: {"17.58" in full_text}')
print(f'N=30 or N = 30: {"N=30" in full_text or "N = 30" in full_text}')

# Check acknowledgements section
ack_start = full_text.lower().find('acknowledgement')
if ack_start > 0:
    ack_section = full_text[ack_start:ack_start+2000]
    print(f'\nAcknowledgement section contains Raposas: {"Raposas" in ack_section}')
    print(f'Acknowledgement section contains Mendez: {"Mendez" in ack_section}')
    
# Count tables
print(f'\n=== TABLE COUNT ===')
print(f'Total tables: {len(doc.tables)}')

# Count figures references
fig_count = full_text.count('Figure 3.')
print(f'\n=== FIGURE REFERENCES ===')
print(f'Figure 3.x references: {fig_count}')
for i in range(1, 12):
    has_fig = f"Figure 3.{i}" in full_text
    print(f'Figure 3.{i}: {has_fig}')

# Check for straight-line exclusion
exclusion_keywords = ['straight-line', 'straight line', 'exclusion', 'excluded']
print(f'\n=== EXCLUSION CRITERIA ===')
for keyword in exclusion_keywords:
    print(f'{keyword}: {keyword in full_text.lower()}')

# Look for specific problematic terms
print(f'\n=== PROBLEMATIC TERMS CHECK ===')
print(f'Contains "interviews" (case-insensitive): {full_text.lower().count("interview")}')
print(f'Contains "Grade C": {"Grade C" in full_text}')
print(f'Contains "[PENDING]": {"[PENDING]" in full_text}')
