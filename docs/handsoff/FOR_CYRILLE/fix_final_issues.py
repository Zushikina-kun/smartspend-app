"""Fix all remaining issues found from reading the actual Word output."""
import shutil, zipfile
from docx import Document
from docx.shared import Pt, Inches
from docx.oxml.ns import qn
from docx.oxml import OxmlElement
from docx.text.paragraph import Paragraph as DocxParagraph

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
FIGS = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\FIGURES'
shutil.copy(DOCX, DOCX + '.finalissues.bak')
doc = Document(DOCX)
log = []

def rp(para, new_text):
    if para.runs:
        para.runs[0].text = new_text
        for r in para.runs[1:]: r.text = ''
    else:
        para.add_run(new_text)

def insert_after(doc, idx, text):
    before_p = doc.paragraphs[idx]
    new_p = OxmlElement('w:p')
    before_p._p.addnext(new_p)
    po = DocxParagraph(new_p, before_p._parent)
    r = po.add_run(text)
    r.font.name = 'Tahoma'
    r.font.size = Pt(12)
    return po

# ── Fix 1: "Table 1.2" references in body ────────────────────────────────
for i, p in enumerate(doc.paragraphs):
    if 'Table 1.2' in p.text:
        new_t = p.text.replace('Table 1.2', 'Table 2')
        rp(p, new_t)
        log.append(f'[{i}] Table 1.2 → Table 2')

# ── Fix 2: "provide simple insights" present tense in Purpose ────────────
for i, p in enumerate(doc.paragraphs):
    if 'respond to user inputs and provide simple insights' in p.text:
        rp(p, p.text.replace('respond to user inputs and provide simple insights',
                               'responded to user inputs and provided simple insights'))
        log.append(f'[{i}] provide → provided (Purpose section)')

# ── Fix 3: "Tables 3.3 and 3.4" ──────────────────────────────────────────
for i, p in enumerate(doc.paragraphs):
    if 'Tables 3.3 and 3.4' in p.text:
        rp(p, p.text.replace('Tables 3.3 and 3.4', 'Tables 8 and 9'))
        log.append(f'[{i}] Tables 3.3 and 3.4 → Tables 8 and 9')

# ── Fix 4: "93.3% already use GCash" in Conclusions ──────────────────────
for i, p in enumerate(doc.paragraphs):
    if '93.3% already use GCash' in p.text:
        rp(p, p.text.replace('93.3% already use GCash', '93.3% already used GCash'))
        log.append(f'[{i}] already use → already used')

# ── Fix 5: "acceptable for a prototype system" ────────────────────────────
for i, p in enumerate(doc.paragraphs):
    if 'below the ≥80 target but acceptable for a prototype system' in p.text:
        rp(p, p.text.replace('below the ≥80 target but acceptable for a prototype system',
                               'below both the 68-point average benchmark and the pre-established target of 80'))
        log.append(f'[{i}] acceptable for prototype → correct framing')

# ── Fix 6: "obtained an overall mean SUS score" missing subject ───────────
for i, p in enumerate(doc.paragraphs):
    t = p.text.strip()
    if t.startswith('obtained an overall mean SUS score'):
        rp(p, 'SmartSpend ' + t)
        log.append(f'[{i}] Added missing "SmartSpend" subject to Obj 3 conclusion')

# ── Fix 7: Population blank "Table _" ────────────────────────────────────
for i, p in enumerate(doc.paragraphs):
    if 'as seen in Table _' in p.text or 'as seen in Table_' in p.text:
        rp(p, p.text.replace('as seen in Table _', 'as presented in Table 3')
                     .replace('as seen in Table_', 'as presented in Table 3'))
        log.append(f'[{i}] Table _ → Table 3')

# ── Fix 8: Duplicate purposive sampling paragraph ────────────────────────
# After the random sampling paragraph, there may be a "The researchers utilized purposive sampling"
# paragraph that now contradicts. Remove it.
for i, p in enumerate(doc.paragraphs):
    if ('The researchers utilized purposive sampling in selecting participants' in p.text and
            i > 150):
        # Check context - if random sampling already mentioned just above, this is a duplicate
        context = ' '.join(doc.paragraphs[max(0,i-5):i+1][j].text for j in range(min(5, i)))
        if 'random sampling' in context.lower():
            rp(p, '')
            log.append(f'[{i}] Removed duplicate purposive sampling paragraph (after random sampling)')

# ── Fix 9: "Table 3.2" in Kanban deliverables ────────────────────────────
for i, p in enumerate(doc.paragraphs):
    if 'LLM benchmarking matrix (Table 3.2)' in p.text:
        rp(p, p.text.replace('Table 3.2', 'Table 7'))
        log.append(f'[{i}] Table 3.2 → Table 7 in Kanban table')
# Also fix in table cells
for t in doc.tables:
    for row in t.rows:
        for cell in row.cells:
            for cp in cell.paragraphs:
                if 'Table 3.2' in cp.text:
                    for run in cp.runs:
                        if 'Table 3.2' in run.text:
                            run.text = run.text.replace('Table 3.2', 'Table 7')
                            log.append(f'Table cell: Table 3.2 → Table 7')

# ── Fix 10: Bullet dash in body "- SmartSpend was developed" ─────────────
for i, p in enumerate(doc.paragraphs):
    t = p.text.strip()
    if t.startswith('-\tSmartSpend was developed') or t.startswith('- SmartSpend was developed'):
        rp(p, t.lstrip('-\t '))
        log.append(f'[{i}] Removed bullet dash from SmartSpend paragraph')

# ── Fix 11: Add missing figure descriptions ───────────────────────────────
fig_descs = {
    'Figure 1:': "Figure 1 shows the financial literacy rates among Filipino adults by demographic group based on the 2021 BSP Financial Inclusion Survey and Inquiro (2024) data. The chart illustrates that only 2% of all adults answered all six literacy questions correctly, while college graduates showed the highest rate at 6%.",
    'Figure 6.': "Figure 6 presents the system flowchart of SmartSpend, illustrating how user inputs are processed through on-device redaction, routed to either a local or cloud LLM provider, parsed into agentic actions, and stored in the SQLite database with optional Firestore synchronization.",
    'Figure 7.': "Figure 7 shows the use case diagram of SmartSpend, depicting the interactions between the user and the system. Key user actions include logging expenses, importing screenshots, chatting with the AI, setting budgets and savings goals, viewing analytics, and checking the Financial Health Score.",
    'Figure 8.': "Figure 8 presents the visual table of contents of SmartSpend, showing the navigation structure from the login screen to the home dashboard and its connected modules including Expenses, Budget, Savings, Analytics, AI Chat, Achievements, and Settings.",
    'Figure 9.': "Figure 9 presents the Login and Register Screen of SmartSpend, which also provides access to Demo Mode for first-time users and a Continue Without Account option for local-only use.",
    'Figure 11.': "Figure 11 presents the Peso Chat interface, where users logged expenses through natural language input in Filipino, English, or Taglish. The AI assistant parsed the input and automatically recorded the transaction.",
    'Figure 12.': "Figure 12 shows the receipt scanning feature of SmartSpend, where the app extracted transaction details from physical receipts using OCR. Users could review and edit the extracted data before confirming the entry.",
    'Figure 13.': "Figure 13 displays the Financial Health Score breakdown screen, showing the user's individual score components including Savings Rate, Overspend Control, Budget Adherence, and Logging Consistency.",
    'Figure 14.': "Figure 14 shows the Budgets screen, where users set spending limits per category and monitored their adherence. The screen also displayed Safe-to-Spend calculations and savings goal progress.",
    'Figure 15.': "Figure 15 presents the Local AI Mode setup screen, which guided users in configuring an offline AI model using tools such as Ollama, LM Studio, or Jan for private use without internet connectivity.",
}

for i, p in enumerate(doc.paragraphs):
    cap = p.text.strip()
    for key, desc in fig_descs.items():
        if cap.startswith(key) and len(cap) < 200:
            # Check if next paragraph is already a description (not a figure/table)
            next_p_text = doc.paragraphs[i+1].text.strip() if i+1 < len(doc.paragraphs) else ''
            next_is_figure = next_p_text.startswith('Figure') or next_p_text.startswith('Table')
            next_is_empty = not next_p_text
            already_has_desc = not next_is_figure and not next_is_empty and len(next_p_text) > 30

            if not already_has_desc:
                insert_after(doc, i, desc)
                log.append(f'[{i}] Added description for {key}')
            break

# ── Fix 12: Re-embed Figure 5 with correct 16/14 chart ───────────────────
fig5_path = f'{FIGS}/Figure_Demographic_Breakdown.png'
import os
if os.path.exists(fig5_path):
    for i, p in enumerate(doc.paragraphs):
        if 'Figure 5' in p.text and 'Demographic Distribution' in p.text:
            # Find image paragraph before caption
            for offset in range(1, 4):
                if i >= offset:
                    img_p = doc.paragraphs[i - offset]
                    if img_p._p.findall('.//' + qn('a:blip')):
                        # Clear and re-embed
                        for run in img_p.runs:
                            run._element.getparent().remove(run._element)
                        run = img_p.add_run()
                        run.add_picture(fig5_path, width=Inches(5.0))
                        img_p.alignment = 1
                        log.append(f'[{i-offset}] Re-embedded Figure 5 with 16/14 chart')
                        break
            break

doc.save(DOCX)
print(f'\n{len(log)} fixes applied:')
for l in log: print(f'  {l}')
