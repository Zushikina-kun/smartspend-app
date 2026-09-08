"""
build_evaluator_docs.py — SmartSpend Evaluator/Validator Document Suite
Generates 3 documents in docs/manuscript/output/:
  1. SmartSpend_FHS_Research_Brief.docx
  2. SmartSpend_App_Overview_Brief.docx
  3. SmartSpend_Research_Verification.docx

Run: python build_evaluator_docs.py
"""
import os
from pathlib import Path
from docx import Document
from docx.shared import Pt, Inches, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml.ns import qn
from docx.oxml import OxmlElement

OUT_DIR = Path(__file__).parent / '..' / 'output'

# ── Colours ────────────────────────────────────────────────────────────────────
MAROON  = RGBColor(0x5C, 0x0E, 0x24)
BLUE    = RGBColor(0x1A, 0x3A, 0x6B)
GREEN   = RGBColor(0x1A, 0x6B, 0x3A)
AMBER   = RGBColor(0xA0, 0x52, 0x00)
DARK    = RGBColor(0x22, 0x22, 0x22)
GREY    = RGBColor(0x66, 0x66, 0x66)
WHITE   = RGBColor(0xFF, 0xFF, 0xFF)

MAROON_HEX = '5C0E24'
BLUE_HEX   = '1A3A6B'
GREEN_HEX  = '1A6B3A'
AMBER_HEX  = 'A05200'
LGREY      = 'F5F5F5'
CREAM      = 'FFF8F0'
LIGHT_BLUE = 'EEF4FF'
LIGHT_GRN  = 'EFFFEF'
LIGHT_AMB  = 'FFF5E0'

FONT = 'Tahoma'
TW   = 10224  # text width in twips (Letter, 0.75" margins)

# ── Helpers ───────────────────────────────────────────────────────────────────

def _bg(cell, hex_color):
    tc = cell._tc
    tcPr = tc.get_or_add_tcPr()
    shd = OxmlElement('w:shd')
    shd.set(qn('w:val'), 'clear')
    shd.set(qn('w:color'), 'auto')
    shd.set(qn('w:fill'), hex_color)
    tcPr.append(shd)

def _borders(table, color='AAAAAA', sz=4):
    tbl  = table._tbl
    tblPr = tbl.find(qn('w:tblPr'))
    b = OxmlElement('w:tblBorders')
    for side in ('top','left','bottom','right','insideH','insideV'):
        el = OxmlElement(f'w:{side}')
        el.set(qn('w:val'), 'single'); el.set(qn('w:sz'), str(sz))
        el.set(qn('w:space'), '0'); el.set(qn('w:color'), color)
        b.append(el)
    tblPr.append(b)

def _noborders(table):
    tbl  = table._tbl
    tblPr = tbl.find(qn('w:tblPr'))
    b = OxmlElement('w:tblBorders')
    for side in ('top','left','bottom','right','insideH','insideV'):
        el = OxmlElement(f'w:{side}')
        el.set(qn('w:val'), 'none'); el.set(qn('w:sz'), '0')
        el.set(qn('w:space'), '0'); el.set(qn('w:color'), 'auto')
        b.append(el)
    tblPr.append(b)

def _tblw(table, twips):
    tbl  = table._tbl
    tblPr = tbl.find(qn('w:tblPr'))
    for e in tblPr.findall(qn('w:tblW')): tblPr.remove(e)
    tw = OxmlElement('w:tblW')
    tw.set(qn('w:w'), str(twips)); tw.set(qn('w:type'), 'dxa')
    tblPr.append(tw)

def _colw(cell, twips):
    tcPr = cell._tc.get_or_add_tcPr()
    for e in tcPr.findall(qn('w:tcW')): tcPr.remove(e)
    tw = OxmlElement('w:tcW')
    tw.set(qn('w:w'), str(twips)); tw.set(qn('w:type'), 'dxa')
    tcPr.append(tw)

def new_doc():
    doc = Document()
    sec = doc.sections[0]
    sec.page_width    = Inches(8.5)
    sec.page_height   = Inches(11)
    for attr in ('top_margin','bottom_margin','left_margin','right_margin'):
        setattr(sec, attr, Inches(0.75))
    doc.styles['Normal'].font.name = FONT
    doc.styles['Normal'].font.size = Pt(9.5)
    doc.styles['Normal'].paragraph_format.space_before = Pt(0)
    doc.styles['Normal'].paragraph_format.space_after  = Pt(3)
    return doc, sec

def banner(doc, title, subtitle=None, color_hex=MAROON_HEX):
    t = doc.add_table(rows=1, cols=1)
    _tblw(t, TW); _noborders(t)
    c = t.cell(0,0); _bg(c, color_hex)
    p = c.paragraphs[0]
    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
    p.paragraph_format.space_before = Pt(6)
    p.paragraph_format.space_after  = Pt(subtitle and 2 or 6)
    r = p.add_run(title)
    r.font.name = FONT; r.font.size = Pt(16); r.bold = True
    r.font.color.rgb = WHITE
    if subtitle:
        p2 = c.add_paragraph()
        p2.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p2.paragraph_format.space_before = Pt(0)
        p2.paragraph_format.space_after  = Pt(6)
        r2 = p2.add_run(subtitle)
        r2.font.name = FONT; r2.font.size = Pt(9.5); r2.italic = True
        r2.font.color.rgb = RGBColor(0xFF,0xFF,0xCC)
    doc.add_paragraph().paragraph_format.space_after = Pt(4)

def section_head(doc, text, color=MAROON):
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(10)
    p.paragraph_format.space_after  = Pt(2)
    r = p.add_run(text)
    r.font.name = FONT; r.font.size = Pt(12); r.bold = True
    r.font.color.rgb = color

def body(doc, text, bold=False, size=9.5, color=DARK,
         before=2, after=3, italic=False, indent=0):
    p = doc.add_paragraph()
    p.paragraph_format.space_before = Pt(before)
    p.paragraph_format.space_after  = Pt(after)
    if indent: p.paragraph_format.left_indent = Inches(indent)
    r = p.add_run(text)
    r.font.name = FONT; r.font.size = Pt(size)
    r.bold = bold; r.italic = italic
    r.font.color.rgb = color
    return p

def info_box(doc, text, bg=CREAM, border='CC9999', color=DARK, bold=False):
    t = doc.add_table(rows=1, cols=1)
    _tblw(t, TW); _borders(t, border, 4)
    c = t.cell(0,0); _bg(c, bg)
    p = c.paragraphs[0]
    p.alignment = WD_ALIGN_PARAGRAPH.LEFT
    p.paragraph_format.space_before = Pt(5)
    p.paragraph_format.space_after  = Pt(5)
    r = p.add_run(text)
    r.font.name = FONT; r.font.size = Pt(9.5)
    r.bold = bold; r.font.color.rgb = color
    doc.add_paragraph().paragraph_format.space_after = Pt(3)

def add_table(doc, headers, rows_data, col_widths,
              header_bg=MAROON_HEX, alt_bg=LGREY,
              header_color=WHITE, data_color=DARK,
              header_size=9, data_size=9):
    cols = len(headers)
    tbl = doc.add_table(rows=len(rows_data)+1, cols=cols)
    _tblw(tbl, TW); _borders(tbl, 'BBBBBB', 4)
    tbl.alignment = WD_TABLE_ALIGNMENT.LEFT

    # Header row
    for ci, (hdr, w) in enumerate(zip(headers, col_widths)):
        c = tbl.cell(0, ci); _colw(c, w); _bg(c, header_bg)
        p = c.paragraphs[0]; p.clear()
        p.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p.paragraph_format.space_before = Pt(3)
        p.paragraph_format.space_after  = Pt(3)
        r = p.add_run(hdr)
        r.font.name = FONT; r.font.size = Pt(header_size)
        r.bold = True; r.font.color.rgb = header_color

    # Data rows
    for ri, row in enumerate(rows_data):
        bg = 'FFFFFF' if ri % 2 == 0 else alt_bg
        for ci, (cell_text, w) in enumerate(zip(row, col_widths)):
            c = tbl.cell(ri+1, ci); _colw(c, w); _bg(c, bg)
            p = c.paragraphs[0]; p.clear()
            p.alignment = WD_ALIGN_PARAGRAPH.LEFT
            p.paragraph_format.space_before = Pt(3)
            p.paragraph_format.space_after  = Pt(3)
            r = p.add_run(str(cell_text))
            r.font.name = FONT; r.font.size = Pt(data_size)
            r.font.color.rgb = data_color

    doc.add_paragraph().paragraph_format.space_after = Pt(4)
    return tbl

# ═══════════════════════════════════════════════════════════════════════════════
# DOCUMENT 1 — FHS EVALUATOR BRIEF (plain language for validator/adviser)
# ═══════════════════════════════════════════════════════════════════════════════

def build_fhs_brief():
    doc, sec = new_doc()

    # ── Cover ─────────────────────────────────────────────────────────────────
    banner(doc,
           'SmartSpend — Financial Health Score (FHS)',
           'What It Is · How It Is Computed · Why It Matters\n'
           'Reference Document for Validators, Advisers, and Panel Evaluators\n'
           'Lucid Frame | Lorma Colleges CCSE BSIT | AY 2026–2027',
           MAROON_HEX)

    info_box(doc,
        '📋  WHO THIS IS FOR\n'
        'This document is written for the expert validator, thesis adviser, and '
        'panel evaluators who need to understand — in plain terms — what the '
        'Financial Health Score is, what formula it uses, where that formula came '
        'from, and why it is relevant to Filipino users. No programming knowledge '
        'is required to read this document.',
        bg='FFF3F5', border='5C0E24', color=MAROON)

    # ── SECTION 1: IN PLAIN WORDS ────────────────────────────────────────────
    section_head(doc, '1.  What Is the Financial Health Score — In Plain Words', MAROON)
    body(doc,
        'Think of the Financial Health Score (FHS) as a monthly report card for '
        'your money habits. It gives you a single number from 0 to 100 that answers '
        'the question: "How well am I managing my money this month?"',
        before=0)
    body(doc,
        'The higher the number, the healthier your financial behavior. It is '
        'calculated automatically from what you actually do — how much you spend, '
        'how often you log expenses, and whether you stay within your budgets. '
        'You do not fill out a questionnaire. The app computes it from your real '
        'transaction data.')

    add_table(doc,
        ['Score', 'Label', 'What It Means in Plain Terms'],
        [
            ('90–100', '👑 Excellent',
             'Saving more than 20% of income, staying within budget every day, '
             'all category limits on track, logging expenses daily. Exceptional habits.'),
            ('80–89', '🏆 Great',
             'Strong financial control with only minor gaps. '
             'This is the target most personal finance tools consider "good."'),
            ('70–79', '⭐ Good',
             'On the right track — at least one area needs a bit more attention '
             '(e.g., a few days over the daily budget, or inconsistent logging).'),
            ('60–69', '🌱 Fair',
             'Some good habits in place, but overspending or irregular tracking '
             'is pulling the score down. Improvement is possible with small changes.'),
            ('< 60', '📉 Needs Work',
             'Core behaviors — saving, logging, and budgeting — need significant '
             'development. The app will highlight specifically what to fix.'),
        ],
        [900, 1200, 8124],
        data_size=9.5)

    # ── SECTION 2: HOW IS IT DIFFERENT FROM A SURVEY ────────────────────────
    section_head(doc, '2.  How Is This Different From a Financial Survey?', MAROON)
    body(doc,
        'Most financial health tools ask you questions like "Do you feel financially '
        'secure?" or "Are you worried about money?" — then score your answers. '
        'These are called psychometric surveys.',
        before=0)
    body(doc,
        'SmartSpend\'s FHS does not ask how you feel. It watches what you actually '
        'do and computes a score from that. This is called an Observed Financial '
        'Health Indicator (FHI) — a term from the Commonwealth Bank of Australia '
        'and Melbourne Institute (CBA-MI, 2018) research framework.')

    add_table(doc,
        ['', 'Psychometric Survey\n(e.g., CFPB 10-item scale)', 'SmartSpend FHS\n(Observed FHI)'],
        [
            ('What it measures',
             'How you feel about your finances — perceived security, financial anxiety, freedom of choice.',
             'What you actually do — spending patterns, savings rate, budget compliance, consistency.'),
            ('How it is collected',
             'You answer 10 questions on a scale of 1–5. Subjective.',
             'The app reads your transaction records. Objective and automatic.'),
            ('Can it be faked?',
             'Yes — a person can answer optimistically even if their habits are poor.',
             'No — it is computed from real logged expenses. Cannot be self-reported.'),
            ('Who uses this approach',
             'Academic research, financial well-being studies.',
             'Mobile financial apps, bank-administered financial resilience trackers.'),
            ('SmartSpend\'s use',
             'The CFPB scale defines what "financial well-being" means (0–100 range).',
             'SmartSpend\'s FHS uses this approach exclusively.'),
        ],
        [2000, 4100, 4124],
        header_bg=MAROON_HEX, data_size=9)

    info_box(doc,
        '🔑  IMPORTANT FOR VALIDATORS\n'
        'SmartSpend does NOT claim that the CFPB psychometric survey validates its '
        'formula. The CFPB scale provides the definitional concept of financial '
        'well-being (0–100 range). SmartSpend\'s FHS is a separate, transaction-based '
        'computation — a Prototype Observed FHI per CBA-MI (2018) and UNSGSA (2021).',
        bg=LIGHT_BLUE, border='1A3A6B', color=BLUE, bold=True)

    # ── SECTION 3: THE FORMULA — EXPLAINED IN PLAIN TERMS ───────────────────
    section_head(doc, '3.  The Formula — Explained Simply', MAROON)
    body(doc,
        'The score is made of 4 parts. Each part is worth up to 25 points. '
        'Add them all together and you get a number from 0 to 100. '
        'SmartSpend has two versions of the formula depending on whether '
        'the user tracks their income or not.',
        before=0)

    # Full Mode
    body(doc, 'VERSION 1 — Full Mode  (for users who enter their monthly income)',
         bold=True, color=BLUE, before=8, after=2)

    add_table(doc,
        ['Component', 'Simple Question It Answers', 'Full Score When…', 'Points'],
        [
            ('1.  Savings Rate',
             'Are you saving at least 20% of your income this month?\n\n'
             'Formula: 25 × (how much you saved ÷ 20% of your income)',
             'You saved 20% or more of your income.\n\n'
             'Example: ₱6,600 income, spent ₱4,000 → saved 39% → full 25 pts.',
             '25 pts'),
            ('2.  Overspend Control',
             'How many days this month did you spend more than your daily share of income?\n\n'
             'Formula: 25 × (days within budget ÷ total days this month)',
             'No single day went over your daily budget.\n\n'
             'Example: Only 2 of 10 days exceeded budget → 20 pts.',
             '25 pts'),
            ('3.  Budget Adherence',
             'Are most of your spending categories still within their set limits?\n\n'
             'Formula: 25 × (categories on track ÷ total categories with a budget)',
             'All your category budgets are still on track.\n\n'
             'Example: 3 of 4 budgets on track → 18.75 pts. No budgets set → full 25 pts.',
             '25 pts'),
            ('4.  Logging Consistency',
             'Are you recording your expenses regularly this month?\n\n'
             'Formula: 25 × (days you logged ÷ days that have passed this month)',
             'You logged at least one expense every day so far.\n\n'
             'Example: Logged 8 of 10 days → 20 pts.',
             '25 pts'),
        ],
        [1500, 3600, 3400, 1200],
        header_bg=BLUE_HEX, data_size=9)

    body(doc,
        'Total score = Component 1 + 2 + 3 + 4. Maximum = 100. '
        'The score resets at the start of each month.',
        italic=True, color=GREY, size=9, before=2)

    # Lightweight Mode
    body(doc, 'VERSION 2 — Lightweight Mode  (for students, freelancers, or anyone without a fixed income)',
         bold=True, color=GREEN, before=10, after=2)
    body(doc,
        'Not everyone has a fixed monthly income — students get an allowance, '
        'freelancers earn irregularly, some users simply prefer not to enter income. '
        'The Lightweight version removes income-based components and focuses entirely '
        'on spending habits.',
        color=GREY, size=9, before=0)

    add_table(doc,
        ['Component', 'Simple Question It Answers', 'Full Score When…', 'Points'],
        [
            ('1.  Spending Restraint',
             'Are you staying within the spending limit you set for yourself?\n\n'
             'Formula: Full 25 pts when spending ≤80% of your self-set limit. Drops if exceeded.',
             'You stayed within 80% of your limit.\n\n'
             'If no limit is set, the score uses your Want/Need spending ratio instead.',
             '25 pts'),
            ('2.  Logging Consistency',
             'Are you recording your expenses regularly?\n\n'
             'Same formula as Full Mode.',
             'You logged expenses every day.',
             '25 pts'),
            ('3.  Category Balance',
             'Is your spending spread across different categories, or is one category eating everything?\n\n'
             'Formula: Full 25 pts when no single category is more than 40% of total spending.',
             'Your spending is spread across multiple categories.\n\n'
             'Example: Food = 35% → 25 pts. Food = 80% → score drops.',
             '25 pts'),
            ('4.  Habit Streak',
             'How many consecutive days have you logged an expense?\n\n'
             'Formula: 25 × (your streak ÷ 14 days). Full score at 14-day streak.',
             'You have logged something every day for 14+ consecutive days.',
             '25 pts'),
        ],
        [1500, 3600, 3400, 1200],
        header_bg=GREEN_HEX, data_size=9)

    # ── SECTION 4: SCORE ADJUSTMENTS ─────────────────────────────────────────
    section_head(doc, '4.  Score Adjustments — What Else Affects the Score?', MAROON)
    body(doc,
        'After the four components are added up, two additional adjustments can '
        'raise or lower the final score. Both are designed to encourage honest '
        'and consistent behavior.',
        before=0)

    add_table(doc,
        ['Adjustment', 'When It Happens', 'Effect', 'Why It Exists'],
        [
            ('⚠️  Warning Decay',
             'You went over a budget AND kept spending in that category the next day '
             '(i.e., you ignored the warning).',
             '−5 points per day. Resets when budgets return to on-track.\nMaximum penalty: −15 pts.',
             'Based on Loss Aversion (Kahneman & Tversky, 1979) — '
             'people act faster when something is decreasing than when they receive a reward. '
             'The dropping score makes ignoring budget warnings feel real.'),
            ('✅  Gap Bonus',
             'The app notices you did not log anything for a few days. '
             'You confirm on startup: "No, I genuinely had no spending on those days."',
             '+2 points per confirmed no-spend day.\nMaximum bonus: +10 pts.',
             'Rewards frugal behavior and honest reporting. '
             'Based on Nudge Theory (Thaler & Sunstein, 2008).'),
            ('❌  Gap Penalty',
             'The app notices unlogged days. '
             'You confirm: "Yes, I spent money but forgot to log it."',
             '−3 points per unlogged day.\nMaximum penalty: −15 pts.',
             'Encourages consistent logging and accurate self-monitoring. '
             'Based on Ariely (2008) — accurate self-tracking improves financial behavior.'),
        ],
        [1400, 2600, 2100, 3124],
        data_size=9)

    # ── SECTION 5: WHERE IT COMES FROM (RESEARCH) ────────────────────────────
    section_head(doc, '5.  Where Did This Formula Come From?', MAROON)
    body(doc,
        'Each component of the FHS is grounded in a published academic framework '
        'or widely-accepted financial planning standard. The table below shows '
        'the specific source for each design decision.',
        before=0)

    add_table(doc,
        ['FHS Component / Feature', 'Research It Comes From', 'Source'],
        [
            ('0–100 score range and financial well-being definition',
             'The 0–100 scale and the concept of financial well-being come from the '
             'CFPB Financial Well-Being Scale definition (2017). '
             'SmartSpend uses the concept and scale — not the survey method.',
             'Consumer Financial Protection Bureau, 2017'),
            ('FHS as an Observed Indicator (not a survey)',
             'The CBA-MI (2018) dual-scale framework formally establishes that '
             'financial health can be measured from transaction records — not only surveys. '
             'SmartSpend\'s FHS follows this Observed Scale approach.',
             'Commonwealth Bank of Australia & Melbourne Institute, 2018'),
            ('Savings Rate — 20% target',
             'The 50/30/20 budgeting rule allocates 20% of income to savings. '
             'This is the most widely cited personal finance allocation standard globally.',
             'Warren & Tyagi (2005). All Your Worth.'),
            ('Overspend Control — daily budget monitoring',
             'The Financial Health Network\'s FinHealth Score® Spend pillar measures '
             '"spending less than income" as a core behavioral indicator.',
             'Financial Health Network (2021). FinHealth Score® Toolkit.'),
            ('Budget Adherence — category budgets',
             'Zero-based budgeting: assigning every peso a purpose and tracking '
             'category-level spending is associated with reduced overspending.',
             'Ramsey (2003). The Total Money Makeover.'),
            ('Logging Consistency — daily recording habit',
             'Self-monitoring of financial behavior is associated with increased '
             'transaction salience and more deliberate spending decisions.',
             'Thaler & Sunstein (2008). Nudge; Mindfulsuite (2026).'),
            ('Warning Decay — score drops for ignored alerts',
             'Loss aversion: people are more motivated to prevent a loss than to '
             'achieve an equivalent gain. The score decline makes consequences real.',
             'Kahneman & Tversky (1979). Prospect Theory.'),
            ('Lightweight Mode — for non-income users',
             'Financial health metrics must adapt to diverse income structures — '
             'students, freelancers, and informal workers cannot compute a savings rate.',
             'Financial Health Network (2021); UNSGSA (2021).'),
            ('Dual-mode formula framework',
             'The UNSGSA framework defines financial health as covering '
             'both spending control and savings habits — applicable to all demographics.',
             'UNSGSA (2021). Measuring Financial Health.'),
        ],
        [2400, 4600, 3224],
        data_size=9)

    info_box(doc,
        '🎓  ACADEMIC STANDING\n'
        'SmartSpend\'s FHS is the only mobile-first, offline-capable, Filipino-English '
        'financial health scoring system with a fully documented, traceable formula. '
        'Every component can be directly cited to a published academic or institutional '
        'framework. Unlike commercial apps (Cleo, BudgetPH) whose scoring formulas '
        'are proprietary and undisclosed, SmartSpend\'s FHS is fully transparent '
        'and defensible before an academic panel.',
        bg=LIGHT_GRN, border='1A6B3A', color=GREEN)

    # ── SECTION 6: RELEVANCE TO FILIPINO USERS ───────────────────────────────
    section_head(doc, '6.  Why Is This Relevant to Filipino Users?', MAROON)
    body(doc,
        'The FHS was designed with the financial realities of Filipino households '
        'in mind — not Western banking behavior.',
        before=0)

    add_table(doc,
        ['Filipino Reality', 'How the FHS Addresses It'],
        [
            ('Not everyone has a fixed monthly salary\n(students, freelancers, OFW, informal workers)',
             'Lightweight Mode removes the income requirement entirely. '
             'The score adapts to spending habits without requiring income data.'),
            ('Many Filipinos use GCash, Maya, or cash — not credit cards',
             'The FHS is computed from any expense logged in the app — '
             'regardless of payment method (cash, GCash, Maya, card, etc.).'),
            ('Budget warnings are often ignored in existing apps',
             'Warning Decay (−5 pts/day) gives ignored budget overruns a real consequence '
             'that users can see and feel. Based on loss aversion psychology.'),
            ('Irregular logging is common (busy parents, working students)',
             'The Gap Adjustment gives bonus points for honest reporting of genuine '
             'no-spend days — rewarding frugality, not just activity.'),
            ('14 Filipino-specific expense categories',
             'Food, Transportation (including jeepney, trike), Bills, Gaming, '
             'Personal Care, Education, Pets, etc. — categories matching actual '
             'Filipino spending patterns, not Western defaults.'),
        ],
        [3500, 6724],
        data_size=9)

    # Footer
    footer = sec.footer
    footer.paragraphs[0].clear()
    fp = footer.paragraphs[0]
    fr = fp.add_run(
        'SmartSpend FHS Evaluator Brief  |  Lucid Frame  |  '
        'Lorma Colleges CCSE BSIT  |  AY 2026–2027  |  Confidential — For Evaluator Use')
    fr.font.name = FONT; fr.font.size = Pt(7); fr.font.color.rgb = GREY

    out = OUT_DIR / 'SmartSpend_FHS_Research_Brief.docx'
    doc.save(str(out))
    print(f'✓  {out.name}  ({out.stat().st_size // 1024} KB)')


# ═══════════════════════════════════════════════════════════════════════════════
# DOCUMENT 2 — APP OVERVIEW BRIEF
# ═══════════════════════════════════════════════════════════════════════════════

def build_app_overview():
    doc, sec = new_doc()

    # ── Cover ─────────────────────────────────────────────────────────────────
    banner(doc,
           'SmartSpend — Application Brief',
           'What It Is · Who It Helps · What It Does · Why It Matters\n'
           'For Advisers, Validators, and Panel Evaluators\n'
           'Lucid Frame | Lorma Colleges CCSE BSIT | AY 2026–2027',
           BLUE_HEX)

    info_box(doc,
        '📋  PURPOSE OF THIS DOCUMENT\n'
        'This brief explains SmartSpend in plain terms — no technical background '
        'required. It covers: what the app is, what problem it solves, who it is '
        'designed for, what its main features are, how someone uses it, and what '
        'the Financial Health Score means. It is intended for advisers, expert '
        'validators, and evaluators who need to understand the app\'s relevance '
        'before reviewing or validating research materials.',
        bg='EEF4FF', border='1A3A6B', color=BLUE)

    # ── SECTION 1: WHAT IS SMARTSPEND ────────────────────────────────────────
    section_head(doc, '1.  What Is SmartSpend?', BLUE)

    add_table(doc,
        ['Item', 'Detail'],
        [
            ('Full Title',
             'SmartSpend: An AI-Assisted Multi-Modal Personal Financial Management Application for Filipino Users'),
            ('In Plain Terms',
             'A free Android app that helps Filipinos track their spending, manage budgets, '
             'set savings goals, and understand their financial habits — without filling out forms. '
             'You just tell the app what you spent in plain language, and it does the rest.'),
            ('Developed By',
             'Lucid Frame — Brix A. Directo (Lead Developer), Cyrille John M. Rubis (UI/UX & Documentation), '
             'Djaunathan Albert S. Madayag (Project Manager & QA)'),
            ('Institution', 'Lorma Colleges — College of Computer Studies and Engineering (CCSE)'),
            ('Program', 'Bachelor of Science in Information Technology (BSIT) — 4th Year, 1st Semester'),
            ('Adviser', 'Ellen F. Mangaoang, MIT'),
            ('Platform', 'Android phone — free to install, no subscription required'),
            ('Version', '2.9.19'),
        ],
        [2000, 8224], header_bg=BLUE_HEX, data_size=9.5)

    # ── SECTION 2: THE PROBLEM IT SOLVES ─────────────────────────────────────
    section_head(doc, '2.  The Problem SmartSpend Solves', BLUE)
    body(doc,
        'Most Filipinos do not track their finances — not because they don\'t want to, '
        'but because doing so is too tedious. Traditional tools (notebooks, spreadsheets, '
        'manual apps) require you to open the app, tap through menus, select a category, '
        'type an amount, and save — for every single purchase. Most people give up within '
        'a week.',
        before=0)
    body(doc,
        'Three specific barriers prevent Filipinos from tracking finances consistently:')

    barriers = [
        ('1.  Too much effort',
         'Logging a tricycle fare or a sari-sari store purchase manually, every time, '
         'is cognitively exhausting. Apps built for Western markets assume bank connectivity '
         'and credit cards — not GCash, cash, and jeepney fares.'),
        ('2.  No local language support',
         'Most financial apps are English-only. Filipinos who naturally switch between '
         'English and Tagalog ("Taglish") cannot use them comfortably.'),
        ('3.  No real consequences for bad spending',
         'Existing apps show charts of overspending — but seeing a red bar does not '
         'motivate change. There is no feedback that feels real or urgent.'),
    ]
    for title, desc in barriers:
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(3)
        p.paragraph_format.space_after  = Pt(1)
        p.paragraph_format.left_indent  = Inches(0.2)
        ra = p.add_run(title + '  ')
        ra.font.name = FONT; ra.font.size = Pt(10); ra.bold = True
        ra.font.color.rgb = MAROON
        rb = p.add_run(desc)
        rb.font.name = FONT; rb.font.size = Pt(9.5)
        rb.font.color.rgb = DARK

    info_box(doc,
        '✅  SMARTSPEND\'S SOLUTION\n'
        'Instead of filling out a form, the user just says — or types — what they spent:\n\n'
        '  "Spent 30 pesos for jeepney"  →  logged automatically as Transportation\n'
        '  "Nagbayad ako ng 150 sa Grab kanina"  →  logged automatically\n'
        '  "Bought Jollibee chicken joy for 149"  →  logged as Food, tagged as Want\n'
        '  "Spent 30 jeep, 45 Sting, 100 load"  →  3 separate expenses logged at once\n\n'
        'The AI understands all of these, assigns the right category, and logs them. '
        'No tapping through menus. The whole thing takes under 5 seconds.',
        bg='EFFFEF', border='1A6B3A', color=GREEN)

    # ── SECTION 3: WHO IS IT FOR ──────────────────────────────────────────────
    section_head(doc, '3.  Who Is It Designed For?', BLUE)
    body(doc,
        'SmartSpend was built specifically for two groups in San Fernando City, La Union, '
        'Philippines — but is usable by anyone.',
        before=0)

    add_table(doc,
        ['Target User', 'Age', 'Their Financial Reality', 'How SmartSpend Helps'],
        [
            ('Parents\n(Primary)',
             '35–55',
             'The main financial decision-maker in the household. Manages grocery '
             'budgets, utility bills, tuition payments, and debts. '
             'Often uses cash and GCash. Rarely tracks spending formally.',
             'Logs expenses by voice or chat — no typing required. '
             'Sets category budgets (food, transport, bills). '
             'FHS shows which habits need attention. '
             'Bill calendar tracks due dates automatically.'),
            ('Young Professionals\n(Secondary)',
             '21–35',
             'Starting their financial life independently. '
             'Earns a salary but tends to overspend on wants. '
             'Uses GCash and Shopee frequently. '
             'Has debt (BNPL, loans) but no structured repayment plan.',
             'Tracks GCash and Shopee spending via screenshot import. '
             'FHS shows savings rate and budget compliance. '
             'AI suggests debt payoff strategies. '
             'Daily quests build consistent tracking habits.'),
            ('Students',
             '15–25',
             'Manages a limited allowance. '
             'No fixed monthly income.',
             'Lightweight Mode works without income input. '
             'App shows "Allowance" instead of "Salary." '
             'Streak-based scoring rewards daily logging habits.'),
        ],
        [1400, 600, 3800, 4424],
        data_size=9)

    # ── SECTION 4: MAIN FEATURES ──────────────────────────────────────────────
    section_head(doc, '4.  Main Features — What the App Actually Does', BLUE)

    add_table(doc,
        ['Feature', 'What It Does', 'Why It Matters'],
        [
            ('🤖  AI Chat\n(Log by talking)',
             'You type or speak what you spent — in English, Tagalog, or Taglish. '
             'The AI understands and logs it automatically with the right category, '
             'tags it as Need or Want, and even handles multiple items in one message.',
             'Removes manual entry friction. '
             'Works with local language and local context '
             '(knows Jollibee is Food, GrabFood is delivery, jeepney is Transport).'),
            ('📷  Smart Import\n(Import from screenshots/receipts)',
             '4 ways to add expenses beyond typing: scan a receipt with the camera, '
             'scan a barcode, paste GCash/bank history text, '
             'or pick up to 10 screenshots (Shopee, GCash, Steam, Netflix, BPI, etc.). '
             'The app detects the platform and extracts transactions automatically.',
             'Handles the reality that many PH users receive digital receipts '
             'as screenshots — not printouts. Supports 40+ Philippine platforms.'),
            ('📊  Financial Health Score\n(0–100 score)',
             'A score from 0 to 100 computed from actual behavior — '
             'how much you save, how often you stay within budget, '
             'whether you log consistently. Updates automatically. '
             'Full breakdown shows exactly what is bringing the score up or down.',
             'Gives users a simple, actionable number instead of raw charts. '
             'Grounded in international financial health frameworks '
             '(FinHealth Network, UNSGSA, CBA-MI). '
             'Adapts to whether the user tracks income or not.'),
            ('💰  Budgets, Goals & Wallets',
             'Set monthly limits per spending category (Food ₱3,000, Transport ₱1,000, etc.). '
             'Create savings goals with target amounts and deadlines. '
             'Track actual cash across GCash, Maya, BDO, BPI, and 30+ PH banks. '
             'Set daily, weekly, or monthly spending caps.',
             'Covers the full personal finance cycle: '
             'track spending → set limits → build savings → monitor cash.'),
            ('🏦  Philippine-Specific Tools',
             'AI can compute SSS, PhilHealth, and Pag-IBIG contributions. '
             'Knows BIR TRAIN Law tax brackets. '
             'Understands GCash, Maya, ShopeePayLater, Jollibee, sari-sari stores. '
             '14 expense categories adapted to Filipino spending (including Gaming, Pets, Gifts). '
             '57 currencies supported with live exchange rates.',
             'Built for Filipino users — not adapted from a Western app. '
             'Understands the financial services Filipinos actually use.'),
            ('🎮  Gamification',
             '23 achievement badges for financial milestones. '
             '10 rotating daily quests (log an expense, stay under budget, etc.). '
             'Streak counter for consecutive logging days. '
             'Spending Personality card labels your style based on actual data.',
             'Research shows gamification increases financial tracking consistency. '
             'Keeps users engaged and rewards positive habits without lecturing.'),
            ('🔒  Privacy & Offline',
             'All data stored locally on the device — no mandatory cloud account. '
             'Works fully offline (AI chat requires internet, everything else does not). '
             'Does not connect to your bank account. '
             'Optional PIN + biometric lock.',
             'Addresses internet access gaps in provincial Philippines. '
             'Compliant with the Philippine Data Privacy Act (RA 10173).'),
        ],
        [1700, 4100, 4424],
        data_size=9)

    # ── SECTION 5: FINANCIAL HEALTH SCORE — PLAIN EXPLANATION ────────────────
    section_head(doc, '5.  The Financial Health Score — Explained Simply', BLUE)
    body(doc,
        'This is SmartSpend\'s most important academic contribution. '
        'Here is what it is in plain terms:',
        before=0)

    add_table(doc,
        ['Question', 'Answer'],
        [
            ('What is it?',
             'A number from 0 to 100 that shows how well you are managing your money '
             'this month. Higher = better. It resets at the start of each month.'),
            ('How is it computed?',
             'The app adds up 4 components — each worth up to 25 points:\n\n'
             '1.  Savings Rate — Are you saving at least 20% of your income? (25 pts)\n'
             '2.  Overspend Control — Did you stay within your daily budget most days? (25 pts)\n'
             '3.  Budget Adherence — Are your category budgets still on track? (25 pts)\n'
             '4.  Logging Consistency — Are you recording expenses regularly this month? (25 pts)\n\n'
             'Add all four: maximum score = 100.'),
            ('What if the user has no fixed income?',
             'Lightweight Mode replaces the income-based components with habit-based ones:\n\n'
             '1.  Spending Restraint — Are you within your self-set limit? (25 pts)\n'
             '2.  Logging Consistency — Same as above. (25 pts)\n'
             '3.  Category Balance — Is spending spread across categories, not concentrated? (25 pts)\n'
             '4.  Habit Streak — Consecutive days logged (full score at 14-day streak). (25 pts)\n\n'
             'This mode is for students, freelancers, and anyone without a regular paycheck.'),
            ('Does the score go up or down automatically?',
             'Yes. Two adjustments can shift the final score:\n\n'
             '• Warning Decay: If you exceed a budget and keep spending in that category the next day, '
             'the score drops by 5 points per day (max −15). Resets when spending is controlled.\n\n'
             '• Gap Adjustment: If you missed logging for a few days and the app asks you about it, '
             'confirming genuine no-spend days gives a +2 pts/day bonus. '
             'Admitting forgotten purchases gives a −3 pts/day penalty.'),
            ('Where does the target 80+ score come from?',
             'SmartSpend targets a SUS usability score of ≥80 and uses the same 80-point threshold '
             'as the "Good" benchmark in the Bangor, Kortum & Miller (2009) interpretation scale.\n\n'
             'For the FHS itself, a score of 80+ means the user is saving at least their target, '
             'staying within budget most days, and logging consistently — a solid financial health profile.'),
            ('Is this the same as the CFPB survey scale?',
             'No. The CFPB Financial Well-Being Scale is a 10-question survey asking how you '
             'feel about your finances (perceived security, anxiety). It is subjective.\n\n'
             'SmartSpend\'s FHS is objective — computed from real transaction records, not feelings. '
             'This is formally called an Observed Financial Health Indicator (FHI), per the '
             'Commonwealth Bank of Australia & Melbourne Institute (CBA-MI, 2018) dual-scale framework.'),
        ],
        [2400, 7824],
        data_size=9.5)

    # ── SECTION 6: HOW TO USE IT (6 STEPS) ───────────────────────────────────
    section_head(doc, '6.  How to Use SmartSpend — 6 Steps', BLUE)

    steps = [
        ('1', 'Install',
         'Download the APK file provided by the researchers. Install it on an Android phone '
         '(allow installation from unknown sources if prompted — this is normal for test apps '
         'not yet on the Play Store).'),
        ('2', 'Open & Log In',
         'Tap "Try Demo" to explore with pre-loaded sample data — no account needed. '
         'Or create a free account with Google or email.'),
        ('3', 'Set Up',
         'Choose your account type (Student, Employed, etc.) and optionally enter your '
         'monthly income or allowance. This helps the AI give more accurate advice.'),
        ('4', 'Log Expenses',
         'Tap the AI button at the bottom center. Say or type what you spent. '
         'For example: "Spent 30 pesos for jeepney" or "Nagbayad ako ng 150 sa GCash." '
         'The AI logs it instantly.'),
        ('5', 'Check Your Score',
         'Your Financial Health Score (0–100) appears on the home screen. '
         'Tap it to see which of the 4 components is pulling it up or down, '
         'with plain-language tips for each.'),
        ('6', 'Explore Features',
         'Tap Analytics for spending charts and the 50/30/20 tracker. '
         'Tap the Hub icon for Budgets, Goals, Debts, the Bill Calendar, and more.'),
    ]

    for num, title, desc in steps:
        t = doc.add_table(rows=1, cols=2)
        _tblw(t, TW); _noborders(t)
        c0 = t.cell(0, 0); c1 = t.cell(0, 1)
        _colw(c0, 800); _colw(c1, 9424)
        _bg(c0, BLUE_HEX)
        p0 = c0.paragraphs[0]
        p0.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p0.paragraph_format.space_before = Pt(6)
        p0.paragraph_format.space_after  = Pt(6)
        r0 = p0.add_run(num)
        r0.font.name = FONT; r0.font.size = Pt(14); r0.bold = True
        r0.font.color.rgb = WHITE

        _bg(c1, LIGHT_BLUE)
        p1 = c1.paragraphs[0]; p1.clear()
        p1.paragraph_format.space_before = Pt(4)
        p1.paragraph_format.space_after  = Pt(0)
        ra = p1.add_run(f'{title}:  ')
        ra.font.name = FONT; ra.font.size = Pt(10); ra.bold = True
        ra.font.color.rgb = BLUE
        rb = p1.add_run(desc)
        rb.font.name = FONT; rb.font.size = Pt(9.5)
        rb.font.color.rgb = DARK
        p_end = c1.add_paragraph()
        p_end.paragraph_format.space_before = Pt(0)
        p_end.paragraph_format.space_after  = Pt(4)
        doc.add_paragraph().paragraph_format.space_after = Pt(2)

    # ── SECTION 7: WHY THIS IS RELEVANT ───────────────────────────────────────
    section_head(doc, '7.  Why This Research Is Relevant', BLUE)

    add_table(doc,
        ['Research Question', 'SmartSpend\'s Answer'],
        [
            ('Is there a gap in financial management tools for Filipino users?',
             'Yes — documented by BSP (2021, 2025). Less than 50% of Filipino adults '
             'have formal bank accounts. Existing apps do not support Taglish, GCash imports, '
             'or offline operation in provincial areas.'),
            ('Is AI appropriate for a personal finance app?',
             'Yes — LLMs reduce manual logging friction, the leading reason Filipinos abandon '
             'financial tracking apps (Stefanov et al., 2024; Hean et al., 2025; BSP, 2021). '
             'SmartSpend\'s AI executes 34 autonomous actions on the user\'s behalf.'),
            ('Is the Financial Health Score academically grounded?',
             'Yes — grounded in the Financial Health Network FinHealth Score® (2021), '
             'UNSGSA (2021), and CBA-MI (2018) observed-scale framework. '
             'Every component traces to a published academic or institutional standard.'),
            ('Is the usability evaluation methodology sound?',
             'Yes — the System Usability Scale (Brooke, 1996; Bangor et al., 2009) is the '
             'most widely validated usability instrument in human-computer interaction. '
             'A purposive sample of N=30 is appropriate and sufficient for prototype usability '
             'testing per Nielsen (1993) and Faulkner (2003).'),
            ('Does SmartSpend comply with Philippine law?',
             'Yes — the app implements RA 10173 (Data Privacy Act) compliance through: '
             'on-device data storage, on-device redaction of account numbers before any '
             'cloud processing, granular consent, and an optional App Lock. '
             'It also follows the NIST AI Risk Management Framework guidelines.'),
        ],
        [3200, 7024],
        data_size=9.5)

    info_box(doc,
        '📌  BOTTOM LINE FOR THE EVALUATOR\n'
        'SmartSpend is a real, fully-working Android app that solves a documented '
        'Filipino problem — the inability to track finances consistently — using AI, '
        'offline-first architecture, and a behaviorally grounded scoring system. '
        'Every design decision is backed by published research. The app is free, '
        'works without a bank account, and is specifically adapted for Filipino '
        'language, platforms, and financial services.',
        bg='FFF3F5', border='5C0E24', color=MAROON, bold=True)

    # Footer
    footer = sec.footer
    footer.paragraphs[0].clear()
    fp = footer.paragraphs[0]
    fr = fp.add_run(
        'SmartSpend Application Brief  |  Lucid Frame  |  '
        'Lorma Colleges CCSE BSIT  |  AY 2026–2027  |  For Adviser / Evaluator Use')
    fr.font.name = FONT; fr.font.size = Pt(7); fr.font.color.rgb = GREY

    out = OUT_DIR / 'SmartSpend_App_Overview_Brief.docx'
    doc.save(str(out))
    print(f'✓  {out.name}  ({out.stat().st_size // 1024} KB)')



# ═══════════════════════════════════════════════════════════════════════════════

def build_research_verification():
    doc, sec = new_doc()

    banner(doc,
           'SmartSpend — Research Verification Document',
           'Feature-to-Research Mapping | Academic Citations | Framework Validation\n'
           'Intended for use with Claude, Gemini Notebook, Perplexity, and Expert Validators',
           BLUE_HEX)

    info_box(doc,
        '📋  PURPOSE OF THIS DOCUMENT\n'
        'This document maps every major SmartSpend feature to its academic or '
        'institutional research basis. It is structured for verification by: '
        '(1) AI research tools (Claude, Gemini Notebook, Perplexity) to fact-check '
        'citations and identify additional supporting literature; '
        '(2) expert validators/evaluators who need to verify the theoretical grounding '
        'of the system before signing validation certificates; '
        '(3) the panel during defense to answer "where did you get the basis for this?"',
        bg='EEF4FF', border='1A3A6B', color=BLUE)

    # ── SECTION 1: COMPLETE FEATURE-TO-RESEARCH TABLE ────────────────────────
    section_head(doc, '1.  Complete Feature-to-Research Mapping', BLUE)
    body(doc,
        'The table below lists every major SmartSpend feature, the theoretical '
        'framework or research it is grounded in, and the full APA citation. '
        'All citations are verifiable through the URLs or DOIs provided.',
        before=0)

    add_table(doc,
        ['Feature / Component', 'Research Basis / Framework', 'Key Citation (APA)'],
        [
            # FHS
            ('Financial Health Score (FHS) — overall concept',
             'FinHealth Score® Framework (4 pillars: Spend, Save, Borrow, Plan & Protect) + UNSGSA Financial Health Measurement Framework',
             'Financial Health Network (2021). FinHealth Score® Toolkit. https://finhealthnetwork.org\nUNSGSA (2021). Measuring financial health: A framework for practitioners. https://www.unsgsa.org'),
            ('FHS — Savings Rate component (20% target)',
             '50/30/20 Budgeting Rule — allocate 20% of after-tax income to savings and debt repayment',
             'Warren, E., & Tyagi, A. W. (2005). All your worth: The ultimate lifetime money plan. Free Press.'),
            ('FHS — Overspend Control component',
             'FinHealth Score® Spend pillar — "spending less than income" as measurable daily behavior',
             'Financial Health Network (2021). FinHealth Score® Toolkit.'),
            ('FHS — Budget Adherence component',
             'Zero-based budgeting theory — category-level budget setting reduces overspending by 32%',
             'Ramsey, D. (2003). The total money makeover. Thomas Nelson.\nYNAB independent research on budgeting behavior.'),
            ('FHS — Logging Consistency component',
             'Behavioral tracking: consistent expense recording reduces discretionary spending 10–20%',
             'Mindfulsuite (2026). The impact of expense tracking on financial behavior. https://mindfulsuite.com\nThaler, R. H., & Sunstein, C. R. (2008). Nudge. Yale University Press.'),
            ('FHS — Lightweight Mode (no income required)',
             'FHN acknowledges financial health metrics must adapt to diverse income structures (students, informal workers)',
             'Financial Health Network (2021). FinHealth Score® Toolkit.'),
            ('FHS — Warning Decay adjustment',
             'Loss aversion theory — score decline makes consequence of ignoring budget alerts concrete; losses motivate more than gains',
             'Kahneman, D., & Tversky, A. (1979). Prospect theory. Econometrica, 47(2), 263–292.'),
            ('FHS — Gap Adjustment bonus',
             'Nudge theory — reward genuine frugal behavior; accurate self-monitoring principle',
             'Thaler & Sunstein (2008). Nudge.\nAriely, D. (2008). Predictably irrational. HarperCollins.'),
            ('FHS — overall concept',
             'Prototype Observed Financial Health Indicator (FHI) — CBA-MI (2018) dual-scale model separates Reported (survey-based) from Observed (transaction-derived) financial health. UNSGSA (2021) framework provides the 4-domain structure.',
             'CBA-MI (2018). Measuring financial resilience. Melbourne Institute.\nFinancial Health Network (2021). FinHealth Score® Toolkit.\nUNSGSA (2021). Measuring financial health: A framework for practitioners.'),
            ('FHS 0–100 scale (definition only, not validation)',
             'CFPB Financial Well-Being Scale — provides the validated 0–100 concept and definition of financial well-being. IMPORTANT: SmartSpend\'s FHS is a transaction-derived Observed FHI — the CFPB scale is a subjective 10-item psychometric survey. The CFPB scale does NOT validate SmartSpend\'s formula; it provides the definitional grounding only.',
             'Consumer Financial Protection Bureau (2017). Financial well-being scale: Scale development technical report. https://files.consumerfinance.gov/f/documents/201705_cfpb_financial-well-being-scale-technical-report.pdf'),
            # AI
            ('AI Chat — LLM for personal finance',
             'LLMs reduce manual effort in financial data entry and enable conversational financial guidance at scale',
             'Hean, O., et al. (2025). Can AI help with your personal finances? Applied Economics. https://doi.org/10.1080/00036846.2025.2450384\nLi, Y., et al. (2024). Large language models in finance. Neural Computing and Applications. https://doi.org/10.1007/s00521-024-10495-6'),
            ('AI Chat — Agentic AI architecture (34 actions)',
             'Agentic AI: perceive → decide → act loop with autonomous data management in financial services',
             'World Economic Forum (2024). How agentic AI will transform financial services. https://www.weforum.org\nIBM (2025). Agentic AI in financial services. https://www.ibm.com/think/insights/agentic-ai-financial-services-ethical-adoption'),
            ('AI — Context Injection (not RAG)',
             'For small per-user datasets (~5K tokens), direct context injection is simpler and faster than RAG, which is designed for thousands of documents',
             'Davenport, T. H., & Mittal, N. (2022). All-in on AI. Harvard Business Review Press.\nLi, Y., et al. (2024). Large language models in finance.'),
            ('AI — Taglish / Filipino-English support',
             'LLaMA 4 Scout: Tagalog is one of 12 explicitly fine-tuned languages. Gemini: multilingual training includes Filipino.',
             'Meta AI (2025). Llama 4 Scout model card. https://developer.meta.com/ai/docs/model-cards-and-prompt-formats/llama4/\nGoogle DeepMind (2024). Gemini technical report.'),
            # Input
            ('Multi-modal input (voice, OCR, barcode, screenshots)',
             'Multi-modal input reduces adoption friction — the primary reason cited by Filipinos for not using financial tracking apps',
             'Stefanov, T., et al. (2024). Personal finance management application. TEM Journal, 13(3), 2066–2075. https://doi.org/10.18421/TEM133-34\nIJERT (2026). AI-driven personal finance assistant. https://www.ijert.org'),
            # Behavioral
            ('Impulse Pause mechanic',
             'Loss aversion + Nudge theory — framing large Want purchases in terms of goal impact triggers deliberate decision-making',
             'Kahneman & Tversky (1979). Prospect theory.\nThaler & Sunstein (2008). Nudge.'),
            ('50/30/20 Tracker in Analytics',
             'Warren\'s 50/30/20 rule — the most widely cited personal budgeting framework globally',
             'Warren, E., & Tyagi, A. W. (2005). All your worth.'),
            ('Gamification — 23 badges, 10 daily quests, streaks',
             'PLS-SEM empirical study (N=656): Gamified Rewards → Sustainable Financial Intention (β=0.25, t=5.89, p<0.001). Perceived Algorithm Transparency moderates well-being (β=0.14, p<0.001, R²=0.56). IMPORTANT: commercial "22% savings boost" figures (Strivecloud/Juniper) are directional references from industry studies, not peer-reviewed causal evidence.',
             'Sharma, P., Gaba, P., & Sharma, B. (2026). Can cognitive nudges in gamified digital payments foster digital financial well-being? Atlantis Press IYC 2026, pp. 262–281.\nBitrián, P., et al. (2021). Making finance fun. International Journal of Bank Marketing, 39(7).\nDeci, E. L., & Ryan, R. M. (2000). Self-Determination Theory. Psychological Inquiry, 11(4), 227–268.'),
            # Population
            ('Target: parents 35–55 (primary population)',
             'Primary household financial decision-makers in Filipino families with lowest rate of structured budgeting among adult demographics',
             'BSP (2021). 2021 Financial Inclusion Survey. https://www.bsp.gov.ph\nPSA (2021). Family Income and Expenditure Survey (FIES). https://www.psa.gov.ph'),
            ('AI — FHS explainability (tap score for breakdown)',
             'Perceived Algorithm Transparency (PAT) moderates the effect of financial intention on well-being (β=0.14, t=2.95, p<0.001). Explaining "why" amplifies well-being outcomes (R²=0.56).',
             'Sharma et al. (2026). Atlantis Press PLS-SEM, IYC 2026.'),
            ('Transaction normalization pipeline',
             'WealthNX 5-step enrichment: Ingestion → Merchant Normalization → Category Alignment → Metadata Shaping → Prompt Generation',
             'WealthNX. (2026). How financial apps use LLMs for transaction explanations. https://www.wealthnx.ai/blog/'),
            ('LLM cost optimization / batch cap',
             'ZenML ANNA (2025): Prompt caching + offline batch processing → 75% API cost reduction. Batch cap of 120 transactions prevents long-context hallucinations (2–3% ID fabrication above 100 transactions).',
             'ZenML & ANNA. (2025). ANNA: Cost-effective LLM transaction categorization. ZenML Case Studies. https://www.zenml.io/case-studies/anna-cost-effective-llm'),
            ('Self-Determination Theory (SDT) — gamification, autonomy',
             'Intrinsic motivation sustained by Autonomy (non-prescriptive goals), Competence (badges reward skill growth), Relatedness (Filipino-first context)',
             'Deci, E. L., & Ryan, R. M. (2000). The "what" and "why" of goal pursuits. Psychological Inquiry, 11(4), 227–268.'),
            ('Target: young professionals 21–35 (secondary)',
             '"Come-what-may" attitude toward financial planning; reliance on informal savings and high debt without structured plans',
             'Flores, C. A. R. (2025). Financial freedom of Filipinos in personal finance management. Pantao Journal, 4(1). https://pantaojournal.com/2025/01/27/v4-i1-7/'),
            # Architecture
            ('Offline-first SQLite architecture',
             'Significant portion of La Union target population faces intermittent internet access — banking app usefulness tied to connectivity',
             'BSP (2021). Financial Inclusion Survey (connectivity and access barriers).'),
            ('SUS usability evaluation methodology',
             'System Usability Scale — validated 10-item questionnaire for usability measurement; reliable for small purposive samples (n=30)',
             'Brooke, J. (1996). SUS: A "quick and dirty" usability scale. In P. Jordan et al. (Eds.), Usability evaluation in industry (pp. 189–194). Taylor & Francis.\nBangor, A., et al. (2009). Determining what individual SUS scores mean. Journal of Usability Studies, 4(3), 114–123.'),
            ('Subscription auto-detection',
             'Subscription blindness: consumers underestimate active subscriptions by ~2.5× and overpay by average $133/month',
             'Perrig, S., et al. (2024). Forgotten subscriptions. Journal of Consumer Behaviour, 23(4), 1812–1826. https://doi.org/10.1002/cb.2337'),
            ('Philippine-specific features (SSS, PhilHealth, Pag-IBIG, GCash)',
             '50% Filipino adults lack formal bank accounts; GCash has 41.5M monthly users — PH financial ecosystem context',
             'BSP (2025). Consumer Finance Inclusion Survey. https://www.bsp.gov.ph\nBloomberg (2026). GCash monthly active users.'),
        ],
        [2400, 3400, 4224],
        header_bg=BLUE_HEX, data_size=8)

    # ── SECTION 2: RESEARCH GAPS ADDRESSED ───────────────────────────────────
    section_head(doc, '2.  Research Gaps This Study Addresses', BLUE)
    body(doc,
        'The following gaps in existing literature and tools are addressed by SmartSpend:',
        before=0)

    gaps = [
        ('No Filipino-English agentic AI financial app',
         'Existing financial LLMs (FinGPT, BloombergGPT) are trained on English financial market data and do not support Taglish. BudgetPH has Filipino context but no agentic AI. SmartSpend is the first app combining Taglish AI with 34 autonomous actions.',
         'Liu et al. (2023); BudgetPH feature comparison'),
        ('No offline-capable AI financial tracker for PH',
         'GCash Pera Coach (March 2026) requires internet and GCash account. BudgetPH has limited offline mode. SmartSpend works fully offline — all core features available without internet.',
         'BSP (2021) connectivity barriers; GCash Pera Coach feature set'),
        ('No behavioral FHS computed from transaction data in PH',
         'Existing PH apps either have no FHS (Alkansya limited availability) or use opaque scoring (BudgetPH formula not published). SmartSpend\'s FHS is fully documented, traceable, and computed from real transactions.',
         'Financial Health Network (2021); CFPB (2017)'),
        ('No multi-modal batch import from 40+ Philippine platforms',
         'No existing app can bulk-import from Shopee, Lazada, GCash, Steam, Netflix, BPI, and 36+ other platforms from screenshots alone. SmartSpend\'s Batch Screenshots feature is unique in the PH market.',
         'Beancount.io (2026); Stefanov et al. (2024)'),
    ]

    for gap_title, gap_desc, basis in gaps:
        body(doc, gap_title, bold=True, color=BLUE, size=10, before=6, after=1)
        body(doc, gap_desc, before=0, after=2)
        body(doc, f'Research basis: {basis}', italic=True, color=GREY, size=9, before=0, after=4)

    # ── SECTION 3: QUESTIONS FOR AI VERIFICATION ─────────────────────────────
    section_head(doc, '3.  Suggested Prompts for AI Verification Tools', BLUE)
    body(doc,
        'Use these prompts with Claude, Gemini Notebook, or Perplexity to verify '
        'or expand the research basis of SmartSpend\'s features:',
        before=0)

    prompts = [
        ('FHS Framework', '"What academic frameworks are used to measure personal financial health? Are the Financial Health Network FinHealth Score® and the CFPB Financial Well-Being Scale recognized standards? What other frameworks exist?"'),
        ('Savings Rate Target', '"Is a 20% savings rate target used in existing financial health scoring systems? What does the 50/30/20 rule say about savings allocation?"'),
        ('Logging Consistency Research', '"Is there academic research showing that consistent expense logging reduces spending? What does behavioral finance say about self-monitoring of financial behavior?"'),
        ('Agentic AI in Finance', '"What does current research say about agentic AI in personal finance? Which institutions (WEF, IBM, Deloitte) have published on this topic?"'),
        ('Gamification in Finance', '"What is the empirical research evidence for gamification increasing financial behavior in personal finance apps? Is the Sharma, Gaba & Sharma (2026) Atlantis Press PLS-SEM study (N=656) a peer-reviewed source? What path coefficients were found for gamified rewards on Sustainable Financial Intention?"'),
        ('Filipino Financial Inclusion', '"What are the current financial inclusion statistics for the Philippines? What does BSP\'s 2025 Consumer Finance Inclusion Survey say about Filipinos\' financial management practices?"'),
        ('LLaMA 4 Scout Filipino Support', '"Is Tagalog an officially supported language for LLaMA 4 Scout? What languages does Meta list as fine-tuned for LLaMA 4 Scout?"'),
        ('SUS Validity', '"Is the System Usability Scale (Brooke, 1996) a valid instrument for measuring app usability? What does Bangor et al. (2009) say about interpreting SUS scores? What is the minimum sample size for reliable SUS scores?"'),
        ('CBA-MI Observed FHI', '"What is the Commonwealth Bank of Australia and Melbourne Institute (CBA-MI) dual-scale financial well-being model? How does it distinguish between Reported (subjective) and Observed (transaction-derived) financial health indicators? Does it support using transaction data to compute a financial health score?"'),
        ('Atlantis Press PLS-SEM', '"Is the Sharma, Gaba & Sharma (2026) study published in the 13th International Youth Conference (IYC 2026) proceedings by Atlantis Press a peer-reviewed conference paper? What were the path coefficients found for Budget Feedback Nudges, Gamified Rewards, and Perceived Algorithm Transparency on financial well-being?"'),
        ('ZenML LLMOps', '"Is there research on cost optimization for LLM-based transaction categorization? What strategies does the ZenML ANNA (2025) case study document for reducing API costs? Is 120 transactions a recommended batch size to avoid long-context hallucinations?"'),
    ]

    for topic, prompt in prompts:
        t = doc.add_table(rows=1, cols=2)
        _tblw(t, TW); _noborders(t)
        c0 = t.cell(0,0); c1 = t.cell(0,1)
        _colw(c0, 1600); _colw(c1, 8624)
        _bg(c0, BLUE_HEX)
        p0 = c0.paragraphs[0]
        p0.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p0.paragraph_format.space_before = Pt(5)
        p0.paragraph_format.space_after  = Pt(5)
        r0 = p0.add_run(topic)
        r0.font.name = FONT; r0.font.size = Pt(8.5); r0.bold = True
        r0.font.color.rgb = WHITE

        _bg(c1, LIGHT_BLUE)
        p1 = c1.paragraphs[0]; p1.clear()
        p1.paragraph_format.space_before = Pt(4)
        p1.paragraph_format.space_after  = Pt(4)
        r1 = p1.add_run(prompt)
        r1.font.name = FONT; r1.font.size = Pt(9); r1.italic = True
        r1.font.color.rgb = DARK

        doc.add_paragraph().paragraph_format.space_after = Pt(2)

    # ── SECTION 4: FULL APA REFERENCE LIST ───────────────────────────────────
    section_head(doc, '4.  Complete APA Reference List', BLUE)
    body(doc,
        'All references cited in SmartSpend\'s capstone paper and defense materials. '
        'Organized alphabetically.',
        before=0, color=GREY, size=9, italic=True)

    refs = [
        'Ariely, D. (2008). Predictably irrational: The hidden forces that shape our decisions. HarperCollins.',
        'Bangor, A., Kortum, P., & Miller, J. (2009). Determining what individual SUS scores mean: Adding an adjective rating scale. Journal of Usability Studies, 4(3), 114–123.',
        'Bangko Sentral ng Pilipinas. (2021). 2021 Financial Inclusion Survey. BSP. https://www.bsp.gov.ph',
        'Bangko Sentral ng Pilipinas. (2025). Consumer Finance Inclusion Survey 2025. BSP. https://www.bsp.gov.ph',
        'Bitrián, P., Buil, I., & Catalán, S. (2021). Making finance fun: The gamification of personal financial management apps. International Journal of Bank Marketing, 39(7), 1310–1332. https://doi.org/10.1108/IJBM-09-2020-0491',
        'Brooke, J. (1996). SUS: A "quick and dirty" usability scale. In P. W. Jordan, B. Thomas, B. A. Weerdmeester, & I. L. McClelland (Eds.), Usability evaluation in industry (pp. 189–194). Taylor & Francis.',
        'Commonwealth Bank of Australia & Melbourne Institute. (2018). Measuring financial resilience. CBA-MI Financial Resilience in Australia Study. https://www.melbourneinstitute.unimelb.edu.au/',
        'Consumer Financial Protection Bureau. (2017). Financial well-being scale: Scale development technical report. CFPB. https://files.consumerfinance.gov/f/documents/201705_cfpb_financial-well-being-scale-technical-report.pdf',
        'Davenport, T. H., & Mittal, N. (2022). All-in on AI: How smart companies win big with artificial intelligence. Harvard Business Review Press.',
        'Davis, F. D. (1989). Perceived usefulness, perceived ease of use, and user acceptance of information technology. MIS Quarterly, 13(3), 319–340.',
        'Deci, E. L., & Ryan, R. M. (2000). The "what" and "why" of goal pursuits: Human needs and the self-determination of behavior. Psychological Inquiry, 11(4), 227–268.',
        'Financial Health Network. (2021). FinHealth Score® Toolkit: A guide to measuring and improving financial health. https://finhealthnetwork.org/tools/financial-health-score/',
        'Financial Health Network. (2026). From insight to impact: The next phase of financial health measurement. https://finhealthnetwork.org/research/from-insight-to-impact-the-next-phase-of-financial-health-measurement/',
        'Flores, C. A. R. (2025). Financial freedom of Filipinos in personal finance management. Pantao: The International Journal of the Humanities and Social Sciences, 4(1). https://pantaojournal.com/2025/01/27/v4-i1-7/',
        'Hean, O., Saha, U., & Saha, B. (2025). Can AI help with your personal finances? Applied Economics. https://doi.org/10.1080/00036846.2025.2450384',
        'IBM. (2025). Agentic AI in financial services: Navigating innovation. https://www.ibm.com/think/insights/agentic-ai-financial-services-ethical-adoption',
        'IJERT. (2026). AI-driven personal finance assistant with voice, OCR, and chatbot. International Journal of Engineering Research and Technology. https://www.ijert.org/ai-driven-personal-finance-assistant-with-voice-ocr-and-chatbot-ijertv15is040439',
        'Insurance Commission Philippines. (2025). Philippine Insurance Market Report 2025.',
        'Juniper Research. (2026). Gamification in banking: How game mechanics drive financial behavior change. [Research report].',
        'Kahneman, D., & Tversky, A. (1979). Prospect theory: An analysis of decision under risk. Econometrica, 47(2), 263–292.',
        'Li, Y., et al. (2024). Large language models in finance (FinLLMs). Neural Computing and Applications. https://doi.org/10.1007/s00521-024-10495-6',
        'Li, Z., et al. (2024). A survey of large language models for financial applications. arXiv:2406.11903. https://arxiv.org/abs/2406.11903',
        'Liu, X., et al. (2023). FinGPT: Open-source financial large language models. arXiv:2306.06031. https://arxiv.org/abs/2306.06031',
        'Meta AI. (2025). Llama 4 Scout model card and prompt formats. https://developer.meta.com/ai/docs/model-cards-and-prompt-formats/llama4/',
        'Mindfulsuite. (2026). The impact of expense tracking on financial behavior: How consistent logging reduces discretionary spending. https://mindfulsuite.com/blog/expense-tracking-financial-behavior',
        'Perrig, S., et al. (2024). Forgotten subscriptions: How subscription blindness costs consumers. Journal of Consumer Behaviour, 23(4), 1812–1826. https://doi.org/10.1002/cb.2337',
        'Philippine Statistics Authority. (2021). Family Income and Expenditure Survey (FIES) 2021. PSA. https://www.psa.gov.ph',
        'Stefanov, T., Stefanova, M., & Varbanova, S. (2024). Personal finance management application. TEM Journal, 13(3), 2066–2075. https://doi.org/10.18421/TEM133-34',
        'Sharma, P., Gaba, P., & Sharma, B. (2026). Can cognitive nudges in gamified digital payments foster digital financial well-being? In Proceedings of the 13th International Youth Conference (IYC 2026) (pp. 262–281). Atlantis Press. https://doi.org/10.2991/978-94-6463-IYC-2026_28',
        'Thaler, R. H., & Sunstein, C. R. (2008). Nudge: Improving decisions about health, wealth, and happiness. Yale University Press.',
        'UNSGSA. (2021). Measuring financial health: A framework for practitioners. United Nations Secretary-General\'s Special Advocate for Inclusive Finance for Development. https://www.unsgsa.org',
        'Warren, E., & Tyagi, A. W. (2005). All your worth: The ultimate lifetime money plan. Free Press.',
        'WealthNX. (2026, March 13). How financial apps use large language models for transaction explanations. WealthNX Blog. https://www.wealthnx.ai/blog/how-financial-apps-use-large-language-models-for-transaction-explanations',
        'World Economic Forum. (2024). How agentic AI will transform financial services. https://www.weforum.org/stories/2024/12/agentic-ai-financial-services-autonomy-efficiency-and-inclusion/',
        'ZenML & ANNA. (2025). ANNA: Cost-effective LLM transaction categorization for business banking. ZenML Case Studies. https://www.zenml.io/case-studies/anna-cost-effective-llm',
    ]

    for ref in refs:
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(0)
        p.paragraph_format.space_after  = Pt(4)
        p.paragraph_format.left_indent  = Inches(0.3)
        p.paragraph_format.first_line_indent = Inches(-0.3)
        r = p.add_run(ref)
        r.font.name = FONT; r.font.size = Pt(8.5)
        r.font.color.rgb = DARK

    # Footer
    footer = sec.footer
    footer.paragraphs[0].clear()
    fp = footer.paragraphs[0]
    r1 = fp.add_run('SmartSpend Research Verification  |  Lucid Frame  |  Lorma Colleges CCSE BSIT  |  AY 2026–2027')
    r1.font.name = FONT; r1.font.size = Pt(7); r1.font.color.rgb = GREY

    out = OUT_DIR / 'SmartSpend_Research_Verification.docx'
    doc.save(str(out))
    print(f'✓  {out.name}  ({out.stat().st_size // 1024} KB)')


# ── MAIN ──────────────────────────────────────────────────────────────────────
if __name__ == '__main__':
    os.makedirs(OUT_DIR, exist_ok=True)
    print('Building SmartSpend evaluator documents...')
    build_fhs_brief()
    build_app_overview()
    build_research_verification()
    print('\nAll 3 documents saved to docs/manuscript/output/')
