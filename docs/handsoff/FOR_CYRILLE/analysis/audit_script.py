"""
READ-ONLY audit script for 1_MAIN_MANUSCRIPT_FINAL.docx
Finds: wrong instructor names, wrong tense, other name inconsistencies
"""
from docx import Document
import re
from datetime import datetime

DOCX_PATH = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
REPORT_PATH = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\analysis\TENSE_AND_NAMES_AUDIT_NOV10.md'

doc = Document(DOCX_PATH)

# ── Collect all paragraphs (body + tables) ──────────────────────────────────
paras = []
for i, p in enumerate(doc.paragraphs):
    if p.text.strip():
        paras.append({'idx': i, 'text': p.text, 'style': p.style.name})

for t_idx, table in enumerate(doc.tables):
    for r_idx, row in enumerate(table.rows):
        for c_idx, cell in enumerate(row.cells):
            for p in cell.paragraphs:
                if p.text.strip():
                    paras.append({
                        'idx': f'TABLE_{t_idx}_R{r_idx}_C{c_idx}',
                        'text': p.text,
                        'style': 'table'
                    })

# ── Helper: guess chapter/section from style or nearby heading ───────────────
def guess_location(idx, text, style):
    """Rough heuristic: use paragraph style or text content."""
    if isinstance(idx, str):
        return "Table Cell"
    t = text.lower()
    if 'abstract' in t:
        return "Abstract"
    if 'acknowledg' in t:
        return "Acknowledgements"
    if 'chapter i' in t and 'chapter ii' not in t:
        return "Chapter I"
    if 'chapter ii' in t and 'chapter iii' not in t:
        return "Chapter II"
    if 'chapter iii' in t:
        return "Chapter III"
    if 'chapter iv' in t:
        return "Chapter IV"
    if 'conclusion' in t or 'recommendation' in t:
        return "Chapter IV"
    if 'result' in t or 'discussion' in t:
        return "Chapter III"
    if 'approval' in t:
        return "Approval Sheet"
    if 'title' in style.lower() or idx < 30:
        return "Front Matter"
    return f"Para ~{idx}"

# ── Build a chapter-context map (scan for heading paragraphs) ────────────────
chapter_map = {}   # para index -> chapter label
current_chapter = "Front Matter"
for p in paras:
    if isinstance(p['idx'], int):
        txt_low = p['text'].lower().strip()
        if re.match(r'^chapter\s+i[^v]', txt_low) or txt_low == 'introduction':
            current_chapter = "Chapter I — Introduction"
        elif re.match(r'^chapter\s+ii[^i]', txt_low) or 'review of related' in txt_low:
            current_chapter = "Chapter II — Review of Related Literature"
        elif re.match(r'^chapter\s+iii', txt_low) or 'results and discussion' in txt_low:
            current_chapter = "Chapter III — Results and Discussion"
        elif re.match(r'^chapter\s+iv', txt_low) or ('conclusion' in txt_low and 'recommendation' in txt_low):
            current_chapter = "Chapter IV — Conclusions and Recommendations"
        elif 'abstract' in txt_low and len(p['text']) < 40:
            current_chapter = "Abstract"
        elif 'acknowledg' in txt_low and len(p['text']) < 40:
            current_chapter = "Acknowledgements"
        elif 'approval sheet' in txt_low:
            current_chapter = "Approval Sheet"
        elif 'title page' in txt_low or ('smartspend' in txt_low and p['idx'] < 5):
            current_chapter = "Title Page"
        chapter_map[p['idx']] = current_chapter

def get_chapter(p):
    if isinstance(p['idx'], str):
        return "Table Cell"
    # walk back to find nearest chapter label
    for i in range(p['idx'], -1, -1):
        if i in chapter_map:
            return chapter_map[i]
    return "Front Matter"

# Pre-populate chapter map by scanning all paragraphs
current_chapter = "Front Matter"
for p in paras:
    if isinstance(p['idx'], int):
        txt_low = p['text'].lower().strip()
        if re.match(r'^chapter\s+i\b', txt_low):
            current_chapter = "Chapter I — Introduction"
        elif re.match(r'^chapter\s+ii\b', txt_low):
            current_chapter = "Chapter II — Review of Related Literature"
        elif re.match(r'^chapter\s+iii\b', txt_low):
            current_chapter = "Chapter III — Results and Discussion"
        elif re.match(r'^chapter\s+iv\b', txt_low):
            current_chapter = "Chapter IV — Conclusions and Recommendations"
        elif txt_low.strip() == 'abstract':
            current_chapter = "Abstract"
        elif txt_low.strip() == 'acknowledgement' or txt_low.strip() == 'acknowledgements':
            current_chapter = "Acknowledgements"
        elif txt_low.strip() == 'approval sheet':
            current_chapter = "Approval Sheet"
        chapter_map[p['idx']] = current_chapter

# ── SECTION 1: WRONG INSTRUCTOR NAME ────────────────────────────────────────
# Patterns:
#   - "Janelli" anywhere
#   - "Mendez" anywhere
#   - "Dr. Raposas" or "Dr Raposas" (title should be Mr.)
#   - Any occurrence of "Raposas" — classify correct vs wrong
#   - Near "instructor" or "TIC" or "Teacher-in-Charge" — name check

name_findings = []

CORRECT_INSTRUCTOR = "Mr. Shekiro R. Raposas, MIT"

for p in paras:
    text = p['text']
    chapter = get_chapter(p)
    snippet = text[:150]

    # Check for "Janelli"
    for m in re.finditer(r'janelli', text, re.IGNORECASE):
        name_findings.append({
            'type': 'WRONG NAME — Janelli found',
            'severity': 'CRITICAL',
            'chapter': chapter,
            'idx': p['idx'],
            'snippet': snippet,
            'currently': m.group(0),
            'should': CORRECT_INSTRUCTOR,
            'context': text[max(0,m.start()-30):m.end()+60].strip(),
        })

    # Check for "Mendez" near instructor context
    for m in re.finditer(r'mendez', text, re.IGNORECASE):
        name_findings.append({
            'type': 'WRONG NAME — Mendez found',
            'severity': 'CRITICAL',
            'chapter': chapter,
            'idx': p['idx'],
            'snippet': snippet,
            'currently': text[max(0,m.start()-20):m.end()+40].strip(),
            'should': 'Check context — if instructor, should be ' + CORRECT_INSTRUCTOR,
            'context': text[max(0,m.start()-30):m.end()+60].strip(),
        })

    # Check for "Dr. Raposas" or "Dr Raposas" (wrong title)
    for m in re.finditer(r'dr\.?\s+raposas', text, re.IGNORECASE):
        name_findings.append({
            'type': 'WRONG TITLE — "Dr. Raposas" (should be Mr.)',
            'severity': 'CRITICAL',
            'chapter': chapter,
            'idx': p['idx'],
            'snippet': snippet,
            'currently': m.group(0),
            'should': CORRECT_INSTRUCTOR,
            'context': text[max(0,m.start()-20):m.end()+60].strip(),
        })

    # Check all Raposas occurrences — look for wrong first name or no "Shekiro"
    for m in re.finditer(r'raposas', text, re.IGNORECASE):
        surrounding = text[max(0,m.start()-50):m.end()+50]
        # Is it correct? Should contain Shekiro
        has_shekiro = bool(re.search(r'shekiro', surrounding, re.IGNORECASE))
        has_mr = bool(re.search(r'\bMr\.?\b', surrounding, re.IGNORECASE))
        has_dr = bool(re.search(r'\bDr\.?\b', surrounding, re.IGNORECASE))
        # Flag if no "Shekiro" near it (possible wrong first name)
        if not has_shekiro:
            name_findings.append({
                'type': 'POSSIBLE WRONG NAME — "Raposas" without "Shekiro" nearby',
                'severity': 'HIGH',
                'chapter': chapter,
                'idx': p['idx'],
                'snippet': snippet,
                'currently': surrounding.strip(),
                'should': CORRECT_INSTRUCTOR + ' (verify full name is used)',
                'context': surrounding.strip(),
            })
        # Flag if Dr. title used
        if has_dr:
            name_findings.append({
                'type': 'WRONG TITLE — Dr. used instead of Mr. for Raposas',
                'severity': 'CRITICAL',
                'chapter': chapter,
                'idx': p['idx'],
                'snippet': snippet,
                'currently': surrounding.strip(),
                'should': CORRECT_INSTRUCTOR,
                'context': surrounding.strip(),
            })

    # Check TIC / Teacher-in-Charge / instructor in charge
    for m in re.finditer(r'(teacher[\-\s]in[\-\s]charge|instructor[\-\s]in[\-\s]charge|\bTIC\b)', text, re.IGNORECASE):
        # check name nearby
        surrounding = text[max(0,m.start()-100):m.end()+100]
        has_shekiro = bool(re.search(r'shekiro', surrounding, re.IGNORECASE))
        has_janelli = bool(re.search(r'janelli', surrounding, re.IGNORECASE))
        has_raposas = bool(re.search(r'raposas', surrounding, re.IGNORECASE))
        if has_janelli:
            name_findings.append({
                'type': 'WRONG NAME near TIC/Teacher-in-Charge',
                'severity': 'CRITICAL',
                'chapter': chapter,
                'idx': p['idx'],
                'snippet': snippet,
                'currently': surrounding.strip(),
                'should': CORRECT_INSTRUCTOR,
                'context': surrounding.strip(),
            })
        elif not has_raposas and not has_shekiro:
            name_findings.append({
                'type': 'TIC/Teacher-in-Charge found — name not visible in context',
                'severity': 'MEDIUM',
                'chapter': chapter,
                'idx': p['idx'],
                'snippet': snippet,
                'currently': surrounding.strip(),
                'should': 'Verify name is ' + CORRECT_INSTRUCTOR,
                'context': surrounding.strip(),
            })

# De-duplicate by (idx, type, context)
seen = set()
unique_name = []
for f in name_findings:
    key = (str(f['idx']), f['type'][:40], f['context'][:60])
    if key not in seen:
        seen.add(key)
        unique_name.append(f)

# ── SECTION 2: TENSE ISSUES ──────────────────────────────────────────────────
tense_findings = []

# Patterns for wrong tense
TENSE_PATTERNS = [
    (r'\bhas been\b', 'has been → had been / was'),
    (r'\bhave been\b', 'have been → had been / were'),
    (r'\bis being\b', 'is being → was being'),
    (r'\bare being\b', 'are being → were being'),
    (r'\bwill be\b', 'will be → was / were'),
    (r'\bwill have\b', 'will have → had'),
    (r'\bwill\b', 'will → (past tense)'),
    (r'\bhelp ensure\b', '"help ensure" → "helped ensure"'),
    (r'\bhelps?\b', 'helps/help → helped (if describing study)'),
    # Present tense verbs describing the study
    (r'\bprovides?\b', 'provides/provide → provided'),
    (r'\ballows?\b', 'allows/allow → allowed'),
    (r'\bshows?\b', 'shows/show → showed'),
    (r'\bdisplays?\b', 'displays/display → displayed'),
    (r'\benables?\b', 'enables/enable → enabled'),
    (r'\buses?\b', 'uses/use → used (if describing study)'),
    (r'\bimplements?\b', 'implements/implement → implemented'),
    (r'\bgenerates?\b', 'generates/generate → generated'),
    (r'\banalyzes?\b', 'analyzes/analyze → analyzed'),
    (r'\bprocesses\b', 'processes → processed'),
    (r'\btracks?\b', 'tracks/track → tracked (if describing study)'),
    (r'\bintegrates?\b', 'integrates/integrate → integrated'),
    (r'\bsupports?\b', 'supports/support → supported'),
    (r'\boffers?\b', 'offers/offer → offered'),
    (r'\bcontributes?\b', 'contributes/contribute → contributed'),
    (r'\baddresses\b', 'addresses → addressed'),
    (r'\bdemonstrates?\b', 'demonstrates/demonstrate → demonstrated'),
    (r'\bindicates?\b', 'indicates/indicate → indicated'),
    (r'\bsuggests?\b', 'suggests/suggest → suggested'),
    (r'\breveals?\b', 'reveals/reveal → revealed'),
    (r'\bconfirms?\b', 'confirms/confirm → confirmed'),
    (r'\bvalidates?\b', 'validates/validate → validated'),
    (r'\bfinds?\b', 'finds/find → found'),
]

# Only flag tense in certain chapters (not lit review, which uses present for general truths)
TENSE_CHAPTERS = [
    "Abstract", "Acknowledgements",
    "Chapter III — Results and Discussion",
    "Chapter IV — Conclusions and Recommendations"
]

for p in paras:
    text = p['text']
    chapter = get_chapter(p)
    snippet = text[:150]

    # Only check tense-sensitive sections
    in_scope = any(ch in chapter for ch in ['Abstract', 'Acknowledg', 'Chapter III', 'Chapter IV'])
    if not in_scope:
        continue

    for pattern, suggestion in TENSE_PATTERNS:
        for m in re.finditer(pattern, text, re.IGNORECASE):
            context = text[max(0,m.start()-50):m.end()+80].strip()
            # Skip obvious false positives:
            # "will" in citations like "Williams", "willingness"
            word = m.group(0).lower()
            if word == 'will' and re.search(r'will\w', text[m.start():m.start()+10], re.IGNORECASE):
                continue
            # "helps" in "it helps the user" — only flag if describing the study
            # "shows" in figure captions — flag anyway, researcher can decide
            severity = 'HIGH'
            if pattern.startswith(r'\bwill\b'):
                severity = 'HIGH'
            elif 'has been' in suggestion or 'have been' in suggestion:
                severity = 'HIGH'
            elif 'help ensure' in suggestion:
                severity = 'HIGH'
            else:
                severity = 'MEDIUM'

            tense_findings.append({
                'type': 'WRONG TENSE',
                'severity': severity,
                'chapter': chapter,
                'idx': p['idx'],
                'snippet': snippet,
                'currently': m.group(0),
                'suggestion': suggestion,
                'context': context,
            })

# De-duplicate
seen2 = set()
unique_tense = []
for f in tense_findings:
    key = (str(f['idx']), f['currently'].lower(), f['context'][:60])
    if key not in seen2:
        seen2.add(key)
        unique_tense.append(f)

# ── SECTION 3: OTHER NAME INCONSISTENCIES ───────────────────────────────────
other_findings = []

# Adviser: should be "Ellen F. Mangaoang, DIT" or "Dr. Ellen F. Mangaoang"
for p in paras:
    text = p['text']
    chapter = get_chapter(p)
    snippet = text[:150]

    # Check Mangaoang for wrong variants
    for m in re.finditer(r'mangaoang', text, re.IGNORECASE):
        surrounding = text[max(0,m.start()-40):m.end()+40]
        # Check if "Ellen" is nearby
        has_ellen = bool(re.search(r'ellen', surrounding, re.IGNORECASE))
        has_dit = bool(re.search(r'DIT', surrounding))
        has_dr = bool(re.search(r'\bDr\.?\b', surrounding, re.IGNORECASE))
        # Flag if missing DIT (in formal references)
        if not has_ellen:
            other_findings.append({
                'type': 'ADVISER NAME — Missing first name "Ellen"',
                'severity': 'MEDIUM',
                'chapter': chapter,
                'idx': p['idx'],
                'snippet': snippet,
                'currently': surrounding.strip(),
                'should': 'Ellen F. Mangaoang, DIT',
            })

    # Check Layco spelling variants — flag anything other than Jeoffrey/Joeffrey
    for m in re.finditer(r'layco', text, re.IGNORECASE):
        surrounding = text[max(0,m.start()-30):m.end()+30]
        # Allowed: Jeoffrey OR Joeffrey (both are acceptable per user)
        has_jeoffrey = bool(re.search(r'j(?:eo|oe)ffrey', surrounding, re.IGNORECASE))
        if not has_jeoffrey:
            other_findings.append({
                'type': 'CHAIRPERSON — Layco first name variant',
                'severity': 'MEDIUM',
                'chapter': chapter,
                'idx': p['idx'],
                'snippet': snippet,
                'currently': surrounding.strip(),
                'should': 'Jeoffrey B. Layco (or Joeffrey)',
            })

    # Check for "Mendez"
    for m in re.finditer(r'mendez', text, re.IGNORECASE):
        surrounding = text[max(0,m.start()-40):m.end()+40]
        other_findings.append({
            'type': 'UNEXPECTED NAME — "Mendez" found',
            'severity': 'CRITICAL',
            'chapter': chapter,
            'idx': p['idx'],
            'snippet': snippet,
            'currently': surrounding.strip(),
            'should': 'Remove or replace — verify who this refers to',
        })

    # Check author name spelling
    # Brix A. Directo
    for m in re.finditer(r'directo', text, re.IGNORECASE):
        surrounding = text[max(0,m.start()-30):m.end()+30]
        has_brix = bool(re.search(r'brix', surrounding, re.IGNORECASE))
        if not has_brix:
            other_findings.append({
                'type': 'AUTHOR — Directo without "Brix"',
                'severity': 'LOW',
                'chapter': chapter,
                'idx': p['idx'],
                'snippet': snippet,
                'currently': surrounding.strip(),
                'should': 'Brix A. Directo',
            })

    # Cyrille John A. Rubis (note: title page says "M." — flag both)
    for m in re.finditer(r'rubis', text, re.IGNORECASE):
        surrounding = text[max(0,m.start()-30):m.end()+30]
        has_cyrille = bool(re.search(r'cyrille', surrounding, re.IGNORECASE))
        if not has_cyrille:
            other_findings.append({
                'type': 'AUTHOR — Rubis without "Cyrille"',
                'severity': 'LOW',
                'chapter': chapter,
                'idx': p['idx'],
                'snippet': snippet,
                'currently': surrounding.strip(),
                'should': 'Cyrille John A. Rubis',
            })

    # Djaunathan Albert G. Madayag
    for m in re.finditer(r'madayag', text, re.IGNORECASE):
        surrounding = text[max(0,m.start()-30):m.end()+30]
        has_djau = bool(re.search(r'djaunathan', surrounding, re.IGNORECASE))
        if not has_djau:
            other_findings.append({
                'type': 'AUTHOR — Madayag without "Djaunathan"',
                'severity': 'LOW',
                'chapter': chapter,
                'idx': p['idx'],
                'snippet': snippet,
                'currently': surrounding.strip(),
                'should': 'Djaunathan Albert G. Madayag',
            })

    # Check middle initial for Rubis (title page shows "M." but requirement says "A.")
    for m in re.finditer(r'cyrille\s+john\s+([A-Z])\.\s+rubis', text, re.IGNORECASE):
        mi = m.group(1).upper()
        if mi not in ('A', 'M'):
            other_findings.append({
                'type': 'AUTHOR — Rubis middle initial unexpected',
                'severity': 'HIGH',
                'chapter': chapter,
                'idx': p['idx'],
                'snippet': snippet,
                'currently': m.group(0),
                'should': 'Cyrille John A. Rubis (verify correct middle initial)',
            })

    # Also flag "Cyrille John M. Rubis" as potentially wrong (should be A.)
    for m in re.finditer(r'cyrille\s+john\s+M\.\s+rubis', text, re.IGNORECASE):
        other_findings.append({
            'type': 'AUTHOR — Rubis middle initial is "M." (should verify if A. is correct)',
            'severity': 'HIGH',
            'chapter': chapter,
            'idx': p['idx'],
            'snippet': snippet,
            'currently': m.group(0),
            'should': 'Cyrille John A. Rubis (verify — original requirement says A.)',
        })

# De-duplicate
seen3 = set()
unique_other = []
for f in other_findings:
    key = (str(f['idx']), f['type'][:50], f['currently'][:40])
    if key not in seen3:
        seen3.add(key)
        unique_other.append(f)

# ── Also do a targeted check on the actual text from the full dump ───────────
# Specifically check: approval sheet area, acknowledgements, abstract
# Look for the specific Rubis middle initial across all paras (not chapter scoped)
rubis_mi_issues = []
for p in paras:
    for m in re.finditer(r'cyrille\s+john\s+([A-Z])\.\s+rubis', p['text'], re.IGNORECASE):
        rubis_mi_issues.append({'idx': p['idx'], 'match': m.group(0), 'mi': m.group(1).upper()})

# ── BUILD THE REPORT ─────────────────────────────────────────────────────────
lines = []
lines.append("# Manuscript Audit Report — Tense & Names")
lines.append(f"**File audited:** 1_MAIN_MANUSCRIPT_FINAL.docx  ")
lines.append(f"**Date:** November 10, 2024  ")
lines.append(f"**Status:** READ-ONLY AUDIT — No changes made to manuscript  ")
lines.append(f"**Purpose:** Document all instances for correction AFTER adviser finishes manual edits  ")
lines.append("")
lines.append("---")
lines.append("")

# ── SECTION 1 ────────────────────────────────────────────────────────────────
lines.append("## SECTION 1: WRONG INSTRUCTOR NAME")
lines.append("")
if not unique_name:
    lines.append("*No instructor name issues found.*")
    lines.append("")
else:
    for n, f in enumerate(unique_name, 1):
        lines.append(f"### Finding {n}")
        lines.append(f"- **Issue type:** {f['type']}")
        lines.append(f"- **Severity:** {f['severity']}")
        lines.append(f"- **Location:** {f['chapter']}")
        lines.append(f"- **Paragraph index:** {f['idx']}")
        lines.append(f"- **Paragraph text (first 150 chars):** \"{f['snippet']}\"")
        lines.append(f"- **Currently says:** \"{f['currently']}\"")
        lines.append(f"- **Should say:** \"{f['should']}\"")
        lines.append(f"- **Full context:** \"{f['context']}\"")
        lines.append("")
        lines.append("---")
        lines.append("")

# ── SECTION 2 ────────────────────────────────────────────────────────────────
lines.append("## SECTION 2: TENSE ISSUES (Present/Future → Past)")
lines.append("")
if not unique_tense:
    lines.append("*No tense issues found.*")
    lines.append("")
else:
    for n, f in enumerate(unique_tense, 1):
        lines.append(f"### Finding {n}")
        lines.append(f"- **Issue type:** WRONG TENSE")
        lines.append(f"- **Severity:** {f['severity']}")
        lines.append(f"- **Location:** {f['chapter']}")
        lines.append(f"- **Paragraph index:** {f['idx']}")
        lines.append(f"- **Paragraph text (first 150 chars):** \"{f['snippet']}\"")
        lines.append(f"- **Currently says:** \"{f['currently']}\"")
        lines.append(f"- **Should say:** {f['suggestion']}")
        lines.append(f"- **Full context:** \"{f['context']}\"")
        lines.append("")
        lines.append("---")
        lines.append("")

# ── SECTION 3 ────────────────────────────────────────────────────────────────
lines.append("## SECTION 3: OTHER NAME INCONSISTENCIES")
lines.append("")

# Add Rubis middle initial note at top
if rubis_mi_issues:
    lines.append("### ⚠️ NOTE: Cyrille John Rubis — Middle Initial Inconsistency")
    lines.append("")
    lines.append("The original requirement specifies **Cyrille John A. Rubis**, but the title page shows **Cyrille John M. Rubis**.")
    lines.append("All occurrences found:")
    for r in rubis_mi_issues:
        lines.append(f"- Para {r['idx']}: `{r['match']}` (middle initial: **{r['mi']}**)")
    lines.append("")
    lines.append("**Action needed:** Confirm correct middle initial with the student, then apply uniformly.")
    lines.append("")
    lines.append("---")
    lines.append("")

if not unique_other:
    lines.append("*No other name inconsistencies found.*")
    lines.append("")
else:
    for n, f in enumerate(unique_other, 1):
        lines.append(f"### Finding {n}")
        lines.append(f"- **Issue type:** {f['type']}")
        lines.append(f"- **Severity:** {f['severity']}")
        lines.append(f"- **Location:** {f['chapter']}")
        lines.append(f"- **Paragraph index:** {f['idx']}")
        lines.append(f"- **Paragraph text (first 150 chars):** \"{f['snippet']}\"")
        lines.append(f"- **Currently says:** \"{f['currently']}\"")
        lines.append(f"- **Should say:** \"{f['should']}\"")
        lines.append("")
        lines.append("---")
        lines.append("")

# ── SUMMARY ──────────────────────────────────────────────────────────────────
total = len(unique_name) + len(unique_tense) + len(unique_other)
lines.append("## SUMMARY")
lines.append("")
lines.append("| Issue Type | Count |")
lines.append("|---|---|")
lines.append(f"| WRONG NAME (Instructor) | {len(unique_name)} |")
lines.append(f"| WRONG TENSE | {len(unique_tense)} |")
lines.append(f"| OTHER NAME INCONSISTENCY | {len(unique_other)} |")
lines.append(f"| **TOTAL** | **{total}** |")
lines.append("")
lines.append("### Next Steps")
lines.append("- Wait for adviser (Maam Ellen) to finish manual edits")
lines.append("- Apply all fixes listed above in one pass")
lines.append("- Re-audit after fixes applied")
lines.append("")

# ── APPENDIX: ALL RAPOSAS OCCURRENCES ────────────────────────────────────────
lines.append("---")
lines.append("")
lines.append("## APPENDIX: All 'Raposas' Occurrences (for verification)")
lines.append("")
lines.append("Every paragraph containing 'Raposas' — verify each is correct form:")
lines.append("")
count_r = 0
for p in paras:
    if re.search(r'raposas', p['text'], re.IGNORECASE):
        chapter = get_chapter(p)
        lines.append(f"- **Para {p['idx']}** ({chapter}): `{p['text'][:200]}`")
        count_r += 1
lines.append(f"\n*Total Raposas occurrences: {count_r}*")
lines.append("")

lines.append("---")
lines.append("")
lines.append("## APPENDIX: All 'Shekiro' Occurrences")
lines.append("")
count_s = 0
for p in paras:
    if re.search(r'shekiro', p['text'], re.IGNORECASE):
        chapter = get_chapter(p)
        lines.append(f"- **Para {p['idx']}** ({chapter}): `{p['text'][:200]}`")
        count_s += 1
lines.append(f"\n*Total Shekiro occurrences: {count_s}*")
lines.append("")

# ── APPENDIX: Abstract + Acknowledgements full text ──────────────────────────
lines.append("---")
lines.append("")
lines.append("## APPENDIX: Abstract Full Text (for tense review)")
lines.append("")
in_abstract = False
for p in paras:
    ch = get_chapter(p)
    if 'Abstract' in ch:
        lines.append(f"> **[{p['idx']}]** {p['text']}")
        lines.append("")

lines.append("---")
lines.append("")
lines.append("## APPENDIX: Acknowledgements Full Text (for tense review)")
lines.append("")
for p in paras:
    ch = get_chapter(p)
    if 'Acknowledg' in ch:
        lines.append(f"> **[{p['idx']}]** {p['text']}")
        lines.append("")

report = "\n".join(lines)

with open(REPORT_PATH, 'w', encoding='utf-8') as f:
    f.write(report)

print(f"Report written to {REPORT_PATH}")
print(f"Section 1 (Wrong Instructor Name): {len(unique_name)} findings")
print(f"Section 2 (Tense Issues):          {len(unique_tense)} findings")
print(f"Section 3 (Other Name Issues):     {len(unique_other)} findings")
print(f"Total:                             {total}")
print(f"Rubis middle initial occurrences:  {len(rubis_mi_issues)}")
print(f"Raposas occurrences:               {count_r}")
