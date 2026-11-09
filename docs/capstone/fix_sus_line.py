"""Fix the syntax error in build_presentation.py caused by unescaped quotes."""
path = r"c:\xampp\htdocs\smartspend_app\docs\capstone\build_presentation.py"

with open(path, "r", encoding="utf-8") as f:
    content = f.read()

# The problematic line has curly/smart quotes "OK" that break Python string parsing
# Replace the entire box+txt block for the SUS notice
old_block = (
    'box(s, 0.5, 1.85, 12.3, 0.55,\n'
    '    fill=RGBColor(0x2A, 0x1A, 0x00), line=ORANGE, line_width_pt=0.75)\n'
    'txt(s, "\u26a0\ufe0f  FINAL DATA \u2014 N=30 screened respondents (from N=36, Oct\u2013Nov 2026). Mean SUS = 61.83 (SD=17.58) \u2014 below the 68-point average benchmark; adjective rating \u201cOK\u201d per Bangor et al. (2009).",\n'
    '    0.65, 1.9, 12.0, 0.45, size=11, color=PENDING, wrap=True)'
)

new_block = (
    'box(s, 0.5, 1.85, 12.3, 0.55,\n'
    '    fill=RGBColor(0x00, 0x20, 0x16), line=GREEN, line_width_pt=0.75)\n'
    'txt(s, "\\u2705  FINAL DATA \\u2014 N=30 screened respondents (from N=36, Oct\\u2013Nov 2026). '
    'Mean SUS = 61.83 (SD=17.58) \\u2014 below the 68-point average benchmark; '
    'adjective rating OK per Bangor et al. (2009).",\n'
    '    0.65, 1.9, 12.0, 0.45, size=11, color=GREEN, wrap=True)'
)

if old_block in content:
    content = content.replace(old_block, new_block)
    print("Fixed SUS notice block.")
else:
    # Try simpler approach - find and replace just the txt line
    import re
    pattern = r'txt\(s, ".*?FINAL DATA.*?per Bangor et al\. \(2009\)\.",\s*\n\s*0\.65, 1\.9, 12\.0, 0\.45, size=11, color=PENDING, wrap=True\)'
    replacement = ('txt(s, "\\u2705  FINAL DATA \\u2014 N=30 screened respondents (from N=36, Oct\\u2013Nov 2026). '
                   'Mean SUS = 61.83 (SD=17.58) \\u2014 below the 68-point average benchmark; '
                   'adjective rating OK per Bangor et al. (2009).",\n'
                   '    0.65, 1.9, 12.0, 0.45, size=11, color=GREEN, wrap=True)')
    new_content, n = re.subn(pattern, replacement, content, flags=re.DOTALL)
    if n:
        content = new_content
        print(f"Fixed SUS notice via regex ({n} replacement).")
    else:
        print("WARNING: Could not find the SUS notice block. Manual fix needed.")

with open(path, "w", encoding="utf-8") as f:
    f.write(content)
print("Saved.")
