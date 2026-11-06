from docx import Document
from docx.oxml.ns import qn
import os

os.makedirs('docs/tools/extracted_images', exist_ok=True)

# Check TEMPLATE and FINAL for their header banners
for fname, label in [
    ('docs/manuscript/templates/TEMPLATE_HABSS.docx', 'TEMPLATE_HABSS'),
    ('docs/manuscript/output/SmartSpend_Manuscript_FINAL.docx', 'FINAL'),
    ('docs/manuscript/templates/TEMPLATE_LORMA_ACCESS_PLUS.docx', 'LORMA_ACCESS_PLUS'),
]:
    print(f'\n=== {label} ===')
    try:
        doc = Document(fname)
        for s_i, section in enumerate(doc.sections):
            for area_name, area in [('header', section.header), ('footer', section.footer)]:
                for para in area.paragraphs:
                    full_text = para.text.strip()
                    if full_text:
                        print(f'  {area_name} text: {full_text[:80]}')
                    for run in para.runs:
                        blips = run._r.findall('.//' + qn('a:blip'), run._r.nsmap)
                        for blip in blips:
                            rId = blip.get(qn('r:embed'))
                            ext_elem = run._r.find('.//' + qn('a:ext'), run._r.nsmap)
                            if ext_elem is not None:
                                w = int(ext_elem.get('cx', 0)) / 914400
                                h = int(ext_elem.get('cy', 0)) / 914400
                            else:
                                w = h = 0
                            try:
                                part = area.part.rels[rId].target_part
                                ext = part.content_type.split('/')[-1]
                                sz = len(part.blob)
                                from PIL import Image
                                import io
                                img = Image.open(io.BytesIO(part.blob))
                                print(f'  {area_name} image: {img.size[0]}x{img.size[1]}px, {sz//1024}KB, display={w:.2f}x{h:.2f}in')
                                # Save it
                                out = f'docs/tools/extracted_images/{label}_{area_name}_{rId}.{ext}'
                                with open(out, 'wb') as f:
                                    f.write(part.blob)
                                print(f'    Saved: {out}')
                            except Exception as e:
                                print(f'  {area_name} image error: {e}')
    except Exception as e:
        print(f'  Error loading: {e}')
