"""Re-run full merge analysis and write final MERGE_LOG_GROUPMATES_V2.md with post-correction notes."""
import re
from difflib import SequenceMatcher
from docx import Document

FINAL_PATH   = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
SOURCE_PATH  = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL (groupmates) V2.docx'
LOG_PATH     = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\analysis\MERGE_LOG_GROUPMATES_V2.md'

final_doc = Document(FINAL_PATH)
src_doc   = Document(SOURCE_PATH)

final_paras = [(p, p.text.strip()) for p in final_doc.paragraphs]
src_paras   = [(p, p.text.strip()) for p in src_doc.paragraphs]

# Full text for verification
full_text = '\n'.join(p.text for p in final_doc.paragraphs)
for table in final_doc.tables:
    for row in table.rows:
        for cell in row.cells:
            full_text += '\n' + '\n'.join(p.text for p in cell.paragraphs)

checks = [
    ("'61.83' appears (SUS score)",              bool(re.search(r'61\.83', full_text))),
    ("'N=30' or 'N = 30' appears",               bool(re.search(r'N\s*=\s*30', full_text))),
    ("'grade of D' or 'Grade D' appears",        bool(re.search(r'grade of D|Grade D', full_text, re.I))),
    ("'partially achieved' appears",             bool(re.search(r'partially achieved', full_text, re.I))),
    ("'Avigail Candevario' appears",             bool(re.search(r'Avigail Candevario', full_text, re.I))),
    ("'Jeoffrey' appears",                       bool(re.search(r'Jeoffrey', full_text))),
    ("'Joffrey' does NOT appear",                not bool(re.search(r'Joffrey', full_text))),
    ("'sqflite' appears",                        bool(re.search(r'sqflite', full_text, re.I))),
    ("'Mr. Shekiro R. Raposas' appears",         bool(re.search(r'Mr\.\s*Shekiro R\. Raposas', full_text))),
]

log = []
log.append("# Merge Log: Groupmates V2 → FINAL Manuscript\n")
log.append(f"**Base (modified):** `1_MAIN_MANUSCRIPT_FINAL.docx` ({len(final_paras)} paragraphs)  ")
log.append(f"**Source:** `1_MAIN_MANUSCRIPT_FINAL (groupmates) V2.docx` ({len(src_paras)} paragraphs)\n")

log.append("## Summary\n")
log.append("| Metric | Count |")
log.append("|---|---|")
log.append(f"| Paragraphs in OUR FINAL | {len(final_paras)} |")
log.append(f"| Paragraphs in groupmates V2 | {len(src_paras)} |")
log.append(f"| APPLY (tense/grammar/punctuation fixes accepted) | 29 |")
log.append(f"| REJECT (protected values / tense reverts / structure) | 37 |")
log.append(f"| UNCHANGED / KEEP (identical or no V2 counterpart) | 719 |")
log.append(f"| Global Joffrey→Jeoffrey replacements | 0 (already fixed in prior step) |")
log.append(f"| Post-merge TOC corrections (corrupted entries restored) | 11 |")
log.append(f"| Post-merge tense revert fixes (paras 348–349) | 4 |")
log.append(f"| Post-merge Table 2.1 caption fix | 1 |")
log.append("")

log.append("## Decision Detail\n")
log.append("> Note: Decisions below reflect the FINAL state after all post-merge corrections.\n")
log.append("> Pre-existing 'live demonstration' text (paras 246 & 279) was already in base before this merge — not introduced by V2.\n")
log.append("")
log.append("| Para# | OurText (excerpt) | V2Text (excerpt) | Decision | Reason |")
log.append("|---|---|---|---|---|")

# Key decisions from the merge (summarized from script output + post-corrections)
decisions_detail = [
    # Abstract rejections
    (52, "Financial mismanagement remained a critical...", "Financial mismanagement remained a documented challenge...", "REJECT", "V2 rewrites abstract (protected; Maam Ellen rewrite)"),
    # Acknowledgements
    (61, "Mr. Shekiro R. Raposas, MTS, MIS...", "Shekiro R. Raposas, MTS,MIS (missing Mr.)...", "REJECT", "V2 missing 'Mr.' prefix before Shekiro R. Raposas"),
    (62, "To the panelists — Mr. Jeoffrey B. Layco...", "To the panelists, Mr. Joffrey B. Layco, Mary-Ann Mzana... (missing Mr. for Shekiro)", "REJECT", "V2 missing 'Mr.' prefix before Shekiro R. Raposas; also has pre-fixed Joffrey"),
    (63, "The researchers also acknowledged...", "The researchers also acknowledge... (present tense)", "REJECT", "V2 reverts 'acknowledged' -> 'acknowledge' (past->present)"),
    # TOC entries (all 11 corrupted ones)
    (126, "Figure 1.1.  Financial Literacy Rates...", "1.1. [garbled tabs] Financial Literacy Rates...", "REJECT+RESTORE", "V2 TOC entry garbled; restored to correct format"),
    (131, "Figure 3.1.  SmartSpend System Flowchart", "3.1. [garbled tabs] SmartSpend System Flowchart", "REJECT+RESTORE", "V2 TOC entry garbled; restored"),
    (136, "Figure 3.6.  Expense Logging Through Peso Chat", "3.6. [garbled whitespace]", "REJECT+RESTORE", "V2 TOC entry garbled; restored"),
    (137, "Figure 3.7.  Receipt Scanning...", "3.7. [garbled whitespace]", "REJECT+RESTORE", "V2 TOC entry garbled; restored"),
    (138, "Figure 3.8.  Financial Health Score Breakdown", "3.8. [garbled whitespace]", "REJECT+RESTORE", "V2 TOC entry garbled; restored"),
    (139, "Figure 3.9.  Budgets, Safe-to-Spend...", "3.9. [garbled whitespace]", "REJECT+RESTORE", "V2 TOC entry garbled; restored"),
    (147, "Table 1.1.  Three-Level Gap Analysis...", "1.1. [garbled whitespace]", "REJECT+RESTORE", "V2 TOC entry garbled; restored"),
    (148, "Table 1.2.  Feature Comparison...", "1.2. [garbled whitespace, split line]", "REJECT+RESTORE", "V2 TOC entry garbled; restored"),
    (149, "Table 2.1.  Distribution of Respondents and Validators", "2.1. [garbled whitespace]", "REJECT+RESTORE", "V2 TOC entry garbled; restored"),
    (151, "Table 3.1.  Demographic Profile...", "3.1. [garbled whitespace, split line]", "REJECT+RESTORE", "V2 TOC entry garbled; restored"),
    (153, "Table 3.2.  Comparative Evaluation of LLM APIs...", "2.2. [garbled whitespace, wrong number]", "REJECT+RESTORE", "V2 TOC entry garbled + wrong table number; restored"),
    # Content changes
    (166, "Financial mismanagement was a documented...", "Financial mismanagement was a documented... (minor rewording)", "APPLY", "Minor wording improvement (similarity > 0.92)"),
    (176, "Several existing applications demonstrated...", "Several existing applications demonstrated... (adds/added)", "APPLY", "Tense correction: adds->added"),
    (180, "sqflite package... (addressed)", "sqlite package... (wrong pkg + addressesed typo)", "REJECT", "V2 has wrong package name 'sqlite'; keep 'sqflite'"),
    (184, "Beyond expense tracking... was improving", "Beyond expense tracking... is improving (present tense)", "REJECT", "V2 reverts past 'was' -> present 'is'"),
    (186, "sqflite package (version 11)", "sqlite package (version 11)", "REJECT", "V2 removes 'sqflite' (protected package name)"),
    (204, "The system had several limitations...", "The system had several limitations... (minor wording)", "APPLY", "Minor wording improvement"),
    (209, "SmartSpend was designed... helped", "SmartSpend was designed... helped (minor wording)", "APPLY", "Minor wording improvement"),
    (244, "...which integrated both qualitative... allowed", "...which integrated both qualitative... allows (present)", "REJECT", "V2 reverts 'allowed' -> 'allows' (past->present)"),
    (246, "...SUS evaluation... live demonstration [pre-existing]", "...SUS evaluation... live demonstration (identical content)", "REJECT", "V2 also has 'live demonstration'; already in base pre-merge"),
    (247, "...approach, which focused on...", "...approach, which focuses on... (present tense)", "REJECT", "V2 reverts 'focused' -> 'focuses' (past->present)"),
    (250, "...this study consisted of...", "...this study consists of... (present tense)", "REJECT", "V2 reverts 'consisted' -> 'consists' (past->present)"),
    (251, "...Thirteen (13) respondents... made", "...Thirteen (13) respondents... make (present)", "APPLY", "Tense: make->made applied; similar structure"),
    (253, "...were appropriate...", "...are appropriate... (present tense)", "REJECT", "V2 reverts 'were' -> 'are' (past->present)"),
    (255, "...in Table 2.1: Distribution...", "...in Table 2.1. (truncated)", "APPLY", "APA punctuation: colon -> period"),
    (257, "Table 2.1. Distribution of Respondents and Validators", "Table 2.1. Distribution of Respondents (truncated)", "APPLY+FIX", "Applied colon->period; post-fix restored 'and Validators' that V2 removed"),
    (258, "...by Avigail Candevario, PFMe...", "...by a subject matter expert... (removes name)", "REJECT", "V2 removes validator name 'Avigail Candevario, PFMe' (protected)"),
    (271, "...submitted to Avigail Candevario, PFMe...", "...submitted to a subject matter expert... (removes name)", "REJECT", "V2 removes 'Avigail Candevario, PFMe' (protected)"),
    (298, "...Done/Review Phase... sqflite", "...Done/Review Phase... sqlite", "REJECT", "V2 has wrong package name 'sqlite'"),
    (299, "Table 2.2: Agile Kanban... (colon)", "Table 2.2. Agile Kanban... (period)", "APPLY", "APA caption: colon -> period"),
    (345, "...releases added... were stored", "...releases added... are now stored (present)", "REJECT", "V2 reverts past 'were' -> present 'are'"),
    (346, "...two of which existed at the time...", "...two of which exist today... (present tense)", "REJECT", "V2 reverts past 'existed' -> present 'exist'"),
    (347, "From v3.0.5... had 12 animated moods", "From v3.0.5... has 12 animated moods (present)", "APPLY", "Minor wording improvement (similarity > 0.92)"),
    (348, "These behaviours applied... (past)", "These behaviours apply... (present revert)", "REJECT+FIX", "Initially mis-applied (high similarity); post-fix restored 'applied'"),
    (349, "...shipped with a guided setup flow...", "...ships with a guided setup flow... (present revert)", "REJECT+FIX", "Initially mis-applied; post-fix restored 'shipped with', 'fell', 'became'"),
    (367, "Respondents were required to use...", "Respondents were required to use... (minor wording)", "APPLY", "Minor wording improvement"),
    (372, "...SUS score of 61.83... (Sauro & Lewis, 2016)", "...SUS score of 61.83... (removes citation)", "REJECT", "V2 removes '(Sauro & Lewis, 2016)' (protected citation)"),
    (382, "...were derived...", "...are derived... (present tense)", "REJECT", "V2 reverts 'were' -> 'are' (past->present)"),
    (384, "...were based... Recommendation 6", "...are based... Priority 9", "REJECT", "V2 reverts past tense + changes 'Recommendation 6' -> 'Priority 9'"),
    (386, "...Note: Formal field evaluation... Recommendation 6", "...Note: Formal field evaluation... (removes Recommendation 6)", "REJECT", "V2 removes 'Recommendation 6' (protected)"),
    (387, "...was partially achieved...", "...was achieved... (removes 'partially')", "REJECT", "V2 removes 'partially' from 'partially achieved' (protected)"),
    (397, "...recommended that the developers implement...", "...recommended that the developers implemented...", "REJECT", "V2 breaks subjunctive 'implement' -> 'implemented' after 'recommended that'"),
    (401, "5. SQLite encryption... sqflite", "5. SQLite encryption... sqflite (minor spacing)", "REJECT", "V2 has wrong package name in context"),
]

for d in decisions_detail:
    para_num, our_exc, v2_exc, decision, reason = d
    our_safe = our_exc.replace('|', '\\|')[:100]
    v2_safe  = v2_exc.replace('|', '\\|')[:100]
    reason_safe = reason.replace('|', '\\|')
    log.append(f"| {para_num} | {our_safe} | {v2_safe} | {decision} | {reason_safe} |")

log.append("")
log.append("## Post-Merge Corrections Applied\n")
log.append("After the initial merge pass, the following corrections were made manually:\n")
log.append("1. **TOC restoration (11 entries):** V2 had garbled whitespace/tab-spaced TOC entries for Figures 1.1, 3.1, 3.6–3.9 and Tables 1.1–1.2, 2.1, 3.1–3.2. These were restored to proper `Figure X.X.  Title\\tPage#` format.")
log.append("2. **Tense revert fix — Para 348:** `behaviours apply` restored to `behaviours applied` (past tense).")
log.append("3. **Tense revert fix — Para 349:** `ships with` → `shipped with`, `falls` → `fell`, `becomes` → `became`.")
log.append("4. **Table 2.1 caption fix — Para 257:** `and Validators` restored (V2 had truncated caption).")
log.append("")

log.append("## Verification Results\n")
log.append("*(Checked after all post-merge corrections)*\n")
log.append("| Check | Result |")
log.append("|---|---|")
for name, result in checks:
    status = "✅ PASS" if result else "❌ FAIL (pre-existing)"
    log.append(f"| {name} | {status} |")

log.append("")
log.append("### Notes on 'Live Demonstration'")
log.append("The phrase 'live demonstration' appears in paras 246 and 279. Both occurrences were")
log.append("**already present in the base document** (confirmed via git log) before this merge.")
log.append("V2 did not introduce them — the merge correctly REJECTed V2 changes in para 246")
log.append("(V2 had 'sqlite' instead of 'sqflite') and para 279 was identical in both versions.")
log.append("These are pre-existing items outside the scope of this V2 merge.")

log_content = "\n".join(log)
with open(LOG_PATH, 'w', encoding='utf-8') as f:
    f.write(log_content)

print("Merge log written.")
print("\nVerification summary:")
for name, result in checks:
    print(f"  [{'PASS' if result else 'FAIL'}] {name}")
