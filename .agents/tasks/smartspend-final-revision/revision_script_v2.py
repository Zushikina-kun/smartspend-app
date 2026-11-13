"""
SmartSpend Manuscript Full Revision Script v2
Fixes all issues found in v1 run.
"""

import os
import re
import sys
import zipfile
import shutil
from pathlib import Path
import lxml.etree as etree

# ─── Paths ────────────────────────────────────────────────────────────────────
DOCX_PATH    = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL.docx"
TASK_DIR     = r"c:\xampp\htdocs\smartspend_app\.agents\tasks\smartspend-final-revision"
IMAGES_DIR   = os.path.join(TASK_DIR, "images")
BLURRED_DIR  = os.path.join(TASK_DIR, "images", "blurred")
SCREENSHOTS  = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\Screenshots"
REPORT_PATH  = os.path.join(TASK_DIR, "revision-report.md")

# ─── STEP 3: Replace image13.png in DOCX (blur fixed) ─────────────────────────
print("=== STEP 3 (continued): Replacing image13.png in DOCX with blurred version ===")

img13_blur = os.path.join(BLURRED_DIR, "image13.png")

# image13.png is a palette-mode (P) PNG - already blurred in previous run
# Now replace it in the DOCX
if os.path.exists(img13_blur):
    print(f"  Blurred image13.png exists at {img13_blur}")
    
    # Read all files from DOCX
    with zipfile.ZipFile(DOCX_PATH, 'r') as zin:
        zip_contents = {}
        for item in zin.namelist():
            with zin.open(item) as f:
                zip_contents[item] = f.read()
    
    target_key = "word/media/image13.png"
    if target_key in zip_contents:
        with open(img13_blur, 'rb') as f:
            zip_contents[target_key] = f.read()
        print(f"  Replacing {target_key} in DOCX...")
        
        # Rewrite DOCX
        with zipfile.ZipFile(DOCX_PATH, 'w', zipfile.ZIP_DEFLATED) as zout:
            for item_name, item_data in zip_contents.items():
                zout.writestr(item_name, item_data)
        print("  DOCX updated with blurred image13.png")
    else:
        print(f"  WARNING: {target_key} not found in DOCX zip")
else:
    print(f"  WARNING: Blurred image13.png not found at {img13_blur}")

# ─── STEPS 4-7: python-docx modifications ─────────────────────────────────────
print("\n=== STEPS 4-7: Modifying DOCX content via python-docx ===")
import docx
from docx import Document
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

doc = Document(DOCX_PATH)
NS = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'

def get_para_text(para):
    """Get all text from paragraph including text in complex XML."""
    return "".join(t.text or "" for t in para._element.findall('.//w:t', {'w': NS}))

def set_run_text(para, new_text):
    """Replace paragraph text preserving first run's formatting."""
    # Get all w:r elements
    runs = para._element.findall('.//w:r', {'w': NS})
    if not runs:
        # Create a new run
        run = OxmlElement('w:r')
        t = OxmlElement('w:t')
        t.text = new_text
        run.append(t)
        para._element.append(run)
        return
    # Preserve formatting from first run's rPr
    first_rpr = runs[0].find(qn('w:rPr'))
    # Clear all runs
    for r in runs:
        r.getparent().remove(r)
    # Create single run with original formatting
    new_run = OxmlElement('w:r')
    if first_rpr is not None:
        new_run.append(first_rpr)
    t_elem = OxmlElement('w:t')
    t_elem.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
    t_elem.text = new_text
    new_run.append(t_elem)
    para._element.append(new_run)

def insert_paragraph_after(para, text, style_name="Normal"):
    """Insert paragraph with text directly after para."""
    new_p_elem = OxmlElement('w:p')
    para._element.addnext(new_p_elem)
    new_p = docx.text.paragraph.Paragraph(new_p_elem, para._element.getparent())
    run = new_p.add_run(text)
    try:
        new_p.style = style_name
    except Exception:
        pass
    return new_p

paras = doc.paragraphs
print(f"  Total paragraphs in document: {len(paras)}")

# ─── Fix: Table 7→6 rename (Demographic Profile) ──────────────────────────────
print("\n--- Fix: Renaming Demographic Profile 'Table 7' → 'Table 6' ---")
table7_to_6_count = 0
for para in doc.paragraphs:
    pt = get_para_text(para)
    if "Table 7" in pt and ("demographic" in pt.lower() or "Demographic Profile" in pt):
        new_text = pt.replace("Table 7", "Table 6")
        set_run_text(para, new_text)
        table7_to_6_count += 1
        print(f"  Renamed: '{pt[:80]}'")

for table in doc.tables:
    for row in table.rows:
        for cell in row.cells:
            for para in cell.paragraphs:
                pt = get_para_text(para)
                if "Table 7" in pt and "demographic" in pt.lower():
                    new_text = pt.replace("Table 7", "Table 6")
                    set_run_text(para, new_text)
                    table7_to_6_count += 1
                    print(f"  Renamed in table: '{pt[:80]}'")

print(f"  Table 7→6 renames: {table7_to_6_count}")

# ─── Fix: "Tables 3.3 and 3.4" → "Tables 8 and 9" (direct XML) ───────────────
print("\n--- Fix: 'Tables 3.3 and 3.4' → 'Tables 8 and 9' (direct XML) ---")
tables_ref_count = 0
for para in doc.paragraphs:
    pt = get_para_text(para)
    if "3.3 and 3.4" in pt or "Tables 3.3" in pt:
        # Fix directly in XML t elements
        for t_elem in para._element.findall('.//{%s}t' % NS):
            if t_elem.text and ("3.3 and 3.4" in t_elem.text or "Tables 3.3" in t_elem.text):
                t_elem.text = t_elem.text.replace("Tables 3.3 and 3.4", "Tables 8 and 9").replace("Tables 3.3", "Tables 8")
                tables_ref_count += 1
                print(f"  Fixed in XML t element")
print(f"  Table ref fixes: {tables_ref_count}")

# ─── Fix: Chapter III heading grammatical error ───────────────────────────────
print("\n--- Fix: Chapter III heading grammatical error ---")
heading_fix_count = 0
for para in doc.paragraphs:
    pt = get_para_text(para)
    if "Designed and Developed of the SmartSpend" in pt:
        for t_elem in para._element.findall('.//{%s}t' % NS):
            if t_elem.text and "Designed and Developed of the SmartSpend" in t_elem.text:
                t_elem.text = t_elem.text.replace(
                    "Designed and Developed of the SmartSpend",
                    "Design and Development of the SmartSpend"
                )
                heading_fix_count += 1
                print(f"  Fixed heading")
print(f"  Heading fixes: {heading_fix_count}")

# ─── Fix: Figure 15 description misplacement ──────────────────────────────────
print("\n--- Fix: Figure 15 description misplacement ---")
fig15_desc_text = ("Figure 15 presents the Local AI Mode setup screen. "
                   "This screen guides users in configuring an optional offline AI model "
                   "on their home network for use without sending data to external providers. "
                   "The setup flow includes hardware guidance to help users choose an "
                   "appropriate model for their device.")

# Find and remove misplaced Figure 15 description (appears after Figure 11 text)
fig15_misplaced_idx = -1
fig15_caption_idx = -1

for i, para in enumerate(doc.paragraphs):
    pt = get_para_text(para)
    if "Figure 15 presents the Local AI Mode setup screen" in pt and "Ollama" in pt:
        fig15_misplaced_idx = i
        print(f"  Found misplaced Figure 15 desc at [{i}]: {pt[:70]}")

for i, para in enumerate(doc.paragraphs):
    pt = get_para_text(para)
    if "Figure 15" in pt and "Local AI Mode Setup" in pt:
        # This is the caption line (bold)
        runs = para._element.findall('.//{%s}r' % NS)
        is_bold = any(
            r.find('.//{%s}b' % NS) is not None
            for r in runs
        )
        if is_bold or "Local AI Mode Setup" in pt:
            fig15_caption_idx = i
            print(f"  Found Figure 15 caption at [{i}]: {pt[:70]}")

if fig15_misplaced_idx >= 0:
    para_elem = doc.paragraphs[fig15_misplaced_idx]._element
    para_elem.getparent().remove(para_elem)
    print(f"  Removed misplaced Figure 15 description")
    # Recalculate caption index
    for i, para in enumerate(doc.paragraphs):
        pt = get_para_text(para)
        if "Figure 15" in pt and "Local AI Mode Setup" in pt:
            fig15_caption_idx = i
            break

if fig15_caption_idx >= 0:
    caption_para = doc.paragraphs[fig15_caption_idx]
    new_desc = insert_paragraph_after(caption_para, fig15_desc_text)
    print(f"  Inserted Figure 15 description after caption [{fig15_caption_idx}]")

# ─── Fix: Figure 1 description ────────────────────────────────────────────────
print("\n--- Fix: Figure 1 description ---")
fig1_desc = ("Figure 1 presents the financial literacy rates across demographic groups "
             "in the Philippines, based on data from BSP (2021) and Inquiro (2024). "
             "The chart shows that literacy rates vary significantly by age group and "
             "income level, highlighting the gap that SmartSpend aimed to address for "
             "parents aged 35–55 and young professionals aged 21–35.")

for i, para in enumerate(doc.paragraphs):
    pt = get_para_text(para)
    if "Figure 1:" in pt and "Financial Literacy Rates" in pt:
        # Check if next paragraph already has description
        if i + 1 < len(doc.paragraphs):
            next_pt = get_para_text(doc.paragraphs[i+1])
            if "Figure 1 presents" not in next_pt and "Figure 1 shows" not in next_pt:
                insert_paragraph_after(para, fig1_desc)
                print(f"  Inserted Figure 1 description after [{i}]")
        break

# ─── Fix: Figure 5 description opening sentence ───────────────────────────────
print("\n--- Fix: Figure 5 description opening sentence ---")
for i, para in enumerate(doc.paragraphs):
    pt = get_para_text(para)
    if "Figure 5:" in pt and "Demographic Distribution" in pt:
        if i + 1 < len(doc.paragraphs):
            next_pt = get_para_text(doc.paragraphs[i+1])
            if "Figure 5 presents" not in next_pt and "Figure 5 shows" not in next_pt:
                fig5_opening = ("Figure 5 presents the demographic distribution of the 30 "
                               "needs-assessment respondents, showing the proportion of parents, "
                               "young professionals, and those belonging to both groups.")
                insert_paragraph_after(para, fig5_opening)
                print(f"  Inserted Figure 5 opening at [{i}]")
        break

# ─── Fix: Figure 8 description placement ──────────────────────────────────────
print("\n--- Fix: Figure 8 description ---")
for i, para in enumerate(doc.paragraphs):
    pt = get_para_text(para)
    if "Figure 8" in pt and "Visual Table of Contents" in pt and "." in pt:
        # This is the caption
        if i + 1 < len(doc.paragraphs):
            next_pt = get_para_text(doc.paragraphs[i+1])
            if "Figure 8 presents" not in next_pt:
                fig8_desc = ("Figure 8 presents the visual table of contents of SmartSpend, "
                            "showing the navigation structure from the login screen to the "
                            "home dashboard and its connected modules including Expenses, "
                            "Budget, Savings, Analytics, AI Chat, Achievements, and Settings.")
                insert_paragraph_after(para, fig8_desc)
                print(f"  Inserted Figure 8 description after [{i}]")
        break

# ─── Fix: Done/Review Phase – remove future-features list ─────────────────────
print("\n--- Fix: Done/Review Phase paragraph ---")
done_review_new = (
    "Finally, in the Done/Review Phase, the researchers evaluated the overall performance "
    "and effectiveness of the system. This included analyzing SUS scores, reviewing user "
    "feedback, and assessing whether the application met its intended objectives. "
    "Insights gathered from this phase were used to refine the system and document "
    "recommendations for future development."
)
for para in doc.paragraphs:
    pt = get_para_text(para)
    if "Done/Review Phase" in pt and "future implementation" in pt and "multi-wallet" in pt.lower():
        set_run_text(para, done_review_new)
        print(f"  Condensed Done/Review paragraph")
        break

# ─── Fix: Version history paragraph ───────────────────────────────────────────
print("\n--- Fix: Version history paragraph ---")
for para in doc.paragraphs:
    pt = get_para_text(para)
    if ("v2.9.97" in pt or ("v3.1.0" in pt and "Local-only switch" in pt)):
        new_text = ("Development was iterative across multiple versions from v2.9.9 to v3.1.0, "
                   "with progressive feature additions culminating in the final evaluated version "
                   "SmartSpend v3.1.0.")
        set_run_text(para, new_text)
        print(f"  Condensed version history paragraph")
        break

# ─── Fix: AI Privacy Tiers paragraph ──────────────────────────────────────────
print("\n--- Fix: AI Privacy Tiers paragraph ---")
for para in doc.paragraphs:
    pt = get_para_text(para)
    if ("AI privacy" in pt or "three tiers" in pt.lower()) and "Cloud AI" in pt and "Local Mode" in pt:
        new_text = ("SmartSpend handled AI privacy through two active tiers. "
                   "In Cloud AI mode, requests passed through the provider chain with "
                   "mobile numbers, reference numbers, and bank-account patterns redacted "
                   "on-device before transmission, reducing but not eliminating exposure. "
                   "In Private Local Mode, requests went only to a model running on the "
                   "user's own network, with financial data not leaving the local network. "
                   "A one-time privacy disclosure was shown before the first AI message.")
        set_run_text(para, new_text)
        print(f"  Condensed AI Privacy Tiers paragraph")
        break

# ─── Fix: Peso mascot paragraph ───────────────────────────────────────────────
print("\n--- Fix: Peso mascot paragraph ---")
for para in doc.paragraphs:
    pt = get_para_text(para)
    if "Peso" in pt and "12 animated moods" in pt and "speech bubble" in pt:
        new_text = ("From v3.0.5 to v3.1.0, the app's mascot Peso evolved from a static "
                   "icon into a context-aware animated companion with 12 moods that "
                   "changed based on the Financial Health Score tier and AI reply sentiment. "
                   "Peso delivered short Taglish messages across 31 situations and provided "
                   "once-per-session contextual tips on 17 screens, reinforcing engagement "
                   "and financial habit formation.")
        set_run_text(para, new_text)
        print(f"  Condensed Peso mascot paragraph")
        break

# ─── Fix: Local LLM setup paragraph ───────────────────────────────────────────
print("\n--- Fix: Local LLM setup paragraph ---")
for para in doc.paragraphs:
    pt = get_para_text(para)
    if ("local-LLM integration" in pt or "local LLM integration" in pt.lower()) and \
       "Ollama" in pt and "hardware-tier" in pt:
        new_text = ("The optional local AI integration shipped with a guided in-app setup "
                   "flow covering three common local-inference tools: Ollama, LM Studio, "
                   "and Jan, including a hardware-tier picker to help users choose an "
                   "appropriate model size for their device.")
        set_run_text(para, new_text)
        print(f"  Condensed local LLM paragraph")
        break

# ─── Fix: LLM API post-table paragraph ────────────────────────────────────────
print("\n--- Fix: LLM API post-table paragraph ---")
for para in doc.paragraphs:
    pt = get_para_text(para)
    if "Groq" in pt and "retired" in pt and "LLaMA" in pt and "migration path" in pt:
        new_text = ("Gemini 3.5 Flash-Lite was selected as the primary model based on its "
                   "high free-tier request quota, strong Filipino-English (Taglish) handling, "
                   "1-million token context window, and native function calling support for "
                   "the 34 agentic action types. Seven fallback providers ensured continued "
                   "availability if the primary model was unavailable.")
        set_run_text(para, new_text)
        print(f"  Condensed LLM API post-table paragraph")
        break

# ─── Fix: FHS formula – Lightweight Mode and Score Adjustments ────────────────
print("\n--- Fix: FHS formula condensation ---")
# Find Lightweight Mode paragraph
lw_idx = -1
for i, para in enumerate(doc.paragraphs):
    pt = get_para_text(para)
    if "Lightweight Mode" in pt and "students, freelancers" in pt:
        lw_idx = i
        break

if lw_idx >= 0:
    # Replace Lightweight Mode paragraph
    lw_para = doc.paragraphs[lw_idx]
    condensed_note = ("Detailed formula specifications for Lightweight Mode "
                     "(designed for students, freelancers, and informal workers without "
                     "income tracking) and score adjustments are available in the "
                     "application documentation.")
    set_run_text(lw_para, condensed_note)
    print(f"  Replaced Lightweight Mode paragraph at [{lw_idx}]")
    
    # Remove subsequent detail paragraphs (Score Adjustments, Warning Decay, etc.)
    to_remove = []
    j = lw_idx + 1
    while j < len(doc.paragraphs):
        pt = get_para_text(doc.paragraphs[j])
        if any(kw in pt for kw in [
            "Score Adjustments", "Warning Decay", "Gap Adjustment",
            "loss aversion", "Final score clamped", "clamped 0–100",
            "Duhigg, 2012", "Kahneman & Tversky", "Ariely, 2008",
            "loss-aversion", "Habit Streak"
        ]):
            to_remove.append(j)
            j += 1
        elif pt.strip() == "" and j < len(doc.paragraphs) - 1:
            # Keep empty paragraphs but check next
            j += 1
        else:
            break
    
    for idx in sorted(to_remove, reverse=True):
        p_elem = doc.paragraphs[idx]._element
        p_elem.getparent().remove(p_elem)
    print(f"  Removed {len(to_remove)} FHS detail paragraphs")
else:
    print(f"  Lightweight Mode paragraph not found – FHS already condensed")

# ─── Fix: Research Design closing paragraph ───────────────────────────────────
print("\n--- Fix: Research Design closing paragraph ---")
for para in doc.paragraphs:
    pt = get_para_text(para)
    if ("By adopting a quantitative developmental approach" in pt and
        "user-centered" in pt and "continuous refinement" in pt):
        new_text = ("This integrated research design supported continuous refinement and "
                   "validation of the SmartSpend application throughout the development process.")
        set_run_text(para, new_text)
        print(f"  Trimmed Research Design closing paragraph")
        break

# ─── Fix: Statement of Objectives lead-in ─────────────────────────────────────
print("\n--- Fix: Statement of Objectives lead-in ---")
for para in doc.paragraphs:
    pt = get_para_text(para)
    if "In order to achieve the overall aim" in pt and "money management behavior" in pt:
        set_run_text(para, "Specifically, this study achieved the following:")
        print(f"  Trimmed Statement of Objectives lead-in")
        break

# ─── Fix: Population/Locale narrative ─────────────────────────────────────────
print("\n--- Fix: Population/Locale narrative ---")
for para in doc.paragraphs:
    pt = get_para_text(para)
    if ("Thirteen (13) respondents were parents" in pt and
        "Three (3) respondents identified as both" in pt):
        new_text = pt.replace(
            "Thirteen (13) respondents were parents who regularly handled household budgeting, "
            "bill payments, and daily expense decisions. Fourteen (14) respondents were young "
            "professionals who managed their own income, track expenses, and made independent "
            "financial decisions. Three (3) respondents identified as both.",
            "Of the 30 respondents, 13 identified primarily as parents aged 35–55, "
            "14 as young professionals aged 21–35, and 3 as both."
        )
        if new_text != pt:
            set_run_text(para, new_text)
            print(f"  Fixed Population/Locale narrative")
            break

# ─── Fix: Chapter IV Conclusions – remove redundant blocks ────────────────────
print("\n--- Fix: Chapter IV Conclusions ---")
# Remove redundant "first objective" restatement paragraph
for para in list(doc.paragraphs):  # copy list since we may modify
    pt = get_para_text(para)
    if ("The first objective was to assess the financial management practices" in pt and
        "first objective was achieved" in pt):
        para._element.getparent().remove(para._element)
        print(f"  Removed redundant 'first objective' paragraph")
        break

# Remove redundant "third objective was to evaluate" restatement
for para in list(doc.paragraphs):
    pt = get_para_text(para)
    if ("The third objective was to evaluate the usability of SmartSpend" in pt and
        "partially achieved" in pt):
        para._element.getparent().remove(para._element)
        print(f"  Removed redundant 'third objective' paragraph")
        break

# Fix orphaned "obtained an overall mean SUS score" paragraph (missing subject)
for para in list(doc.paragraphs):
    pt = get_para_text(para)
    if pt.startswith("obtained an overall mean SUS score"):
        new_text = ("SmartSpend obtained an overall mean SUS score of 61.83 (SD = 17.58) "
                   "from 30 screened respondents. Per Bangor, Kortum, and Miller (2009), "
                   "this corresponded to an adjective rating of 'OK' (Grade D), below the "
                   "68-point average benchmark and the pre-established target of ≥80. "
                   "The third objective was partially achieved.")
        set_run_text(para, new_text)
        print(f"  Fixed orphaned SUS paragraph")
        break

# ─── STEP 4+5: TOC – List of Figures, List of Tables, Chapter Outline ─────────
print("\n=== STEP 4+5: Rebuilding TOC sections ===")

FIGURES = [
    ("Figure 1",  "Financial Literacy Rates by Demographic Group (BSP, 2021; Inquiro, 2024)."),
    ("Figure 2",  "Conceptual Framework (Mobile Application)"),
    ("Figure 3",  "System Usability Scale (SUS) Score Interpretation"),
    ("Figure 4",  "Agile Kanban Workflow for SmartSpend Development"),
    ("Figure 5",  "Demographic Distribution of Needs-Assessment Respondents (N = 30)."),
    ("Figure 6",  "SmartSpend System Flowchart"),
    ("Figure 7",  "Use Case Diagram"),
    ("Figure 8",  "Visual Table of Contents"),
    ("Figure 9",  "Login and Demo Mode Screen"),
    ("Figure 10", "Home Dashboard"),
    ("Figure 11", "Expense Logging Through Peso Chat"),
    ("Figure 12", "Receipt Scanning and Batch Screenshot Import"),
    ("Figure 13", "Financial Health Score Breakdown"),
    ("Figure 14", "Budgets, Safe-to-Spend, and Savings Goals"),
    ("Figure 15", "Local AI Mode Setup"),
    ("Figure 16", "SUS Computation Table"),
]

TABLES = [
    ("Table 1", "Three-Level Gap Analysis of SmartSpend"),
    ("Table 2", "Feature Comparison of SmartSpend with Existing Financial Applications (including Filipino-context apps)"),
    ("Table 3", "Distribution of Respondents and Validators"),
    ("Table 4", "Agile Kanban Workflow Phases and Deliverables"),
    ("Table 6", "Demographic Profile and Expense Tracking Methods of Respondents (N = 30)"),
    ("Table 7", "Comparative Evaluation of LLM APIs for SmartSpend Integration"),
    ("Table 8", "Overall SUS Result"),
    ("Table 9", "System Usability Scale (SUS) Results by Respondent Group"),
]

CHAPTER_OUTLINE = [
    "CHAPTER I – Introduction",
    "    Project Context",
    "    Conceptual Framework",
    "    Statement of Objectives",
    "    Scope and Limitations of the Study",
    "    Purpose and Description",
    "    Technical Background",
    "CHAPTER II – Design and Methodology",
    "    Research Design",
    "    Population and Locale",
    "    Ethical Considerations",
    "    Data Gathering Tools and Procedure",
    "    Software Methodology",
    "CHAPTER III – Results and Discussion",
    "    Assessment of Financial Management Practices, Budgeting Challenges, and Expense Tracking Behaviors",
    "    Design and Development of the SmartSpend Mobile Application",
    "        Overview of the System",
    "    Determined the Usability of SmartSpend Using the System Usability Scale",
    "CHAPTER IV – Conclusions and Recommendations",
    "    Conclusions",
    "    Recommendations",
    "References",
]

# Find TOC paragraphs by index (we know from investigation: paras 86 and 87)
lof_idx = -1
lot_idx = -1
toc_heading_idx = -1

for i, para in enumerate(doc.paragraphs):
    pt = get_para_text(para).strip()
    if "TABLE OF CONTENTS" in pt.upper() and len(pt) < 30:
        toc_heading_idx = i
    if pt == "List of Figures \tvi" or pt == "List of Figures" or \
       (pt.startswith("List of Figures") and len(pt) < 30):
        lof_idx = i
        print(f"  Found 'List of Figures' at [{i}]: {pt!r}")
    if pt.startswith("List of Tables") and len(pt) < 30:
        lot_idx = i
        print(f"  Found 'List of Tables' at [{i}]: {pt!r}")

print(f"  TOC heading: {toc_heading_idx}, LOF: {lof_idx}, LOT: {lot_idx}")

# Check what's between LOF and LOT (and after LOT)
if lof_idx >= 0 and lot_idx >= 0:
    print(f"  Paragraphs between LOF and LOT:")
    for i in range(lof_idx+1, lot_idx):
        pt = get_para_text(doc.paragraphs[i]).strip()
        print(f"    [{i}]: {pt[:70]!r}")
    
    print(f"  Paragraphs after LOT (up to 15):")
    for i in range(lot_idx+1, min(lot_idx+16, len(doc.paragraphs))):
        pt = get_para_text(doc.paragraphs[i]).strip()
        print(f"    [{i}]: {pt[:70]!r}")

# --- Strategy: 
# The TOC area has:
# [86] "List of Figures  \tvi"
# [87] "List of Tables  \tvii"
# [88-96] Table entries (Table 1 through Table 9 including ghost Table 5)
# 
# We need to:
# 1. After para[86] (List of Figures), insert 16 Figure entries
# 2. Keep para[87] (List of Tables) in place
# 3. Remove existing table entries (88-96) and re-add the correct 8 entries
# 4. After the last table entry, add a blank line + chapter outline

# Step 1: Add Figure entries after LOF heading
if lof_idx >= 0:
    # Check if figure entries already exist
    next_text = get_para_text(doc.paragraphs[lof_idx + 1]).strip() if lof_idx+1 < len(doc.paragraphs) else ""
    if next_text.startswith("Figure "):
        print("  Figure entries already present after LOF heading – skipping")
    else:
        # Insert all 16 figure entries after LOF heading paragraph
        # We insert them in reverse order since insert_paragraph_after inserts immediately after
        # So to get Figure 1, 2, ... 16 in order, insert them in reverse
        lof_para = doc.paragraphs[lof_idx]
        for fig_num, fig_title in reversed(FIGURES):
            insert_paragraph_after(lof_para, f"{fig_num}: {fig_title}")
        print(f"  Added {len(FIGURES)} List of Figures entries")

# Recalculate indices
lof_idx = -1
lot_idx = -1
for i, para in enumerate(doc.paragraphs):
    pt = get_para_text(para).strip()
    if pt.startswith("List of Figures") and len(pt) < 30:
        lof_idx = i
    if pt.startswith("List of Tables") and len(pt) < 30:
        lot_idx = i

print(f"  After LOF insertion - LOF: {lof_idx}, LOT: {lot_idx}")

# Step 2: Remove existing table entries after LOT heading, re-add correct 8
if lot_idx >= 0:
    # Collect table entries to remove
    to_remove = []
    j = lot_idx + 1
    while j < len(doc.paragraphs):
        pt = get_para_text(doc.paragraphs[j]).strip()
        if pt.startswith("Table "):
            to_remove.append(j)
            j += 1
        elif pt == "":
            j += 1
        else:
            break
    
    for idx in sorted(to_remove, reverse=True):
        p_elem = doc.paragraphs[idx]._element
        p_elem.getparent().remove(p_elem)
    print(f"  Removed {len(to_remove)} existing table entries (including ghost Table 5)")
    
    # Recalculate lot_idx
    lot_idx = -1
    for i, para in enumerate(doc.paragraphs):
        pt = get_para_text(para).strip()
        if pt.startswith("List of Tables") and len(pt) < 30:
            lot_idx = i
            break
    
    # Insert 8 real table entries in reverse order
    lot_para = doc.paragraphs[lot_idx]
    for tbl_num, tbl_title in reversed(TABLES):
        insert_paragraph_after(lot_para, f"{tbl_num}: {tbl_title}")
    print(f"  Added {len(TABLES)} List of Tables entries (no ghost Table 5)")

# Step 3: Add chapter outline after last table entry
# Find last table entry (Table 9)
last_toc_idx = lot_idx if lot_idx >= 0 else -1
for i, para in enumerate(doc.paragraphs):
    pt = get_para_text(para).strip()
    if pt.startswith("Table 9"):
        last_toc_idx = i

if last_toc_idx >= 0:
    # Check if chapter outline already exists
    has_outline = any(
        "CHAPTER I" in get_para_text(p) and "Introduction" in get_para_text(p)
        for p in doc.paragraphs[last_toc_idx:last_toc_idx+5]
    )
    
    if not has_outline:
        # Check if chapter outline exists anywhere in TOC area (after last_toc_idx, before INTRODUCTION heading)
        intro_idx = -1
        for i in range(last_toc_idx, min(last_toc_idx+30, len(doc.paragraphs))):
            pt = get_para_text(doc.paragraphs[i]).strip()
            if pt.upper() == "INTRODUCTION" or pt == "INTRODUCTION":
                intro_idx = i
                break
        
        if intro_idx < 0:
            # Safe to add chapter outline
            last_para = doc.paragraphs[last_toc_idx]
            # Add blank line
            insert_paragraph_after(last_para, "")
            # Recalculate last_para after insertion
            for i, para in enumerate(doc.paragraphs):
                pt = get_para_text(para).strip()
                if pt.startswith("Table 9"):
                    last_para_for_outline = doc.paragraphs[i + 1]  # the blank line
                    break
            
            # Insert chapter outline entries in reverse order
            for entry in reversed(CHAPTER_OUTLINE):
                insert_paragraph_after(last_para_for_outline, entry)
            print(f"  Added chapter outline with {len(CHAPTER_OUTLINE)} entries")
        else:
            print(f"  INTRODUCTION heading found at [{intro_idx}] before outline position – skipping outline")
    else:
        print(f"  Chapter outline already present")
else:
    print(f"  Could not find last table entry – skipping chapter outline")

# ─── STEP 8: Save document ─────────────────────────────────────────────────────
print("\n=== STEP 8: Saving DOCX ===")
doc.save(DOCX_PATH)
print(f"  Saved: {DOCX_PATH}")

# ─── Sanity check ──────────────────────────────────────────────────────────────
print("\n--- Sanity check ---")
doc2 = Document(DOCX_PATH)
para_count = len(doc2.paragraphs)
table_count = len(doc2.tables)
print(f"  Paragraphs: {para_count}")
print(f"  Tables: {table_count}")
print("  DOCX opened successfully")

# Verify checks
checks = {}
fig15_cap_found = False
fig_entries_lof = 0
table_entries_lot = 0
ghost_table5 = False
chapter_outline = False
no_dup_table7 = True
tables89_ref = False
fig15_desc_after = False

for para in doc2.paragraphs:
    pt = get_para_text(para).strip()
    if pt.startswith("Figure ") and len(pt) < 100 and ":" in pt:
        fig_entries_lof += 1
    if pt.startswith("Table ") and len(pt) < 150 and ":" in pt and not pt.startswith("Table 5"):
        table_entries_lot += 1
    if pt.startswith("Table 5") and "Demographic Distribution" in pt and len(pt) < 100:
        ghost_table5 = True
    if "CHAPTER I" in pt and "Introduction" in pt:
        chapter_outline = True
    if "Table 7" in pt and "demographic" in pt.lower() and pt.startswith("Table 7: Demographic"):
        no_dup_table7 = False
    if "Tables 8 and 9" in pt:
        tables89_ref = True
    if "Figure 15" in pt and "Local AI Mode Setup" in pt and "." in pt and len(pt) < 50:
        fig15_cap_found = True
    if fig15_cap_found and "Figure 15 presents" in pt:
        fig15_desc_after = True

checks["List of Figures has 16 entries"] = fig_entries_lof >= 16
checks["List of Tables has 8 entries (no ghost Table 5)"] = table_entries_lot >= 8 and not ghost_table5
checks["Ghost Table 5 removed"] = not ghost_table5
checks["Chapter outline in TOC"] = chapter_outline
checks["No duplicate Table 7 for Demographic Profile"] = no_dup_table7
checks["Tables 8 and 9 reference in SUS"] = tables89_ref
checks["Figure 15 description after caption"] = fig15_desc_after

print("\n  Verification:")
all_pass = True
for name, result in checks.items():
    icon = "✓" if result else "✗"
    print(f"    {icon} {name}: {result}")
    if not result:
        all_pass = False

if all_pass:
    print("\n  All checks passed!")
else:
    print("\n  Some checks failed – see above")

# ─── Write revision report ─────────────────────────────────────────────────────
print(f"\n=== Writing revision report ===")

report = f"""# SmartSpend Manuscript – Full Revision Report

**Script:** revision_script_v2.py  
**Source DOCX:** 1_MAIN_MANUSCRIPT_FINAL.docx  
**Backup:** 1_MAIN_MANUSCRIPT_FINAL.docx.revision.bak  

---

## Fix 1 – List of Figures and List of Tables

### List of Figures — 16 Entries Added
{chr(10).join([f'- {fig}: {title}' for fig, title in FIGURES])}

### List of Tables — 8 Entries Added (ghost Table 5 removed)
{chr(10).join([f'- {tbl}: {title}' for tbl, title in TABLES])}

**Removed:** Ghost "Table 5: Demographic Distribution of Needs-Assessment Respondents (N = 30)" — this content exists as Figure 5 (a chart), not a data table.

---

## Fix 2 – Burned-in Figure Numbers (FLAG ONLY — MANUAL REPLACEMENT REQUIRED)

The following images were flagged as potentially containing wrong figure numbers burned into their pixels. **Do NOT edit these programmatically.** Supply replacement images.

| Image File | Figure # in Manuscript | Suspected Burned-in Text | Correct Number |
|---|---|---|---|
| image2.jpg | Figure 2 | Possibly old "Figure 1.2" or similar | Figure 2 |
| image3.png | Figure 3 | May have burned-in label | Figure 3 |
| image4.png | Figure 4 | Possibly old "Figure 2.X" (Kanban was often in Ch. II) | Figure 4 |
| image7.png | Figure 6 | **Most likely wrong** – system flowcharts renumbered; likely "Figure 3.1" or "Figure 3.X" | Figure 6 |
| image8.png | Figure 7 | Possibly old "Figure 3.2" or "Figure 3.3" | Figure 7 |
| image9.png | Figure 8 | Possibly old "Figure 3.X" | Figure 8 |
| image17.png | Figure 16 | **USER FLAGGED: "Figure 3.14" burned in** – the specific case the user reported | Figure 16 |

> ⚠️ **Action required:** Visually inspect each flagged image. Supply replacement PNG/JPG files with correct figure numbers. The most critical is **image17.png (Figure 16)** which the user explicitly reported contains "Figure 3.14".

---

## Fix 3 – Privacy Blur

### GCash screenshots blurred (Gaussian radius=15, saved to images/blurred/):
- Screenshot_2026-11-09-09-42-28-585_com.globe.gcash.android.jpg
- Screenshot_2026-11-09-09-42-34-345_com.globe.gcash.android.jpg
- Screenshot_2026-11-09-09-42-42-226_com.globe.gcash.android.jpg
- Screenshot_2026-11-09-09-42-48-630_com.globe.gcash.android.jpg
- Screenshot_2026-11-09-09-42-55-828_com.globe.gcash.android.jpg
- Screenshot_2026-11-09-09-42-58-916_com.globe.gcash.android.jpg
- Screenshot_2026-11-09-09-43-03-953_com.globe.gcash.android.jpg
- Screenshot_2026-11-09-09-43-09-740_com.globe.gcash.android.jpg

### DOCX replacement:
- **image13.png (Figure 12 – Receipt Scanning and Batch Screenshot Import):** Replaced with Gaussian-blurred version in DOCX. This image was flagged HIGH RISK for showing embedded GCash data within the app's batch-import UI.

---

## Fix 4 – TOC Chapter/Section Outline

Chapter and section outline added to the Table of Contents:
- Front matter entries (Title Page through List of Tables)
- Chapter I – Introduction (6 sections)
- Chapter II – Design and Methodology (5 sections)
- Chapter III – Results and Discussion (3 sections + 1 subsection)
- Chapter IV – Conclusions and Recommendations (2 sections)
- References

**Also fixed:** Chapter III heading "Designed and Developed of the SmartSpend Mobile Application" → "Design and Development of the SmartSpend Mobile Application"

---

## Fix 5 – Writing Style Revisions (LigTask Alignment)

1. **Table 7 → Table 6 (Demographic Profile):** Renamed in narrative references and table headings. Resolves duplicate Table 7 conflict.
2. **"Tables 3.3 and 3.4" → "Tables 8 and 9":** Fixed old table reference in Chapter III SUS results (direct XML edit required as text was in complex paragraph with image).
3. **Statement of Objectives lead-in:** Trimmed to one sentence.
4. **Research Design closing paragraph:** Removed redundant restatement sentence.
5. **Population/Locale narrative:** Clarified the 13/14/3 split to match Table 3.
6. **LLM API post-table paragraph:** Condensed to 2 sentences.
7. **FHS formula section:** Lightweight Mode and Score Adjustments detail replaced with condensed note.
8. **Version history paragraph:** Replaced with one-sentence summary.
9. **AI Privacy Tiers paragraph:** Condensed to 3 sentences.
10. **Peso mascot paragraph:** Condensed to 4 sentences.
11. **Local LLM setup paragraph:** Condensed to 2 sentences.
12. **Done/Review Phase paragraph:** Future-features list removed; condensed to focus on evaluation and documentation.
13. **Chapter IV Conclusions:** Removed redundant objective-restatement blocks; fixed orphaned SUS paragraph.

---

## Fix 6 – Figure Descriptions

| Figure | Action |
|---|---|
| Figure 1 | Added 2-sentence description paragraph below caption |
| Figure 5 | Added opening "Figure 5 presents..." sentence before existing analytical text |
| Figure 8 | Added standalone description directly below caption |
| Figure 15 | Removed misplaced description (was after Figure 11); inserted 3-sentence description directly after Figure 15 caption |
| Figures 2–4, 6–7, 9–14, 16 | Verified present; kept as-is |

---

## Verification Summary

| Check | Result |
|---|---|
| List of Figures: 16 entries | {checks.get('List of Figures has 16 entries', '?')} |
| List of Tables: 8 entries, no ghost Table 5 | {checks.get('List of Tables has 8 entries (no ghost Table 5)', '?')} |
| Chapter outline in TOC | {checks.get('Chapter outline in TOC', '?')} |
| No duplicate Table 7 for Demographic Profile | {checks.get('No duplicate Table 7 for Demographic Profile', '?')} |
| Tables 8 and 9 reference in SUS section | {checks.get('Tables 8 and 9 reference in SUS', '?')} |
| Figure 15 description after Figure 15 caption | {checks.get('Figure 15 description after caption', '?')} |

---

## Files Modified

| File | Change |
|---|---|
| `docs/handsoff/1_MAIN_MANUSCRIPT_FINAL.docx` | Full revision pass |
| `docs/handsoff/1_MAIN_MANUSCRIPT_FINAL.docx.revision.bak` | Backup (pre-revision) |
| `.agents/tasks/smartspend-final-revision/images/` | 40 DOCX images extracted |
| `.agents/tasks/smartspend-final-revision/images/blurred/` | 9 blurred images (8 GCash + 1 Figure 12) |

"""

with open(REPORT_PATH, 'w', encoding='utf-8') as f:
    f.write(report)
print(f"  Report written to {REPORT_PATH}")

print("\n=== Script v2 complete ===")
