"""
fix_chapters.py — Apply text replacements to all chapter markdown files.
"""
import re, os

CHAPTER_DIR = r"c:\xampp\htdocs\smartspend_app\docs\manuscript\reseaches"
FILES = [
    "smartspend-thesis-chapter-1.md",
    "smartspend-thesis-chapter-2.md",
    "smartspend-thesis-chapter-3.md",
    "smartspend-thesis-chapter-4.md",
]

# Simple string replacements (old, new)
SIMPLE = [
    ("62.50",             "61.83"),
    ("63.06",             "61.83"),
    ("56.30",             "61.83"),
    ("97.0%",             "96.7%"),
    ("18.59",             "17.58"),
    ("25 achievement",    "36 achievement"),
    ("23 achievement",    "36 achievement"),
    ("31 agentic",        "34 agentic"),
    ("Mangaoang, MIT",    "Mangaoang, DIT"),
    ("Mangaoang MIT",     "Mangaoang DIT"),
    ("proposed system",   "developed system"),
    ("will be evaluated", "was evaluated"),
    ("will be conducted", "was conducted"),
]

# Regex replacements (pattern, repl) — careful with boundaries
REGEX = [
    # N=5 not followed by digit → N=30
    (r"N=5([^0-9])",   r"N=30\1"),
    (r"N=25([^0-9])",  r"N=30\1"),
    (r"N=31([^0-9])",  r"N=30\1"),
    (r"N=33([^0-9])",  r"N=30\1"),
    # n=5 (lowercase) in SUS context — only where it says "n=5" with parenthetical SUS
    # Not touching general n=5 as it may be subset sizes
]

def process_file(path):
    with open(path, "r", encoding="utf-8") as f:
        text = f.read()

    original = text
    changes = {}

    for old, new in SIMPLE:
        count = text.count(old)
        if count:
            text = text.replace(old, new)
            changes[old] = count

    for pattern, repl in REGEX:
        new_text, n = re.subn(pattern, repl, text)
        if n:
            changes[f"regex:{pattern}"] = n
            text = new_text

    # Verzola check
    if "Verzola" in text:
        lines = text.splitlines()
        new_lines = []
        removed = 0
        for line in lines:
            if "Verzola" in line:
                lower = line.lower()
                if any(ctx in lower for ctx in ["panelist", "member", "panel", "committee", "adviser", "instructor"]):
                    removed += 1
                    continue  # remove this line
            new_lines.append(line)
        if removed:
            text = "\n".join(new_lines)
            changes["Verzola (panelist lines removed)"] = removed

    # [[PENDING detection
    pending_count = text.count("[[PENDING")
    if pending_count:
        changes["[[PENDING detected (flagged)"] = pending_count

    if text != original:
        with open(path, "w", encoding="utf-8") as f:
            f.write(text)

    return changes

def main():
    all_results = {}
    for fname in FILES:
        path = os.path.join(CHAPTER_DIR, fname)
        if not os.path.exists(path):
            print(f"SKIP (not found): {fname}")
            continue
        changes = process_file(path)
        all_results[fname] = changes
        if changes:
            print(f"\n{fname}:")
            for k, v in changes.items():
                print(f"  {k}: {v}")
        else:
            print(f"\n{fname}: no changes needed")

    print("\n" + "="*60)
    print("CHAPTER FIXES COMPLETE")
    print("="*60)

if __name__ == "__main__":
    main()
