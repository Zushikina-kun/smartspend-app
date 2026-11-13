"""Fix corrupted paragraph 385 and do a final comprehensive tense scan."""
import shutil, re
from docx import Document
from docx.oxml.ns import qn

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
shutil.copy(DOCX, DOCX + '.p385.backup')
doc = Document(DOCX)

fixes = []

# ── Fix para 385: corrupted concatenation ─────────────────────────────────
# Current (corrupted):
# "These results showed that the third objective of the study was partially achieved:
#  usability was evaluated with the System Usability Scale with 30 valid respondents,
#  but the mean score of 61.83 fell below was evaluated using the System Usability Scal..."
#
# Should be (from Maam Ellen's tense corrections + our Obj3 fix):
# "These results showed that the third objective of the study was partially achieved:
#  usability was evaluated using the System Usability Scale with 30 valid respondents,
#  but the mean score of 61.83 fell below the 68-point benchmark and the pre-established
#  target of 80."

CORRECT_385 = (
    "These results showed that the third objective of the study was partially achieved: "
    "usability was evaluated using the System Usability Scale with 30 valid respondents, "
    "but the mean score of 61.83 fell below the 68-point benchmark (Sauro & Lewis, 2016) "
    "and the pre-established target of 80."
)

para = doc.paragraphs[385]
current = para.text
if 'fell below was evaluated' in current or 'fell below the 68' not in current:
    # Clear all runs and set correct text in first run
    for run in para.runs:
        run.text = ''
    if para.runs:
        para.runs[0].text = CORRECT_385
    else:
        para.add_run(CORRECT_385)
    fixes.append(f"FIXED para 385: replaced corrupted text")
    fixes.append(f"  WAS: {current[:120]}")
    fixes.append(f"  NOW: {CORRECT_385[:120]}")
else:
    fixes.append(f"Para 385 looks OK already: {current[:120]}")

# ── Scan ALL paragraphs for any remaining present-tense issues ────────────
# Broad sweep — only narrative body text, skip refs/appendices/captions
# Focus on verbs that should definitely be past tense in a completed study
SKIP_KEYWORDS = ['table', 'figure', 'appendix', 'reference', 'doi', 'http',
                 'questionnaire:', 'by signing', 'you may', 'your response',
                 'participation is', 'please', 'select all', 'issuance']
TENSE_PAIRS = [
    ('remains a critical', 'remained a critical'),
    ('is a documented and pressing', 'was a documented and pressing'),
    ('suggests this picture is', 'suggested this picture was'),
    ('reports that 74%', 'reported that 74%'),
    ('correctly answer basic', 'correctly answered basic'),
    ('have difficulty maintaining', 'had difficulty maintaining'),
    ('rely heavily on user discipline', 'relied heavily on user discipline'),
    ('do not provide proactive', 'did not provide proactive'),
    ('may download budgeting', 'might download budgeting'),
    ('discontinue use when', 'discontinued use when'),
    ('is designed for bank-connected', 'was designed for bank-connected'),
    ('does not support offline', 'did not support offline'),
    ('can interpret natural language', 'could interpret natural language'),
    ('nor does it compute', 'nor did it compute'),
    ('provides AI-based expense', 'provided AI-based expense'),
    ('confirm that there is still room', 'confirmed that there was still room'),
    ('uniquely fills', 'uniquely filled'),
    ('answers financial-literacy questions on demand', 'answered financial-literacy questions on demand'),
    ('does not track expenses', 'did not track expenses'),
    ('manually record expenses and review', 'manually recorded expenses and reviewed'),
    ('provide basic budgeting functionalities', 'provided basic budgeting functionalities'),
    ('often fail to offer proactive', 'often failed to offer proactive'),
    ('have started changing how', 'had started changing how'),
    ('provides a simple reference point', 'provided a simple reference point'),
    ('helps users quickly understand', 'helped users quickly understand'),
    ('supports multiple input methods', 'supported multiple input methods'),
    ('Users can manually encode', 'Users could manually encode'),
    ('analyzes financial data, generates summaries', 'analyzed financial data, generated summaries'),
    ('and provides actionable insights', 'and provided actionable insights'),
    ('addresses these challenges', 'addressed these challenges'),
    ('focuses on assessing', 'focused on assessing'),
    ('supports both online and offline', 'supported both online and offline'),
    ('may not reflect real-time pricing', 'might not reflect real-time pricing'),
    ('Users are advised to verify', 'Users were advised to verify'),
    ('processes personal financial data', 'processed personal financial data'),
    ('is therefore designed with', 'was therefore designed with'),
    ('the prototype can establish', 'the prototype could establish'),
    ('implements a data-minimization', 'implemented a data-minimization'),
    ('helps users recognize how', 'helped users recognize how'),
    ('may influence financial decisions', 'might influence financial decisions'),
    ('includes individuals who aim', 'included individuals who aimed'),
    ('who aim to manage their finances', 'who aimed to manage their finances'),
    ('the application retrieves cloud data', 'the application retrieved cloud data'),
    ('and merges it into the local', 'and merged it into the local'),
    ('Gemini 3.5 Flash-Lite (Google) is the primary model', 'Gemini 3.5 Flash-Lite (Google) was the primary model'),
    ('keeps working if any single provider', 'kept working if any single provider'),
    ('detects multiple line entries', 'detected multiple line entries'),
    ('routes the data to', 'routed the data to'),
    ('the study ensures that the system', 'the study ensured that the system'),
    ('who manage their own income', 'who managed their own income'),
    ('track expenses, and make independent', 'tracked expenses, and made independent'),
    ('This review ensures that the questions', 'This review ensured that the questions'),
    ('This chapter outlines the conceptual', 'This chapter outlined the conceptual'),
    ('chapter introduces the problem', 'chapter introduced the problem'),
    ('chapter presents the', 'chapter presented the'),
    ('data indicate that many adults', 'data indicated that many adults'),
    ('also includes a daily', 'also included a daily'),
    ('also include a daily', 'also included a daily'),
    ('Chapter I presents', 'Chapter I presented'),
    ('Chapter II presents', 'Chapter II presented'),
    ('Chapter III presents', 'Chapter III presented'),
    ('This chapter presents', 'This chapter presented'),
    ('compete in this space and are acknowledged', 'competed in this space and were acknowledged'),
    ('reveal gaps that SmartSpend intends', 'revealed gaps that SmartSpend intended'),
    ('makes it suitable for users', 'made it suitable for users'),
    ('can interpret natural language', 'could interpret natural language'),
    ('is a critical design decision', 'was a critical design decision'),
    ('it directly influences', 'it directly influenced'),
    ('Gemini 3.5 Flash-Lite was selected.*because it offers', None),  # skip regex
    ('offers a high free-tier request quota', 'offered a high free-tier request quota'),
    ('SmartSpend uses dynamic full-context injection', 'SmartSpend used dynamic full-context injection'),
    ('a typical user has 20–50 expenses', 'a typical user had 20–50 expenses'),
    ('the assistant receive today', 'the assistant received today'),
    ('a summary card shows which items', 'a summary card showed which items'),
    ('first shows a warning', 'first showed a warning'),
    ('current research indicates this is feasible', 'current research indicated this was feasible'),
    ('a haptic service provides tactile', 'a haptic service provided tactile'),
    ('ships with a guided in-app setup', 'shipped with a guided in-app setup'),
]

for i, para in enumerate(doc.paragraphs):
    t = para.text
    if not t.strip():
        continue
    # Skip sections we shouldn't touch
    if any(sk in t.lower() for sk in SKIP_KEYWORDS):
        continue
    for old, new in TENSE_PAIRS:
        if new is None:
            continue
        if old in t:
            # Apply replacement across runs
            full = para.text
            new_full = full.replace(old, new, 1)
            if new_full != full and para.runs:
                para.runs[0].text = new_full
                for run in para.runs[1:]:
                    run.text = ''
                fixes.append(f"TENSE [{i}]: '{old[:60]}' → '{new[:60]}'")
                break  # one fix per para per pass

# ── Save ──────────────────────────────────────────────────────────────────
doc.save(DOCX)

print(f"Done. {len(fixes)} fixes applied.")
for f in fixes:
    print(f"  {f}")

# Final verification
doc2 = Document(DOCX)
vals = {
    '61.83': False, '17.58': False, 'Mr. Shekiro': False,
    'Dr. Ellen': False, 'grade of D': False, 'Candevario': False,
    'partially achieved': False,
}
for p in doc2.paragraphs:
    for k in vals:
        if k.lower() in p.text.lower():
            vals[k] = True

print("\nVERIFICATION:")
for k, v in vals.items():
    print(f"  {'OK' if v else 'MISSING'}: {k}")

imgs = sum(len(p._p.findall('.//' + qn('a:blip'))) for p in doc2.paragraphs)
print(f"  Images: {imgs}")
print(f"  Para 385 now: {doc2.paragraphs[385].text[:150]}")
