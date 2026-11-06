from pypdf import PdfReader

# Check HABSS template PDF - look specifically for validation/appointment letters
for fname, label in [
    ('docs/manuscript/templates/Template_HABSS.pdf', 'HABSS Template'),
    ('docs/manuscript/templates/Template_LucidFrame_SmartSpend.pdf', 'LucidFrame Template'),
    ('docs/manuscript/templates/Reference_HABSS_NewRevised_Chap1-5.pdf', 'HABSS Reference'),
]:
    reader = PdfReader(fname)
    print(f'\n=== {label}: {len(reader.pages)} pages ===')
    for i, page in enumerate(reader.pages):
        t = page.extract_text() or ''
        box = page.mediabox
        w = float(box.width)
        h = float(box.height)
        orientation = 'LANDSCAPE' if w > h else 'PORTRAIT'
        # Look for validation/letter/appointment pages
        if any(kw in t.lower() for kw in ['certif', 'validat', 'appointment', 'letter', 'dear', 'permission', 'expert']):
            print(f'  Page {i+1} [{orientation} {w:.0f}x{h:.0f}pt]: {t[:300]}')
            print()
