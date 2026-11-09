"""
fill_pending.py — Fill [[PENDING]] tags in the DOCX with final data.
The table [[PENDING]] cells are figure placeholders (need manual screenshots).
The paragraph [[PENDING]] block will be replaced with final SUS data.
"""
from docx import Document

DOCX_PATH = r"c:\xampp\htdocs\smartspend_app\docs\handsoff\CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx"

SUS_FINAL = (
    "SmartSpend obtained an overall mean SUS score of 61.83 (SD = 17.58, Median = 52.50) "
    "from N=30 screened respondents (from a pool of N=36, with 6 excluded for insufficient "
    "app usage time). Per Bangor, Kortum, and Miller (2009), this corresponds to an adjective "
    "rating of \"OK\" (Grade C). The score is below the 68-point average SUS benchmark and below "
    "the pre-established target of \u226580 — acknowledged as a limitation of the current prototype stage. "
    "Scores ranged from 35.0 to 100.0, reflecting variance across the diverse respondent profile. "
    "The third research objective was evaluated and documented with specific UI/UX areas identified "
    "for improvement."
)

def main():
    print(f"Opening: {DOCX_PATH}")
    doc = Document(DOCX_PATH)

    para_fixed = 0
    table_pending_count = 0

    # Fix the paragraph [[PENDING]] block (SUS section)
    for para in doc.paragraphs:
        if "[[PENDING" in para.text and "SUS" in para.text:
            # Replace the entire run text
            for run in para.runs:
                if "[[PENDING" in run.text:
                    run.text = SUS_FINAL
                    para_fixed += 1
                    print(f"  Fixed SUS [[PENDING]] paragraph.")
                    break

    # Count table [[PENDING]] cells (figure placeholders — must stay for manual insertion)
    for tbl in doc.tables:
        for row in tbl.rows:
            for cell in row.cells:
                for para in cell.paragraphs:
                    if "[[PENDING]]" in para.text:
                        table_pending_count += 1

    doc.save(DOCX_PATH)
    print(f"Saved: {DOCX_PATH}")
    print(f"\nParagraph [[PENDING]] fixed: {para_fixed}")
    print(f"Table [[PENDING]] cells remaining: {table_pending_count} — these are figure placeholders, insert screenshots manually.")

if __name__ == "__main__":
    main()
