"""Extract logos from HABSS template and LigTask reference PDFs."""
import pymupdf
import os

os.makedirs('docs/tools/extracted_images/logos', exist_ok=True)

count = 0
for fname, label in [
    ('docs/manuscript/templates/Template_HABSS.pdf', 'habss'),
    ('docs/manuscript/templates/Reference_HABSS_NewRevised_Chap1-5.pdf', 'habss_ref'),
    ('docs/manuscript/templates/Reference_LigTask_Manuscript.pdf', 'ligtask'),
]:
    doc = pymupdf.open(fname)
    print(f'\n=== {label}: {len(doc)} pages ===')
    for page_num in range(min(8, len(doc))):
        page = doc[page_num]
        images = page.get_images(full=True)
        if images:
            print(f'  Page {page_num+1}: {len(images)} images')
            for img_idx, img in enumerate(images):
                xref = img[0]
                try:
                    base = doc.extract_image(xref)
                    img_bytes = base["image"]
                    ext = base["ext"]
                    w = base.get("width", 0)
                    h = base.get("height", 0)
                    out = f'docs/tools/extracted_images/logos/{label}_p{page_num+1}_img{img_idx}.{ext}'
                    with open(out, 'wb') as f:
                        f.write(img_bytes)
                    print(f'    {os.path.basename(out)}: {w}x{h}px {len(img_bytes)//1024}KB')
                    count += 1
                except Exception as e:
                    print(f'    Error: {e}')

print(f'\nTotal extracted: {count}')
