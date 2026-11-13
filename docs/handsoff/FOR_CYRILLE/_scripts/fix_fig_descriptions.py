"""
Fix figure descriptions - insert IMMEDIATELY after each figure caption.
First cleans up misplaced descriptions, then inserts correctly.
"""
import shutil
from docx import Document
from docx.shared import Pt
from docx.oxml import OxmlElement
from docx.text.paragraph import Paragraph as DocxParagraph
from docx.oxml.ns import qn

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
shutil.copy(DOCX, DOCX + '.figdesc.bak')
doc = Document(DOCX)
log = []

# Map: figure keyword -> correct description
DESCRIPTIONS = {
    'Figure 3:': (
        "Figure 3 shows the SUS Score Interpretation Framework used in this study. "
        "Scores range from 0 to 100 and are categorized as Not Acceptable (below 51), "
        "Marginal (51 to 70), and Acceptable (71 and above) based on Bangor et al. (2008). "
        "The 68-point average benchmark (Sauro & Lewis, 2016) and the pre-established target "
        "of 80 are marked with reference lines. SmartSpend's mean score of 61.83 falls in "
        "the Marginal range, below both benchmarks."
    ),
    'Figure 6.': (
        "Figure 6 presents the system flowchart of SmartSpend, showing how user inputs are "
        "preprocessed on-device (redacting sensitive data), then routed to either a private "
        "local LLM or the cloud provider chain. Valid entries are stored in SQLite and "
        "optionally synced to Firebase, while the Financial Health Score is computed from "
        "transaction data."
    ),
    'Figure 7.': (
        "Figure 7 shows the use case diagram of SmartSpend. The user can log expenses, "
        "import screenshots, chat with the AI assistant (Peso), set budgets and savings "
        "goals, view analytics, and check the Financial Health Score. The system handles "
        "FHS calculation, notifications, and cloud synchronization."
    ),
    'Figure 9.': (
        "Figure 9 presents the Login and Demo Mode Screen of SmartSpend. Users can sign "
        "in with an account, continue without an account for local-only storage, or try "
        "Demo Mode which loads realistic sample data for exploration without registration."
    ),
    'Figure 10.': (
        "Figure 10 presents the Home Dashboard of SmartSpend, which displayed the user's "
        "Financial Health Score, recent transactions, and spending insights. The dashboard "
        "served as the main navigation screen for accessing all key features of the application."
    ),
    'Figure 11.': (
        "Figure 11 presents the Peso Chat interface, where users logged expenses through "
        "natural language input in Filipino, English, or Taglish. The AI assistant parsed "
        "the input and automatically recorded the transaction with the appropriate category "
        "and amount."
    ),
    'Figure 12.': (
        "Figure 12 shows the receipt scanning and batch screenshot import feature. The app "
        "used OCR to extract transaction details from physical receipts and e-wallet "
        "screenshots. Users could review, edit categories, and confirm entries before "
        "recording them."
    ),
    'Figure 13.': (
        "Figure 13 displays the Financial Health Score breakdown screen, showing the "
        "user's scores for each component: Savings Rate, Overspend Control, Budget "
        "Adherence, and Logging Consistency. The overall score out of 100 provides "
        "a quick summary of the user's budgeting behavior."
    ),
    'Figure 14.': (
        "Figure 14 shows the Budgets, Safe-to-Spend, and Savings Goals screen. Users "
        "set spending limits per category and monitored their adherence. The screen also "
        "displays the calculated safe-to-spend amount and progress toward savings goals."
    ),
    'Figure 16.': (
        "Figure 16 presents a sample SUS computation for one respondent who scored 75.0, "
        "illustrating how the SUS formula is applied. For odd-numbered items, the "
        "contribution is the scale position minus 1; for even-numbered items, it is 5 "
        "minus the scale position. The sum is multiplied by 2.5. This is a single example; "
        "the overall mean of 61.83 shown in Table 8 is the average across all 30 respondents."
    ),
}

# Step 1: Remove all previously misinserted description paragraphs
# (those starting with "Figure X presents/shows/displays" that don't match their position)
stray_indices = []
for i, p in enumerate(doc.paragraphs):
    t = p.text.strip()
    # Detect stray descriptions: start with "Figure N" desc but current para is different figure
    for key in DESCRIPTIONS:
        fignum = key.rstrip(':.')
        desc_start = f"{fignum} presents" if ':' not in key else f"{fignum} shows"
        # Check all description starts
        for start in [f"{fignum} presents", f"{fignum} shows", f"{fignum} displays"]:
            if t.startswith(start) and i > 100:
                # Check if this is after the CORRECT figure caption
                prev_fig = ''
                for j in range(i-1, max(0, i-5), -1):
                    pt = doc.paragraphs[j].text.strip()
                    if pt.startswith('Figure'):
                        prev_fig = pt[:15]
                        break
                # If caption above doesn't match, it's stray
                if key.rstrip(':.') not in prev_fig:
                    stray_indices.append(i)
                    log.append(f'[{i}] Marked stray: {t[:60]}')

# Remove stray paragraphs (clear them)
for idx in stray_indices:
    if idx < len(doc.paragraphs):
        p = doc.paragraphs[idx]
        if p.runs:
            p.runs[0].text = ''
            for r in p.runs[1:]: r.text = ''

# Step 2: Find each figure caption and insert description right after it
def insert_after(doc, para_idx, text):
    before_p = doc.paragraphs[para_idx]
    new_p = OxmlElement('w:p')
    before_p._p.addnext(new_p)
    po = DocxParagraph(new_p, before_p._parent)
    r = po.add_run(text)
    r.font.name = 'Tahoma'
    r.font.size = Pt(12)
    return po

# Reload after clearing strays
doc.save(DOCX)
doc = Document(DOCX)

for key, desc in DESCRIPTIONS.items():
    fignum = key.rstrip(':.')
    for i, p in enumerate(doc.paragraphs):
        t = p.text.strip()
        if t.startswith(key) and len(t) < 150 and i > 100:
            # Check if next non-empty para is already this description
            next_text = ''
            for j in range(i+1, min(i+3, len(doc.paragraphs))):
                nt = doc.paragraphs[j].text.strip()
                if nt:
                    next_text = nt[:60]
                    break
            already = any(next_text.startswith(f'{fignum} {v}') for v in ['presents', 'shows', 'displays'])
            if not already:
                insert_after(doc, i, desc)
                log.append(f'[{i}] Inserted description for {key}')
            else:
                log.append(f'[{i}] Already has description for {key} — skip')
            break

doc.save(DOCX)
print(f'\n{len(log)} actions:')
for l in log: print(f'  {l}')

# Final check
doc2 = Document(DOCX)
print('\n=== FINAL CHECK ===')
for i, p in enumerate(doc2.paragraphs):
    t = p.text.strip()
    if t.startswith('Figure ') and len(t) < 150 and i > 100:
        next_text = ''
        for j in range(i+1, min(i+3, len(doc2.paragraphs))):
            nt = doc2.paragraphs[j].text.strip()
            if nt:
                next_text = nt[:70]
                break
        has_desc = next_text and not next_text.startswith('Figure') and not next_text.startswith('Table') and len(next_text) > 20
        status = '✅' if has_desc else '❌'
        print(f'  {status} {t[:60]}')
        if has_desc:
            print(f'    desc: {next_text[:60]}')
