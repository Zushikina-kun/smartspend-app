"""
Final cleanup script:
1. Remove "FORMAT: fiirstname middlename lastname - alphabetical order" from title page
2. Add Avigail Candevario, PFMe to Chapter II validation section
3. Fix any remaining Table 1.1 cell tense (dominates→dominated, etc.)
4. Apply remaining fuzzy tense fixes from not-found list
5. Verify all protected values
"""
import shutil, re
from docx import Document
from docx.shared import Pt

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
shutil.copy(DOCX, DOCX + '.cleanup.backup')
doc = Document(DOCX)

log = []

# ── 1. Remove formatting note from title page ─────────────────────────────
for i, para in enumerate(doc.paragraphs[:30]):
    t = para.text
    if 'FORMAT:' in t or 'fiirstname' in t or 'middlename lastname' in t:
        log.append(f"REMOVED formatting note at para {i}: {t[:80]}")
        for run in para.runs:
            run.text = ''

# ── 2. Table 1.1 cell tense fixes ─────────────────────────────────────────
tense_map_cells = [
    ('Manual entry dominates', 'Manual entry dominated'),
    ('AI categorization degrades for non-English', 'AI categorization degraded for non-English'),
    ('AI categorization degrades', 'AI categorization degraded'),
    ('Local apps lack LLM chat', 'Local apps lacked LLM chat'),
    ('Parents abandon apps', 'Parents abandoned apps'),
    ('warnings ignored', 'warnings were ignored'),
    ('can support personal', 'could support personal'),
    ('reveal gaps', 'revealed gaps'),
]
for table in doc.tables:
    for row in table.rows:
        for cell in row.cells:
            for old, new in tense_map_cells:
                if old in cell.text:
                    for para in cell.paragraphs:
                        for run in para.runs:
                            if old in run.text:
                                run.text = run.text.replace(old, new)
                                log.append(f"TABLE CELL: '{old}' → '{new}'")

# ── 3. Fuzzy tense fixes in body paragraphs ───────────────────────────────
# These are the remaining not-found items — apply by finding the verb in context
body_fixes = [
    # (search_phrase, old_verb, new_verb)
    ('More recent data', 'suggests this picture', 'suggested this picture'),
    ('More recent data', 'is beginning to shift', 'was beginning to shift'),
    ('2025 report', 'reports that 74%', 'reported that 74%'),
    ('2025 report', 'now correctly answer', 'correctly answered'),
    ('inclusion surveys report', 'report that many adults', 'reported that many adults'),
    ('inclusion surveys', 'have difficulty', 'had difficulty'),
    ('rely heavily on user discipline', 'do not provide', 'did not provide'),
    ('may download budgeting apps', 'may download', 'might download'),
    ('may download budgeting apps', 'discontinue use', 'discontinued use'),
    ('is designed for bank-connected', 'is designed for', 'was designed for'),
    ('does not support offline', 'does not support', 'did not support'),
    ('provides AI-based expense', 'provides AI-based', 'provided AI-based'),
    ('confirm that there is still room', 'confirm that there is', 'confirmed that there was'),
    ('compete in this space', 'compete in this', 'competed in this'),
    ('are acknowledged here', 'are acknowledged', 'were acknowledged'),
    ('uniquely fills', 'uniquely fills', 'uniquely filled'),
    ('answers financial-literacy questions on demand', 'answers financial', 'answered financial'),
    ('does not track expenses', 'does not track', 'did not track'),
    ('manually record expenses', 'manually record expenses', 'manually recorded expenses'),
    ('review static summaries', 'review static summaries', 'reviewed static summaries'),
    ('provide basic budgeting', 'provide basic budgeting', 'provided basic budgeting'),
    ('often fail to offer', 'fail to offer', 'failed to offer'),
    ('have started changing', 'have started changing', 'had started changing'),
    ('provides a simple reference', 'provides a simple reference', 'provided a simple reference'),
    ('helps users quickly understand', 'helps users quickly', 'helped users quickly'),
    ('supports multiple input methods', 'supports multiple input', 'supported multiple input'),
    ('Users can manually encode', 'can manually encode', 'could manually encode'),
    ('analyzes financial data', 'analyzes financial data', 'analyzed financial data'),
    ('generates summaries', 'generates summaries', 'generated summaries'),
    ('provides actionable insights', 'provides actionable', 'provided actionable'),
    ('addresses these challenges', 'addresses these challenges', 'addressed these challenges'),
    ('focuses on assessing', 'focuses on', 'focused on'),
    ('supports both online and offline', 'supports both online', 'supported both online'),
    ('may not reflect real-time', 'may not reflect', 'might not reflect'),
    ('Users are advised to verify', 'are advised to verify', 'were advised to verify'),
    ('processes personal financial data', 'processes personal', 'processed personal'),
    ('is therefore designed with', 'is therefore designed', 'was therefore designed'),
    ('the prototype can establish', 'can establish', 'could establish'),
    ('implements a data-minimization', 'implements a data', 'implemented a data'),
    ('exceeds typical patterns', 'exceeds typical', 'exceeded typical'),
    ('also includes a daily mood', 'also includes a daily', 'also included a daily'),
    ('helps users recognize', 'helps users recognize', 'helped users recognize'),
    ('may influence financial decisions', 'may influence', 'might influence'),
    ('includes individuals who aim', 'includes individuals', 'included individuals'),
    ('who aim to manage', 'who aim to', 'who aimed to'),
    ('the application retrieves cloud data', 'retrieves cloud data', 'retrieved cloud data'),
    ('merges it into the local', 'merges it into', 'merged it into'),
    ('is the primary model, backed', 'is the primary model', 'was the primary model'),
    ('keeps working if any single', 'keeps working', 'kept working'),
    ('detects multiple line entries', 'detects multiple', 'detected multiple'),
    ('routes the data to', 'routes the data', 'routed the data'),
    ('the study ensures that the system', 'ensures that the system', 'ensured that the system'),
    ('professionals who manage their own income', 'who manage their own', 'who managed their own'),
    ('track expenses, and make independent', 'track expenses, and make', 'tracked expenses, and made'),
    ('This review ensures that the questions', 'review ensures that', 'review ensured that'),
    ('this writing, Gemini 3.5 Flash-Lite', 'is the primary model', 'was the primary model'),
    ('chapter outlines the conceptual framework', 'outlines the conceptual', 'outlined the conceptual'),
    ('chapter introduces', 'introduces', 'introduced'),
    ('chapter presents', 'presents', 'presented'),
    ('chapter discusses', 'discusses', 'discussed'),
    ('data indicate that many adults', 'indicate that many', 'indicated that many'),
    ('data indicate', 'indicate ', 'indicated '),
    ('still lacked formal financial', 'lacked formal', 'lacked formal'),  # already past
]

for i, para in enumerate(doc.paragraphs):
    t = para.text
    for search, old_v, new_v in body_fixes:
        if search.lower() in t.lower() and old_v in t:
            # Replace in runs
            for run in para.runs:
                if old_v in run.text:
                    run.text = run.text.replace(old_v, new_v)
                    log.append(f"BODY [{i}]: '{old_v}' → '{new_v}'")
                    break

# ── 4. Add Avigail Candevario to validation section ───────────────────────
avigail_added = False
for i, para in enumerate(doc.paragraphs):
    t = para.text
    # Look for the validation paragraph in Ch II
    if ('content validation' in t.lower() or 'survey questionnaire' in t.lower()) and \
       ('validated' in t.lower() or 'validator' in t.lower()):
        if 'Avigail' not in t and 'Candevario' not in t:
            # Update paragraph to include validator name
            for run in para.runs:
                if 'validated' in run.text.lower() or 'validator' in run.text.lower():
                    # Try to insert name after "validated by"
                    if 'validated by' in run.text.lower():
                        old = run.text
                        run.text = run.text.replace(
                            'validated by the undersigned',
                            'validated by Avigail Candevario, PFMe'
                        ).replace(
                            'validated by a',
                            'validated by Avigail Candevario, PFMe, a'
                        )
                        if run.text != old:
                            log.append(f"VALIDATOR [{i}]: added Avigail Candevario, PFMe")
                            avigail_added = True
                            break
    # Also look for "content validator" label
    if ('content validator' in t.lower() or 'avigail' in t.lower()):
        log.append(f"VALIDATOR REF [{i}]: {t[:100]}")

# Also replace any generic "content validator" in Step 1 / validation section
for i, para in enumerate(doc.paragraphs):
    t = para.text
    if 'Appendix D' in t and ('validation' in t.lower() or 'certificate' in t.lower()):
        log.append(f"APPENDIX D REF [{i}]: {t[:120]}")

# ── 5. Save and report ────────────────────────────────────────────────────
doc.save(DOCX)

print(f"Saved. {len(log)} changes made.")
for entry in log:
    print(f"  {entry}")

# Quick verification
doc2 = Document(DOCX)
vals = {
    '61.83': False, '17.58': False, 'Mr. Shekiro': False,
    'Dr. Ellen': False, 'grade of D': False, 'Candevario': False,
}
for p in doc2.paragraphs:
    for k in vals:
        if k in p.text:
            vals[k] = True
print("\nVERIFICATION:")
for k, v in vals.items():
    print(f"  {'OK' if v else 'MISSING'}: {k}")

from docx.oxml.ns import qn
imgs = sum(len(p._p.findall('.//' + qn('a:blip'))) for p in doc2.paragraphs)
print(f"  Images: {imgs}")
print(f"  Paras: {len(doc2.paragraphs)}")
