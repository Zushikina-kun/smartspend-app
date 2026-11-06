from docx import Document
from docx.oxml.ns import qn

doc = Document('docs/handsoff/CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx')
section = doc.sections[0]
header = section.header

for para in header.paragraphs:
    for run in para.runs:
        blips = run._r.findall('.//' + qn('a:blip'), run._r.nsmap)
        for blip in blips:
            rId = blip.get(qn('r:embed'))
            try:
                part = header.part.rels[rId].target_part
                ext = part.content_type.split('/')[-1]
                fname = f'docs/tools/extracted_images/header_{rId}.{ext}'
                with open(fname, 'wb') as f:
                    f.write(part.blob)
                print(f'Saved {fname} ({len(part.blob)} bytes)')
            except Exception as e:
                print(f'Error {rId}: {e}')
