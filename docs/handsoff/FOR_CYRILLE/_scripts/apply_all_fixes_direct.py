"""
Apply ALL remaining fixes directly to the FINAL manuscript.
Single-pass, no workflows.
"""
import shutil
from docx import Document
from docx.shared import Pt
from docx.oxml.ns import qn

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
shutil.copy(DOCX, DOCX + '.all_fixes.bak')
doc = Document(DOCX)
log = []

def replace_para(para, new_text):
    if para.runs:
        para.runs[0].text = new_text
        for r in para.runs[1:]: r.text = ''
    else:
        para.add_run(new_text)

def clear_para(para):
    if para.runs:
        para.runs[0].text = ''
        for r in para.runs[1:]: r.text = ''

# ── FIX 1: Susan → Avigail ────────────────────────────────────────────────
for i, p in enumerate(doc.paragraphs):
    if 'Susan C. Arquisal' in p.text:
        new_t = p.text.replace(
            'Susan C. Arquisal, a graduate of Bachelor of Science in Commerce major in Management and an active business owner with experience in financial management and business operations',
            'Avigail Candevario, PFMe, a subject matter expert in financial management and business operations'
        )
        replace_para(p, new_t)
        log.append(f'[{i}] Susan → Avigail')
    # Delete blank-name validator duplicate
    if 'reviewed by , a graduate of Bachelor of Science' in p.text:
        clear_para(p)
        log.append(f'[{i}] Deleted blank-name validator duplicate')

# ── FIX 2: Research Design — mixed methods → quantitative ────────────────
for i, p in enumerate(doc.paragraphs):
    t = p.text
    if 'By combining mixed methods and developmental approaches' in t:
        new_t = t.replace(
            'By combining mixed methods and developmental approaches',
            'By combining quantitative and developmental approaches'
        )
        replace_para(p, new_t)
        log.append(f'[{i}] mixed methods → quantitative in conclusion sentence')
    if 'mixed-methods developmental research design, which integrated both qualitative and quantitative' in t:
        new_t = t.replace(
            'mixed-methods developmental research design, which integrated both qualitative and quantitative',
            'quantitative descriptive developmental research design, which integrated quantitative'
        )
        replace_para(p, new_t)
        log.append(f'[{i}] Research design sentence fixed')

# ── FIX 3: Table references ───────────────────────────────────────────────
for i, p in enumerate(doc.paragraphs):
    t = p.text
    if 'Table 1.1 presented a three-level' in t or 'Table 1.1 presented' in t:
        new_t = t.replace('Table 1.1', 'Table 1')
        replace_para(p, new_t); log.append(f'[{i}] Table 1.1 → Table 1')
    if 'Table 2.1 summarized' in t:
        new_t = t.replace('Table 2.1 summarized', 'Table 2 summarized')
        replace_para(p, new_t); log.append(f'[{i}] Table 2.1 → Table 2')
    if 'Table 2.1 presented' in t and 'SUS' not in t:
        new_t = t.replace('Table 2.1 presented', 'Table 2 presented')
        replace_para(p, new_t); log.append(f'[{i}] Table 2.1 → Table 2 (presented)')
    if 'Table 2.2' in t and 'Kanban' in t:
        new_t = t.replace('Table 2.2', 'Table 4')
        replace_para(p, new_t); log.append(f'[{i}] Table 2.2 → Table 4 (Kanban)')
    if 'Table 3.2 presented' in t or 'Table 3.2' in t:
        new_t = t.replace('Table 3.2', 'Table 7')
        replace_para(p, new_t); log.append(f'[{i}] Table 3.2 → Table 7')
    if 'Tables 3.3 and 3.4' in t:
        new_t = t.replace('Tables 3.3 and 3.4', 'Tables 8 and 9')
        replace_para(p, new_t); log.append(f'[{i}] Tables 3.3/3.4 → 8/9')
    if 'Table 3.3' in t and 'SUS' in t:
        new_t = t.replace('Table 3.3,', 'Table 8,').replace('Table 3.3.', 'Table 8.')
        if new_t != t: replace_para(p, new_t); log.append(f'[{i}] Table 3.3 → Table 8')

# ── FIX 4: Tense fixes ────────────────────────────────────────────────────
tense_fixes = [
    ('SmartSpend allows users to control', 'SmartSpend allowed users to control'),
    ('93.3% already use GCash', '93.3% already used GCash'),
    ('This score is below', 'This score was below'),
]
for i, p in enumerate(doc.paragraphs):
    for old, new in tense_fixes:
        if old in p.text:
            replace_para(p, p.text.replace(old, new))
            log.append(f'[{i}] Tense: "{old[:40]}" → past')

# ── FIX 5: Conclusion paragraph 1 ────────────────────────────────────────
for i, p in enumerate(doc.paragraphs):
    if 'below the ≥80 target but acceptable for a prototype system' in p.text:
        new_t = p.text.replace(
            'below the ≥80 target but acceptable for a prototype system',
            'below both the 68-point average benchmark and the pre-established target of 80'
        )
        replace_para(p, new_t); log.append(f'[{i}] Conclusion: "acceptable" → correct framing')

# ── FIX 6: Abstract - provider chain ─────────────────────────────────────
for i, p in enumerate(doc.paragraphs):
    if 'a six-provider AI failover chain' in p.text:
        new_t = p.text.replace(
            'a six-provider AI failover chain',
            'an eight-provider cloud failover chain (Gemini 3.5 Flash-Lite as primary, seven fallbacks)'
        )
        replace_para(p, new_t); log.append(f'[{i}] Abstract: 6→8 providers')
    if 'Seven recommendations were identified' in p.text:
        new_t = p.text.replace('Seven recommendations were identified', 'Nine recommendations were identified')
        replace_para(p, new_t); log.append(f'[{i}] Abstract: 7→9 recommendations')

# ── FIX 7: Scope and Limitations — replace 4 paragraphs with 2 ───────────
scope_heading_idx = None
for i, p in enumerate(doc.paragraphs):
    if p.text.strip() == 'Scope and Limitations of the Study' and i > 100:
        scope_heading_idx = i
        break

if scope_heading_idx:
    NEW_SCOPE = ("The study was limited to the development and evaluation of SmartSpend as an "
        "Android mobile application. The system supported voice input, receipt scanning through "
        "OCR, barcode scanning, and text-based chat through the AI assistant. It integrated a "
        "large language model API for natural language processing and financial assistance, local "
        "data storage through SQLite, and optional cloud synchronization through Firebase. A "
        "Financial Health Score was developed as a prototype indicator of budgeting behavior.")
    NEW_LIMITS = ("The system was available only on Android devices. Direct banking integration "
        "was excluded. The application did not provide professional financial or investment advice. "
        "OCR accuracy depended on receipt image quality. Voice recognition was affected by "
        "background noise. All AI features required an active internet connection.")

    # Replace first 2 body paragraphs, clear the rest until next heading
    body_paras = []
    for j in range(scope_heading_idx + 1, min(scope_heading_idx + 10, len(doc.paragraphs))):
        t = doc.paragraphs[j].text.strip()
        if t and (doc.paragraphs[j].style.name.startswith('Heading') or
                  'Purpose and Description' in t or 'Technical Background' in t or
                  'CHAPTER' in t.upper()):
            break
        body_paras.append(j)

    if len(body_paras) >= 1:
        replace_para(doc.paragraphs[body_paras[0]], NEW_SCOPE)
        log.append(f'Set Scope para 1 at [{body_paras[0]}]')
    if len(body_paras) >= 2:
        replace_para(doc.paragraphs[body_paras[1]], NEW_LIMITS)
        log.append(f'Set Scope para 2 at [{body_paras[1]}]')
    for j in body_paras[2:]:
        clear_para(doc.paragraphs[j])
        log.append(f'Cleared Scope para at [{j}]')

# ── FIX 8: Technical Background — replace with condensed version ──────────
tb_start = None
tb_end = None
for i, p in enumerate(doc.paragraphs):
    if p.text.strip() == 'Technical Background' and i > 100:
        tb_start = i
    if tb_start and i > tb_start + 1:
        t = p.text.strip()
        if t and (p.style.name.startswith('Heading') or
                  'CHAPTER II' in t.upper() or 'Research Design' in t or
                  'DESIGN AND METHODOLOGY' in t.upper()):
            tb_end = i
            break

NEW_TB = [
    "In this section, the researchers described the technologies used in the design and development of the SmartSpend mobile application.",
    "Flutter. Flutter was used to build the SmartSpend Android application, providing a consistent and responsive user interface across different screen sizes and device configurations.",
    "SQLite. SQLite served as the local database of SmartSpend, storing all financial data — including expenses, budgets, savings goals, and chat history — directly on the device to ensure full offline functionality.",
    "Firebase. Firebase Firestore was used to synchronize financial data across devices whenever the user was online. Firebase Authentication managed user sign-in, supporting email/password and Google login. Firebase Crashlytics monitored the application for errors during development and testing.",
    "LLM API. A large language model API was integrated as the AI engine of SmartSpend to enable natural language expense logging and financial assistance in Filipino, English, and Taglish. Gemini 3.5 Flash-Lite was selected as the primary model after a comparative evaluation of available providers, with seven fallback providers ensuring continued availability if one was unavailable.",
    "Speech-to-Text. The speech-to-text function was used to allow users to record expenses using voice input, detecting Filipino English and automatically converting spoken descriptions into text for AI parsing.",
    "Google ML Kit OCR. ML Kit's text recognizer was used to extract transaction details from receipt images. The extracted text was routed to the AI assistant for automatic expense recording, with users able to review and edit entries before confirming.",
    "Mobile Scanner. A barcode scanning library was used to let users scan product barcodes, after which the AI assistant prompted them to describe the transaction for recording.",
    "fl_chart. The fl_chart library was used to display spending analytics in the app, including category breakdowns and monthly spending trends.",
    "local_auth. The local authentication library was used to enable biometric login (fingerprint or face unlock) as a convenience option after the user's first successful sign-in.",
    "Financial Health Score. SmartSpend computed a Financial Health Score (FHS) ranging from 0 to 100 as a single indicator of the user's budgeting behavior. The score was computed from components including Savings Rate, Overspend Control, Budget Adherence, and Logging Consistency. The detailed formula is discussed in Chapter III.",
]

if tb_start and tb_end:
    body_range = list(range(tb_start + 1, tb_end))
    for idx, new_text in zip(body_range, NEW_TB):
        replace_para(doc.paragraphs[idx], new_text)
        log.append(f'TB para [{idx}]: set to {new_text[:50]}')
    for idx in body_range[len(NEW_TB):]:
        clear_para(doc.paragraphs[idx])
        log.append(f'TB cleared [{idx}]')

# ── Save and report ───────────────────────────────────────────────────────
doc.save(DOCX)
print(f'\nApplied {len(log)} fixes.')
for l in log:
    print(f'  {l}')
