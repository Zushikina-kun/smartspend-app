"""
build_defense_prep.py — SmartSpend Pre-Final Defense Prep Package
Generates SmartSpend_Defense_Prep.docx in docs/manuscript/output/

Sections:
  A. Overview & Team Roles
  B. Day-of-Defense Checklist
  C. Demo Script (timing cues)
  D. Q&A Drill — 22 Questions (with model answers)
  E. Weak Spots Briefing
  F. Quick-Reference Numbers Card

Run: python build_defense_prep.py
"""
import os
from pathlib import Path
from docx import Document
from docx.shared import Pt, Inches, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

OUT = Path(__file__).parent / '..' / 'output' / 'SmartSpend_Defense_Prep.docx'

# ── Colours ────────────────────────────────────────────────────────────────────
MAROON   = RGBColor(0x5C, 0x0E, 0x24)
GOLD     = RGBColor(0xC9, 0xA8, 0x4C)
BLUE     = RGBColor(0x2A, 0x4A, 0x7F)
GREEN    = RGBColor(0x1A, 0x6B, 0x3A)
AMBER    = RGBColor(0xC9, 0x70, 0x00)
DARK     = RGBColor(0x22, 0x22, 0x22)
GREY     = RGBColor(0x66, 0x66, 0x66)
WHITE    = RGBColor(0xFF, 0xFF, 0xFF)
RED      = RGBColor(0xAA, 0x00, 0x00)

MAROON_HEX = '5C0E24'
BLUE_HEX   = '2A4A7F'
GREEN_HEX  = '1A6B3A'
AMBER_HEX  = 'C97000'
CREAM      = 'FFF8F0'
LIGHT_BLUE = 'EEF4FF'
LIGHT_GRN  = 'EFFFEF'
LIGHT_AMB  = 'FFF5E0'
LIGHT_RED  = 'FFF0F0'
LGREY      = 'F5F5F5'

FONT = 'Tahoma'

# ── Helpers ───────────────────────────────────────────────────────────────────
def _set_cell_bg(cell, hex_color):
    tc = cell._tc
    tcPr = tc.get_or_add_tcPr()
    shd = OxmlElement('w:shd')
    shd.set(qn('w:val'),   'clear')
    shd.set(qn('w:color'), 'auto')
    shd.set(qn('w:fill'),  hex_color)
    tcPr.append(shd)

def _set_borders(table, color='AAAAAA', sz=4):
    tbl  = table._tbl
    tblPr = tbl.find(qn('w:tblPr'))
    b = OxmlElement('w:tblBorders')
    for side in ('top','left','bottom','right','insideH','insideV'):
        el = OxmlElement(f'w:{side}')
        el.set(qn('w:val'),   'single')
        el.set(qn('w:sz'),    str(sz))
        el.set(qn('w:space'), '0')
        el.set(qn('w:color'), color)
        b.append(el)
    tblPr.append(b)

def _no_borders(table):
    tbl   = table._tbl
    tblPr = tbl.find(qn('w:tblPr'))
    b = OxmlElement('w:tblBorders')
    for side in ('top','left','bottom','right','insideH','insideV'):
        el = OxmlElement(f'w:{side}')
        el.set(qn('w:val'),   'none')
        el.set(qn('w:sz'),    '0')
        el.set(qn('w:space'), '0')
        el.set(qn('w:color'), 'auto')
        b.append(el)
    tblPr.append(b)

def _set_tbl_width(table, twips):
    tbl   = table._tbl
    tblPr = tbl.find(qn('w:tblPr'))
    for e in tblPr.findall(qn('w:tblW')): tblPr.remove(e)
    tw = OxmlElement('w:tblW')
    tw.set(qn('w:w'), str(twips)); tw.set(qn('w:type'), 'dxa')
    tblPr.append(tw)

def _set_col_width(cell, twips):
    tcPr = cell._tc.get_or_add_tcPr()
    for e in tcPr.findall(qn('w:tcW')): tcPr.remove(e)
    tw = OxmlElement('w:tcW')
    tw.set(qn('w:w'), str(twips)); tw.set(qn('w:type'), 'dxa')
    tcPr.append(tw)

def _para(container, text, bold=False, size=9.5, color=DARK,
           align=WD_ALIGN_PARAGRAPH.LEFT, before=2, after=3,
           italic=False):
    if hasattr(container, 'add_paragraph'):
        p = container.add_paragraph()
    else:
        p = container
    p.alignment = align
    p.paragraph_format.space_before = Pt(before)
    p.paragraph_format.space_after  = Pt(after)
    if text:
        r = p.add_run(text)
        r.font.name   = FONT
        r.font.size   = Pt(size)
        r.bold        = bold
        r.italic      = italic
        r.font.color.rgb = color
    return p

def _cell_para(cell, text, bold=False, size=9.5, color=DARK,
               align=WD_ALIGN_PARAGRAPH.LEFT, before=3, after=3,
               italic=False, clear=True):
    if clear and cell.paragraphs:
        p = cell.paragraphs[0]
        p.clear()
    else:
        p = cell.add_paragraph()
    p.alignment = align
    p.paragraph_format.space_before = Pt(before)
    p.paragraph_format.space_after  = Pt(after)
    if text:
        r = p.add_run(text)
        r.font.name   = FONT
        r.font.size   = Pt(size)
        r.bold        = bold
        r.italic      = italic
        r.font.color.rgb = color
    return p

def _cell_add(cell, text, bold=False, size=9.5, color=DARK,
              align=WD_ALIGN_PARAGRAPH.LEFT, before=1, after=2,
              italic=False):
    p = cell.add_paragraph()
    p.alignment = align
    p.paragraph_format.space_before = Pt(before)
    p.paragraph_format.space_after  = Pt(after)
    if text:
        r = p.add_run(text)
        r.font.name   = FONT
        r.font.size   = Pt(size)
        r.bold        = bold
        r.italic      = italic
        r.font.color.rgb = color
    return p

TW = 10224  # page text width in twips

doc = Document()
sec = doc.sections[0]
sec.page_width    = Inches(8.5)
sec.page_height   = Inches(11)
for attr in ('top_margin','bottom_margin','left_margin','right_margin'):
    setattr(sec, attr, Inches(0.7))

doc.styles['Normal'].font.name = FONT
doc.styles['Normal'].font.size = Pt(9.5)
doc.styles['Normal'].paragraph_format.space_before = Pt(0)
doc.styles['Normal'].paragraph_format.space_after  = Pt(3)

# ── Page footer ───────────────────────────────────────────────────────────────
footer = sec.footer
footer.paragraphs[0].clear()
fp = footer.paragraphs[0]
fp.paragraph_format.space_before = Pt(0)
fp.paragraph_format.space_after  = Pt(0)
fr = fp.add_run('SmartSpend Pre-Final Defense Prep  |  Lucid Frame  |  Lorma Colleges CCSE BSIT  |  AY 2026–2027')
fr.font.name = FONT; fr.font.size = Pt(7); fr.font.color.rgb = GREY
fp.add_run('\t')
fr2 = fp.add_run('CONFIDENTIAL — FOR INTERNAL USE ONLY')
fr2.font.name = FONT; fr2.font.size = Pt(7); fr2.bold = True; fr2.font.color.rgb = MAROON

# ── Section-header helper ─────────────────────────────────────────────────────
def section_banner(title, subtitle=None, color_hex=MAROON_HEX):
    t = doc.add_table(rows=1, cols=1)
    _set_tbl_width(t, TW)
    _no_borders(t)
    c = t.cell(0, 0)
    _set_cell_bg(c, color_hex)
    p = c.paragraphs[0]
    p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    p.paragraph_format.space_before = Pt(5)
    p.paragraph_format.space_after  = Pt(3)
    r = p.add_run(f'  {title}')
    r.font.name = FONT; r.font.size = Pt(14); r.bold = True; r.font.color.rgb = WHITE
    if subtitle:
        p2 = c.add_paragraph()
        p2.alignment = WD_ALIGN_PARAGRAPH.LEFT
        p2.paragraph_format.space_before = Pt(0)
        p2.paragraph_format.space_after  = Pt(4)
        r2 = p2.add_run(f'  {subtitle}')
        r2.font.name = FONT; r2.font.size = Pt(9); r2.italic = True
        r2.font.color.rgb = RGBColor(0xFF, 0xFF, 0xCC)
    doc.add_paragraph().paragraph_format.space_after = Pt(2)

def sub_heading(text, color=MAROON):
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(8)
    p.paragraph_format.space_after  = Pt(2)
    r = p.add_run(text)
    r.font.name = FONT; r.font.size = Pt(11); r.bold = True; r.font.color.rgb = color

def divider():
    t = doc.add_table(rows=1, cols=1)
    _set_tbl_width(t, TW)
    _no_borders(t)
    c = t.cell(0, 0)
    _set_cell_bg(c, 'DDDDDD')
    p = c.paragraphs[0]
    p.paragraph_format.space_before = Pt(0)
    p.paragraph_format.space_after  = Pt(0)
    doc.add_paragraph().paragraph_format.space_after = Pt(3)

def info_box(text, bg_hex=CREAM, border='CC9999', color=DARK, bold=False):
    t = doc.add_table(rows=1, cols=1)
    _set_tbl_width(t, TW)
    _set_borders(t, border, 4)
    c = t.cell(0, 0)
    _set_cell_bg(c, bg_hex)
    _cell_para(c, text, bold=bold, color=color, before=5, after=5, size=9.5)
    doc.add_paragraph().paragraph_format.space_after = Pt(2)

# ═════════════════════════════════════════════════════════════════════════════
# ── COVER ─────────────────────────────────────────────────────────────────────
# ═════════════════════════════════════════════════════════════════════════════
cover = doc.add_table(rows=1, cols=1)
_set_tbl_width(cover, TW)
_no_borders(cover)
cc = cover.cell(0, 0)
_set_cell_bg(cc, MAROON_HEX)
for txt_data in [
    ('PRE-FINAL DEFENSE PREP PACKAGE', True, 22, WHITE),
    ('SmartSpend: An AI-Assisted Mobile Financial Tracking and Advisory Application', False, 12, RGBColor(0xFF,0xFF,0xCC)),
    ('', False, 6, WHITE),
    ('Brix A. Directo  ·  Cyrille John M. Rubis  ·  Djaunathan Albert S. Madayag', False, 11, RGBColor(0xFF,0xFF,0xFF)),
    ('Lucid Frame  |  BSIT 4th Year  |  Lorma Colleges CCSE  |  AY 2026–2027, 1st Semester', False, 9, RGBColor(0xCC,0xCC,0xCC)),
    ('Adviser: Ellen F. Mangaoang, MIT', True, 9, GOLD),
    ('', False, 6, WHITE),
    ('Version 2.9.11  |  September 2026', False, 9, RGBColor(0xCC,0xCC,0xCC)),
]:
    label, bd, sz, col = txt_data
    p = cc.add_paragraph() if cc.paragraphs[0].text else cc.paragraphs[0]
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(4 if bd else 2)
    p.paragraph_format.space_after  = Pt(2)
    if label:
        rr = p.add_run(label)
        rr.font.name = FONT; rr.font.size = Pt(sz); rr.bold = bd; rr.font.color.rgb = col

doc.add_paragraph()

# ═════════════════════════════════════════════════════════════════════════════
# SECTION A — OVERVIEW & TEAM ROLES
# ═════════════════════════════════════════════════════════════════════════════
section_banner('A.  OVERVIEW & TEAM ROLES',
               'Who does what — from opening to Q&A', MAROON_HEX)

_para(doc,
    'This document is your complete preparation kit for the Pre-Final Defense. Read every '
    'section. Drill the Q&A until answers come without hesitation. The defense typically '
    'runs 30–40 minutes: ~8 min presentation + ~8 min demo + 15–20 min Q&A.',
    size=9.5, before=0, after=6)

sub_heading('Team Roles Assignment', MAROON)

roles_tbl = doc.add_table(rows=4, cols=3)
_set_tbl_width(roles_tbl, TW)
_set_borders(roles_tbl, 'BBBBBB', 4)

role_headers = ['Member', 'Primary Role During Defense', 'Owns These Questions']
role_data = [
    ('Brix A. Directo\n(Group Leader)',
     'Presenter — opens, closes, and handles Q&A.\n'
     'Leads the live demo (holds the phone).\n'
     'Speaks for the group when panel asks "you" questions.',
     'AI architecture, context injection vs RAG,\n'
     '34 agentic actions, FHS formula, security,\n'
     'tech stack, all "why did you choose X?" questions.'),
    ('Cyrille John M. Rubis\n(UI/UX & Docs)',
     'Handles manuscript/paper questions.\n'
     'Presents Slides 2–3 (Problem + Objectives)\n'
     'and Slides 12–13 (Methodology + SUS).',
     'Manuscript structure, Chapter 1–5 content,\n'
     'related literature, SUS scoring, respondents,\n'
     'research design, theoretical frameworks.'),
    ('Djaunathan Albert S. Madayag\n(PM & QA)',
     'Handles comparison + validation questions.\n'
     'Presents Slides 10–11 (App Comparison +\n'
     'Smart Import) and Slide 15 (Conclusions).',
     'Competitive analysis (BudgetPH, GCash Pera Coach),\n'
     'testing, QA, validation, limitations,\n'
     'post-capstone roadmap, scoping decisions.'),
]

for ci, hdr in enumerate(role_headers):
    c = roles_tbl.cell(0, ci)
    _set_cell_bg(c, MAROON_HEX)
    _set_col_width(c, [2200, 4400, 3624][ci])
    _cell_para(c, hdr, bold=True, color=WHITE, align=WD_ALIGN_PARAGRAPH.CENTER, size=9.5)

for ri, (name, role, owns) in enumerate(role_data, start=1):
    bg = LGREY if ri % 2 == 0 else 'FFFFFF'
    for ci, (text, w) in enumerate(zip([name, role, owns], [2200, 4400, 3624])):
        c = roles_tbl.cell(ri, ci)
        _set_col_width(c, w)
        _set_cell_bg(c, bg)
        _cell_para(c, text, size=9, color=DARK, before=4, after=4)

doc.add_paragraph()

info_box(
    '📌  RULE: Whoever is speaking controls the room. When a panel member asks a question, '
    'the person whose area it is answers FIRST — then the others can add. Never talk over '
    'each other. If unsure, Brix takes it. Never say "I don\'t know" — say "That is outside '
    'our current scope, but here is our plan for it post-capstone..."',
    bg_hex='FFF3F5', border='CC9999', color=MAROON, bold=True)

# ═════════════════════════════════════════════════════════════════════════════
# SECTION B — DAY-OF-DEFENSE CHECKLIST
# ═════════════════════════════════════════════════════════════════════════════
doc.add_page_break()
section_banner('B.  DAY-OF-DEFENSE CHECKLIST',
               'Complete this 1 hour before — do not skip any item', BLUE_HEX)

checklist_sections = [
    ('PHONE / APK', [
        ('☐', 'APK v2.9.11 installed and opens without crash'),
        ('☐', 'Logged in with a demo account (not your personal data)'),
        ('☐', 'Demo data loaded: Profile → Load Demo Data'),
        ('☐', 'AI daily limit reset: AI screen → ⋮ → Reset Daily Limit'),
        ('☐', 'WiFi connected and stable'),
        ('☐', 'Screen brightness set to MAX'),
        ('☐', 'Screen timeout set to 5 minutes or Never'),
        ('☐', 'Notifications silenced / Do Not Disturb ON'),
        ('☐', 'Battery 80%+ or charging'),
        ('☐', 'Screen mirroring ready (scrcpy / Vysor) if presenting on projector'),
        ('☐', 'Wallet balances set to realistic values (GCash ₱500, Cash ₱1,200)'),
        ('☐', '3–4 recent transactions visible on home screen'),
        ('☐', 'At least 1 Shopee / Steam screenshot saved in gallery for Batch Import demo'),
    ]),
    ('PRESENTATION MATERIALS', [
        ('☐', 'SmartSpend_Defense_Slides.pptx open on laptop — advance to Slide 1'),
        ('☐', 'Compliance matrix printed (SmartSpend_Compliance_Matrix_PreFinal.docx)'),
        ('☐', 'Extra printed copies of compliance matrix (1 per panel member + 1 for adviser)'),
        ('☐', 'Pens available for panel to write recommendations'),
        ('☐', 'Backup copy of APK on USB drive'),
    ]),
    ('TEAM READINESS', [
        ('☐', 'All 3 members present 15 minutes early'),
        ('☐', 'Each member has read their Q&A section in this document'),
        ('☐', 'Demo flow run-through done at least once this morning'),
        ('☐', 'Role assignments confirmed — who speaks on which slide'),
        ('☐', 'Formal attire (school uniform or smart casual — check adviser guidance)'),
    ]),
    ('JUST BEFORE ENTERING', [
        ('☐', 'Phone on Silent (not vibrate — audible vibration is distracting)'),
        ('☐', 'Laptop plugged in or battery 50%+'),
        ('☐', 'Compliance matrix distributed to panel members upon entry'),
        ('☐', 'Deep breath. You built something genuinely impressive. Own it.'),
    ]),
]

for section_title, items in checklist_sections:
    sub_heading(section_title, BLUE)
    for icon, item in items:
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(1)
        p.paragraph_format.space_after  = Pt(1)
        p.paragraph_format.left_indent  = Inches(0.2)
        r = p.add_run(f'{icon}  {item}')
        r.font.name = FONT; r.font.size = Pt(9.5); r.font.color.rgb = DARK

doc.add_paragraph()

# ═════════════════════════════════════════════════════════════════════════════
# SECTION C — DEMO SCRIPT WITH TIMING CUES
# ═════════════════════════════════════════════════════════════════════════════
doc.add_page_break()
section_banner('C.  DEMO SCRIPT — 8–9 MINUTE FLOW',
               'Practice this until the narration is natural, not memorized', GREEN_HEX)

_para(doc,
    'The demo is the most important 9 minutes. Panels form their strongest impression here. '
    'Brix holds the phone and narrates. Cyrille and Djaunathan are silent unless the panel '
    'interrupts with a question. Do not read from a script during the demo — practice until '
    'it flows naturally.',
    size=9.5, before=0, after=6, italic=True, color=GREY)

demo_steps = [
    ('0:00 – 0:30', '30 sec', 'OPENING STATEMENT', MAROON_HEX,
     'NARRATE: "SmartSpend is an AI-assisted financial tracking app for Filipino users. '
     'Instead of filling out forms, you talk to the AI — and it handles everything. '
     'Let me show you."',
     'SHOW: Home screen with spending card visible at top. Do not scroll yet.',
     ''),
    ('0:30 – 2:30', '2 min', 'AI CHAT — 3 INPUT METHODS + 1 ADVISORY', MAROON_HEX,
     'TAP: AI button (center of bottom nav).',
     'NARRATE: "The AI screen is the core of the app. Let me show three ways to log expenses."',
     'STEP 1 — Voice:\n'
     '  TAP mic → say: "Spent 30 pesos for jeepney fare"\n'
     '  WAIT for response\n'
     '  NARRATE: "Parsed as Transportation, Need, ₱30. Logged directly to the database."\n\n'
     'STEP 2 — Text:\n'
     '  TYPE: "Bought Jollibee chicken joy for 149"\n'
     '  WAIT for response\n'
     '  NARRATE: "Knows Jollibee is Food, tagged as Want. No dropdowns, no category picker."\n\n'
     'STEP 3 — Wallet update (shows agentic breadth):\n'
     '  TYPE: "My GCash is 500 pesos"\n'
     '  WAIT for response\n'
     '  NARRATE: "Not just expenses — it manages wallet balances directly. GCash updated to ₱500."\n\n'
     'STEP 4 — Filipino advisory question:\n'
     '  TYPE: "How do I apply for SSS loan?"\n'
     '  WAIT for response\n'
     '  NARRATE: "Not just a tracker — a financial companion. SSS, PhilHealth, Pag-IBIG, BIR, investments."'),
    ('2:30 – 4:00', '1.5 min', 'SMART IMPORT — 4-MODE SHEET', BLUE_HEX,
     'TAP: Camera icon (bottom-left of input row, looks like a camera).',
     'NARRATE: "This opens SmartSpend\'s unified import system — four modes in one."',
     'SHOW: The 4-mode bottom sheet.\n'
     'NARRATE: "Live Camera for barcodes and receipts. Single Photo auto-detects what it is. '
     'Batch Screenshots — this is the unique one — pick up to 10 screenshots and the app '
     'figures out the platform automatically."\n\n'
     'TAP: Batch Screenshots → pick 2–3 screenshots (Shopee or Steam).\n'
     'NARRATE: "Detected Shopee and Steam — each gets its own AI extraction prompt tuned '
     'for that platform. 40+ platforms supported — GCash, Lazada, GrabFood, Netflix, BPI."\n\n'
     'TAP back. Show Live Camera briefly → receipt mode toggle.\n'
     'NARRATE: "Receipt mode — multiple items open a review screen before saving."'),
    ('4:00 – 5:30', '1.5 min', 'WALLETS & SETTINGS', GREEN_HEX,
     'TAP: Home tab → SCROLL DOWN to the green Wallet card.',
     'NARRATE: "Wallet system — tracks actual cash across all accounts."',
     'TAP: Wallet card → wallet sheet opens.\n'
     'NARRATE: "Cash on Hand, GCash, Maya — 30+ Philippine banks and e-wallets."\n\n'
     'SHOW: Log Allowance button (blue, below wallet card).\n'
     'NARRATE: "For students — tap when allowance arrives. Long-press for custom amount."\n\n'
     'GO TO: Profile → App Settings.\n'
     'NARRATE: "App Settings — auto-deduct wallets, mood check-in, impulse pause, budget alerts."\n\n'
     'TOGGLE: Balance Mode ON → show Profile card change.\n'
     'NARRATE: "Balance Mode — shows total wallet cash instead of income-based remaining. '
     'Same data, different context." TOGGLE back OFF.'),
    ('5:30 – 7:00', '1.5 min', 'ANALYTICS', MAROON_HEX,
     'TAP: Analytics tab (bottom nav).',
     'NARRATE: "Analytics — where the data becomes insight."',
     'SHOW: Navigation chips row at top.\n'
     'NARRATE: "Quick links to Goals, Debts, Budgets, Wallets, Calendar, Import."\n\n'
     'SCROLL slowly through:\n'
     '  "Pie chart — 14 categories including Gaming, Personal Care, Travel."\n'
     '  "50/30/20 tracker — Needs vs Wants vs Savings against the rule."\n'
     '  "Market Insights — live PHP exchange rates."\n'
     '  "Spending Personality — labels your style from your data."'),
    ('7:00 – 8:00', '1 min', 'FINANCIAL HEALTH SCORE BREAKDOWN', MAROON_HEX,
     'TAP: Home tab → SCROLL FAR DOWN to FHS score card.',
     'NARRATE: "Financial Health Score — 0 to 100. Four components, 25 points each."',
     'TAP: FHS card → breakdown sheet opens.\n'
     'NARRATE:\n'
     '  "Savings Rate — saving 20% or more? Full 25 points."\n'
     '  "Overspend Control — how many days stayed under daily budget?"\n'
     '  "Budget Adherence — all category budgets within limit?"\n'
     '  "Logging Consistency — recording expenses every day?"\n'
     '  "Income-relative. A student with ₱6,600 and a professional with ₱50,000 '
     'are scored fairly against their own income."\n\n'
     'SHOW: "Ask AI to explain my score" link.\n'
     'NARRATE: "Users tap here for a plain-language AI explanation."'),
    ('8:00 – 8:30', '30 sec', 'GAMIFICATION', GREEN_HEX,
     'TAP: Home → scroll to Daily Quests area.',
     'NARRATE: "Gamification layer. Daily Quests — 4 rotating challenges, streak counter, inspired by gacha game dailies."',
     'SHOW: Mood check-in widget.\n'
     'NARRATE: "Daily mood check-in — correlates with spending in Analytics."\n'
     'SHOW: Badges row if visible. "23 achievement badges, impulse pause, subscription auto-detection."'),
    ('8:30 – 9:00', '30 sec', 'ARCHITECTURE + CLOSING', BLUE_HEX,
     'No specific screen — narrate over any screen.',
     'NARRATE: "Architecture — fully serverless. Flutter + Firebase + Groq API + SQLite. Zero hosting cost."',
     'NARRATE: "Context injection — not RAG. User financial data injected directly into each AI prompt. '
     'Simpler, faster, no vector database needed."\n\n'
     'CLOSING: "SmartSpend demonstrates that a genuinely capable AI financial assistant can be built '
     'entirely on free-tier services. The goal: make financial literacy accessible. You don\'t need '
     'to know what a budget is — just tell it what you spent."'),
]

for time_range, duration, title, color_hex, instruction, narration, detail in demo_steps:
    # Step header
    step_tbl = doc.add_table(rows=1, cols=2)
    _set_tbl_width(step_tbl, TW)
    _no_borders(step_tbl)
    _set_cell_bg(step_tbl.cell(0, 0), color_hex)
    _set_cell_bg(step_tbl.cell(0, 1), color_hex)
    _set_col_width(step_tbl.cell(0, 0), 2400)
    _set_col_width(step_tbl.cell(0, 1), 7824)
    _cell_para(step_tbl.cell(0, 0), time_range, bold=True, color=WHITE, size=10, before=4, after=4)
    _cell_para(step_tbl.cell(0, 1), f'{title}  [{duration}]', bold=True, color=WHITE, size=10, before=4, after=4)

    content_tbl = doc.add_table(rows=1, cols=1)
    _set_tbl_width(content_tbl, TW)
    _set_borders(content_tbl, 'CCCCCC', 4)
    _set_cell_bg(content_tbl.cell(0, 0), 'FAFAFA')
    cc2 = content_tbl.cell(0, 0)
    _cell_para(cc2, instruction, bold=True, color=BLUE, size=9.5, before=5, after=2)
    _cell_add(cc2, narration, color=MAROON, size=9, italic=True, before=1, after=3)
    if detail:
        _cell_add(cc2, detail, color=DARK, size=9, before=2, after=5)

    doc.add_paragraph().paragraph_format.space_after = Pt(4)

# ═════════════════════════════════════════════════════════════════════════════
# SECTION D — Q&A DRILL (22 QUESTIONS)
# ═════════════════════════════════════════════════════════════════════════════
doc.add_page_break()
section_banner('D.  Q&A DRILL — 22 HARDEST QUESTIONS',
               'Read the question, cover the answer, say it aloud, then check. Repeat until automatic.',
               MAROON_HEX)

_para(doc,
    'Practice method: One person reads the question. The designated member answers aloud '
    'WITHOUT reading. Then compare to the model answer. Drill until you can answer every '
    'question in your section in under 45 seconds with no hesitation.',
    size=9.5, before=0, after=8, italic=True, color=GREY)

qa_data = [
    # (number, owner, question, model_answer, difficulty)
    # difficulty: HIGH / MED / LOW
    (1, 'Brix', 'HIGH',
     'How does the Financial Health Score work? Walk us through the formula.',
     'FHS is a behavioral metric from 0 to 100, computed entirely from transaction data — '
     'no bank connection needed.\n\n'
     'Full Mode (income tracking ON) — 4 components, 25 points each:\n'
     '  1. Savings Rate: 25 × min(1, savingsRate ÷ 0.20). Full 25 pts when saving ≥20% of income.\n'
     '  2. Overspend Control: 25 × (1 − overDays ÷ activeDays). Days where spending exceeded '
     'the daily income budget.\n'
     '  3. Budget Adherence: 25 × (onBudget ÷ totalBudgets). How many category budgets are on track.\n'
     '  4. Logging Consistency: 25 × (loggedDays ÷ activeDays). Are you recording every day?\n\n'
     'Lightweight Mode (income OFF) — same 4 slots: Spending Restraint, Consistency, '
     'Category Balance (no single category >40%), Habit Streak (14-day streak = full score).\n\n'
     'Two adjustments:\n'
     '  Warning Decay: −5 pts/day (max −15) if you ignore a budget warning.\n'
     '  Gap Adjustment: −3 or +2 pts/day for verified unlogged days.\n\n'
     'Tap the score card on the home screen for the full breakdown.'),

    (2, 'Brix', 'HIGH',
     'What is agentic AI? How is SmartSpend "agentic"?',
     'Agentic AI means the AI doesn\'t just answer questions — it takes autonomous actions '
     'on real data. SmartSpend has 34 action types.\n\n'
     'The loop is: Perceive (user sends a message) → Decide (AI classifies intent into one '
     'of 34 action types, outputs structured JSON) → Act (the app writes directly to SQLite).\n\n'
     'Example: "I spent 85 pesos on lunch" → AI outputs '
     '{action: "log_expense", amount: 85, category: "Food", type: "Want"} → '
     'expense_service.dart writes to the database. No human confirmation needed.\n\n'
     'This is what separates SmartSpend from apps that just answer financial questions — '
     'it actually manages your data, not just talks about it.'),

    (3, 'Brix', 'HIGH',
     'Why did you use Context Injection instead of RAG?',
     'RAG — Retrieval-Augmented Generation — is designed for large knowledge bases: '
     'thousands of documents requiring vector search and embedding.\n\n'
     'Our per-user dataset is tiny: ~50 expenses, 8 budgets, 5 goals, 4 wallets. '
     'That is roughly 3,000–5,000 tokens — it fits entirely in one prompt.\n\n'
     'Context injection: before every AI message, the app queries SQLite and builds '
     'a structured context string with all user financial data, then injects it into '
     'the system prompt. Simpler, faster, no vector database, no embedding cost.\n\n'
     'RAG would add infrastructure overhead — a vector store, embedding API, '
     'retrieval pipeline — for a problem that doesn\'t need it. Our architecture is '
     'appropriate for the scale of a single mobile user\'s financial data.'),

    (4, 'Brix', 'HIGH',
     'What happens if all 6 AI providers go down simultaneously?',
     'The app remains fully functional. All core features work completely offline: '
     'manual expense logging via forms, all analytics, budgets, goals, FHS calculation, '
     'wallets, debts, recurring transactions.\n\n'
     'The AI chat screen shows a friendly message: "All AI providers are currently busy. '
     'Please try again in a few minutes or use manual entry."\n\n'
     'Simultaneous failure is statistically negligible for a 30-respondent academic study: '
     'Gemini ~1,500/day, LLaMA 4 Scout + LLaMA 3.3 70B + LLaMA 3.1 8B on Groq ~16,400/day, '
     'Cerebras 1M tokens/day — combined over 50,000+ requests per day. Rate limits reset '
     'within minutes (Groq/Cerebras) or at midnight (Gemini daily limits).'),

    (5, 'Brix', 'HIGH',
     'Why not use finance-specialized LLMs like FinGPT or BloombergGPT?',
     'Three reasons:\n\n'
     '1. Filipino-English capability: Finance-specialized models are trained on English '
     'financial data. None of them handle Taglish — they fail on "nag-gastos ako ng 85 '
     'sa Jollibee." Gemini and LLaMA 4 Scout both handle Filipino-English correctly '
     '(Tagalog is one of Meta\'s 12 explicitly fine-tuned languages for LLaMA 4 Scout).\n\n'
     '2. No free API: BloombergGPT has no hosted API. FinGPT requires self-hosting on a GPU. '
     'Our stack is entirely free-tier — zero operating cost for an academic deployment.\n\n'
     '3. No function calling: Finance-specialized models lack native tool/function calling '
     'support. Our 34 agentic actions require reliable structured JSON output — Gemini and '
     'Groq both support native function calling.\n\n'
     'Per FrontierFinance Benchmark (2026): tool harness architecture matters more than '
     'model specialization for consumer-facing financial workloads.'),

    (6, 'Brix', 'MED',
     'How is the data secure? What protects the user\'s financial information?',
     'Multiple layers:\n\n'
     '1. On-device storage: Primary data lives in SQLite on the user\'s device. '
     'The app never sends raw financial data to external servers.\n\n'
     '2. Firebase Firestore: Sync data is protected by UID-scoped security rules — '
     'each user can only read and write their own data. No cross-user access possible.\n\n'
     '3. API key protection: The AI provider API key is fetched at runtime from '
     'Firebase Remote Config — it is never hardcoded in the APK binary. '
     'Decompiling the APK reveals no credentials.\n\n'
     '4. App Lock: PIN + biometric authentication built in.\n\n'
     '5. AI privacy: Only expense text and anonymized financial summaries are sent '
     'to AI providers — no names, phone numbers, or bank account details.\n\n'
     '6. Rate limiting: 60 AI messages per user per day prevents abuse.'),

    (7, 'Brix', 'MED',
     'What are the 34 agentic action types? Give at least 5 examples.',
     'The 34 actions cover 8 categories:\n\n'
     '• Expenses: log_expense, update_expense, delete_expense, delete_by_date\n'
     '• Income & Wallets: set_income, add_income, set_wallet_balance, transfer_wallet\n'
     '• Budgets: set_budget\n'
     '• Goals: add_goal, update_goal, delete_goal\n'
     '• Debts: add_debt, update_debt\n'
     '• Recurring: add_recurring, delete_recurring\n'
     '• Analysis: plan_salary_split, analyze_goal_feasibility, suggest_debt_payoff, '
     'generate_monthly_plan, compare_periods, explain_fhs_breakdown, '
     'project_savings_timeline, detect_subscriptions, simulate_what_if, '
     'create_debt_payment_plan, split_expense, and more\n'
     '• Settings: set_spending_limit, add_insurance_policy, set_account_type\n\n'
     'Example in action: "Set a ₱3,000 budget for food this month" → '
     'AI outputs {action: "set_budget", category: "Food", amount: 3000} → '
     'budget_service.dart writes it. Done.'),

    (8, 'Brix', 'MED',
     'Why Flutter? Why not React Native or a native Android app?',
     'Three reasons for this project:\n\n'
     '1. Single codebase: Flutter compiles to native ARM for both Android and iOS. '
     'One codebase for a 3-person team is a practical necessity.\n\n'
     '2. Performance: Flutter compiles to native code — near-native rendering, '
     'no JavaScript bridge like React Native. Important for the real-time '
     'FHS chart animations and SQLite queries.\n\n'
     '3. Dart ecosystem: sqflite for SQLite, firebase_core, speech_to_text, '
     'mobile_scanner — all mature packages with strong Flutter support.\n\n'
     'React Native would have required bridging for SQLite and OCR. '
     'Native Android would have doubled the codebase for any future iOS port.'),

    (9, 'Brix', 'HIGH',
     'What is the theoretical basis for SmartSpend\'s behavioral design and gamification?',
     'Four frameworks — each grounded in published research:\n\n'
     '1. Nudge Theory (Thaler & Sunstein, 2008): Startup alerts, Warning Decay, and '
     'budget alert framing are choice-architecture nudges — they guide behavior '
     'without restricting the user\'s freedom.\n\n'
     '2. Prospect Theory / Loss Aversion (Kahneman & Tversky, 1979): The Warning '
     'Decay (−5 pts/day) makes ignoring budget overruns concretely painful. '
     'Losses motivate more than equivalent gains.\n\n'
     '3. Self-Determination Theory — SDT (Deci & Ryan, 2000): The 23 achievement '
     'badges and streak system support Competence (rewarding skill growth). '
     'Non-prescriptive, customizable goals support Autonomy. Filipino-first '
     'framing supports Relatedness.\n\n'
     '4. Empirical validation — Atlantis Press PLS-SEM (Sharma, Gaba & Sharma, 2026; '
     'N=656): Personalized Budget Feedback Nudges → Sustainable Financial Intention '
     '(β=0.28, t=6.21, p<0.001). Gamified Rewards → SFI (β=0.25, t=5.89, p<0.001). '
     'Perceived Algorithm Transparency moderates the path to Digital Financial '
     'Well-being (β=0.14, t=2.95, p<0.001) — the model explains 56% of variance '
     'in well-being (R²=0.56). This directly validates why SmartSpend explains '
     'its FHS breakdown in plain language.'),

    (10, 'Brix', 'HIGH',
     'What is the academic basis for the FHS? How is it different from the CFPB scale?',
     'The FHS is formally positioned as a Prototype Observed Financial Health '
     'Indicator (FHI) — NOT a psychometric survey instrument.\n\n'
     'The distinction is grounded in the Commonwealth Bank of Australia & Melbourne '
     'Institute (CBA-MI, 2018) dual-scale model:\n'
     '  • Reported Scale — subjective, self-reported psychological states '
     '(like the CFPB 10-item survey — asks about financial anxiety, perceived '
     'security, freedom of choice)\n'
     '  • Observed Scale — objective, computed from administrative/transaction data\n\n'
     'SmartSpend\'s FHS belongs to the Observed category: it is computed from '
     'actual SQLite transaction records — savings rate, overspend days, budget '
     'adherence, logging consistency — not from how the user feels about money.\n\n'
     'Claiming "our FHS is validated by the CFPB scale" would be a construct mismatch '
     '— subjective psychological states cannot be programmatically calculated from '
     'transaction logs. The correct academic framing:\n'
     '"Our FHS is a Prototype Observed FHI per CBA-MI (2018) and UNSGSA (2021) '
     'dual-scale guidelines. The CFPB scale provides the definitional grounding '
     '(0–100 range, financial well-being definition) but does not validate our formula."'),

    (11, 'Cyrille', 'HIGH',
     'What is your research design? Why mixed methods?',
     'Mixed: Quantitative surveys + SUS scores are triangulated with qualitative '
     'interview data and think-aloud observations. Neither method alone would give '
     'a complete picture of usability and user needs.'),

    (12, 'Cyrille', 'HIGH',
     'Why only 30 respondents? Is that statistically valid?',
     'Purposive sampling is appropriate for exploratory capstone research.\n\n'
     'Three supporting arguments:\n\n'
     '1. Nielsen\'s Law: 5 users uncover 85% of usability issues. 30 respondents '
     'far exceeds the threshold for identifying major usability problems.\n\n'
     '2. SUS validation: Bangor et al. (2009) validated SUS for small purposive samples. '
     'The scale was specifically designed to produce reliable scores with n < 50.\n\n'
     '3. Research purpose: We are not generalizing to all Filipinos — we are evaluating '
     'SmartSpend\'s usability with a representative purposive sample of our target population: '
     'parents 35–55 (n=20) and young professionals 21–35 (n=10) in La Union.\n\n'
     'This is consistent with similar capstone and thesis studies in the BSIT curriculum.'),

    (13, 'Cyrille', 'MED',
     'Explain the SUS scoring method. What score are you targeting?',
     'System Usability Scale (Brooke, 1996) — 10 items, 5-point Likert scale.\n\n'
     'Scoring: Odd items (positive): score − 1. Even items (negative): 5 − score. '
     'Sum all 10 adjusted scores × 2.5 = SUS score (0–100).\n\n'
     'Interpretation (Bangor et al., 2009):\n'
     '  ≥90 = A+ Excellent/Best Imaginable\n'
     '  85–89 = A Excellent\n'
     '  80–84 = B Good ← OUR TARGET\n'
     '  70–79 = C OK / Marginal\n'
     '  <70 = Poor / Not Acceptable\n\n'
     'We target ≥80 (Good, Acceptable). This is the industry standard threshold '
     'for a system to be considered usable. Administered after a guided live demo '
     'using Demo Mode to 30 purposively selected respondents.'),

    (14, 'Cyrille', 'MED',
     'What theoretical frameworks ground your study?',
     'Five frameworks — each explicitly grounded in published research:\n\n'
     '1. Behavioral Finance Theory (Kahneman & Tversky, 1979; Thaler & Sunstein, 2008): '
     'Loss aversion and nudge theory underpin the Impulse Pause mechanic, budget alerts, '
     'and Warning Decay in the FHS.\n\n'
     '2. Financial Capability Framework (BSP, 2021): Four components — knowledge, attitude, '
     'behavior, access. SmartSpend addresses all four through AI advice, gamification, '
     'agentic tracking, and offline access.\n\n'
     '3. Self-Determination Theory — SDT (Deci & Ryan, 2000): Intrinsic motivation sustained '
     'by Autonomy (non-prescriptive goals), Competence (23 badges reward skill growth), '
     'and Relatedness (Filipino-first framing and local financial context).\n\n'
     '4. Technology Acceptance Model (Davis, 1989): Perceived usefulness + ease of use → '
     'adoption. The SUS evaluation directly measures this.\n\n'
     '5. 50/30/20 Budgeting Rule (Warren & Tyagi, 2005): Built into SmartSpend\'s Analytics '
     'tab as a live Needs/Wants/Savings tracker.\n\n'
     'Empirical support: Sharma, Gaba & Sharma (2026) PLS-SEM (N=656) validates the '
     'SDT-gamification-nudge design with exact path coefficients (Budget Nudge β=0.28, '
     'Gamification β=0.25, Algorithm Transparency R²=0.56).'),

    (15, 'Cyrille', 'MED',
     'Who are your expert validators and what did they validate?',
     'SmartSpend\'s validation used a credential-based approach — validators are identified '
     'by qualifications (educational background, occupation, years of experience) rather '
     'than by name, in compliance with ethical research standards on participant privacy.\n\n'
     'Validators covered three domains:\n'
     '  1. IT/Software expert — validated the system architecture, AI accuracy, '
     'database design, and technical completeness.\n'
     '  2. Financial literacy expert — validated the FHS formula, financial advice '
     'accuracy, and alignment with PH financial standards (SSS, PhilHealth, BIR).\n'
     '  3. Language/UX expert — validated the Taglish AI parsing accuracy, UI/UX '
     'clarity, and accessibility for the target population.\n\n'
     'If asked why name is optional: "Ethical research standards protect validator '
     'privacy. What matters is their qualifications, which are documented."'),

    (16, 'Djaunathan', 'HIGH',
     'How does SmartSpend compare to GCash Pera Coach?',
     'GCash Pera Coach (launched March 2026, built with Microsoft) is a financial '
     'literacy chatbot embedded inside GCash. It teaches financial concepts via Q&A '
     'in English and Filipino.\n\n'
     'Key differences:\n'
     '  • Pera Coach answers questions. SmartSpend manages your actual data — '
     '31 autonomous actions on SQLite.\n'
     '  • Pera Coach has no expense tracking. SmartSpend tracks, categorizes, '
     'analyzes, and generates insights.\n'
     '  • Pera Coach has no Financial Health Score. SmartSpend has a 4-component '
     'behavioral FHS.\n'
     '  • Pera Coach requires GCash (internet, account). SmartSpend works fully offline.\n'
     '  • Pera Coach is GCash-only. SmartSpend tracks all payment methods: cash, '
     'GCash, Maya, BDO, BPI, etc.\n\n'
     'They are complementary, not competing: Pera Coach teaches you about money; '
     'SmartSpend manages your money.'),

    (17, 'Djaunathan', 'HIGH',
     'How does SmartSpend compare to BudgetPH?',
     'BudgetPH is the closest Filipino-first competitor.\n\n'
     'Where BudgetPH leads:\n'
     '  • Paluwagan tracker (rotating savings group — uniquely Filipino)\n'
     '  • 15th/30th payday cycle awareness\n\n'
     'Where SmartSpend leads:\n'
     '  • 34 agentic AI actions vs insights-only\n'
     '  • Multi-modal input: voice, OCR, barcode, 40+ screenshot platforms\n'
     '  • Offline-first (BudgetPH requires internet for most features)\n'
     '  • Financial Health Score (BudgetPH has a simpler budget score)\n'
     '  • Gamification: 23 achievement badges vs basic XP/levels\n'
     '  • Android APK (BudgetPH is primarily PWA)\n\n'
     'Paluwagan is SmartSpend\'s highest-priority post-capstone feature. It is on the '
     'roadmap — deprioritized during Capstone 2 to focus on the AI agentic system '
     'and FHS, which are the primary academic contributions.'),

    (18, 'Djaunathan', 'MED',
     'What are the limitations of SmartSpend?',
     'Honest, scoped limitations:\n\n'
     '1. Android-only: iOS version is out of scope for Capstone 2. Flutter supports '
     'iOS — a port is planned post-capstone.\n\n'
     '2. No direct bank integration: BSP Open Finance API is still in early pilot '
     '(UnionBank only as of July 2025). Manual import via batch screenshots bridges this gap.\n\n'
     '3. AI is not infallible: The app includes human-in-the-loop: confidence score display, '
     'review screen for batch imports, and shake-to-undo within 60 seconds.\n\n'
     '4. No paluwagan tracker: Planned post-capstone. Architecture supports it.\n\n'
     '5. API dependency: AI features require internet. Core features are fully offline.\n\n'
     '6. Not professional financial advice: SmartSpend provides general financial '
     'information for educational purposes only — consistent with Mint, YNAB, Cleo globally.'),

    (19, 'Djaunathan', 'MED',
     'Why did you scope out iOS? Why not build for both platforms?',
     'Practical decision for a 3-person capstone team:\n\n'
     '1. Team capacity: 3 developers with a one-semester timeline. iOS requires a Mac '
     'for building and an Apple Developer account ($99/year). Neither was available.\n\n'
     '2. Target population: Our respondents — parents 35–55 and young professionals '
     '21–35 in La Union — predominantly use Android. PH Android market share is ~85%.\n\n'
     '3. Flutter architecture: The codebase is already cross-platform. Adding iOS '
     'is a configuration and testing task, not a rewrite. It is the first item on '
     'the post-capstone roadmap.\n\n'
     'Scoping decisions are part of good project management, not a weakness.'),

    (20, 'Any', 'MED',
     'What makes SmartSpend uniquely Filipino?',
     'Seven specifically Filipino design decisions:\n\n'
     '1. Taglish AI: Understands "nag-gastos ako ng 85 sa Jollibee" — Filipino-English '
     'mixed input, trained into the system prompt with 12 Taglish trigger rules.\n\n'
     '2. PH financial knowledge: SSS, PhilHealth, Pag-IBIG, BIR TRAIN Law, '
     '13th month pay, 11.11 sales — all in the AI knowledge base.\n\n'
     '3. PH-specific merchants: Jollibee, GrabFood, ShopeePayLater, Palengke, siomai — '
     'auto-categorized correctly.\n\n'
     '4. 20+ PH banks + 5 e-wallets in the wallet system.\n\n'
     '5. 40+ PH platforms in Batch Screenshots: GCash, Maya, BPI, BDO, Shopee, Lazada.\n\n'
     '6. 8 Filipino account types: Student, Working Student, Freelancer, OFW context.\n\n'
     '7. Financial inclusion design: Works fully offline — no bank account needed, '
     'supporting BSP\'s goal of reaching unbanked Filipinos.'),

    (21, 'Any', 'LOW',
     'What is the FMS (Financial Management Score)? How is it different from FHS?',
     'They measure different things — they are complementary, not redundant.\n\n'
     'FHS (Financial Health Score) measures financial OUTCOMES:\n'
     '  "Are you saving 20%? Staying within budget? Controlling overspend?"\n'
     '  → Measures the result of your financial behavior.\n\n'
     'FMS (Financial Management Score) measures management BEHAVIOR:\n'
     '  "Are you logging consistently? Are your entries complete? Are you engaging?"\n'
     '  → Measures the discipline of using the app correctly.\n\n'
     'A user can have a high FHS (great financial outcomes) and a low FMS '
     '(rarely opens the app — entered all data in one session at month end). '
     'The two scores together give a complete picture: health AND discipline.\n\n'
     'Grounded in Financial Health Network (2026) and Elenvo AI (2026) research, '
     'which explicitly distinguish health outcomes from management behaviors.'),

    (22, 'Any', 'LOW',
     'What are your post-capstone plans for SmartSpend?',
     'Four priority items after the Final Defense:\n\n'
     '1. Paluwagan tracker — highest priority. Uses existing debt + recurring '
     'infrastructure with a rotating-round tracking layer.\n\n'
     '2. Backend proxy via Firebase Cloud Function — moves the AI API key '
     'server-side for production-grade security.\n\n'
     '3. Google Play Store submission — APK is signed and release builds are '
     'available (arm64-v8a, armeabi-v7a, x86_64).\n\n'
     '4. Family wallet sharing + 15th/30th payday cycle awareness.\n\n'
     'The codebase is production-quality — it was built to be maintainable '
     'beyond the capstone. Version 2.9.11, GitHub: github.com/Zushikina-kun/smartspend-app'),
]

for num, owner, difficulty, question, answer in qa_data:
    diff_color = {'HIGH': MAROON_HEX, 'MED': BLUE_HEX, 'LOW': GREEN_HEX}[difficulty]
    diff_label = {'HIGH': '🔴 HIGH', 'MED': '🟡 MED', 'LOW': '🟢 LOW'}[difficulty]

    q_tbl = doc.add_table(rows=1, cols=3)
    _set_tbl_width(q_tbl, TW)
    _no_borders(q_tbl)
    _set_cell_bg(q_tbl.cell(0, 0), diff_color)
    _set_cell_bg(q_tbl.cell(0, 1), diff_color)
    _set_cell_bg(q_tbl.cell(0, 2), diff_color)
    _set_col_width(q_tbl.cell(0, 0), 600)
    _set_col_width(q_tbl.cell(0, 1), 7824)
    _set_col_width(q_tbl.cell(0, 2), 1800)
    _cell_para(q_tbl.cell(0, 0), f'Q{num:02d}', bold=True, color=WHITE, size=11,
               align=WD_ALIGN_PARAGRAPH.CENTER, before=5, after=5)
    _cell_para(q_tbl.cell(0, 1), question, bold=True, color=WHITE, size=10, before=5, after=5)
    _cell_para(q_tbl.cell(0, 2), f'{diff_label}  |  {owner}', color=WHITE, size=9,
               align=WD_ALIGN_PARAGRAPH.RIGHT, before=5, after=5)

    a_tbl = doc.add_table(rows=1, cols=1)
    _set_tbl_width(a_tbl, TW)
    _set_borders(a_tbl, 'CCCCCC', 4)
    _set_cell_bg(a_tbl.cell(0, 0), LIGHT_BLUE if difficulty == 'HIGH' else
                                   LIGHT_AMB if difficulty == 'MED' else LIGHT_GRN)
    _cell_para(a_tbl.cell(0, 0), answer, size=9, color=DARK, before=6, after=6)
    doc.add_paragraph().paragraph_format.space_after = Pt(4)

# ═════════════════════════════════════════════════════════════════════════════
# SECTION E — WEAK SPOTS BRIEFING
# ═════════════════════════════════════════════════════════════════════════════
doc.add_page_break()
section_banner('E.  WEAK SPOTS BRIEFING',
               'These are the spots where panels push back hardest. Know these cold.',
               AMBER_HEX)

_para(doc,
    'Based on the project scope, these are the 6 areas most likely to receive '
    'hard follow-up questions during the Pre-Final Defense. Each weak spot includes '
    'the likely attack and the correct deflection.',
    size=9.5, before=0, after=8, italic=True, color=GREY)

weak_spots = [
    ('WEAK SPOT 1 — SUS Not Yet Done',
     'Panel Attack: "You\'re presenting Objective 3 conclusions, but you haven\'t '
     'administered the SUS yet. How can you conclude anything about usability?"',
     'Correct Deflection:',
     'The Pre-Final Defense evaluates the system and methodology — not final results. '
     'Slide 13 explicitly marks the SUS result as a placeholder. We are presenting '
     'the validated instrument, sampling plan (30 purposive respondents), and '
     'administration protocol. The SUS will be administered in Week 7 as scheduled. '
     'The target (SUS ≥ 80) is based on the instrument\'s established benchmarks '
     '(Bangor et al., 2009) — it is a standard, not a guess. This is the same approach '
     'used in every developmental capstone study.',
     LIGHT_RED),

    ('WEAK SPOT 2 — Only 30 Respondents',
     'Panel Attack: "30 respondents is too small. How can you generalize to all Filipinos?"',
     'Correct Deflection:',
     'We are not generalizing to all Filipinos. This is a purposive sample study — '
     'the 30 respondents represent the specific target population: parents 35–55 and '
     'young professionals 21–35 in La Union. '
     'Nielsen\'s Law (1993) shows 5 users find 85% of usability issues. '
     'Bangor et al. (2009) validated SUS specifically for small purposive samples. '
     'This sampling approach is academically appropriate for an exploratory developmental '
     'capstone study. Further generalization would require a separate large-scale study — '
     'which is explicitly noted as a post-capstone recommendation.',
     LIGHT_RED),

    ('WEAK SPOT 3 — AI Errors / Accuracy',
     'Panel Attack: "What if the AI misclassifies an expense? How do you handle AI errors?"',
     'Correct Deflection:',
     'SmartSpend is designed with human-in-the-loop at every point:\n'
     '1. Confidence threshold: Low-confidence AI responses trigger a review screen.\n'
     '2. Batch import review: All batch screenshot results show a review screen '
     'before any data is saved — user confirms each item.\n'
     '3. Shake-to-undo: Within 60 seconds of any AI action, shaking the phone '
     'reverses the change.\n'
     '4. Edit anytime: Every logged expense, budget, and goal is fully editable.\n'
     '5. Manual fallback: The full manual entry form is always available — AI is '
     'a convenience layer, not a requirement.\n\n'
     'No AI system is infallible. SmartSpend is designed so that AI errors '
     'are easy to catch and reverse.',
     LIGHT_AMB),

    ('WEAK SPOT 4 — No Bank Integration',
     'Panel Attack: "Why didn\'t you integrate with actual bank APIs? That would make it more useful."',
     'Correct Deflection:',
     'Philippine Open Banking is still in early pilot stages. As of July 2025, only '
     'UnionBank has a publicly accessible API — and it is not freely available to '
     'third-party developers for academic projects.\n\n'
     'BSP\'s Open Finance Framework (Circular 1105) is still being implemented. '
     'Major PH banks (BPI, BDO, Metrobank) have not yet published developer APIs.\n\n'
     'SmartSpend\'s Batch Screenshot Import (40+ platforms) bridges this gap — '
     'users can import from GCash, BPI, Maya, and 37 other platforms by sharing '
     'a screenshot. This is the practical, privacy-preserving alternative available today.',
     LIGHT_AMB),

    ('WEAK SPOT 5 — Free AI Tier Reliability',
     'Panel Attack: "Your free-tier APIs could be discontinued anytime. '
     'Is this system viable long-term?"',
     'Correct Deflection:',
     'For a capstone academic study: yes, completely viable. The 30-respondent '
     'SUS evaluation will generate far fewer than the daily free limits '
     '(60 messages/user/day × 30 users = 1,800 messages max — well within '
     'Gemini\'s ~1,500 + Groq\'s ~16,400 combined free tier).\n\n'
     'For long-term production: the post-capstone roadmap includes a Firebase '
     'Cloud Function backend proxy, which allows switching to paid tiers '
     '(Gemini Pay-as-you-go: $0.075/1M tokens) with zero app-side code changes. '
     'The architecture was designed for this upgrade path.\n\n'
     'Gemini 3.1 Flash-Lite is a Google-maintained model. Groq\'s free tier '
     'has been stable since January 2024. Risk is acknowledged and mitigated.',
     LIGHT_GRN),

    ('WEAK SPOT 6 — Why Two Scores (FHS vs FMS)?',
     'Panel Attack: "FHS and FMS seem to measure the same thing. Isn\'t one redundant?"',
     'Correct Deflection:',
     'They measure completely different dimensions:\n\n'
     'FHS (Financial Health Score) = OUTCOMES. '
     '"Are you actually saving money? Staying within budget? '
     'Your financial results this month."\n\n'
     'FMS (Financial Management Score) = BEHAVIOR. '
     '"Are you using the app correctly? Logging consistently? '
     'Your financial discipline and engagement."\n\n'
     'Counter-example: A user who inputs one big batch import at month end '
     'might have excellent FHS (saved 25%, all budgets on track) but a low FMS '
     '(logged only 1 day of 30, poor consistency). Conversely, someone who logs '
     'every ₱5 transaction but consistently overspends has high FMS, low FHS.\n\n'
     'The separation is grounded in Financial Health Network (2026) research, '
     'which explicitly distinguishes health outcomes from management behaviors. '
     'Both scores together give a complete picture — health AND discipline.',
     LIGHT_GRN),
]

for title, attack, deflection_label, deflection, bg in weak_spots:
    t = doc.add_table(rows=1, cols=1)
    _set_tbl_width(t, TW)
    _no_borders(t)
    _set_cell_bg(t.cell(0, 0), AMBER_HEX)
    _cell_para(t.cell(0, 0), f'  ⚠️  {title}', bold=True, color=WHITE, size=11,
               before=5, after=5)

    b = doc.add_table(rows=1, cols=1)
    _set_tbl_width(b, TW)
    _set_borders(b, 'CCCCCC', 4)
    _set_cell_bg(b.cell(0, 0), bg)
    bc = b.cell(0, 0)
    _cell_para(bc, attack, italic=True, color=RED, size=9.5, before=5, after=3)
    _cell_add(bc, deflection_label, bold=True, color=GREEN, size=9.5, before=3, after=2)
    _cell_add(bc, deflection, color=DARK, size=9, before=1, after=6)
    doc.add_paragraph().paragraph_format.space_after = Pt(4)

# ═════════════════════════════════════════════════════════════════════════════
# SECTION F — QUICK-REFERENCE NUMBERS CARD
# ═════════════════════════════════════════════════════════════════════════════
doc.add_page_break()
section_banner('F.  QUICK-REFERENCE NUMBERS CARD',
               'Print this page. Tape it inside your folder. Glance before entering.',
               BLUE_HEX)

_para(doc,
    'These are the numbers panels commonly test. Know them without thinking.',
    size=9.5, before=0, after=6, italic=True, color=GREY)

numbers = [
    ('Version', '2.9.11'),
    ('Platform', 'Android (Flutter/Dart)'),
    ('Database', 'SQLite v11 — 20 tables'),
    ('AI Agentic Actions', '34'),
    ('AI Providers', '6 (auto-failover, all free tier)'),
    ('Primary AI Model', 'Gemini 3.1 Flash-Lite'),
    ('Daily AI Limit', '60 messages/user/day'),
    ('Screens', '37'),
    ('Services', '26'),
    ('Achievement Badges', '23'),
    ('Daily Quests', '10 rotating'),
    ('Expense Categories', '14 built-in + unlimited custom'),
    ('Screenshot Platforms', '40+'),
    ('PH Banks in DB', '20 banks + 5 e-wallets'),
    ('Currencies Supported', '57'),
    ('Build Size', '44.7 MB (arm64-v8a, obfuscated)'),
    ('FHS Max Score', '100 (4 components × 25 pts)'),
    ('FHS Full Mode Components', 'Savings Rate, Overspend Control, Budget Adherence, Logging Consistency'),
    ('FHS Lightweight Components', 'Spending Restraint, Logging Consistency, Category Balance, Habit Streak'),
    ('FHS Warning Decay', '−5 pts/day, max −15 pts'),
    ('SUS Target', '≥ 80 (Good / Acceptable)'),
    ('Respondents', '30 purposive (20 parents 35–55, 10 young professionals 21–35)'),
    ('GitHub', 'github.com/Zushikina-kun/smartspend-app'),
    ('Group Name', 'Lucid Frame'),
    ('School', 'Lorma Colleges — CCSE, BSIT 4th Year'),
    ('Academic Year', '2026–2027, 1st Semester'),
    ('Adviser', 'Ellen F. Mangaoang, MIT'),
    ('Key Stat — BSP 2025', '50% Filipino adults have formal bank accounts'),
    ('Key Stat — EY 2026', '18% of consumers use AI specifically for budgeting'),
    ('Key Stat — Juniper Research 2026', 'Gamification is empirically linked to increased savings intention in fintech apps (exact % from commercial sources, used as directional reference)'),
]

num_tbl = doc.add_table(rows=len(numbers), cols=2)
_set_tbl_width(num_tbl, TW)
_set_borders(num_tbl, 'CCCCCC', 4)
for ri, (label, value) in enumerate(numbers):
    bg = LGREY if ri % 2 == 0 else 'FFFFFF'
    lc = num_tbl.cell(ri, 0)
    vc = num_tbl.cell(ri, 1)
    _set_col_width(lc, 3600)
    _set_col_width(vc, 6624)
    _set_cell_bg(lc, bg)
    _set_cell_bg(vc, bg)
    _cell_para(lc, label, bold=True, color=MAROON, size=9, before=3, after=3)
    _cell_para(vc, value, color=DARK, size=9, before=3, after=3)

doc.add_paragraph()

info_box(
    '🎯  FINAL NOTE — You built SmartSpend. You know every line of it. The panel does not. '
    'Your job is not to survive the defense — it is to explain your work confidently to people '
    'who are evaluating whether you understand what you built. Answer directly. Own your '
    'scoping decisions. When something is post-capstone, say so without apology. '
    'You have 34 agentic actions, a dual-mode FHS, 40+ screenshot platforms, and a '
    'completely free-tier serverless architecture. That is genuinely impressive work. '
    'Know the logic — not just the memorization. Good luck.',
    bg_hex='FFF3F5', border='5C0E24', color=MAROON, bold=True)

# ── Save ──────────────────────────────────────────────────────────────────────
os.makedirs(OUT.parent, exist_ok=True)
doc.save(str(OUT))
print(f'✓ Saved: {OUT.name}  ({OUT.stat().st_size // 1024} KB)')
print('  Sections:')
print('    A. Overview & Team Roles')
print('    B. Day-of-Defense Checklist')
print('    C. Demo Script (8-9 min with timing cues)')
print('    D. Q&A Drill — 22 Questions (Brix 10, Cyrille 5, Djaunathan 5, Any 2)')
print('    E. Weak Spots Briefing (6 panel attack scenarios)')
print('    F. Quick-Reference Numbers Card (30 key figures)')
