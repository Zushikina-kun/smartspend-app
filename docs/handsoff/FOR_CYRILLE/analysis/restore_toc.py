"""
restore_toc.py — Restore corrupted TOC entries in the merged FINAL.

The merge script applied some V2 TOC entries that had garbled tab-whitespace
formatting. We identify corrupted entries (missing 'Figure' or 'Table' prefix,
or having internal multi-spaces/tabs), then restore from the V1 merge log
knowledge + correct formatting.

Corrupted paras detected (1-indexed):
  Para 126: should be 'Figure 1.1.  Financial Literacy Rates by Demographic Group (BSP, 2021; Inquiro, 2024)\t4'
  Para 131: should be 'Figure 3.1.  SmartSpend System Flowchart\t53'
  Para 136: should be 'Figure 3.6.  Expense Logging Through Peso Chat\t64'
  Para 137: should be 'Figure 3.7.  Receipt Scanning and Batch Screenshot Import\t65'
  Para 138: should be 'Figure 3.8.  Financial Health Score Breakdown\t66'
  Para 139: should be 'Figure 3.9.  Budgets, Safe-to-Spend, and Savings Goals\t67'
  Para 147: should be 'Table 1.1.  Three-Level Gap Analysis of SmartSpend\t5'
  Para 148: should be 'Table 1.2.  Feature Comparison of SmartSpend with Existing Financial Applications\t8'
  Para 149: should be 'Table 2.1.  Distribution of Respondents and Validators\t31'
  Para 151: should be 'Table 3.1.  Demographic Profile and Expense Tracking Methods of Respondents (N = 30)\t44'
  Para 153: should be 'Table 3.2.  Comparative Evaluation of LLM APIs for SmartSpend Integration\t47'
"""

from docx import Document
import re

FINAL_PATH = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'

# Map: (0-indexed para index) -> correct text to restore
# These are the proper entries as they should appear in a List of Figures/Tables
CORRECTIONS = {
    125: 'Figure 1.1.  Financial Literacy Rates by Demographic Group (BSP, 2021; Inquiro, 2024)\t4',
    130: 'Figure 3.1.  SmartSpend System Flowchart\t53',
    135: 'Figure 3.6.  Expense Logging Through Peso Chat\t64',
    136: 'Figure 3.7.  Receipt Scanning and Batch Screenshot Import\t65',
    137: 'Figure 3.8.  Financial Health Score Breakdown\t66',
    138: 'Figure 3.9.  Budgets, Safe-to-Spend, and Savings Goals\t67',
    146: 'Table 1.1.  Three-Level Gap Analysis of SmartSpend\t5',
    147: 'Table 1.2.  Feature Comparison of SmartSpend with Existing Financial Applications\t8',
    148: 'Table 2.1.  Distribution of Respondents and Validators\t31',
    150: 'Table 3.1.  Demographic Profile and Expense Tracking Methods of Respondents (N = 30)\t44',
    152: 'Table 3.2.  Comparative Evaluation of LLM APIs for SmartSpend Integration\t47',
}

doc = Document(FINAL_PATH)
paras = list(doc.paragraphs)

restored = 0
for idx, correct_text in CORRECTIONS.items():
    p = paras[idx]
    current = p.text
    if current.strip() == correct_text.strip():
        print(f"  Para {idx+1}: already correct, skip")
        continue
    # Check this is actually a garbled TOC entry (heuristic: starts with number, has tabs/spaces)
    stripped = current.strip()
    if re.match(r'^\d+\.\d+', stripped) or ('   ' in current and len(current) > 10):
        # Restore: set first run to correct text, blank others
        runs = p.runs
        if runs:
            runs[0].text = correct_text
            for r in runs[1:]:
                r.text = ''
        else:
            p.add_run(correct_text)
        print(f"  Para {idx+1}: RESTORED -> {repr(correct_text)}")
        restored += 1
    else:
        print(f"  Para {idx+1}: not garbled ({repr(current[:80])}), skip")

print(f"\nTotal restored: {restored}")
doc.save(FINAL_PATH)
print("Saved.")
