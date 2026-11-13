from docx import Document
import re, zipfile

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL.docx'
doc = Document(DOCX)

all_text = '\n'.join(p.text for p in doc.paragraphs)
table_text = '\n'.join(c.text for t in doc.tables for row in t.rows for c in row.cells)
full_doc = all_text + '\n' + table_text

# 1. No "mixed-methods"
print('MC1 mixed-methods absent:', 'mixed-methods' not in full_doc)

# 2. quantitative descriptive developmental in sections
qdd = 'quantitative descriptive developmental'
print('MC2 qdd anywhere:', qdd in full_doc.lower())

# 3. random sampling / purposive sampling
print('MC3a random sampling:', 'random sampling' in full_doc)
print('MC3b purposive sampling:', 'purposive sampling' in full_doc)

# 4. nine recommendations
print('MC4 nine recommendations:', 'nine recommendations' in full_doc.lower() or 'Nine recommendations' in full_doc)

# 5. 9 recommendations present
rec_count = sum(1 for x in ['1. ','2. ','3. ','4. ','5. ','6. ','7. ','8. ','9. '] if x in full_doc)
print(f'MC5 recs 1-9 present count: {rec_count}/9')

# 6. eight-provider cloud failover chain with Gemini 3.5 Flash-Lite
print('MC6a eight-provider:', 'eight-provider' in full_doc)
print('MC6b Gemini 3.5 Flash-Lite primary:', 'Gemini 3.5 Flash-Lite' in full_doc)
print('MC6c seven fallbacks:', 'seven fallback' in full_doc or 'seven (7) fallback' in full_doc)

# 7. SUS values
print('MC7a SUS 61.83:', '61.83' in full_doc)
print('MC7b SD 17.58:', '17.58' in full_doc)
print('MC7c N=30:', 'N = 30' in full_doc or 'N=30' in full_doc)
print('MC7d Grade D:', 'Grade D' in full_doc or 'grade of D' in full_doc)
print('MC7e adjective OK:', '"OK"' in full_doc or 'adjective rating of' in full_doc or 'OK' in full_doc)
print('MC7f partially achieved:', 'partially achieved' in full_doc)

# 8. Needs assessment 16+14=30
print('MC8 16 parents + 14 YP:', '16' in full_doc and '14' in full_doc)

# 9. SUS 10+20=30
print('MC9 SUS 10 parents (58.25 mean):', '58.25' in full_doc)

# 10. 96.7% and 93.3%
print('MC10a 96.7%:', '96.7' in full_doc)
print('MC10b 93.3%:', '93.3' in full_doc)

# 11. Avigail Candevario, PFMe
print('MC11a Avigail Candevario:', 'Avigail Candevario' in full_doc)
print('MC11b PFMe:', 'PFMe' in full_doc or 'PF Me' in full_doc)

# 12. Panel members
print('MC12a Jeoffrey B. Layco:', 'Jeoffrey' in full_doc and 'Layco' in full_doc)
print('MC12b Shekiro MTS MIS:', 'Shekiro R. Raposas, MTS, MIS' in full_doc)
print('MC12c Mary-Ann Mzana MTS:', 'Mary-Ann' in full_doc and 'Mzana' in full_doc)

# 13. Adviser Ellen Flores Mangaoang DIT
print('MC13 Mangaoang DIT:', 'Mangaoang' in full_doc and 'DIT' in full_doc)

# 14. Gemini 3.5 Flash-Lite (not 1.5)
print('MC14a Gemini 3.5 Flash-Lite:', 'Gemini 3.5 Flash-Lite' in full_doc)
print('MC14b no Gemini 1.5:', 'Gemini 1.5' not in full_doc)

# 15. 8 LLM APIs evaluated
print('MC15 8 LLM APIs:', '8 LLM' in full_doc or 'eight (8) LLM' in full_doc or 'eight LLM' in full_doc.lower())

# 16. Figure 17 and Figure 18
print('MC16a Figure 17:', 'Figure 17' in full_doc)
print('MC16b Figure 18:', 'Figure 18' in full_doc)

# 17. Table 9
print('MC17 Table 9:', 'Table 9' in full_doc)

# 18. No chapter-prefixed figure/table numbers
chap_fig = bool(re.search(r'Figure\s+\d+\.\d+', full_doc))
chap_tab = bool(re.search(r'Table\s+\d+\.\d+', full_doc))
print('MC18a no Figure X.Y:', not chap_fig)
print('MC18b no Table X.Y:', not chap_tab)

# 19. Figure captions format "Figure N. Title"
fig_caps = re.findall(r'Figure \d+\.', full_doc)
print(f'MC19 Figure N. format count: {len(fig_caps)}, sample: {fig_caps[:3]}')

# 20. Table captions format "Table N: Title"
tab_caps = re.findall(r'Table \d+:', full_doc)
print(f'MC20 Table N: format count: {len(tab_caps)}, sample: {tab_caps[:3]}')

# 21. Word comments preserved
with zipfile.ZipFile(DOCX, 'r') as z:
    files = z.namelist()
    has_comments = 'word/comments.xml' in files
    if has_comments:
        comm_xml = z.read('word/comments.xml').decode('utf-8', errors='replace')
        import xml.etree.ElementTree as ET
        root = ET.fromstring(comm_xml)
        ns = {'w': 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'}
        comments = root.findall('.//w:comment', ns)
        print(f'MC21 comments present: {len(comments)} comment(s)')
    else:
        print('MC21 comments present: False')

# 22. No "proposed SmartSpend" or "will be developed"
print('MC22a no proposed SmartSpend:', 'proposed SmartSpend' not in full_doc)
print('MC22b no will be developed:', 'will be developed' not in full_doc)

# 23. Table 3 note
note_text = 'Note. The content validator participated separately and is not included in the respondent total of 30.'
print('MC23 Table 3 note:', note_text in full_doc)

# 24. No Figure 3.14, no duplicate Demographic Distribution
print('MC24a no Figure 3.14:', 'Figure 3.14' not in full_doc)
dd_count = full_doc.count('Demographic Distribution')
print(f'MC24b Demographic Distribution count: {dd_count} (<=2 is ok)')
