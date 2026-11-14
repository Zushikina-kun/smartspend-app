"""
Audit the Source of Truth manuscript against the SMARTSPEND_MASTER_FIX_GUIDE.
Checks every item and reports DONE / NEEDS FIX / CHECK MANUALLY.
"""
from docx import Document

DOCX = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\Source of Truth\1_MAIN_MANUSCRIPT_FINAL.docx"
doc  = Document(DOCX)

ms_text   = '\n'.join(p.text for p in doc.paragraphs)
ms_tables = '\n'.join(c.text for t in doc.tables for row in t.rows for c in row.cells)
ms = ms_text + '\n' + ms_tables
ml = ms.lower()

results = []

def chk(label, done, note=''):
    results.append((label, done, note))

# ── ABSTRACT / CHAPTER I ─────────────────────────────────────────────────
chk('E3: Table 2 ref in Ch1 (not Table 3)',
    'Table 2 summarized the key feature differences' in ms or
    'Table 2 summarized' in ms)

chk('E4: Tech BG LLM: "ten candidate models from four providers"',
    'ten candidate models from four providers' in ms)

chk('E5: Tech BG citations removed (Sloane, Bociek, etc.)',
    '(Sloane, 2022)' not in ms and
    '(Bociek, 2023' not in ms and
    '(Flutter 4 Fun, 2022)' not in ms and
    '(The Flutter Authors, 2013)' not in ms,
    'Check also: Google 2024a/b/c/e removed from Tech BG')

chk('E6: "eight-model cloud failover chain" in abstract',
    'eight-model cloud failover chain' in ms)

chk('E6: "eight-model" in Ch1 Tech BG',
    'eight-model cloud failover chain' in ms)

# ── CHAPTER II RESEARCH DESIGN ───────────────────────────────────────────
chk('E7: Research Design para 1 is quantitative-only (no "both qualitative and quantitative")',
    'both qualitative and quantitative' not in ml)

chk('E8: "On the other hand, the quantitative aspect" deleted',
    'On the other hand, the quantitative aspect' not in ms)

chk('E9: "based on the survey and usability data gathered"',
    'based on the survey and usability data gathered' in ms)

chk('E10: "By adopting a quantitative descriptive developmental approach"',
    'By adopting a quantitative descriptive developmental approach' in ms)

chk('E10: "This research design supported"',
    'This research design supported' in ms)

# ── POPULATION ───────────────────────────────────────────────────────────
chk('E11: Population opening sentence fixed (no "1 content validator as seen in Table 3")',
    '1 content validator as seen in Table 3' not in ms and
    'One content validator participated separately' in ms)

chk('E12: Sampling paragraph has 13/14/3 split (Option B: also has 16+14 total)',
    'Thirteen (13) respondents were parents' in ms and
    'Fourteen (14) respondents were young professionals' in ms and
    'Three (3) respondents identified as both' in ms)

chk('E12: Option B classification note present',
    'counted with the parent group' in ms or
    'classified as parents based on' in ms or
    'Q1 age bracket' in ms)

chk('E13: Table 3 shows 16+14=30 (Option B)',
    '16' in ms_tables and '14' in ms_tables)

chk('E13: Table 3 validator note present',
    'content validator' in ml and 'separately' in ml and ('not counted' in ml or 'is not included' in ml))

chk('E13: Stray duplicate validator note above Fig4 deleted',
    ms_text.count('content validator participated separately') <= 1,
    'Should appear only once (in Table 3 note or Population)')

chk('E14: Validator "(see Appendix D)" present',
    '(see Appendix D)' in ms)

chk('E14: "Technical Validation Certificate" sentence deleted',
    'Technical Validation Certificate' not in ms)

chk('E14: "intentional selection" language removed',
    'intentional selection' not in ml)

chk('E14: Replacement random sampling sentence present',
    'eligible to participate, and respondents were selected at random' in ms)

chk('E15: "(see Appendix B)" in Ethical Considerations',
    '(see Appendix B)' in ms)

chk('E16: Appendix D ref in Data Gathering',
    ms.count('(see Appendix D)') >= 2,
    'Should appear at least twice: validator para + data gathering')

# ── SOFTWARE METHODOLOGY ─────────────────────────────────────────────────
chk('E17: "Figure 4" (not "Figure #")',
    'Figure #' not in ms and 'Figure 4' in ms)

chk('E17: Done/Review future-features list removed',
    'multi-wallet system enabling separate tracking' not in ms and
    'GCash, Maya, GrabPay, ShopeePay, BDO, BPI' not in ms)

# ── CHAPTER III ───────────────────────────────────────────────────────────
chk('E18: Table 5 note says "parents n = 16" (Option B)',
    'parents n = 16' in ms or '(parents n = 16' in ms)

chk('E18: Table 5 intro: "16 parents aged 35-55 (53.3%)"',
    '16 parents aged 35' in ms or '16 parents aged 35–55' in ms)

chk('E18: "SUS evaluation used a separate group" sentence',
    'SUS evaluation used a separate group' in ms or
    'separate group of respondents' in ms)

chk('E19: Chapter III heading fixed (Design and Development of)',
    'Designed and Developed of' not in ms)

chk('E19: "EXPLAIN WHAT DID" placeholder removed',
    'EXPLAIN WHAT DID IN THE DESIGN AND DEVELOPMENT' not in ms)

chk('E19: Design rationale paragraph present',
    'Guided by the needs assessment results, the researchers designed SmartSpend' in ms)

chk('E20: "From the ten candidate models in Table 6"',
    'From the ten candidate models in Table 6' in ms or
    'ten candidate models' in ms)

chk('E21: Peso/dopamine note deleted',
    'dopamine' not in ml and
    'Present Peso as a design feature' not in ms)

chk('E21: "open item" note deleted',
    'known open item pending confirmation' not in ms)

chk('E21: "Introductory paragraph then table" placeholder deleted',
    'Introductory paragraph then table then discussion' not in ms)

chk('E22: Figure 15 description is Peso chat (not Local AI)',
    'Local AI Mode setup screen' not in ms or
    'nag-lunch' in ms or 'Peso chat' in ml)

chk('E22: Figure 17 description is FHS Breakdown (not SUS dist)',
    'distribution of individual SUS scores' not in ms or
    'Financial Health Score breakdown' in ms)

chk('E22: Figure 18 description is Budgets screen (not SUS by group)',
    'SUS scores broken down by respondent group' not in ms or
    'Budgets screen' in ms)

chk('E22: Figure 11 include relationship corrected',
    '"View FHS Score" and "Calculate FHS"' in ms or
    'View FHS Score' in ms)

chk('E22: Figure 14 Expert Tracker label',
    'Expert Tracker' in ms)

# ── CHAPTER III SUS ───────────────────────────────────────────────────────
chk('E23: "Tables 7 and 8" (not "Tables 3.3 and 3.4")',
    'Tables 3.3 and 3.4' not in ms)

chk('E23: "No formal open-ended survey data" (lowercase s, no interviews)',
    'no interviews were conducted' in ml or
    'no open-ended or interview data' in ml)

# ── CHAPTER IV ────────────────────────────────────────────────────────────
chk('E24: Conclusions: "ten candidate models from four providers"',
    'ten candidate models from four providers' in ms)

chk('E24: Conclusions: "eight-model cloud failover chain"',
    'eight-model cloud failover chain' in ms)

chk('E24: Conclusions: no "20 candidate LLM models"',
    '20 candidate LLM' not in ms)

chk('E24: Conclusions: third objective "partially achieved"',
    'partially achieved' in ml)

chk('E25: Google 2024f in references',
    '2024f' in ms)

chk('E25: UNSGSA/Gubbins citation fixed',
    'Gubbins' in ms or 'UNSGSA' in ms)

# ── FRONT MATTER ─────────────────────────────────────────────────────────
chk('E1: Only one TOC (old one with Transcript of Interview deleted)',
    ms.count('TABLE OF CONTENTS') <= 2,
    'If > 2 occurrences, old TOC may still be present')

chk('E1: "Transcript of Interview" appendix removed',
    'Transcript of Interview' not in ms)

chk('E2: Appendix C = SUS Questionnaire (not SUS Individual Scores)',
    'APPENDIX C: SUS Individual Scores' not in ms or
    'APPENDIX C: System Usability Scale' in ms or
    'APPENDIX C: SUS Questionnaire' in ms)

# ── PRINT RESULTS ─────────────────────────────────────────────────────────
print(f"\n{'='*65}")
print(f"AUDIT: Source of Truth vs SMARTSPEND_MASTER_FIX_GUIDE")
print(f"{'='*65}")

done  = [(l, n) for l, ok, n in results if ok]
needs = [(l, n) for l, ok, n in results if not ok]

print(f"\n✅ DONE ({len(done)}):")
for l, n in done:
    note = f'  ({n})' if n else ''
    print(f"  ✅ {l}{note}")

print(f"\n❌ NEEDS FIX ({len(needs)}):")
for l, n in needs:
    note = f'\n     ℹ️  {n}' if n else ''
    print(f"  ❌ {l}{note}")

print(f"\n{'='*65}")
print(f"Total: {len(done)}/{len(results)} done, {len(needs)} remaining")
