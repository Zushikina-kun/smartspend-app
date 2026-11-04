"""
SmartSpend Defense Presentation Builder
Run: python docs/capstone/build_presentation.py
Output: docs/capstone/SmartSpend_Defense_Presentation.pptx
"""

from pptx import Presentation
from pptx.util import Inches, Pt, Emu
from pptx.dml.color import RGBColor
from pptx.enum.text import PP_ALIGN
from pptx.util import Inches, Pt
import copy

# ── BRAND COLORS ─────────────────────────────────────────────────────────────
GREEN      = RGBColor(0x00, 0xC8, 0x96)   # kPesoGreen
GREEN_DARK = RGBColor(0x00, 0x8F, 0x6A)   # kPesoGreenDark
NAVY       = RGBColor(0x0D, 0x1B, 0x2A)   # dark navy
NAVY2      = RGBColor(0x16, 0x20, 0x32)   # slightly lighter navy
WHITE      = RGBColor(0xFF, 0xFF, 0xFF)
GRAY       = RGBColor(0x9E, 0xAD, 0xB8)
ORANGE     = RGBColor(0xFF, 0x8C, 0x00)
RED        = RGBColor(0xE8, 0x45, 0x45)
PENDING    = RGBColor(0xFF, 0xC1, 0x07)   # amber for pending notices
BLACK      = RGBColor(0x00, 0x00, 0x00)

SLIDE_W = Inches(13.33)
SLIDE_H = Inches(7.5)

prs = Presentation()
prs.slide_width  = SLIDE_W
prs.slide_height = SLIDE_H

BLANK = prs.slide_layouts[6]  # completely blank


# ── HELPER FUNCTIONS ─────────────────────────────────────────────────────────

def add_slide():
    return prs.slides.add_slide(BLANK)


def bg(slide, color=NAVY):
    """Fill the slide background."""
    fill = slide.background.fill
    fill.solid()
    fill.fore_color.rgb = color


def box(slide, left, top, width, height,
        fill=None, line=None, line_width_pt=1.0):
    """Add a rectangle shape."""
    from pptx.enum.shapes import MSO_SHAPE_TYPE
    shape = slide.shapes.add_shape(
        1,  # MSO_SHAPE_TYPE.RECTANGLE
        Inches(left), Inches(top), Inches(width), Inches(height)
    )
    f = shape.fill
    if fill:
        f.solid(); f.fore_color.rgb = fill
    else:
        f.background()

    ln = shape.line
    if line:
        ln.color.rgb = line
        ln.width = Pt(line_width_pt)
    else:
        ln.fill.background()
    return shape


def txt(slide, text, left, top, width, height,
        size=18, bold=False, color=WHITE, align=PP_ALIGN.LEFT,
        italic=False, wrap=True, font_name="Calibri"):
    """Add a text box."""
    txb = slide.shapes.add_textbox(
        Inches(left), Inches(top), Inches(width), Inches(height))
    txb.word_wrap = wrap
    tf = txb.text_frame
    tf.word_wrap = wrap
    p = tf.paragraphs[0]
    p.alignment = align
    run = p.add_run()
    run.text = text
    run.font.size = Pt(size)
    run.font.bold = bold
    run.font.italic = italic
    run.font.color.rgb = color
    run.font.name = font_name
    return txb


def accent_bar(slide, color=GREEN):
    """4px green accent bar across the top."""
    b = box(slide, 0, 0, 13.33, 0.08, fill=color)
    return b


def tag_label(slide, text):
    """Small uppercase green tag."""
    txt(slide, text, 0.5, 0.15, 12, 0.3,
        size=10, bold=True, color=GREEN)


def title_text(slide, main, sub=None, top=0.55):
    """Big slide title + optional subtitle."""
    txt(slide, main, 0.5, top, 12.3, 1.2,
        size=32, bold=True, color=WHITE)
    if sub:
        txt(slide, sub, 0.5, top + 1.1, 12.3, 0.8,
            size=16, color=GRAY)


def card(slide, left, top, width, height,
         heading, body, heading_color=GREEN, body_size=13):
    """Dark card with heading + body text."""
    box(slide, left, top, width, height,
        fill=RGBColor(0x1A, 0x2A, 0x3A),
        line=GREEN, line_width_pt=0.75)
    txt(slide, heading, left + 0.15, top + 0.12, width - 0.3, 0.35,
        size=13, bold=True, color=heading_color)
    txt(slide, body, left + 0.15, top + 0.48, width - 0.3, height - 0.6,
        size=body_size, color=GRAY, wrap=True)


def pending_notice(slide, left, top, width, msg):
    """Amber pending notice box."""
    box(slide, left, top, width, 0.55,
        fill=RGBColor(0x2A, 0x1E, 0x00),
        line=ORANGE, line_width_pt=0.75)
    txt(slide, "⏳  " + msg, left + 0.15, top + 0.08, width - 0.3, 0.42,
        size=11, color=PENDING, wrap=True)


def stat_block(slide, left, top, number, label, width=1.9):
    """Green stat card."""
    box(slide, left, top, width, 1.0,
        fill=RGBColor(0x00, 0x30, 0x24),
        line=GREEN, line_width_pt=0.75)
    txt(slide, number, left, top + 0.08, width, 0.5,
        size=28, bold=True, color=GREEN, align=PP_ALIGN.CENTER)
    txt(slide, label, left, top + 0.55, width, 0.38,
        size=10, color=GRAY, align=PP_ALIGN.CENTER)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 1 — TITLE
# ══════════════════════════════════════════════════════════════════════════════
s = add_slide()
bg(s, RGBColor(0x04, 0x10, 0x1C))
accent_bar(s)

# Coin emoji substitute — big circle
box(s, 6.1, 0.8, 1.1, 1.1, fill=GREEN)
txt(s, "₱", 6.1, 0.82, 1.1, 1.1,
    size=36, bold=True, color=NAVY, align=PP_ALIGN.CENTER)

txt(s, "SmartSpend", 1.5, 1.9, 10.3, 0.9,
    size=44, bold=True, color=GREEN, align=PP_ALIGN.CENTER, font_name="Calibri")

txt(s, "An AI-Assisted Mobile Financial Tracking and Advisory Application",
    1.0, 2.75, 11.3, 0.65,
    size=20, bold=False, color=WHITE, align=PP_ALIGN.CENTER)

txt(s, "For Personal Financial Management of Parents and Young Professionals\nin San Fernando City, La Union",
    1.5, 3.35, 10.3, 0.75,
    size=14, color=GRAY, align=PP_ALIGN.CENTER, italic=True)

# Team
txt(s, "Brix A. Directo  ·  Cyrille John M. Rubis  ·  Djaunathan Albert S. Madayag",
    1.0, 4.25, 11.3, 0.45,
    size=14, bold=True, color=WHITE, align=PP_ALIGN.CENTER)
txt(s, "Lead Developer             UI/UX & Documentation             Project Manager & QA",
    1.0, 4.65, 11.3, 0.35,
    size=11, color=GRAY, align=PP_ALIGN.CENTER)

# Meta
txt(s, "Adviser: Ms. Ellen F. Mangaoang, DIT   ·   Lorma Colleges CCSE   ·   November 9, 2026",
    1.0, 5.2, 11.3, 0.4,
    size=12, color=GRAY, align=PP_ALIGN.CENTER)

txt(s, "BSIT Capstone 2  ·  AY 2026–2027", 1.0, 5.6, 11.3, 0.35,
    size=11, color=GREEN, align=PP_ALIGN.CENTER, bold=True)

txt(s, "1 / 15", 12.3, 7.1, 0.8, 0.3, size=10, color=GRAY, align=PP_ALIGN.RIGHT)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 2 — PROBLEM STATEMENT
# ══════════════════════════════════════════════════════════════════════════════
s = add_slide()
bg(s)
accent_bar(s)
tag_label(s, "CHAPTER I  ·  INTRODUCTION")
title_text(s, "The Problem: Filipino Finance Management Gaps")

# Left: problem cards
problems = [
    ("💸 Manual Tracking Friction",
     "Filipino users abandon expense trackers — GCash, Shopee, and multi-wallet transactions require too much manual effort."),
    ("🌐 No Local Language Support",
     "Existing apps don't understand Taglish, GCash, Paluwagan, ShopeePay, or local merchant names."),
    ("📊 Passive Data, No Behavioral Feedback",
     "Apps show charts but create no consequences when spending warnings are ignored. Users need nudges, not just graphs."),
]
for i, (h, b) in enumerate(problems):
    box(s, 0.5, 1.85 + i * 1.55, 6.3, 1.4,
        fill=RGBColor(0x20, 0x08, 0x08),
        line=RED, line_width_pt=0.75)
    txt(s, h, 0.65, 1.9 + i * 1.55, 6.0, 0.4, size=13, bold=True, color=RED)
    txt(s, b, 0.65, 2.28 + i * 1.55, 6.0, 0.9, size=12, color=GRAY, wrap=True)

# Right: stats
stats = [("74%", "Financial\nLiteracy Rate"), ("<50%", "Maintain Any\nBudget"),
         ("85%", "Household\nFinancial Access"), ("41.5M", "GCash Monthly\nUsers")]
for i, (n, l) in enumerate(stats):
    r, c = divmod(i, 2)
    stat_block(s, 7.1 + c * 2.9, 1.85 + r * 1.25, n, l, width=2.6)

# Source
txt(s, "BSP CFIS 2025  ·  BSP Consumer Expectations Survey",
    0.5, 6.95, 12, 0.35, size=10, color=GRAY)
txt(s, "2 / 15", 12.3, 7.1, 0.8, 0.3, size=10, color=GRAY, align=PP_ALIGN.RIGHT)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 3 — OBJECTIVES
# ══════════════════════════════════════════════════════════════════════════════
s = add_slide()
bg(s, RGBColor(0x08, 0x0F, 0x18))
accent_bar(s)
tag_label(s, "CHAPTER I  ·  RESEARCH OBJECTIVES")
title_text(s, "What This Study Aims to Do")

objs = [
    ("01", "NEEDS ASSESSMENT",
     "Assess existing financial management practices, budgeting challenges, and expense tracking behaviors of parents (35–55) and young professionals (21–35) in San Fernando City, La Union"),
    ("02", "SYSTEM DESIGN & DEVELOPMENT",
     "Design and develop SmartSpend — an offline-first Flutter/Android application with Taglish AI, multi-modal input, and a transaction-derived Financial Health Score"),
    ("03", "USABILITY EVALUATION",
     "Evaluate the system using the System Usability Scale (SUS, N=30), targeting a mean score ≥80 (\"Good\" per Bangor, Kortum & Miller, 2009)"),
]
for i, (num, label, body) in enumerate(objs):
    box(s, 0.5 + i * 4.28, 1.85, 3.9, 3.8,
        fill=RGBColor(0x00, 0x28, 0x1E), line=GREEN, line_width_pt=1.0)
    txt(s, num, 0.6 + i * 4.28, 2.0, 3.7, 0.8,
        size=40, bold=True, color=GREEN)
    txt(s, label, 0.65 + i * 4.28, 2.75, 3.7, 0.4,
        size=10, bold=True, color=GREEN)
    txt(s, body, 0.65 + i * 4.28, 3.15, 3.65, 2.3,
        size=13, color=GRAY, wrap=True)

# Gap card
box(s, 0.5, 5.85, 12.3, 0.95,
    fill=RGBColor(0x0A, 0x20, 0x18), line=GREEN, line_width_pt=0.5)
txt(s, "🎯  Research Gap:", 0.65, 5.9, 3, 0.4, size=12, bold=True, color=GREEN)
txt(s, "No existing study evaluates an integrated mobile prototype combining Taglish AI logging + GCash screenshot import + transaction-derived Financial Health Score for the Filipino context.",
    0.65, 6.2, 12.0, 0.5, size=12, color=GRAY)
txt(s, "3 / 15", 12.3, 7.1, 0.8, 0.3, size=10, color=GRAY, align=PP_ALIGN.RIGHT)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 4 — THEORETICAL FRAMEWORK
# ══════════════════════════════════════════════════════════════════════════════
s = add_slide()
bg(s)
accent_bar(s)
tag_label(s, "CHAPTER II  ·  THEORETICAL FRAMEWORK")
title_text(s, "Built on Behavioral Economics")

theories = [
    ("🔔  Nudge Theory",
     "Thaler & Sunstein (2008)",
     "Choice architecture guides behavior without restricting freedom. Budget alerts, Warning Decay (−5 pts/day), and startup gap prompts are designed nudges applied at the moment of decision."),
    ("💡  Self-Determination Theory",
     "Deci & Ryan (2000)",
     "36 badges + streaks = Competence reward. Customizable goals = Autonomy. Filipino-first Taglish framing = Relatedness. SDT explains why the gamification sustains habit formation."),
    ("📉  Prospect Theory",
     "Kahneman & Tversky (1979)",
     "Losses feel ~2× more painful than equivalent gains. Warning Decay: FHS drops −5 pts/day when budget warnings are ignored — making the cost of ignoring alerts concrete and visible."),
]
for i, (h, src, b) in enumerate(theories):
    box(s, 0.5 + i * 4.28, 1.85, 3.9, 3.3,
        fill=RGBColor(0x00, 0x28, 0x1E), line=GREEN, line_width_pt=0.75)
    txt(s, h, 0.65 + i * 4.28, 1.98, 3.65, 0.45, size=13, bold=True, color=GREEN)
    txt(s, src, 0.65 + i * 4.28, 2.4, 3.65, 0.35, size=11, color=GRAY, italic=True)
    txt(s, b, 0.65 + i * 4.28, 2.72, 3.65, 2.2, size=12, color=GRAY, wrap=True)

# CBA-MI basis
box(s, 0.5, 5.35, 12.3, 1.3,
    fill=RGBColor(0x00, 0x20, 0x16), line=GREEN, line_width_pt=0.75)
txt(s, "🏦  FHS Academic Basis — CBA–Melbourne Institute (2018)",
    0.65, 5.42, 12, 0.4, size=13, bold=True, color=GREEN)
txt(s, "The Financial Health Score adapts the CBA–Melbourne Institute Observed Financial Health Indicator (Comerton-Forde et al., 2018) — a transaction-based 0–100 scale with equal-weighted components. We call ours a \"Prototype Observed Financial Health Indicator (FHI)\" per Melbourne Institute naming guidance. UNSGSA (2021) validates using transaction data as an early-stage complement to survey-based scales.",
    0.65, 5.8, 12.0, 0.75, size=11, color=GRAY, wrap=True)
txt(s, "4 / 15", 12.3, 7.1, 0.8, 0.3, size=10, color=GRAY, align=PP_ALIGN.RIGHT)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 5 — FHS FORMULA
# ══════════════════════════════════════════════════════════════════════════════
s = add_slide()
bg(s, RGBColor(0x08, 0x0F, 0x18))
accent_bar(s)
tag_label(s, "CHAPTER II–III  ·  FINANCIAL HEALTH SCORE")
title_text(s, "The FHS Formula — Where It Came From")

# Formula block (left)
box(s, 0.5, 1.85, 5.8, 3.0,
    fill=RGBColor(0x00, 0x00, 0x00), line=GREEN, line_width_pt=1.0)
formula = (
    "FHS (Full Mode) = 4 × 25 pts each:\n\n"
    "① Savings Rate    = 25 × min(1, rate/0.20)\n"
    "② Overspend Ctrl  = 25 × (1−weighted/active)\n"
    "③ Budget Adher.   = 25 × (onBudget/total)\n"
    "④ Log Consistency = 25 × (loggedDays/active)\n\n"
    "Adj: Warning Decay −5 pts/day (max −15)\n"
    "Lightweight: Spending Restraint + Category\n"
    "Balance + Consistency + Habit Streak"
)
txt(s, formula, 0.65, 1.95, 5.5, 2.8,
    size=11, color=GREEN, font_name="Courier New")

pending_notice(s, 0.5, 5.05,
    5.8, "Objective 1 results [PENDING] — replace with actual survey frequencies once N=30 is complete.")

# Derivation table (right)
headers = ["Component", "Academic Basis"]
rows = [
    ("Savings Rate (20% target)", "Warren & Tyagi (2004) — 50/30/20 rule"),
    ("Overspend Control", "Kahneman & Tversky (1979) — loss aversion"),
    ("Budget Adherence", "FinHealth Score® Plan pillar (FHN, 2021)"),
    ("Logging Consistency", "Deci & Ryan (2000) — SDT Competence"),
    ("Equal weights (25 pts)", "CBA–MI (2018) equal-weight observed scale"),
    ("Warning Decay", "Prospect Theory — loss-salience principle"),
]
col_w = [3.1, 3.5]
x0 = 6.7
# header row
for j, (h, w) in enumerate(zip(headers, col_w)):
    box(s, x0 + sum(col_w[:j]), 1.85, w, 0.4,
        fill=RGBColor(0x00, 0x40, 0x30), line=GREEN, line_width_pt=0.5)
    txt(s, h, x0 + sum(col_w[:j]) + 0.07, 1.9, w - 0.1, 0.35,
        size=11, bold=True, color=GREEN)
for i, row in enumerate(rows):
    fill_c = RGBColor(0x0A, 0x1A, 0x14) if i % 2 == 0 else RGBColor(0x06, 0x12, 0x0E)
    for j, (cell, w) in enumerate(zip(row, col_w)):
        box(s, x0 + sum(col_w[:j]), 2.25 + i * 0.7, w, 0.65,
            fill=fill_c, line=RGBColor(0x1A, 0x3A, 0x2A), line_width_pt=0.4)
        txt(s, cell, x0 + sum(col_w[:j]) + 0.07, 2.28 + i * 0.7, w - 0.1, 0.6,
            size=11, color=GRAY)

txt(s, "5 / 15", 12.3, 7.1, 0.8, 0.3, size=10, color=GRAY, align=PP_ALIGN.RIGHT)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 6 — SYSTEM ARCHITECTURE
# ══════════════════════════════════════════════════════════════════════════════
s = add_slide()
bg(s)
accent_bar(s)
tag_label(s, "CHAPTER III  ·  SYSTEM DESIGN")
title_text(s, "SmartSpend System Architecture")

# Architecture flow
flow = ["User Input\n(7 Modalities)", "AI Processing\n(9 Providers)", "SQLite DB\n(v14 · 26 tables)", "Analytics + FHS\n(0–100 score)"]
for i, label in enumerate(flow):
    box(s, 0.5 + i * 3.25, 1.85, 2.9, 0.9,
        fill=RGBColor(0x00, 0x28, 0x1E), line=GREEN, line_width_pt=1.0)
    txt(s, label, 0.5 + i * 3.25, 1.9, 2.9, 0.8,
        size=12, bold=True, color=GREEN, align=PP_ALIGN.CENTER)
    if i < 3:
        txt(s, "→", 3.4 + i * 3.25, 2.05, 0.35, 0.5,
            size=18, bold=True, color=GREEN, align=PP_ALIGN.CENTER)

# 7 input modalities
modalities = [
    ("💬", "AI Chat\n(Taglish)"), ("🎙️", "Voice\nInput"), ("📷", "OCR\nReceipt"),
    ("🖼️", "Batch\nScreenshots"), ("🔢", "Barcode\nLookup"), ("📋", "Bank CSV\nPaste"), ("✏️", "Manual\nEntry"),
]
for i, (icon, label) in enumerate(modalities):
    box(s, 0.5 + i * 1.82, 3.0, 1.65, 1.1,
        fill=RGBColor(0x06, 0x14, 0x10), line=RGBColor(0x00, 0x80, 0x60), line_width_pt=0.5)
    txt(s, icon, 0.5 + i * 1.82, 3.05, 1.65, 0.45, size=18, align=PP_ALIGN.CENTER)
    txt(s, label, 0.5 + i * 1.82, 3.48, 1.65, 0.55,
        size=10, color=GRAY, align=PP_ALIGN.CENTER)

# Stats row
stats6 = [("34", "AI Actions"), ("9", "Providers"), ("45", "Screens"), ("26", "DB Tables"), ("36", "Badges"), ("100%", "Core Offline")]
for i, (n, l) in enumerate(stats6):
    stat_block(s, 0.5 + i * 2.05, 4.3, n, l, width=1.85)

txt(s, "6 / 15", 12.3, 7.1, 0.8, 0.3, size=10, color=GRAY, align=PP_ALIGN.RIGHT)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 7 — PESO COMPANION
# ══════════════════════════════════════════════════════════════════════════════
s = add_slide()
bg(s, RGBColor(0x00, 0x1E, 0x14))
accent_bar(s)
tag_label(s, "CHAPTER III  ·  PESO COMPANION SYSTEM")
title_text(s, "Meet Peso — Your AI Money Buddy")

peso_cards = [
    ("🎭  12 Moods",
     "Idle animation (bob + eye blink every ~4s), mood pop-in elastic transition. Responds to FHS score, budget status, and user gestures."),
    ("🗣️  31 Voice Contexts",
     "PesoVoiceService: 2–4 random Taglish variants per context. Prevents semantic satiation — different line every session."),
    ("👆  Gesture System",
     "Double-tap → surprised + voice line. Long-press → context tip sheet. Idle 8s → winks at you (once/hour anti-Clippy)."),
    ("⭕  FHS Tier Ring",
     "🟢 Green ≥70 · 🟠 Orange ≥50 · 🔴 Red <50. Score tier visible instantly without reading the number."),
    ("🔁  Behavioral Loop",
     "Log daily → streak celebration → reinforces habit. FHS tier change → Peso reacts. Notification tap → context greeting."),
    ("⚠️  Scope Note",
     "These are design features grounded in SDT and Nudge Theory. Longitudinal behavioral effect has NOT been measured — present as design, not as measured outcome."),
]
for i, (h, b) in enumerate(peso_cards):
    r, c = divmod(i, 3)
    card(s, 0.5 + c * 4.28, 1.85 + r * 2.4, 3.9, 2.2, h, b)

txt(s, "7 / 15", 12.3, 7.1, 0.8, 0.3, size=10, color=GRAY, align=PP_ALIGN.RIGHT)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 8 — PRIVACY & RA 10173
# ══════════════════════════════════════════════════════════════════════════════
s = add_slide()
bg(s, RGBColor(0x08, 0x0F, 0x18))
accent_bar(s)
tag_label(s, "CHAPTER III  ·  DATA PRIVACY")
title_text(s, "Privacy-First AI — RA 10173 Alignment")

tiers = [
    ("☁️  Cloud AI (Default)",
     "On-device regex redacts BEFORE sending:\n• PH mobile numbers (09XX/+63)\n• GCash ref numbers (12–18 digits)\n• OTPs and PIN codes\n• Bank account numbers\n\nNote: Free-tier Gemini content may be used to improve Google products."),
    ("🏠  Local AI (Private Mode)",
     "User connects Ollama/LM Studio/Jan on their own PC. While server is reachable, no data leaves the home network.\n\nLocal-only toggle: AI stops responding instead of falling back to cloud — for maximum privacy."),
    ("📱  On-Device AI (Roadmap v5.0)",
     "Gemma 4 E2B (~2.6 GB) via LiteRT LM SDK. Viable on 6 GB RAM / Android 10+ phones.\n\nStatus: Planned ~2027. Listed as Recommendation, NOT a delivered feature."),
]
for i, (h, b) in enumerate(tiers):
    card(s, 0.5 + i * 4.28, 1.85, 3.9, 3.5, h, b, body_size=11)

# Payload card
box(s, 0.5, 5.55, 12.3, 1.25,
    fill=RGBColor(0x00, 0x20, 0x16), line=GREEN, line_width_pt=0.5)
txt(s, "📦  What is sent to cloud AI per request (~5,000–8,000 tokens):",
    0.65, 5.6, 12, 0.4, size=12, bold=True, color=GREEN)
txt(s, "Recent 10 expenses (item names + amounts only)  ·  Budget limits  ·  Savings goals  ·  Wallet balances  ·  Conversation history\n"
       "Philippine financial reference data (SSS/PhilHealth/BNPL)  ·  NO account numbers  ·  NO receipt images  ·  NO personal IDs",
    0.65, 5.98, 12.0, 0.75, size=11, color=GRAY, wrap=True)
txt(s, "8 / 15", 12.3, 7.1, 0.8, 0.3, size=10, color=GRAY, align=PP_ALIGN.RIGHT)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 9 — EVALUATION PROTOCOL
# ══════════════════════════════════════════════════════════════════════════════
s = add_slide()
bg(s)
accent_bar(s)
tag_label(s, "CHAPTER III  ·  METHODOLOGY")
title_text(s, "Evaluation Protocol")

# Respondent profile
box(s, 0.5, 1.85, 6.3, 2.1,
    fill=RGBColor(0x00, 0x28, 0x1E), line=GREEN, line_width_pt=0.75)
txt(s, "👥  Respondent Profile (N=30 Purposive Sample)",
    0.65, 1.9, 6.0, 0.4, size=13, bold=True, color=GREEN)
stat_block(s, 0.7, 2.35, "20", "Parents\nAges 35–55", width=2.8)
stat_block(s, 3.7, 2.35, "10", "Young Professionals\nAges 21–35", width=2.8)
txt(s, "San Fernando City, La Union  ·  Purposive sampling  ·  Used app ≥10 min before answering SUS",
    0.65, 3.52, 6.0, 0.38, size=10, color=GRAY)

# SUS info
box(s, 0.5, 4.08, 6.3, 2.0,
    fill=RGBColor(0x00, 0x20, 0x16), line=GREEN, line_width_pt=0.5)
txt(s, "📋  System Usability Scale (SUS — Brooke, 1996)",
    0.65, 4.13, 6.0, 0.38, size=12, bold=True, color=GREEN)
txt(s, "Standard 10-item instrument  ·  1–5 scale per item\n"
       "Formula: =((Q1-1)+(5-Q2)+...+(5-Q10))×2.5\n"
       "Target: Mean ≥80 = \"Good\" (Bangor et al., 2009)",
    0.65, 4.5, 6.0, 1.4, size=11, color=GRAY)

# SUS scale table (right)
sus_rows = [("90–100", "Excellent", "A+"), ("80–89", "Good  ← TARGET", "B"),
            ("70–79", "OK", "C"), ("60–69", "Poor", "D"), ("<60", "Awful", "F")]
txt(s, "SUS Score Interpretation (Bangor et al., 2009)",
    7.0, 1.85, 6.0, 0.4, size=12, bold=True, color=GREEN)
for i, (score, adj, grade) in enumerate(sus_rows):
    fill_c = RGBColor(0x00, 0x28, 0x1E) if i == 1 else RGBColor(0x0A, 0x14, 0x10)
    box(s, 7.0, 2.28 + i * 0.75, 6.0, 0.68, fill=fill_c,
        line=RGBColor(0x1A, 0x3A, 0x2A), line_width_pt=0.4)
    col_g = GREEN if i <= 1 else (ORANGE if i == 2 else RED)
    txt(s, score, 7.1, 2.32 + i * 0.75, 1.8, 0.6, size=12, color=WHITE)
    txt(s, adj, 8.9, 2.32 + i * 0.75, 3.2, 0.6, size=12,
        bold=(i == 1), color=col_g)
    txt(s, grade, 12.1, 2.32 + i * 0.75, 0.8, 0.6, size=12, color=GRAY)

pending_notice(s, 7.0, 6.3, 6.0,
    "Survey data collection in progress. SUS scores, frequency tables, and demographic breakdowns will be added here once N=30 responses are complete.")
txt(s, "9 / 15", 12.3, 7.1, 0.8, 0.3, size=10, color=GRAY, align=PP_ALIGN.RIGHT)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 10 — RESULTS OBJECTIVE 2
# ══════════════════════════════════════════════════════════════════════════════
s = add_slide()
bg(s, RGBColor(0x08, 0x0F, 0x18))
accent_bar(s)
tag_label(s, "CHAPTER III  ·  RESULTS — OBJECTIVE 2")
title_text(s, "System Development Results (v3.1.2)")

# Stats
stats10 = [("34", "AI Actions"), ("9", "Providers"), ("45", "Screens"),
           ("26", "DB Tables"), ("36", "Badges"), ("100%", "Offline Core")]
for i, (n, l) in enumerate(stats10):
    stat_block(s, 0.5 + i * 2.05, 1.75, n, l, width=1.85)

# AI chain
txt(s, "9-Provider AI Fallback Chain:",
    0.5, 3.0, 12, 0.4, size=12, bold=True, color=GREEN)
chain = ["Gemini 3.5\nFlash-Lite", "Gemini 3.5\nFlash", "GPT-OSS\n120B (Groq)",
         "Qwen3.6/\nQwen3.8", "GPT-OSS\n20B / Mini", "Cerebras", "Local LLM\n(Optional)"]
for i, label in enumerate(chain):
    box(s, 0.5 + i * 1.82, 3.4, 1.6, 0.75,
        fill=RGBColor(0x00, 0x28, 0x1E),
        line=GREEN if i == 0 else RGBColor(0x00, 0x60, 0x48), line_width_pt=0.5)
    txt(s, label, 0.5 + i * 1.82, 3.43, 1.6, 0.68,
        size=10, color=GREEN if i == 0 else GRAY, align=PP_ALIGN.CENTER)
    if i < 6:
        txt(s, "→", 2.1 + i * 1.82, 3.63, 0.2, 0.35,
            size=11, color=GREEN, align=PP_ALIGN.CENTER)

# Performance table
perf = [("OCR Precision (GCash/Maya)", "91.2% *"), ("OCR Recall (GCash/Maya)", "88.5% *"),
        ("AI Categorization (Taglish)", "94.6% *"), ("DB Sync Recovery", "100%"),
        ("Average AI Response Time", "<1.8 seconds")]
txt(s, "Engineering Performance Benchmarks:",
    0.5, 4.3, 12, 0.4, size=12, bold=True, color=GREEN)
for i, (metric, val) in enumerate(perf):
    fill_c = RGBColor(0x06, 0x14, 0x10) if i % 2 == 0 else RGBColor(0x0A, 0x1A, 0x14)
    box(s, 0.5, 4.72 + i * 0.45, 8.5, 0.42, fill=fill_c,
        line=RGBColor(0x1A, 0x3A, 0x2A), line_width_pt=0.3)
    txt(s, metric, 0.65, 4.76 + i * 0.45, 6.5, 0.38, size=11, color=GRAY)
    box(s, 9.1, 4.72 + i * 0.45, 3.7, 0.42, fill=fill_c,
        line=RGBColor(0x1A, 0x3A, 0x2A), line_width_pt=0.3)
    txt(s, val, 9.2, 4.76 + i * 0.45, 3.5, 0.38, size=11, bold=True, color=GREEN)

txt(s, "* Internal estimates — formal 50-receipt parsing test pending",
    0.5, 6.98, 12, 0.3, size=10, color=GRAY)
txt(s, "10 / 15", 12.3, 7.1, 0.8, 0.3, size=10, color=GRAY, align=PP_ALIGN.RIGHT)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 11 — SUS RESULTS (PENDING)
# ══════════════════════════════════════════════════════════════════════════════
s = add_slide()
bg(s)
accent_bar(s)
tag_label(s, "CHAPTER III  ·  RESULTS — OBJECTIVE 3")
title_text(s, "Usability Evaluation Results")

pending_notice(s, 0.5, 1.85, 12.3,
    "Survey data collection is currently in progress. Replace ALL [PENDING] cells below with actual Google Forms export data once N=30 responses are complete. DO NOT invent or estimate numbers.")

# SUS table
cols = ["Respondent Group", "N", "Mean SUS Score", "SD", "Range", "Adjective"]
widths = [3.0, 0.7, 2.0, 1.0, 1.5, 2.5]
x0 = 0.5
# header
for j, (col, w) in enumerate(zip(cols, widths)):
    box(s, x0 + sum(widths[:j]), 2.7, w, 0.5,
        fill=RGBColor(0x00, 0x40, 0x30), line=GREEN, line_width_pt=0.5)
    txt(s, col, x0 + sum(widths[:j]) + 0.07, 2.75, w - 0.1, 0.4,
        size=11, bold=True, color=GREEN)

sus_data = [
    ("Parents (35–55)", "20", "[PENDING]", "[PENDING]", "[PENDING]", "[PENDING]"),
    ("Young Professionals (21–35)", "10", "[PENDING]", "[PENDING]", "[PENDING]", "[PENDING]"),
    ("Overall", "30", "[PENDING]", "[PENDING]", "[PENDING]", "[PENDING]"),
]
for i, row in enumerate(sus_data):
    fill_c = RGBColor(0x0A, 0x1A, 0x14) if i % 2 == 0 else RGBColor(0x06, 0x12, 0x0E)
    for j, (cell, w) in enumerate(zip(row, widths)):
        box(s, x0 + sum(widths[:j]), 3.2 + i * 0.65, w, 0.6,
            fill=fill_c, line=RGBColor(0x1A, 0x3A, 0x2A), line_width_pt=0.3)
        c = ORANGE if "[PENDING]" in cell else (GREEN if i == 2 else GRAY)
        txt(s, cell, x0 + sum(widths[:j]) + 0.07, 3.25 + i * 0.65,
            w - 0.1, 0.55, size=11, bold=(i == 2), color=c)

txt(s, "Target: Mean ≥80 = \"Good\" (Bangor, Kortum & Miller, 2009)  ·  Formula: =((Q1-1)+(5-Q2)+...+(5-Q10))×2.5",
    0.5, 5.3, 12.3, 0.4, size=11, color=GRAY)

box(s, 0.5, 5.75, 12.3, 1.1,
    fill=RGBColor(0x1A, 0x1A, 0x00), line=ORANGE, line_width_pt=0.5)
txt(s, "📊  Analysis approach (fill in when data arrives):",
    0.65, 5.8, 12, 0.38, size=12, bold=True, color=ORANGE)
txt(s, "1. Export Google Forms → Sheets  2. Apply SUS formula in column L  3. AVERAGE(L2:L31) for mean, STDEV.S for SD  4. Map to Bangor et al. adjective scale  5. Report separately for each group",
    0.65, 6.15, 12.0, 0.62, size=11, color=GRAY, wrap=True)

txt(s, "11 / 15", 12.3, 7.1, 0.8, 0.3, size=10, color=GRAY, align=PP_ALIGN.RIGHT)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 12 — CONCLUSIONS
# ══════════════════════════════════════════════════════════════════════════════
s = add_slide()
bg(s, RGBColor(0x08, 0x0F, 0x18))
accent_bar(s)
tag_label(s, "CHAPTER IV  ·  CONCLUSIONS")
title_text(s, "Conclusions & Key Findings")

concl = [
    ("Objective 1\nNeeds Assessment",
     "[PENDING — replace with survey findings]\n\nPreliminary: Three gaps confirmed — manual logging friction, no Taglish support, and passive tracking without behavioral feedback."),
    ("Objective 2\nSystem Design",
     "SmartSpend v3.1.2 successfully engineered:\n✅ 34 agentic actions · 9 AI providers\n✅ 7 input modalities · 45 screens\n✅ Gemini 3.5 Flash-Lite as primary engine\n✅ FHS as Prototype Observed FHI (CBA-MI basis)\n✅ RA 10173 data minimization implemented"),
    ("Objective 3\nUsability Evaluation",
     "SUS evaluation in progress (N=30)\n\n[PENDING — replace with actual mean score and adjective rating]\n\nOCR: 91.2% precision / 88.5% recall *\nAI categorization: 94.6% *\nDB sync recovery: 100%"),
]
for i, (h, b) in enumerate(concl):
    box(s, 0.5 + i * 4.28, 1.85, 3.9, 5.0,
        fill=RGBColor(0x00, 0x20, 0x16), line=GREEN, line_width_pt=0.75)
    txt(s, h, 0.65 + i * 4.28, 1.95, 3.65, 0.65,
        size=13, bold=True, color=GREEN)
    txt(s, b, 0.65 + i * 4.28, 2.58, 3.65, 4.0,
        size=12, color=GRAY, wrap=True)

txt(s, "* Internal estimates — formal test pending",
    0.5, 6.98, 12, 0.3, size=10, color=GRAY)
txt(s, "12 / 15", 12.3, 7.1, 0.8, 0.3, size=10, color=GRAY, align=PP_ALIGN.RIGHT)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 13 — RECOMMENDATIONS
# ══════════════════════════════════════════════════════════════════════════════
s = add_slide()
bg(s)
accent_bar(s)
tag_label(s, "CHAPTER IV  ·  RECOMMENDATIONS")
title_text(s, "Future Work & Recommendations")

recs = [
    (GREEN, "✅ DONE", "Paluwagan Tracker",
     "Rotating savings group management. Implemented in v3.0.0 using existing debt/recurring DB infrastructure."),
    (GREEN, "✅ DONE", "Peso Companion System",
     "12-mood mascot, behavioral feedback loop, screen-aware tips. Implemented v3.0.5–v3.1.2."),
    (ORANGE, "🔄 PLANNED", "Payday-Cycle Budgeting",
     "Semi-monthly (15th/30th) budget resets matching Philippine payroll cycles."),
    (ORANGE, "🔄 PLANNED", "Localized SMS Autologging",
     "Android Notification Listener captures GCash/bank texts automatically — no manual entry needed."),
    (GRAY, "⏳ FUTURE", "Longitudinal Study",
     "6–12 month study measuring whether FHS actually changes spending behavior over time."),
    (GRAY, "⏳ v5.0 ~2027", "On-Device AI",
     "Gemma 4 E2B INT4 (~2.6 GB) via LiteRT LM SDK. Viable when 6 GB RAM phones are PH majority."),
]
for i, (dot_c, badge, title, body) in enumerate(recs):
    r, c = divmod(i, 2)
    box(s, 0.5 + c * 6.45, 1.85 + r * 1.7, 6.1, 1.55,
        fill=RGBColor(0x06, 0x14, 0x10), line=dot_c, line_width_pt=0.5)
    box(s, 0.6 + c * 6.45, 1.92 + r * 1.7, 0.12, 0.12, fill=dot_c)
    txt(s, badge, 0.85 + c * 6.45, 1.9 + r * 1.7, 1.4, 0.35,
        size=10, bold=True, color=dot_c)
    txt(s, title, 2.35 + c * 6.45, 1.9 + r * 1.7, 3.7, 0.35,
        size=12, bold=True, color=WHITE)
    txt(s, body, 0.65 + c * 6.45, 2.25 + r * 1.7, 5.85, 0.95,
        size=11, color=GRAY, wrap=True)

txt(s, "13 / 15", 12.3, 7.1, 0.8, 0.3, size=10, color=GRAY, align=PP_ALIGN.RIGHT)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 14 — DEMO SLIDE
# ══════════════════════════════════════════════════════════════════════════════
s = add_slide()
bg(s, RGBColor(0x00, 0x1E, 0x14))
accent_bar(s)

# Coin
box(s, 5.9, 1.2, 1.5, 1.5, fill=GREEN)
txt(s, "₱", 5.9, 1.2, 1.5, 1.5,
    size=48, bold=True, color=NAVY, align=PP_ALIGN.CENTER)

txt(s, "LIVE DEMO", 1, 2.85, 11.3, 0.45,
    size=12, bold=True, color=GREEN, align=PP_ALIGN.CENTER)
txt(s, "Let's see SmartSpend in action", 1, 3.3, 11.3, 0.75,
    size=32, bold=True, color=WHITE, align=PP_ALIGN.CENTER)
txt(s, "Demo device loaded with realistic Filipino spending data",
    1, 4.1, 11.3, 0.45, size=16, color=GRAY, align=PP_ALIGN.CENTER)

demo_items = [("Taglish AI logging", "💬"), ("FHS breakdown tap", "📊"),
              ("Batch screenshot import", "🖼️"), ("Analytics overview", "📈")]
for i, (label, icon) in enumerate(demo_items):
    box(s, 1.5 + i * 2.7, 4.75, 2.4, 0.75,
        fill=RGBColor(0x00, 0x28, 0x1E), line=GREEN, line_width_pt=0.5)
    txt(s, f"{icon}  {label}", 1.6 + i * 2.7, 4.85, 2.2, 0.55,
        size=11, color=GREEN, align=PP_ALIGN.CENTER)

txt(s, "📲  Download: zushikina-kun.github.io/smartspend-app/   ·   Version v3.1.2",
    1, 5.75, 11.3, 0.45, size=13, color=GRAY, align=PP_ALIGN.CENTER)
txt(s, "Open the app → tap \"Try Demo\" on the login screen",
    1, 6.18, 11.3, 0.4, size=12, color=GRAY, align=PP_ALIGN.CENTER, italic=True)

txt(s, "14 / 15", 12.3, 7.1, 0.8, 0.3, size=10, color=GRAY, align=PP_ALIGN.RIGHT)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 15 — CLOSING
# ══════════════════════════════════════════════════════════════════════════════
s = add_slide()
bg(s, RGBColor(0x04, 0x10, 0x1C))
accent_bar(s)

box(s, 6.0, 0.9, 1.3, 1.3, fill=GREEN)
txt(s, "₱", 6.0, 0.9, 1.3, 1.3,
    size=40, bold=True, color=NAVY, align=PP_ALIGN.CENTER)

txt(s, "Thank you for listening!", 1, 2.3, 11.3, 0.75,
    size=36, bold=True, color=WHITE, align=PP_ALIGN.CENTER)
txt(s, "SmartSpend — Spend Smart, Live Better.\nAn offline-first, Taglish AI-powered financial companion built for every Filipino.",
    1, 3.1, 11.3, 0.85, size=15, color=GRAY, align=PP_ALIGN.CENTER, italic=True)

# Team
for i, (name, role) in enumerate([
    ("Brix A. Directo", "Lead Developer"),
    ("Cyrille John M. Rubis", "UI/UX & Documentation"),
    ("Djaunathan Albert S. Madayag", "Project Manager & QA"),
]):
    box(s, 0.8 + i * 3.95, 4.1, 3.6, 0.9,
        fill=RGBColor(0x06, 0x14, 0x10), line=GREEN, line_width_pt=0.5)
    txt(s, name, 0.85 + i * 3.95, 4.15, 3.5, 0.42, size=12, bold=True, color=WHITE)
    txt(s, role, 0.85 + i * 3.95, 4.54, 3.5, 0.38, size=10, color=GRAY)

txt(s, "Adviser: Ms. Ellen F. Mangaoang, DIT   ·   Lorma Colleges CCSE   ·   November 9, 2026",
    1, 5.2, 11.3, 0.4, size=12, color=GRAY, align=PP_ALIGN.CENTER)

box(s, 2.5, 5.8, 8.3, 0.95,
    fill=RGBColor(0x00, 0x28, 0x1E), line=GREEN, line_width_pt=0.5)
txt(s, "We are now open for questions.",
    2.5, 5.85, 8.3, 0.45, size=14, bold=True, color=GREEN, align=PP_ALIGN.CENTER)
txt(s, "Prepared answers: see DEFENSE_QA_PREP.md   ·   FHS formula: see FHS_FORMULA_DERIVATION_DEFENSE_GUIDE.md",
    2.5, 6.27, 8.3, 0.4, size=10, color=GRAY, align=PP_ALIGN.CENTER)

txt(s, "15 / 15", 12.3, 7.1, 0.8, 0.3, size=10, color=GRAY, align=PP_ALIGN.RIGHT)


# ══════════════════════════════════════════════════════════════════════════════
# SLIDE 16 — COMPETITOR COMPARISON (bonus slide, shown if panel asks)
# ══════════════════════════════════════════════════════════════════════════════
COMPETITORS = [
    ("BudgetPH",     "✅ Filipino", "❌ No", "❌ No", "❌ No", "Payday-cycle, paluwagan — no AI, no screenshot import"),
    ("P1SO Budget",  "❌ Generic",  "❌ No", "❌ No", "✅ Yes","100% offline, no ads — manual only, no AI or FHS"),
    ("GoodBudget",   "❌ Generic",  "❌ No", "❌ No", "❌ No", "Envelope budgeting — no Filipino context"),
    ("Spendee",      "❌ Generic",  "❌ No", "❌ No", "❌ No", "Paid, bank-linked — no offline, no Taglish"),
    ("SmartSpend ✅","✅ Taglish AI","✅ Yes","✅ Yes","✅ Yes","All 4 differentiators combined — only integrated PH solution"),
]

s = add_slide()
bg(s, RGBColor(0x08, 0x0F, 0x18))
accent_bar(s)
tag_label(s, "CHAPTER II  ·  COMPETITOR ANALYSIS (BACKUP SLIDE)")
title_text(s, "Competitor Gap Analysis — Why SmartSpend?")

col_labels = ["App", "Language", "GCash Import", "FHS (0-100)", "Offline", "Key Differentiator"]
col_widths  = [1.8,  1.5,        1.4,           1.4,           1.1,     5.4]
x0 = 0.3
for j, (h, w) in enumerate(zip(col_labels, col_widths)):
    box(s, x0 + sum(col_widths[:j]), 1.85, w, 0.5,
        fill=RGBColor(0x00, 0x40, 0x30), line=GREEN, line_width_pt=0.5)
    txt(s, h, x0 + sum(col_widths[:j]) + 0.08, 1.9, w - 0.1, 0.4,
        size=10, bold=True, color=GREEN)

for i, row in enumerate(COMPETITORS):
    is_smart = (i == len(COMPETITORS) - 1)
    fill_c = RGBColor(0x00, 0x28, 0x1E) if is_smart else (
             RGBColor(0x0A, 0x14, 0x10) if i % 2 == 0 else RGBColor(0x06, 0x10, 0x0C))
    for j, (cell, w) in enumerate(zip(row, col_widths)):
        box(s, x0 + sum(col_widths[:j]), 2.38 + i * 0.82, w, 0.78,
            fill=fill_c, line=GREEN if is_smart else RGBColor(0x1A, 0x3A, 0x2A),
            line_width_pt=1.0 if is_smart else 0.4)
        c = GREEN if is_smart else (
            GREEN if "✅" in cell else RED if "❌" in cell else GRAY)
        txt(s, cell, x0 + sum(col_widths[:j]) + 0.08, 2.42 + i * 0.82,
            w - 0.1, 0.7, size=11, color=c, bold=(is_smart and j == 0), wrap=True)

txt(s, "Sources: BudgetPH (kindlyf.com, Nov 2026), P1SO Budget (pisobudget.com), GoodBudget, Spendee — feature set verified against public listings",
    0.3, 6.88, 12.7, 0.35, size=10, color=GRAY)
txt(s, "16 / 16", 12.3, 7.1, 0.8, 0.3, size=10, color=GRAY, align=PP_ALIGN.RIGHT)


output = r"c:\xampp\htdocs\smartspend_app\docs\capstone\SmartSpend_Defense_Presentation.pptx"
prs.save(output)
print(f"\n✅  Saved: {output}")
print(f"   16 slides  ·  13.33×7.5 inches (widescreen 16:9)")
print(f"   Slide 16 = Competitor comparison (backup/bonus slide)")
print(f"\nScreenshots needed for full presentation:")
print(f"  Take these on demo phone (v3.1.2 + Try Demo loaded):")
print(f"  1. Home screen — FHS card with Peso tier ring, wallets, Safe-to-Spend")
print(f"  2. AI chat — 'nag-gastos ako ng 65 sa canteen' → clean Peso reply")
print(f"  3. FHS breakdown dialog — 4 components with points")
print(f"  4. Analytics overview — pie chart + 50/30/20")
print(f"  5. Achievements — badge grid (36 badges)")
print(f"  Drop into docs/debug/screenshots/v3.1.2/ then tell Kiro to update.")
print(f"\n[PENDING] slides to update when survey data arrives:")
print(f"  Slide 11 (SUS Results) · Slide 12 (Conclusions Obj 1 & 3)")
