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
# DOCUMENT 1 — FHS RESEARCH BRIEF
# ═══════════════════════════════════════════════════════════════════════════════

def build_fhs_brief():
    doc, sec = new_doc()

    # Cover banner
    banner(doc,
           'FINANCIAL HEALTH SCORE (FHS)',
           'Research Basis, Formula, and Framework Comparison\n'
           'SmartSpend — Lucid Frame | Lorma Colleges CCSE BSIT | AY 2026–2027',
           MAROON_HEX)

    info_box(doc,
        '📋  PURPOSE OF THIS DOCUMENT\n'
        'This document presents the academic and theoretical basis for SmartSpend\'s '
        'Financial Health Score (FHS). It is intended for use by the panel evaluators, '
        'thesis adviser, and external validators to verify the scientific grounding of '
        'the scoring system before and during the Pre-Final Defense.',
        bg='FFF3F5', border='5C0E24', color=MAROON, bold=False)

    # ── SECTION 1: WHAT IS THE FHS ───────────────────────────────────────────
    section_head(doc, '1.  What is the Financial Health Score (FHS)?', MAROON)
    body(doc,
        'The Financial Health Score is a single numerical indicator (0–100) that '
        'measures how well a user is managing their personal finances based entirely '
        'on their recorded transaction data. It is computed automatically from the '
        'user\'s actual spending, income, and budgeting behavior — no survey or '
        'self-reported answers are required.',
        before=0)
    body(doc,
        'The FHS is displayed on the SmartSpend home screen and updates every time '
        'the user logs an expense. Users can tap the score card to see a full '
        'component-by-component breakdown with plain-language explanations.')

    info_box(doc,
        '💡  KEY DIFFERENTIATOR\n'
        'Unlike the CFPB Financial Well-Being Scale (survey-based, 10 questions) '
        'or Cleo\'s proprietary score, SmartSpend\'s FHS is a behavioral computation — '
        'it derives the score entirely from actual transaction records in the '
        'local SQLite database, making it objective, real-time, and verifiable.',
        bg=LIGHT_BLUE, border='1A3A6B', color=BLUE)

    # ── SECTION 2: EXISTING FRAMEWORKS ──────────────────────────────────────
    section_head(doc, '2.  Existing Frameworks This Is Based On', MAROON)

    add_table(doc,
        ['Framework', 'Publisher', 'Year', 'What It Measures', 'How SmartSpend Uses It'],
        [
            ('FinHealth Score® Toolkit',
             'Financial Health Network',
             '2021 / 2026',
             '4 pillars: Spend, Save, Borrow, Plan & Protect — 8 behavioral indicators. Produces a 0–100 score.',
             'Primary inspiration. Our Savings Rate component maps directly to the Save pillar; Overspend Control maps to the Spend pillar.'),
            ('UNSGSA Financial Health Measurement Framework',
             'United Nations SGSA',
             '2021',
             'Defines financial health as: meeting current obligations, feeling secure, and having freedom of financial choice.',
             'Cited in Chapter 3 as the international framework our FHS is "informed by." The 4-component structure reflects UNSGSA\'s Spend-Save-Plan emphasis.'),
            ('CFPB Financial Well-Being Scale',
             'Consumer Financial Protection Bureau (USA)',
             '2017',
             '10-item survey producing a 0–100 score. Validated across large US samples.',
             'Provides the validated 0–100 scale concept and the definition of financial well-being. SmartSpend replicates the range but uses a transaction-derived Observed FHI — the CFPB scale is a subjective survey instrument and does NOT validate SmartSpend\'s formula directly.'),
            ('CBA-MI Observed Financial Well-Being Scale',
             'Commonwealth Bank of Australia & Melbourne Institute',
             '2018',
             'Dual-scale model: Reported (subjective, survey-based) vs Observed (administrative/transaction-derived) financial health indicators.',
             'SmartSpend\'s FHS is formally a Prototype Observed FHI per this framework — objective, transaction-derived, not a psychometric survey.'),
            ('50/30/20 Budgeting Rule',
             'Warren & Tyagi (2005)',
             '2005',
             'Allocate 50% of income to Needs, 30% to Wants, 20% to Savings. Simple, widely-cited rule.',
             'The 20% savings target is the benchmark for our Savings Rate component (full 25 pts when saving ≥20%).'),
            ('Zero-Based Budgeting',
             'Ramsey (2003)',
             '2003',
             'Assign every peso a purpose. Category budgets are associated with spending restraint.',
             'Basis for the Budget Adherence component — exact percentage reductions are treated as directional, not causal, in our local sample.'),
            ('Behavioral Finance / Nudge Theory',
             'Kahneman & Tversky (1979); Thaler & Sunstein (2008)',
             '1979 / 2008',
             'Loss aversion: losses hurt more than equivalent gains. Nudges guide behavior without restricting choice.',
             'Warning Decay (score drops when budget warnings are ignored) and Gap Adjustment are behavioral nudges grounded in these frameworks.'),
            ('Self-Determination Theory (SDT)',
             'Deci & Ryan (2000)',
             '2000',
             'Intrinsic motivation sustained by Autonomy, Competence, and Relatedness.',
             'Competence → badges/streaks reward growth. Autonomy → non-prescriptive goals. Relatedness → Filipino-first framing.'),
            ('PLS-SEM Empirical Validation',
             'Sharma, Gaba & Sharma (2026) Atlantis Press',
             '2026',
             'N=656 structural model: Nudge β=0.28, Gamification β=0.25 → Financial Intention. PAT moderates well-being (R²=0.56).',
             'Provides empirical path coefficients validating why SmartSpend combines nudges, gamification, and FHS explainability.'),
        ],
        [1700, 1400, 700, 3300, 3124],
        data_size=8.5)

    # ── SECTION 3: FORMULA ───────────────────────────────────────────────────
    section_head(doc, '3.  The SmartSpend FHS Formula', MAROON)
    body(doc,
        'The FHS has two modes depending on whether the user has income/wallet '
        'tracking enabled. Both modes produce a score from 0 to 100.',
        before=0)

    body(doc, '3A.  FULL MODE  (Income Tracking: ON)', bold=True, color=BLUE, before=8)
    body(doc, 'Used when the user has entered their monthly income. Score = 4 components × 25 pts each.',
         color=GREY, size=9, before=0, after=1)

    add_table(doc,
        ['#', 'Component', 'What It Measures', 'Formula', 'Max Pts', 'Research Basis'],
        [
            ('1', 'Savings Rate',
             'Are you saving at least 20% of your income this month?',
             '25 × min(1, savingsRate ÷ 0.20)\nwhere savingsRate = (income − spent) ÷ income',
             '25', 'Warren & Tyagi (2005) — 50/30/20 rule; FHN Save pillar'),
            ('2', 'Overspend Control',
             'How many days this month did your spending stay within the daily budget?',
             '25 × (1 − overDays ÷ activeDays)\noverDays = days where spending > income ÷ daysInMonth',
             '25', 'Financial Health Network (2021) — Spend pillar: "spending less than income"'),
            ('3', 'Budget Adherence',
             'What percentage of your category budgets are on track?',
             '25 × (onBudgetCategories ÷ totalBudgetCategories)\nFull 25 pts if no budgets set',
             '25', 'Ramsey (2003) zero-based budgeting; YNAB research (−32% overspend with category budgets)'),
            ('4', 'Logging Consistency',
             'How regularly are you recording expenses this month?',
             '25 × (loggedDays ÷ activeDays)\nScoped to current month only',
             '25', 'Mindfulsuite (2026): consistent tracking reduces discretionary spending 10–20%; Thaler & Sunstein (2008)'),
        ],
        [300, 1400, 2000, 2100, 600, 3000],
        header_bg=BLUE_HEX, data_size=8.5)

    body(doc, '3B.  LIGHTWEIGHT MODE  (Income Tracking: OFF)', bold=True, color=GREEN, before=8)
    body(doc,
        'Used when the user does not track income — for students, freelancers, or '
        'informal workers without a fixed monthly income. Score adapts to '
        'spending habits only.',
        color=GREY, size=9, before=0, after=1)
    body(doc,
        'Basis: Financial Health Network (2021) explicitly states that financial health '
        'metrics must adapt to diverse income structures. Not all Filipinos have '
        'fixed monthly incomes.',
        italic=True, color=GREY, size=9, before=0)

    add_table(doc,
        ['#', 'Component', 'What It Measures', 'Formula', 'Max Pts', 'Research Basis'],
        [
            ('1', 'Spending Restraint',
             'Are you staying within your self-set spending limit?',
             'Full 25 pts at ≤80% of limit; scales to 0 at 2× limit\nFallback: Want/Need ratio if no limit set',
             '25', 'Ramsey (2003); BSP (2021): budget-setting behavior'),
            ('2', 'Logging Consistency',
             'How regularly are you recording expenses?',
             'Same formula as Full Mode:\n25 × (loggedDays ÷ activeDays)',
             '25', 'Thaler & Sunstein (2008); Mindfulsuite (2026)'),
            ('3', 'Category Balance',
             'Is your spending spread across multiple categories, or concentrated in one?',
             'Full 25 pts when top category ≤40%\nScales to 0 when one category = 100%',
             '25', 'Financial Health Network (2021) — spending diversification'),
            ('4', 'Habit Streak',
             'How many consecutive days have you logged at least one expense?',
             '25 × (streak ÷ 14)\nFull 25 pts at 14-day streak',
             '25', 'Duhigg (2012) — habit loop theory; Bitrián et al. (2021) gamification'),
        ],
        [300, 1400, 2000, 2100, 600, 3000],
        header_bg=GREEN_HEX, data_size=8.5)

    # ── SECTION 4: SCORE ADJUSTMENTS ─────────────────────────────────────────
    section_head(doc, '4.  Score Adjustments (Applied After Component Sum)', MAROON)

    add_table(doc,
        ['Adjustment', 'Trigger', 'Effect', 'Max Impact', 'Research Basis'],
        [
            ('Warning Decay',
             'A budget category is exceeded AND the user continues spending in that category the next day.',
             '−5 points per consecutive day. Resets when all budgets return to on-track.',
             'Max −15 pts (3 days)',
             'Kahneman & Tversky (1979) — loss aversion: score decline makes consequence of ignoring budget alerts concrete and persistent.'),
            ('Gap Adjustment\n(Penalty)',
             'App detects unlogged days on startup. User confirms: "Yes, I spent but forgot to log."',
             '−3 points per unlogged-but-spent day.',
             'Max −15 pts',
             'Ariely (2008) — accurate self-monitoring principle. Incentivizes honest reporting.'),
            ('Gap Adjustment\n(Bonus)',
             'App detects unlogged days on startup. User confirms: "No spending — genuinely clean day."',
             '+2 points per confirmed no-spend day.',
             'Max +10 pts',
             'Thaler & Sunstein (2008) — nudge theory: rewards frugal behavior that would otherwise be penalized for non-logging.'),
        ],
        [1400, 2100, 1900, 1200, 2824],
        header_bg=AMBER_HEX, data_size=8.5)

    # ── SECTION 5: SCORE INTERPRETATION ─────────────────────────────────────
    section_head(doc, '5.  Score Interpretation Scale', MAROON)

    add_table(doc,
        ['Score Range', 'Label', 'Meaning', 'Recommended Action'],
        [
            ('90–100', '👑 Excellent', 'Consistently saving ≥20%, all budgets on track, logging daily.',
             'Maintain habits. Consider increasing savings goal or investing surplus.'),
            ('80–89', '🏆 Great', 'Strong financial control with minor gaps.',
             'Review which component is below 25 pts and target it specifically.'),
            ('70–79', '⭐ Good', 'On the right track, but at least one component needs attention.',
             'Set or review category budgets. Improve daily logging consistency.'),
            ('60–69', '🌱 Fair', 'Some financial management behaviors in place, but significant room to improve.',
             'Focus on the lowest-scoring component first. Use the AI to explain your breakdown.'),
            ('< 60', '📉 Needs Work', 'Core financial behaviors (saving, logging, budgeting) need significant development.',
             'Start with Logging Consistency — log every day for 7 days to see immediate improvement.'),
        ],
        [1400, 1300, 3800, 3224],
        header_bg=MAROON_HEX, data_size=8.5)

    # ── SECTION 6: COMPARISON TABLE ──────────────────────────────────────────
    section_head(doc, '6.  Comparison with Existing Financial Health Scoring Systems', MAROON)

    add_table(doc,
        ['System', 'Publisher', 'Score Range', 'Computation Method',
         'Filipino Context', 'Offline?', 'Free?'],
        [
            ('FinHealth Score®', 'Financial Health Network', '0–100',
             '8 behavioral indicators via survey + linked account data',
             '❌ US-focused', '❌', '❌ Institutional'),
            ('CFPB Financial Well-Being Scale', 'CFPB (USA)', '0–100',
             '10-item self-report survey (subjective)',
             '❌ US-focused', '✅ Paper-based', '✅'),
            ('Cleo Health Score', 'Cleo (UK)', '0–100',
             'Proprietary; savings + bill payment patterns (not disclosed)',
             '❌', '❌', '❌ Subscription'),
            ('BudgetPH Score', 'BudgetPH (PH)', 'Unlisted',
             'Budget adherence + streak tracking (formula not published)',
             '✅ Filipino', '✅ Limited', '✅'),
            ('Alkansya Financial Health', 'Alkansya (PH)', '0–100',
             'Spending patterns + net worth (formula not published)',
             '✅ Filipino', '❌ Web only', '⚠️ Limited'),
            ('SmartSpend FHS', 'Lucid Frame (this study)', '0–100',
             '4-component behavioral formula computed from SQLite transaction data. '
             'Dual-mode (Full/Lightweight). Fully documented and traceable.',
             '✅ Full Taglish AI', '✅ Fully offline', '✅ Always free'),
        ],
        [1800, 1700, 900, 2500, 1100, 800, 800],
        header_bg=MAROON_HEX, data_size=8)

    info_box(doc,
        '🎓  ACADEMIC ADVANTAGE\n'
        'SmartSpend\'s FHS is the only mobile-first, offline-capable, Filipino-English '
        'financial health scoring system with a fully documented, academically-traceable '
        'formula. Unlike Cleo or BudgetPH whose formulas are proprietary, every '
        'component and threshold in SmartSpend\'s FHS can be directly cited to a '
        'published academic framework.',
        bg=LIGHT_GRN, border='1A6B3A', color=GREEN)

    # ── SECTION 7: APA CITATIONS ─────────────────────────────────────────────
    section_head(doc, '7.  APA Citations for the FHS Framework', MAROON)

    citations = [
        'Consumer Financial Protection Bureau. (2017). Financial well-being scale: Scale development technical report. CFPB. https://files.consumerfinance.gov/f/documents/201705_cfpb_financial-well-being-scale-technical-report.pdf',
        'Financial Health Network. (2021). FinHealth Score® Toolkit: A guide to measuring and improving financial health. https://finhealthnetwork.org/tools/financial-health-score/',
        'Financial Health Network. (2026). From insight to impact: The next phase of financial health measurement. https://finhealthnetwork.org/research/from-insight-to-impact-the-next-phase-of-financial-health-measurement/',
        'Kahneman, D., & Tversky, A. (1979). Prospect theory: An analysis of decision under risk. Econometrica, 47(2), 263–292.',
        'Mindfulsuite. (2026). The impact of expense tracking on financial behavior: How consistent logging reduces discretionary spending. https://mindfulsuite.com/blog/expense-tracking-financial-behavior',
        'Thaler, R. H., & Sunstein, C. R. (2008). Nudge: Improving decisions about health, wealth, and happiness. Yale University Press.',
        'UNSGSA. (2021). Measuring financial health: A framework for practitioners. United Nations Secretary-General\'s Special Advocate for Inclusive Finance for Development. https://www.unsgsa.org',
        'Warren, E., & Tyagi, A. W. (2005). All your worth: The ultimate lifetime money plan. Free Press.',
    ]
    for c in citations:
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(1)
        p.paragraph_format.space_after  = Pt(3)
        p.paragraph_format.left_indent  = Inches(0.3)
        p.paragraph_format.first_line_indent = Inches(-0.3)
        r = p.add_run(c)
        r.font.name = FONT; r.font.size = Pt(8.5)
        r.font.color.rgb = DARK

    # Footer
    footer = sec.footer
    footer.paragraphs[0].clear()
    fp = footer.paragraphs[0]
    r1 = fp.add_run('SmartSpend FHS Research Brief  |  Lucid Frame  |  Lorma Colleges CCSE BSIT  |  AY 2026–2027')
    r1.font.name = FONT; r1.font.size = Pt(7); r1.font.color.rgb = GREY

    out = OUT_DIR / 'SmartSpend_FHS_Research_Brief.docx'
    doc.save(str(out))
    print(f'✓  {out.name}  ({out.stat().st_size // 1024} KB)')


# ═══════════════════════════════════════════════════════════════════════════════
# DOCUMENT 2 — APP OVERVIEW BRIEF
# ═══════════════════════════════════════════════════════════════════════════════

def build_app_overview():
    doc, sec = new_doc()

    banner(doc,
           'SmartSpend — Application Overview',
           'Purpose, Features, and Usage Guide for Survey Evaluators\n'
           'Lucid Frame | Lorma Colleges CCSE BSIT | AY 2026–2027, 1st Semester',
           BLUE_HEX)

    info_box(doc,
        '📋  PURPOSE OF THIS DOCUMENT\n'
        'This document provides evaluators, validators, and survey respondents with '
        'a plain-language overview of SmartSpend — what it does, who it is for, '
        'how to use it, and what makes it different. It is intended to be read '
        'before filling out the System Usability Scale (SUS) survey.',
        bg='EEF4FF', border='1A3A6B', color=BLUE)

    # ── SECTION 1: PROJECT IDENTITY ──────────────────────────────────────────
    section_head(doc, '1.  Project Identity', BLUE)

    add_table(doc,
        ['Item', 'Detail'],
        [
            ('Full Title', 'SmartSpend: An AI-Assisted Multi-Modal Personal Financial Management Application for Filipino Users Using Agentic Large Language Model Architecture'),
            ('Developed By', 'Lucid Frame — Brix A. Directo (Lead Dev), Cyrille John M. Rubis (UI/UX & Docs), Djaunathan Albert S. Madayag (PM & QA)'),
            ('Institution', 'Lorma Colleges — College of Computer Studies and Engineering (CCSE)'),
            ('Program', 'Bachelor of Science in Information Technology (BSIT) — 4th Year, 1st Semester'),
            ('Academic Year', '2026–2027, 1st Semester'),
            ('Adviser', 'Ellen F. Mangaoang, MIT'),
            ('Platform', 'Android (free APK, no Play Store account needed)'),
            ('Version', '2.9.19'),
            ('GitHub', 'github.com/Zushikina-kun/smartspend-app'),
        ],
        [2200, 8024], header_bg=BLUE_HEX, data_size=9)

    # ── SECTION 2: MAIN PURPOSE ──────────────────────────────────────────────
    section_head(doc, '2.  Main Purpose — The Problem It Solves', BLUE)
    body(doc,
        'Most Filipinos do not track their finances — not because they don\'t want '
        'to, but because existing tools (spreadsheets, manual apps) require too much '
        'effort. You have to open the app, tap through menus, select a category, '
        'enter the amount, and save. This friction causes most people to give up '
        'within a week.',
        before=0)
    body(doc,
        'SmartSpend removes this friction entirely. Instead of filling out a form, '
        'you just tell it what you spent in plain language:')

    examples = [
        '"I spent 85 pesos for lunch at the canteen"',
        '"Nagbayad ako ng 150 sa Grab kanina"',
        '"Bought Jollibee chicken joy for 149"',
        '"Spent 30 jeep, 45 Sting, 100 load"',
    ]
    for ex in examples:
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(1)
        p.paragraph_format.space_after  = Pt(1)
        p.paragraph_format.left_indent  = Inches(0.3)
        r = p.add_run(f'→  {ex}')
        r.font.name = FONT; r.font.size = Pt(9.5)
        r.font.color.rgb = MAROON; r.italic = True

    body(doc,
        'The AI understands all of these, logs the expense automatically, assigns '
        'the right category, and tags it as Need or Want. No forms. No dropdowns. '
        'No manual entry required.')

    info_box(doc,
        '🎯  CORE CONCEPT\n'
        'User says something  →  AI understands  →  App logs it automatically  →  '
        'Your finances are tracked  →  You see your Financial Health Score\n\n'
        'The entire loop takes under 5 seconds.',
        bg='FFF3F5', border='5C0E24', color=MAROON)

    # ── SECTION 3: TARGET USERS ──────────────────────────────────────────────
    section_head(doc, '3.  Who Is It For?', BLUE)

    add_table(doc,
        ['User Type', 'Age Range', 'Why SmartSpend Helps', 'Account Type in App'],
        [
            ('Parents', '35–55', 'Primary household financial decision-makers. Often lack structured budgeting tools. SmartSpend helps track household spending and set category budgets.', 'Employed / Business Owner / General'),
            ('Young Professionals', '21–35', 'Starting independent financial lives. Need to build saving habits and manage debt. SmartSpend\'s AI provides personalized financial advice.', 'Employed / Freelancer / Working Student'),
            ('Students', '15–25', 'Managing limited allowances. SmartSpend adapts language ("Allowance" instead of "Income") and provides student-appropriate budget splits.', 'Student / Working Student'),
            ('Freelancers & Self-Employed', '21–55', 'Irregular income makes budgeting hard. Lightweight Mode tracks spending habits without needing a fixed monthly income figure.', 'Freelancer / Business Owner'),
            ('General Users', 'Any', 'Anyone who wants to start tracking spending without a steep learning curve.', 'General / Other'),
        ],
        [1500, 900, 4900, 2624], header_bg=BLUE_HEX, data_size=8.5)

    # ── SECTION 4: KEY FEATURES ──────────────────────────────────────────────
    section_head(doc, '4.  Key Features', BLUE)

    feature_groups = [
        ('🤖  AI Chat Assistant', [
            ('What it does', '34 types of autonomous actions — log expenses, set budgets, update wallet balances, track debts, set savings goals, compute SSS/PhilHealth contributions, and more — all through natural language chat.'),
            ('Languages supported', 'English, Filipino/Tagalog, and Taglish (mixed). The AI automatically detects and matches the user\'s language.'),
            ('Example actions', '"Spent 30 for jeep" → logs Transportation ₱30. "Budget ko sa pagkain 3000" → sets Food budget to ₱3,000. "My GCash is 500" → updates GCash wallet balance.'),
            ('Advisory capability', 'Beyond logging: answers questions about SSS loans, PhilHealth benefits, Pag-IBIG, investment options (MP2, time deposits), tax computation (BIR TRAIN Law), and Philippine banking comparisons.'),
        ]),
        ('📊  Financial Health Score (FHS)', [
            ('What it shows', 'A score from 0 to 100 on the home screen, updated every time you log an expense. Reflects how well you are managing your finances this month.'),
            ('Components (Full Mode)', 'Savings Rate (25 pts) + Overspend Control (25 pts) + Budget Adherence (25 pts) + Logging Consistency (25 pts)'),
            ('Components (Lightweight)', 'Spending Restraint (25 pts) + Logging Consistency (25 pts) + Category Balance (25 pts) + Habit Streak (25 pts)'),
            ('Where it appears', 'Home screen, Profile screen, Analytics screen, and as a shareable Financial Health Certificate.'),
        ]),
        ('📷  Smart Import — 4 Ways to Add Expenses', [
            ('AI Chat (text/voice)', 'Type or speak what you spent. The AI parses and logs it.'),
            ('Live Camera', 'Point at a barcode/QR code or take a photo of a receipt. The app extracts the items automatically.'),
            ('Batch Screenshots', 'Pick up to 10 screenshots from Shopee, GCash, Steam, Netflix, BPI, BDO, Lazada, etc. The app detects the platform (40+ supported) and extracts all transactions.'),
            ('Paste Text', 'Copy your GCash, BPI, or BDO transaction history text and paste it. The AI parses all rows at once.'),
        ]),
        ('💰  Budgets, Goals & Wallets', [
            ('Category Budgets', '14 built-in categories (Food, Transport, Bills, Shopping, Gaming, Health, Education, etc.) with monthly limits. Pace indicators show if you\'re spending faster than expected.'),
            ('Savings Goals', 'Create goals with target amounts and deadlines. The app calculates how much you need to save per month.'),
            ('Wallet Balances', 'Track cash across Cash on Hand, GCash, Maya, BDO, BPI, and 30+ other Philippine banks and e-wallets.'),
            ('Spending Limits', 'Set daily, weekly, monthly, or yearly spending caps. Progress bars and alerts appear when you\'re approaching the limit.'),
        ]),
        ('🎮  Gamification', [
            ('23 Achievement Badges', 'Earned for financial milestones: first savings goal, 7-day streak, first debt paid, 100 expenses logged, FHS reaching 80+, and more.'),
            ('10 Daily Quests', '4 rotating quests per day (log an expense, stay under budget, avoid Want spending, etc.) with a streak counter.'),
            ('Spending Personality', 'Labels your spending style from your actual data (Consistent Saver, Foodie Spender, Impulse Buyer, etc.) — no survey needed.'),
        ]),
        ('🔒  Privacy & Security', [
            ('Offline-first', 'All core features work without internet. Data is stored locally on your device.'),
            ('No bank connectivity', 'SmartSpend does not connect to your bank account. You enter or import data manually — your bank credentials are never shared.'),
            ('API key security', 'AI provider API keys are fetched at runtime from Firebase Remote Config — never hardcoded in the app file.'),
            ('App Lock', 'Optional PIN + biometric lock on startup.'),
        ]),
    ]

    for group_title, features in feature_groups:
        body(doc, group_title, bold=True, color=BLUE, size=10.5, before=8, after=2)
        add_table(doc,
            ['Feature', 'Description'],
            [[f, d] for f, d in features],
            [2000, 8024], header_bg=BLUE_HEX,
            header_color=WHITE, data_color=DARK, data_size=8.5)

    # ── SECTION 5: HOW TO USE ─────────────────────────────────────────────────
    section_head(doc, '5.  How to Use SmartSpend — Quick Start', BLUE)

    steps = [
        ('Step 1', 'Install the app',
         'Download the APK from the GitHub releases page or from the shared file provided by the researchers. '
         'Install it on your Android phone (tap the APK file → allow installation from unknown sources if prompted).'),
        ('Step 2', 'Log in or try Demo Mode',
         'Create a Google or email account, OR tap "Try Demo" on the login screen to explore a pre-loaded '
         'Filipino sample dataset without signing up. Demo data is never synced and is automatically cleared on login.'),
        ('Step 3', 'Set your account type and income',
         'Choose your account type (Student, Employed, etc.) and optionally enter your monthly income or allowance. '
         'This helps the AI give relevant advice and compute the Financial Health Score accurately.'),
        ('Step 4', 'Log expenses via AI Chat',
         'Tap the AI button (center of the bottom navigation bar). Type or say what you spent. '
         'The AI will log it automatically. You can also ask financial questions here.'),
        ('Step 5', 'Check your Financial Health Score',
         'Scroll the home screen to see your FHS card (0–100). Tap it to see the component breakdown '
         'and specific tips for improvement.'),
        ('Step 6', 'Explore Analytics, Budgets, and Goals',
         'Tap the Analytics tab for spending charts and the 50/30/20 tracker. '
         'Tap the Hub icon (grid) for Budgets, Goals, Debts, and more features.'),
    ]

    for step_num, step_title, step_desc in steps:
        t = doc.add_table(rows=1, cols=2)
        _tblw(t, TW); _noborders(t)
        c0 = t.cell(0, 0); c1 = t.cell(0, 1)
        _colw(c0, 900); _colw(c1, 9324)
        _bg(c0, BLUE_HEX)
        p0 = c0.paragraphs[0]; p0.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p0.paragraph_format.space_before = Pt(6); p0.paragraph_format.space_after = Pt(6)
        r0 = p0.add_run(step_num)
        r0.font.name = FONT; r0.font.size = Pt(9); r0.bold = True
        r0.font.color.rgb = WHITE

        _bg(c1, LIGHT_BLUE)
        p1 = c1.paragraphs[0]; p1.clear()
        p1.paragraph_format.space_before = Pt(4)
        p1.paragraph_format.space_after  = Pt(0)
        r1a = p1.add_run(f'{step_title}:  ')
        r1a.font.name = FONT; r1a.font.size = Pt(9.5); r1a.bold = True
        r1a.font.color.rgb = BLUE
        r1b = p1.add_run(step_desc)
        r1b.font.name = FONT; r1b.font.size = Pt(9.5)
        r1b.font.color.rgb = DARK

        p_end = c1.add_paragraph()
        p_end.paragraph_format.space_before = Pt(0)
        p_end.paragraph_format.space_after  = Pt(4)

        doc.add_paragraph().paragraph_format.space_after = Pt(2)

    # ── SECTION 6: WHAT THE SURVEY MEASURES ──────────────────────────────────
    section_head(doc, '6.  What the Survey Measures — SUS Explained', BLUE)
    body(doc,
        'After using SmartSpend, you will be asked to complete a 10-item System '
        'Usability Scale (SUS) questionnaire. The SUS measures how easy and usable '
        'you found the app — not whether you liked it or whether you agree with '
        'financial advice it gave.',
        before=0)
    body(doc, 'The SUS asks questions like:')

    sus_examples = [
        'I thought the app was easy to use.',
        'I would need the support of a technical person to be able to use this system.',
        'I felt very confident using the app.',
        'I needed to learn a lot of things before I could get going with this system.',
    ]
    for s in sus_examples:
        p = doc.add_paragraph()
        p.paragraph_format.space_before = Pt(1)
        p.paragraph_format.space_after  = Pt(1)
        p.paragraph_format.left_indent  = Inches(0.3)
        r = p.add_run(f'•  {s}')
        r.font.name = FONT; r.font.size = Pt(9.5)
        r.font.color.rgb = DARK

    body(doc, 'Each item is answered on a 1–5 scale (Strongly Disagree to Strongly Agree).')

    add_table(doc,
        ['SUS Score', 'Grade', 'Adjective Rating', 'Acceptability'],
        [
            ('≥ 90', 'A+', 'Best Imaginable', 'Acceptable'),
            ('85–89', 'A', 'Excellent', 'Acceptable'),
            ('80–84', 'B', 'Good ← Target', 'Acceptable'),
            ('70–79', 'C', 'OK', 'Marginal'),
            ('< 70', 'D / F', 'Poor to Awful', 'Not Acceptable'),
        ],
        [1500, 1000, 2500, 4224],
        header_bg=MAROON_HEX, data_size=9)

    body(doc,
        'SmartSpend targets a SUS score of ≥80 (Good / Acceptable). '
        'This is the established threshold for a system to be considered usable '
        'per Bangor, Kortum, & Miller (2009).',
        italic=True, color=GREY, size=9)

    # Footer
    footer = sec.footer
    footer.paragraphs[0].clear()
    fp = footer.paragraphs[0]
    r1 = fp.add_run('SmartSpend App Overview Brief  |  Lucid Frame  |  Lorma Colleges CCSE BSIT  |  AY 2026–2027')
    r1.font.name = FONT; r1.font.size = Pt(7); r1.font.color.rgb = GREY

    out = OUT_DIR / 'SmartSpend_App_Overview_Brief.docx'
    doc.save(str(out))
    print(f'✓  {out.name}  ({out.stat().st_size // 1024} KB)')


# ═══════════════════════════════════════════════════════════════════════════════
# DOCUMENT 3 — RESEARCH VERIFICATION
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
