"""
fix_manuscript.py — Pre-defense pass: fix all known value errors in the DOCX manuscript.
Run: python docs/capstone/fix_manuscript.py
"""
import re
import copy
from docx import Document
from docx.oxml.ns import qn

DOCX_PATH = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx"

# -------------------------------------------------------------------
# Simple text replacements (exact string → replacement)
# Applied everywhere: paragraphs + table cells
# -------------------------------------------------------------------
SIMPLE_REPLACEMENTS = [
    ("62.50",             "61.83"),
    ("63.06",             "61.83"),
    ("56.30",             "61.83"),
    ("97.0%",             "96.7%"),
    # N=5 variants — careful: don't hit N=50, etc.
    # handled with regex below
    ("N=31,",             "N=30,"),
    ("N=31)",             "N=30)"),
    ("N=25 ",             "N=30 "),
    ("N=33 ",             "N=30 "),
    ("N=33,",             "N=30,"),
    ("N=33)",             "N=30)"),
    ("25 achievement",    "36 achievement"),
    ("23 achievement",    "36 achievement"),
    ("31 agentic",        "34 agentic"),
    ("18.59",             "17.58"),
    ("Mangaoang, MIT",    "Mangaoang, DIT"),
    ("Mangaoang MIT",     "Mangaoang DIT"),
    ("SmartSpend SmartSpend", "SmartSpend"),
    ("proposed system",   "was developed"),     # past tense
    ("will be evaluated", "was evaluated"),
    ("will be conducted", "was conducted"),
    ("will be administered", "was administered"),
    ("will be used",      "was used"),
    ("is proposed",       "was developed"),
]

# Regex-based replacements (pattern, replacement)
REGEX_REPLACEMENTS = [
    # N=5 not followed by digit (catches N=5 , N=5. N=5) but NOT N=50)
    (r"N=5([^0-9])",  r"N=30\1"),
    # N=31 not followed by digit
    (r"N=31([^0-9])", r"N=30\1"),
]

# Verzola: remove only if appears as panelist/committee member
VERZOLA_CONTEXTS = ["panelist", "member", "panel", "committee", "instructor", "adviser"]

counters = {}

def apply_to_text(text):
    """Apply all replacements to a string. Returns (new_text, change_dict)."""
    changes = {}
    orig = text

    # Simple replacements
    for old, new in SIMPLE_REPLACEMENTS:
        if old in text:
            count = text.count(old)
            text = text.replace(old, new)
            changes[old] = changes.get(old, 0) + count

    # Regex replacements
    for pattern, repl in REGEX_REPLACEMENTS:
        new_text, n = re.subn(pattern, repl, text)
        if n:
            key = f"regex:{pattern}"
            changes[key] = changes.get(key, 0) + n
            text = new_text

    # Verzola — only remove if context implies panelist role
    if "Verzola" in text:
        lower = text.lower()
        is_panelist_context = any(ctx in lower for ctx in VERZOLA_CONTEXTS)
        if is_panelist_context:
            # Remove sentence containing Verzola
            sentences = re.split(r'(?<=[.!?])\s+', text)
            new_sentences = [s for s in sentences if "Verzola" not in s]
            text = " ".join(new_sentences)
            changes["Verzola (panelist context removed)"] = 1
        else:
            changes["Verzola (KEPT — not panelist context)"] = text.count("Verzola")

    # Appendix D — remove if it's an interview guide reference
    if "Appendix D" in text:
        lower = text.lower()
        if "interview" in lower or "guide" in lower:
            sentences = re.split(r'(?<=[.!?])\s+', text)
            new_sentences = [s for s in sentences if not ("Appendix D" in s and ("interview" in s.lower() or "guide" in s.lower()))]
            if len(new_sentences) < len(sentences):
                text = " ".join(new_sentences)
                changes["Appendix D (interview guide context removed)"] = 1
            else:
                changes["Appendix D (KEPT — not interview guide)"] = 1
        else:
            changes["Appendix D (KEPT — not interview guide)"] = 1

    return text, changes


def fix_run_text(run_text):
    """Fix a run's text without destroying formatting."""
    new_text, changes = apply_to_text(run_text)
    return new_text, changes


def process_paragraph(para, context_label=""):
    """Process all runs in a paragraph."""
    para_changes = {}
    # Collect the full paragraph text first for context
    full_text = para.text

    for run in para.runs:
        if not run.text:
            continue
        new_text, changes = fix_run_text(run.text)
        if new_text != run.text:
            run.text = new_text
        for k, v in changes.items():
            para_changes[k] = para_changes.get(k, 0) + v

    # Check for [[PENDING in full text
    if "[[" in full_text or "[[PENDING" in full_text:
        bracket_count = full_text.count("[[")
        para_changes["[[PENDING detected (not auto-removed)"] = para_changes.get("[[PENDING detected (not auto-removed)", 0) + bracket_count

    return para_changes


def merge_changes(total, partial):
    for k, v in partial.items():
        total[k] = total.get(k, 0) + v


def main():
    print(f"Opening: {DOCX_PATH}")
    doc = Document(DOCX_PATH)
    total_changes = {}

    # Process body paragraphs
    print("Processing body paragraphs...")
    for i, para in enumerate(doc.paragraphs):
        changes = process_paragraph(para, f"para[{i}]")
        merge_changes(total_changes, changes)

    # Process tables
    print("Processing tables...")
    for table in doc.tables:
        for row in table.rows:
            for cell in row.cells:
                for para in cell.paragraphs:
                    changes = process_paragraph(para, "table_cell")
                    merge_changes(total_changes, changes)

    # Save
    doc.save(DOCX_PATH)
    print(f"\nSaved: {DOCX_PATH}")

    # Report
    print("\n" + "="*60)
    print("REPLACEMENT SUMMARY")
    print("="*60)
    if not total_changes:
        print("No changes needed — document was already clean.")
    else:
        for key, count in sorted(total_changes.items()):
            print(f"  {key}: {count} replacement(s)")
    print("="*60)

    pending_count = total_changes.get("[[PENDING detected (not auto-removed)", 0)
    if pending_count:
        print(f"\n⚠️  [[PENDING]] tags found: {pending_count} — review manually before printing!")
    else:
        print("\n✅ No [[PENDING]] tags detected.")

    verzola_kept = total_changes.get("Verzola (KEPT — not panelist context)", 0)
    if verzola_kept:
        print(f"\n⚠️  Verzola appears {verzola_kept}× in non-panelist context — review manually.")


if __name__ == "__main__":
    main()
