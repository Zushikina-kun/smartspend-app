"""
Organize the FOR_CYRILLE folder and handsoff root.
Moves old versions, scripts, and backups into subfolders.
Leaves only the essential files at the top level.
"""
import os, shutil

BASE = r"c:\xampp\htdocs\smartspend_app\docs\handsoff"
FC   = os.path.join(BASE, "FOR_CYRILLE")

# ── Create clean subfolder structure ──────────────────────────────────────
dirs = [
    os.path.join(FC, "_backups"),
    os.path.join(FC, "_scripts"),
    os.path.join(FC, "_old_versions"),
    os.path.join(FC, "_reports"),
]
for d in dirs:
    os.makedirs(d, exist_ok=True)

moved = []

def mv(src, dst_dir, reason=""):
    if os.path.isfile(src):
        fname = os.path.basename(src)
        dst = os.path.join(dst_dir, fname)
        # avoid overwrite collision
        if os.path.exists(dst):
            base, ext = os.path.splitext(fname)
            dst = os.path.join(dst_dir, base + "_dup" + ext)
        shutil.move(src, dst)
        moved.append(f"{reason}: {fname}")

BACKUPS   = os.path.join(FC, "_backups")
SCRIPTS   = os.path.join(FC, "_scripts")
OLD_VERS  = os.path.join(FC, "_old_versions")
REPORTS   = os.path.join(FC, "_reports")

# ── MOVE: .bak / .backup files ────────────────────────────────────────────
for fname in os.listdir(FC):
    fpath = os.path.join(FC, fname)
    if not os.path.isfile(fpath): continue
    if any(fname.endswith(e) for e in ['.bak', '.backup']):
        mv(fpath, BACKUPS, "backup")

# ── MOVE: Python scripts (keep verify_all_three.py at top) ────────────────
KEEP_SCRIPTS = {'verify_all_three.py'}
for fname in os.listdir(FC):
    fpath = os.path.join(FC, fname)
    if not os.path.isfile(fpath): continue
    if fname.endswith('.py') and fname not in KEEP_SCRIPTS:
        mv(fpath, SCRIPTS, "script")

# ── MOVE: old manuscript versions ─────────────────────────────────────────
OLD_DOCX = [
    '1_MAIN_MANUSCRIPT.docx',
    '1_MAIN_MANUSCRIPT_FINAL(groupmates ver).docx',
    '1_MAIN_MANUSCRIPT_FINAL(MAIN).docx',
    '1_MAIN_MANUSCRIPT_FINAL(MAINV2).docx',
    '1_MAIN_MANUSCRIPT_FINAL(V3).docx',
    '1_MAIN_MANUSCRIPT_FINAL_BACKUP.docx',
    '1_MAIN_MANUSCRIPT_FINAL.docx.pdf',
]
for fname in OLD_DOCX:
    mv(os.path.join(FC, fname), OLD_VERS, "old version")

# ── MOVE: old PPT versions ────────────────────────────────────────────────
OLD_PPT = [
    '3_PRESENTATION.pptx',
    '3_PRESENTATION_BACKUP.pptx',
    '3_PRESENTATION_FINAL.pptx',
    '3_PRESENTATION.html',
    '3_PRESENTATION_FINAL.html',
]
for fname in OLD_PPT:
    mv(os.path.join(FC, fname), OLD_VERS, "old ppt")

# ── MOVE: old script version ──────────────────────────────────────────────
mv(os.path.join(FC, '4_DEFENSE_SCRIPT.md'), OLD_VERS, "old script")

# ── MOVE: report/audit .md and .json (keep key ones at top) ──────────────
KEEP_MD = {
    '5_DEFENSE_REVIEWER_NOV16.md',
    'CONFIRM_CHECKLIST_NOV16.md',
    'DEFENSE_MORNING_CHECKLIST.md',
    'DO_NOT_CHANGE.md',
}
for fname in os.listdir(FC):
    fpath = os.path.join(FC, fname)
    if not os.path.isfile(fpath): continue
    if fname.endswith('.md') and fname not in KEEP_MD:
        mv(fpath, REPORTS, "report/md")
    if fname in ('audit-review.json', 'review.json', 'review.md'):
        mv(fpath, REPORTS, "review file")

# ── MOVE: misc files ──────────────────────────────────────────────────────
MISC_MOVE = [
    'STATUS.txt', 'FILES_CREATED_NOV9.txt', 'COMPLETION_CERTIFICATE.txt',
]
for fname in MISC_MOVE:
    mv(os.path.join(FC, fname), REPORTS, "misc")

# ── MOVE: temp Word lock file ─────────────────────────────────────────────
mv(os.path.join(FC, '~$MAIN_MANUSCRIPT_FINAL.docx'), BACKUPS, "temp lock file")

# ── CLEAN HANDSOFF ROOT ───────────────────────────────────────────────────
ROOT_CLEAN = os.path.join(BASE, "_old")
os.makedirs(ROOT_CLEAN, exist_ok=True)

ROOT_MOVE = [
    '1_MAIN_MANUSCRIPT_FINAL (1).docx',
    '1_MAIN_MANUSCRIPT_FINAL (1).docx.bak',
    '1_MAIN_MANUSCRIPT_FINAL.docx (1).md',
    '1_MAIN_MANUSCRIPT_FINAL.docx.blocker1.bak',
    '1_MAIN_MANUSCRIPT_FINAL.docx.revision.bak',
    '1_MAIN_MANUSCRIPT_FINAL.docx.md',
    'apply_all_10_fixes.py',
    'patch_missing_paras.py',
]
for fname in ROOT_MOVE:
    mv(os.path.join(BASE, fname), ROOT_CLEAN, "handsoff root cleanup")

print(f"\nMoved {len(moved)} files:")
for m in moved:
    print(f"  {m}")
print("\nDone.")
