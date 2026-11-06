from pypdf import PdfReader

# Read the exact content validation certificate page from LucidFrame template
reader = PdfReader('docs/manuscript/templates/Template_LucidFrame_SmartSpend.pdf')

# Page 60 (index 59) has the CONTENT VALIDATION CERTIFICATE
for i in [58, 59, 60]:
    page = reader.pages[i]
    t = page.extract_text() or ''
    box = page.mediabox
    w = float(box.width)
    h = float(box.height)
    orientation = 'LANDSCAPE' if w > h else 'PORTRAIT'
    print(f'=== Page {i+1} [{orientation} {w:.0f}x{h:.0f}pt] ===')
    print(t)
    print()
