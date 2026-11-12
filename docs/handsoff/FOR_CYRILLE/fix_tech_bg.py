"""
Rewrite Technical Background:
- Remove 'what it is' definitions
- Keep only 'how we used it in SmartSpend'
- Condense to 1-2 sentences per tool
- Remove excess detail (category lists, auth flows, barcode overlay specs, etc.)
- Remove inline citations
- Fuse Firebase tools into one paragraph
- Keep FHS brief (details are in Ch III)
"""
import shutil
from docx import Document
from docx.oxml.ns import qn
from lxml import etree

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
shutil.copy(DOCX, DOCX + '.techbg.bak')
doc = Document(DOCX)

# Find Technical Background heading
tb_start = None
tb_end = None
for i, p in enumerate(doc.paragraphs):
    t = p.text.strip()
    if t == 'Technical Background' and i > 150:
        tb_start = i
    if tb_start and i > tb_start + 2:
        # End when we hit the next chapter or major heading
        if t and p.style.name.startswith('Heading') and 'Technical' not in t:
            tb_end = i
            break
        if 'CHAPTER II' in t.upper() or 'Research Design' in t or 'Research Methodology' in t.upper():
            tb_end = i
            break

print(f'Technical Background: paras {tb_start} to {tb_end}')
if not tb_start:
    print('ERROR: not found'); exit(1)

# Print current content
print('Current paragraphs:')
for i in range(tb_start, min(tb_end or tb_start+30, len(doc.paragraphs))):
    t = doc.paragraphs[i].text.strip()
    if t: print(f'  [{i}] {t[:100]}')

# New condensed Technical Background
# Format: intro sentence, then each tool is "Tool. How we used it in SmartSpend."
NEW_TECH_BG_PARAS = [
    # intro
    ("In this section, the researchers described the technologies used in the design "
     "and development of the SmartSpend mobile application."),
    # Flutter
    ("Flutter. Flutter was used to build the SmartSpend Android application, "
     "providing a consistent and responsive user interface across different screen sizes "
     "and device configurations."),
    # SQLite
    ("SQLite. SQLite served as the local database of SmartSpend, storing all financial "
     "data — including expenses, budgets, savings goals, and chat history — directly on "
     "the device to ensure full offline functionality."),
    # Firebase (all three fused into one paragraph)
    ("Firebase. Firebase Firestore was used to synchronize financial data across devices "
     "whenever the user was online. Firebase Authentication managed user sign-in, "
     "supporting email/password and Google login. Firebase Crashlytics monitored the "
     "application for errors during development and testing."),
    # LLM API
    ("LLM API. A large language model API was integrated as the AI engine of SmartSpend "
     "to enable natural language expense logging and financial assistance in Filipino, "
     "English, and Taglish. Gemini 3.5 Flash-Lite was selected as the primary model after "
     "a comparative evaluation of available providers, with seven fallback providers "
     "ensuring continued availability if one was unavailable."),
    # Speech to Text
    ("Speech-to-Text. The speech-to-text function was used to allow users to record "
     "expenses using voice input, detecting Filipino English and automatically converting "
     "spoken descriptions into text for AI parsing."),
    # OCR
    ("Google ML Kit OCR. ML Kit's text recognizer was used to extract transaction details "
     "from receipt images. The extracted text was routed to the AI assistant for automatic "
     "expense recording, with users able to review and edit entries before confirming."),
    # Barcode
    ("Mobile Scanner. A barcode scanning library was used to let users scan product "
     "barcodes, after which the AI assistant prompted them to describe the transaction "
     "for recording."),
    # fl_chart
    ("fl_chart. The fl_chart library was used to display spending analytics in the app, "
     "including category breakdowns and monthly spending trends."),
    # local_auth
    ("local_auth. The local authentication library was used to enable biometric login "
     "(fingerprint or face unlock) as a convenience option after the user's first "
     "successful sign-in."),
    # FHS
    ("Financial Health Score. SmartSpend computed a Financial Health Score (FHS) ranging "
     "from 0 to 100 as a single indicator of the user's budgeting behavior. The score "
     "was computed from components including Savings Rate, Overspend Control, Budget "
     "Adherence, and Logging Consistency. The detailed formula is discussed in Chapter III."),
]

# Replace the content of paras tb_start+1 onwards
# First, determine actual paragraph objects to replace
content_start = tb_start + 1
content_end = tb_end if tb_end else tb_start + 30

# How many existing content paras?
existing = []
for i in range(content_start, content_end):
    if i < len(doc.paragraphs):
        existing.append(i)

print(f'\nReplacing {len(existing)} existing paras with {len(NEW_TECH_BG_PARAS)} new paras')

# Replace first N paragraphs with new content
for idx, (para_i, new_text) in enumerate(zip(existing, NEW_TECH_BG_PARAS)):
    para = doc.paragraphs[para_i]
    if para.runs:
        para.runs[0].text = new_text
        for r in para.runs[1:]: r.text = ''
    else:
        para.add_run(new_text)
    print(f'  Set [{para_i}]: {new_text[:60]}...')

# Clear any remaining existing paragraphs beyond what we needed
for para_i in existing[len(NEW_TECH_BG_PARAS):]:
    para = doc.paragraphs[para_i]
    t = para.text.strip()
    # Don't clear if it's a heading or next section
    if t and not para.style.name.startswith('Heading'):
        if para.runs:
            para.runs[0].text = ''
            for r in para.runs[1:]: r.text = ''
        print(f'  Cleared [{para_i}]: {t[:60]}')

doc.save(DOCX)
print('\nSaved.')

# Verify
doc2 = Document(DOCX)
print('\nNew Technical Background:')
tb2 = None
for i, p in enumerate(doc2.paragraphs):
    if p.text.strip() == 'Technical Background' and i > 150:
        tb2 = i
        break
if tb2:
    for i in range(tb2, min(tb2 + 15, len(doc2.paragraphs))):
        t = doc2.paragraphs[i].text.strip()
        if t: print(f'  [{i}] {t[:110]}')
