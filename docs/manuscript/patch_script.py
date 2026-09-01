"""
patch_script.py
Rewrites update_working_docx.py with corrected line spacing and spacing rules.
Key fix: all new body paragraphs use ls=480 (double space, matching templates).
No explicit space-before/after — templates use inherited (blank lines for gaps).
"""
import re

with open("update_working_docx.py", encoding="utf-8") as f:
    src = f.read()

# ── FIX 1: _p() function — add ls parameter, use it in XML ───────────────────
old_p_sig = 'def _p(text, bold=False, italic=False,\n       align="both", sb=0, sa=0, fi=720,\n       font=FONT, size=12):'
new_p_sig = 'def _p(text, bold=False, italic=False,\n       align="both", sb=0, sa=0, fi=720,\n       font=FONT, size=12, ls=480):'
src = src.replace(old_p_sig, new_p_sig)

# Add ls to spacing XML in _p body
old_ppr = "        f'<w:pPr>'\n        f'<w:jc w:val=\"{align}\"/>'\n        f'{fi_xml}'\n        f'</w:pPr>'"
new_ppr = (
    "        f'<w:pPr>'\n"
    "        f'<w:jc w:val=\"{align}\"/>'\n"
    "        + (f'<w:spacing w:line=\"{ls}\" w:lineRule=\"auto\"/>' if ls else '')\n"
    "        + f'{fi_xml}'\n"
    "        + f'</w:pPr>'"
)
# This approach won't work cleanly with the f-string concatenation in the xml var
# Better: rebuild the xml variable construction

# Find the xml = ( ... ) block in _p and replace it
old_xml_block = '''    xml = (
        f\'<w:p xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">\'
        f\'<w:pPr>\'
        f\'<w:jc w:val="{align}"/>\'
        f\'{fi_xml}\'
        f\'</w:pPr>\'
        f\'<w:r>\'
        f\'<w:rPr>\'
        f\'<w:rFonts w:ascii="{font}" w:hAnsi="{font}" w:cs="{font}"/>\'
        f\'<w:sz w:val="{sz_half}"/><w:szCs w:val="{sz_half}"/>\'
        f\'{bold_xml}{ital_xml}\'
        f\'</w:rPr>\'
        f\'<w:t xml:space="preserve">{t_esc}</w:t>\'
        f\'</w:r>\'
        f\'</w:p>\'
    )'''

new_xml_block = '''    ls_xml = f\'<w:spacing w:line="{ls}" w:lineRule="auto"/>\' if ls else ""
    xml = (
        f\'<w:p xmlns:w="http://schemas.openxmlformats.org/wordprocessingml/2006/main">\'
        f\'<w:pPr>\'
        f\'<w:jc w:val="{align}"/>\'
        f\'{ls_xml}\'
        f\'{fi_xml}\'
        f\'</w:pPr>\'
        f\'<w:r>\'
        f\'<w:rPr>\'
        f\'<w:rFonts w:ascii="{font}" w:hAnsi="{font}" w:cs="{font}"/>\'
        f\'<w:sz w:val="{sz_half}"/><w:szCs w:val="{sz_half}"/>\'
        f\'{bold_xml}{ital_xml}\'
        f\'</w:rPr>\'
        f\'<w:t xml:space="preserve">{t_esc}</w:t>\'
        f\'</w:r>\'
        f\'</w:p>\'
    )'''

if old_xml_block in src:
    src = src.replace(old_xml_block, new_xml_block)
    print("  Fixed _p() xml block")
else:
    print("  WARNING: Could not find _p() xml block to patch — check manually")
    # Show what we found around the area
    idx = src.find('<w:jc w:val="{align}"/>')
    if idx > 0:
        print(f"  Found align at idx {idx}:")
        print(repr(src[idx-100:idx+200]))

# ── FIX 2: _section_hdr — use ls=276 (1.15x) matching template headers ───────
old_sh = 'def _section_hdr(text):\n    """UPPERCASE bold centered section heading."""\n    return _p(text, bold=True, align="center", sb=12, sa=12, fi=0)'
new_sh = 'def _section_hdr(text):\n    """UPPERCASE bold centered section heading — ls=276 (1.15x) matching templates."""\n    return _p(text, bold=True, align="center", fi=0, ls=276)'
if old_sh in src:
    src = src.replace(old_sh, new_sh)
    print("  Fixed _section_hdr()")
else:
    print("  WARNING: _section_hdr() not found as expected")

# ── FIX 3: _sub_hdr — ls=480 (double) matching template subsection labels ─────
old_subh = 'def _sub_hdr(text):\n    """Bold left-aligned subsection label."""\n    return _p(text, bold=True, align="both", sb=12, sa=6, fi=0)'
new_subh = 'def _sub_hdr(text):\n    """Bold left-aligned subsection label — double spaced, no extra sb/sa."""\n    return _p(text, bold=True, align="both", fi=0, ls=480)'
if old_subh in src:
    src = src.replace(old_subh, new_subh)
    print("  Fixed _sub_hdr()")
else:
    print("  WARNING: _sub_hdr() not found as expected")

# ── FIX 4: _body — double spaced, no explicit sb/sa ──────────────────────────
old_body = 'def _body(text, italic=False):\n    """Standard body: justify, 0.5\\" indent, 12pt sb/sa."""\n    return _p(text, italic=italic, align="both", sb=12, sa=12, fi=720)'
new_body = 'def _body(text, italic=False):\n    """Standard body: justify, 0.5\\" indent, double spaced (ls=480) — matches both templates."""\n    return _p(text, italic=italic, align="both", fi=720, ls=480)'
if old_body in src:
    src = src.replace(old_body, new_body)
    print("  Fixed _body()")
else:
    print("  WARNING: _body() not found as expected")

# ── FIX 5: _body0 — double spaced, no indent ─────────────────────────────────
old_b0 = 'def _body0(text, bold=False, italic=False):\n    """Body without first-line indent (numbered items, refs)."""\n    return _p(text, bold=bold, italic=italic, align="both", sb=6, sa=6, fi=0)'
new_b0 = 'def _body0(text, bold=False, italic=False):\n    """Body without first-line indent (numbered items, refs) — double spaced, no explicit sb/sa."""\n    return _p(text, bold=bold, italic=italic, align="both", fi=0, ls=480)'
if old_b0 in src:
    src = src.replace(old_b0, new_b0)
    print("  Fixed _body0()")
else:
    print("  WARNING: _body0() not found as expected")

# ── FIX 6: _multi_run — add ls=480 ───────────────────────────────────────────
old_mr = 'def _multi_run(segments, align="both", sb=12, sa=12, fi=720):'
new_mr = 'def _multi_run(segments, align="both", sb=0, sa=0, fi=720, ls=480):'
if old_mr in src:
    src = src.replace(old_mr, new_mr)
    print("  Fixed _multi_run() signature")
else:
    print("  WARNING: _multi_run() sig not found")

# Fix _multi_run's spacing xml
old_mr_sp = "    sb_t = int(sb * 20); sa_t = int(sa * 20)"
new_mr_sp = "    sb_t = int(sb * 20); sa_t = int(sa * 20)\n    ls_tag = f'<w:spacing w:line=\"{ls}\" w:lineRule=\"auto\"/>' if ls else ''"
if old_mr_sp in src:
    src = src.replace(old_mr_sp, new_mr_sp)
    print("  Fixed _multi_run() sb_t line")

old_mr_ppr = "    fi_x = f'<w:ind w:firstLine=\"{fi}\"/>' if fi else \"\"\n    parts = []"
new_mr_ppr = "    fi_x = f'<w:ind w:firstLine=\"{fi}\"/>' if fi else \"\"\n    ls_x  = ls_tag if 'ls_tag' in dir() else ''\n    parts = []"
if old_mr_ppr in src:
    src = src.replace(old_mr_ppr, new_mr_ppr)

old_mr_xml = "    xml = (\n        f'<w:p xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\">'\n        f'<w:pPr><w:jc w:val=\"{align}\"/>'\n        f'<w:spacing w:before=\"{sb_t}\" w:after=\"{sa_t}\"/>{fi_x}'\n        f'</w:pPr>{\"\"\".\"\"\".join(parts)}</w:p>'\n    )"
if old_mr_xml in src:
    src = src.replace(old_mr_xml, 
        "    xml = (\n        f'<w:p xmlns:w=\"http://schemas.openxmlformats.org/wordprocessingml/2006/main\">'\n        f'<w:pPr><w:jc w:val=\"{align}\"/>{ls_x}{fi_x}'\n        f'</w:pPr>{\"\".join(parts)}</w:p>'\n    )")
    print("  Fixed _multi_run() xml block")

# ── FIX 7: Table cell spacing — use pt 4/4 to match templates ─────────────────
# Template tables use minimal spacing, not 40 twips
old_tcell = "f'<w:p xmlns:w=\"{NS_W}\">'\n                f'<w:pPr><w:spacing w:before=\"40\" w:after=\"40\"/></w:pPr>'"
new_tcell = "f'<w:p xmlns:w=\"{NS_W}\">'\n                f'<w:pPr><w:spacing w:before=\"0\" w:after=\"0\" w:line=\"240\" w:lineRule=\"auto\"/></w:pPr>'"
if old_tcell in src:
    src = src.replace(old_tcell, new_tcell)
    print("  Fixed table cell spacing (40 -> 0 twips, single spaced)")
else:
    print("  WARNING: table cell spacing not found as expected")

# Write patched file
with open("update_working_docx.py", "w", encoding="utf-8") as f:
    f.write(src)

print("\nPatch complete. Run update_working_docx.py to regenerate.")
