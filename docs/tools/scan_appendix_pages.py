from pypdf import PdfReader

reader = PdfReader('docs/manuscript/templates/Reference_HABSS_NewRevised_Chap1-5.pdf')
print(f'HABSS Ref: {len(reader.pages)} pages')
for i in range(65, len(reader.pages)):
    page = reader.pages[i]
    t = page.extract_text() or ''
    if t.strip():
        box = page.mediabox
        w, h = float(box.width), float(box.height)
        orient = 'LANDSCAPE' if w > h else 'PORTRAIT'
        print(f'p{i+1} [{orient} {w:.0f}x{h:.0f}]: {t[:300]}')
        print()
