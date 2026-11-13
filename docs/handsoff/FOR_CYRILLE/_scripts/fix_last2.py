from docx import Document
import shutil

DOCX = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
shutil.copy(DOCX, DOCX + '.fix4.backup')
doc = Document(DOCX)

# ── Diagnose CFIS 2025 ────────────────────────────────────────────────────
print("=== CFIS paragraphs ===")
for i, para in enumerate(doc.paragraphs):
    if 'CFIS' in para.text:
        print(f"  para {i}: {para.text[:120]!r}")

# ── Diagnose v3.1.0 evaluated ─────────────────────────────────────────────
print("\n=== v3.1.0 paragraphs ===")
for i, para in enumerate(doc.paragraphs):
    if 'v3.1.0' in para.text:
        print(f"  para {i}: {para.text[:120]!r}")

# The verify script checks: 'v3.1.0' in t and ('evaluated' in t.lower() or 'build' in t.lower())
# Let's check what's near the SUS section
print("\n=== Paragraphs near 'build evaluated' or 'evaluated was' ===")
for i, para in enumerate(doc.paragraphs):
    t = para.text.lower()
    if ('build evaluated' in t or 'evaluated was' in t or 'version evaluated' in t
            or ('v3.1.0' in para.text and 'peso' in t)):
        print(f"  para {i}: {para.text[:150]!r}")
