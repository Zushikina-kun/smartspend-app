import sys
from docx import Document
from docx.oxml.ns import qn

SRC = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\1_MAIN_MANUSCRIPT_FINAL(MAIN_V4) (2).docx"
doc = Document(SRC)
paras = doc.paragraphs

def has_image(p):
    for run in p.runs:
        if run._element.findall('.//' + qn('a:blip')):
            return True
        if run._element.findall('.//' + qn('w:drawing')):
            return True
    return False

# Key paragraphs the brief references — print full text
keys = [51,52,53,54,166,177,178,184,196,197,209,213,220,221,222,223,224,225,226,227,228,229,230,231,232,233,234,
        240,241,242,244,245,246,247,248,249,250,251,252,253,254,255,262,263,264,265,266,267,268,269,270,271,272,273,274,
        289,290,291,292,293,295,296,297,298,299,300,301,302,303,304,305,306,307,308,309,310,311,312,313,
        316,317,318,319,320,321,322,323,324,325,326,333,334,335,336,337,338,339,340,341,342,343,344,345,346,347,348,349,350,
        351,352,353,354,355,356,357,358,359,360,361,362,363,364,365,366,367,
        371,372,373,374,375,376,377,378,379,380,381,382,383,
        385,386,387,389,433,434,444,445,446,447,448,449,450,
        674,675,676,677,678,679,680,681,682,683,684,685,686,687]

for i in keys:
    if i < len(paras):
        p = paras[i]
        style = p.style.name if p.style else "?"
        img = " [IMG]" if has_image(p) else ""
        print(f"===== [{i:04d}] ({style}){img} =====")
        print(p.text)
        print()
