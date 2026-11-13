"""
Deep cross-check: PPT slide content vs manuscript.
Extracts key facts from manuscript and compares against each PPT slide.
Reports every discrepancy found.
"""
from docx import Document
from pptx import Presentation
import re

DOCX   = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL.docx"
PPT    = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\SmartSpend_Defense.pptx"
SCRIPT = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\4_DEFENSE_SCRIPT_FINAL.md"

doc = Document(DOCX)
prs = Presentation(PPT)
script = open(SCRIPT, encoding='utf-8').read()

# ── Extract manuscript full text ──────────────────────────────────────────
ms_text = '\n'.join(p.text for p in doc.paragraphs)
ms_tables = '\n'.join(c.text for t in doc.tables for row in t.rows for c in row.cells)
ms_full = ms_text + '\n' + ms_tables

# ── Extract PPT full text per slide ───────────────────────────────────────
def slide_text(slide):
    texts = []
    def get(shape):
        if shape.has_text_frame:
            texts.append(shape.text_frame.text)
        if shape.shape_type == 6:
            for s in shape.shapes: get(s)
    for shape in slide.shapes: get(shape)
    return ' | '.join(t.strip() for t in texts if t.strip())

ppt_all = ''
for i, slide in enumerate(prs.slides):
    t = slide_text(slide)
    ppt_all += t + '\n'
    notes = slide.notes_slide.notes_text_frame.text.strip()
    if notes: ppt_all += notes + '\n'

issues = []

def chk(label, condition, detail=''):
    if not condition:
        issues.append(f'  ❌ {label}' + (f'\n     → {detail}' if detail else ''))
    else:
        issues.append(f'  ✅ {label}')

print("=" * 60)
print("CROSS-CHECK: PPT vs MANUSCRIPT")
print("=" * 60)

# ── SLIDE 3 — Problem / statistics ───────────────────────────────────────
print("\nSlide 3 — Problem / Statistics:")
chk("2% BSP stat", '2%' in ppt_all)
chk("50% budget stat", '50%' in ppt_all or '< 50%' in ppt_all)
chk("10% mobile app stat (needs assessment)", '10%' in ppt_all)
# MS has CFIS 2025: 74% literacy
chk("BSP CFIS 2025 reference", 'CFIS' in ppt_all or 'cfis' in ppt_all.lower() or '2025' in ppt_all)
chk("MS: 74% literacy (CFIS 2025)", '74%' in ms_full)

# ── SLIDE 4 — Gap Analysis / Table 1 ─────────────────────────────────────
print("\nSlide 4 — Gap Analysis (Table 1):")
chk("Table 1 ref in PPT", 'Table 1' in ppt_all or 'Table 2' in ppt_all)
chk("MS Table 1 three levels", 'International' in ms_full and 'National' in ms_full and 'Demographic' in ms_full)
chk("PPT has three gap levels", 'International' in ppt_all and 'National' in ppt_all and 'Demographic' in ppt_all)

# ── SLIDE 5 — Feature Comparison / Table 2 ───────────────────────────────
print("\nSlide 5 — Feature Comparison (Table 2):")
chk("PPT refs Table 2", 'Table 2' in ppt_all)
# MS Table 2 has these apps
for app in ['Tarsi', 'YNAB', 'Monarch', 'Copilot']:
    chk(f"App '{app}' in MS Table 2", app in ms_full)
# Check PPT mentions them or at least the table
chk("PPT acknowledges comparison", 'Table 2' in ppt_all or 'comparison' in ppt_all.lower())
# MS: PocketGuard is discussed in body but NOT in Table 2 columns
chk("MS: PocketGuard in body text", 'PocketGuard' in ms_full)

# ── SLIDE 6 — Objectives ─────────────────────────────────────────────────
print("\nSlide 6 — Objectives:")
chk("PPT Obj 1: assess practices", 'assess' in ppt_all.lower() or 'financial management practices' in ppt_all.lower())
chk("PPT Obj 2: design and develop", 'design and develop' in ppt_all.lower())
chk("PPT Obj 3: SUS", 'SUS' in ppt_all or 'System Usability Scale' in ppt_all)
# Age ranges
chk("PPT has 35-55 age range", '35' in ppt_all and '55' in ppt_all)
chk("PPT has 21-35 age range", '21' in ppt_all and '35' in ppt_all)
chk("MS: San Fernando City La Union", 'San Fernando City' in ms_full)
chk("PPT has La Union mention", 'La Union' in ppt_all)

# ── SLIDE 8 — Methodology ────────────────────────────────────────────────
print("\nSlide 8 — Methodology:")
chk("PPT: quantitative descriptive developmental", 'quantitative descriptive developmental' in ppt_all.lower())
chk("PPT: random sampling", 'random sampling' in ppt_all.lower())
chk("PPT: 16 parents needs assessment", '16' in ppt_all)
chk("PPT: 14 YP needs assessment", '14' in ppt_all)
chk("PPT: 10 parents SUS", '10' in ppt_all)
chk("PPT: 20 YP SUS", '20' in ppt_all)
chk("PPT: 30 valid of 36", '30' in ppt_all and '36' in ppt_all)
chk("PPT: purposive for validator", 'purposive' in ppt_all.lower() or 'validator' in ppt_all.lower())
# MS: separate groups
chk("MS: separate groups stated", 'separate group' in ms_full or 'separate samples' in ms_full or 'separately' in ms_full)

# ── SLIDE 9 — Objective 1 Results ────────────────────────────────────────
print("\nSlide 9 — Objective 1 Results:")
chk("PPT: 96.7%", '96.7' in ppt_all)
chk("PPT: 93.3%", '93.3' in ppt_all)
chk("PPT: 29 of 30", '29' in ppt_all)
chk("PPT: 28 of 30", '28' in ppt_all)
# MS also has: receipts 90%, mental estimates 53.3%, e-wallet 43.3%
chk("MS: receipts 90%", '90.0%' in ms_full or '90%' in ms_full)
chk("PPT has tracking methods chart", 'tracking' in ppt_all.lower() or 'receipt' in ppt_all.lower())

# ── SLIDE 10 — System Overview ───────────────────────────────────────────
print("\nSlide 10 — System Overview:")
chk("PPT: 34 AI actions", '34' in ppt_all)
chk("PPT: 7 input modalities", '7' in ppt_all)
chk("PPT: 26 SQLite tables", '26' in ppt_all)
chk("PPT: 45 screens", '45' in ppt_all)
chk("PPT: 36 badges", '36' in ppt_all)
chk("MS: 34 agentic actions", '34 autonomous' in ms_full or '34 agentic' in ms_full or '34 autonomous financial' in ms_full)
chk("PPT: 9 AI providers", '9' in ppt_all)
# MS says 8-provider chain, 7 fallbacks
chk("MS: eight-provider chain", 'eight-provider' in ms_full)
chk("PPT: APK size ~47.5MB", '47.5' in ppt_all or 'APK' in ppt_all)

# ── SLIDE 11 — Screenshots / Figure numbers ──────────────────────────────
print("\nSlide 11 — App Screenshots:")
# MS now has figures renumbered — after merge we have different figure numbers
# Check what figure numbers are in PPT for screenshots
slide11_text = slide_text(prs.slides[10])
print(f"  PPT Slide 11 text: {slide11_text[:300]}")
# MS: Login=Fig 13, Home=Fig 14, Chat=Fig 15, Receipt=Fig 16, FHS=Fig 17
# (after the merge with Ellen's V4 which added more figures in Ch1/Ch2)
# Let's check what the MS actually says now
for fig_ref in ['Figure 13', 'Figure 14', 'Figure 15', 'Figure 16', 'Figure 17']:
    chk(f"MS has {fig_ref}", fig_ref in ms_full or fig_ref.replace(' ', '\xa0') in ms_full)
# What does PPT say?
for fig_ref in ['Figure 9', 'Figure 10', 'Figure 11', 'Figure 12', 'Figure 13']:
    if fig_ref in slide11_text:
        print(f"  PPT Slide 11 uses {fig_ref}")

# ── SLIDE 12 — LLM Selection ─────────────────────────────────────────────
print("\nSlide 12 — LLM Selection:")
chk("PPT: 8 candidate LLM APIs", '8 candidate LLM APIs' in ppt_all or 'eight candidate' in ppt_all.lower())
chk("PPT: Gemini 3.5 Flash-Lite", 'Gemini 3.5 Flash-Lite' in ppt_all)
chk("PPT: No Gemini 1.5", 'Gemini 1.5' not in ppt_all)
chk("PPT: 7 fallback providers", '7 fallback' in ppt_all or 'seven fallback' in ppt_all.lower())
chk("MS: Table 6 LLM comparison", 'Gemini 3.5 Flash-Lite' in ms_tables)
# MS: "eight candidate LLM APIs" in body
chk("MS: eight candidate LLM APIs", 'eight candidate LLM APIs' in ms_full)
# PPT: mentions 1M token context
chk("PPT: 1M token context", '1M' in ppt_all or '1,048' in ppt_all or 'million' in ppt_all.lower())

# ── SLIDE 13 — FHS ───────────────────────────────────────────────────────
print("\nSlide 13 — Financial Health Score:")
chk("PPT: 4 components Full Mode", 'Savings Rate' in ppt_all and 'Overspend Control' in ppt_all)
chk("PPT: Budget Adherence", 'Budget Adherence' in ppt_all)
chk("PPT: Logging Consistency", 'Logging Consistency' in ppt_all)
chk("PPT: Lightweight Mode", 'Lightweight Mode' in ppt_all or 'Lightweight' in ppt_all)
chk("MS: FHS prototype indicator", 'Prototype Observed Financial Health Indicator' in ms_full)
chk("PPT: Prototype FHS mention", 'prototype' in ppt_all.lower() or 'Prototype Observed' in ppt_all)

# ── SLIDE 14 — Privacy ───────────────────────────────────────────────────
print("\nSlide 14 — Privacy Tiers:")
chk("PPT: Cloud AI tier", 'Cloud AI' in ppt_all)
chk("PPT: Local Mode tier", 'Local' in ppt_all)
chk("PPT: On-device planned", 'Planned' in ppt_all or 'planned' in ppt_all)
chk("PPT: 150 AI requests limit", '150' in ppt_all)
chk("MS: on-device redaction", 'redact' in ms_full.lower())
chk("PPT: RA 10173 / Data Privacy Act", 'Data Privacy Act' in ppt_all or '10173' in ppt_all or '2012' in ppt_all)

# ── SLIDE 15 — SUS Results ───────────────────────────────────────────────
print("\nSlide 15 — SUS Results:")
chk("PPT: 61.83", '61.83' in ppt_all)
chk("PPT: SD 17.58", '17.58' in ppt_all)
chk("PPT: Grade D", 'Grade D' in ppt_all)
chk("PPT: OK adjective", '"OK"' in ppt_all or 'adjective "OK"' in ppt_all)
chk("PPT: Below 68", '68' in ppt_all)
chk("PPT: Below 80 target", '80' in ppt_all)
chk("PPT: Q1 mean 4.35", '4.35' in ppt_all)
chk("PPT: Q9 mean 4.19", '4.19' in ppt_all)
chk("PPT: Q6 Q2 concerns", 'Q6' in ppt_all and 'Q2' in ppt_all)
chk("MS: median 55.0", '55.00' in ms_full or '55.0' in ms_full)
chk("PPT: median 55.0", '55.0' in ppt_all or '55' in ppt_all)
chk("PPT: N=30 valid of 36", '30' in ppt_all and '36' in ppt_all)

# ── SLIDE 16 — Limitations ───────────────────────────────────────────────
print("\nSlide 16 — Limitations:")
chk("PPT: parsing accuracy figures", '91.2%' in ppt_all or '88.5%' in ppt_all)
chk("MS: parsing accuracy in manuscript", '91.2' in ms_full or '88.5' in ms_full)
chk("PPT: Android only limitation", 'Android' in ppt_all)
chk("PPT: internet required", 'internet' in ppt_all.lower() or 'connection' in ppt_all.lower())

# ── SLIDE 17 — Conclusions ───────────────────────────────────────────────
print("\nSlide 17 — Conclusions:")
chk("PPT: Obj 1 Achieved", 'Achieved' in ppt_all)
chk("PPT: Obj 2 Achieved", '34 AI actions' in ppt_all or 'v3.1.0' in ppt_all)
chk("PPT: Obj 3 Partially achieved", 'Partially achieved' in ppt_all or 'partially achieved' in ppt_all.lower())
chk("MS: eight candidate LLM in conclusions", 'eight candidate LLM' in ms_full)
chk("PPT Slide 17: eight candidate", 'eight candidate' in slide_text(prs.slides[16]).lower())

# ── SLIDE 18 — Recommendations ───────────────────────────────────────────
print("\nSlide 18 — Recommendations:")
chk("PPT: Recs 1-7 on slide", 'Payday' in ppt_all and 'Backend API' in ppt_all)
chk("PPT notes: Rec 8 UI/UX", 'UI/UX refinement' in ppt_all)
chk("PPT notes: Rec 9 parsing", 'Formal parsing' in ppt_all or 'parsing evaluation' in ppt_all.lower())
chk("MS: 9 recommendations total", '9. Formal parsing evaluation' in ms_full)

# ── Summary ───────────────────────────────────────────────────────────────
print("\n" + "=" * 60)
print("SUMMARY")
print("=" * 60)
pass_count = sum(1 for i in issues if i.strip().startswith('✅'))
fail_count = sum(1 for i in issues if i.strip().startswith('❌'))
for i in issues:
    print(i)
print(f"\n✅ {pass_count} pass   ❌ {fail_count} issues found")
