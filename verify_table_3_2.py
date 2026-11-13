"""Verify Table 3.2 content"""
from docx import Document

doc = Document(r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx")

print("=== Looking for Table 3.2 (AI models table) ===\n")

for idx, table in enumerate(doc.tables):
    # Check for AI models table
    has_gemini = False
    has_gpt = False
    
    for row in table.rows:
        row_text = ' '.join([cell.text for cell in row.cells])
        if "Gemini" in row_text:
            has_gemini = True
        if "GPT" in row_text or "Claude" in row_text:
            has_gpt = True
    
    if has_gemini and has_gpt:
        print(f"Table {idx} appears to be AI models table:")
        print(f"Rows: {len(table.rows)}, Columns: {len(table.columns)}")
        print("\nTable content:")
        print("-" * 100)
        
        for row_idx, row in enumerate(table.rows):
            cells_text = []
            for cell_idx, cell in enumerate(row.cells):
                cells_text.append(f"[{cell_idx}]{cell.text[:50]}")
            print(f"Row {row_idx}: {' | '.join(cells_text)}")
            
            # Check for Gemini 3.7
            for cell_idx, cell in enumerate(row.cells):
                if "3.7" in cell.text and "Flash" in cell.text:
                    print(f"\n*** Found Gemini 3.7 Flash at Row {row_idx}, Cell {cell_idx} ***")
                    print(f"Cell {cell_idx}: {cell.text}")
                    if cell_idx + 1 < len(row.cells):
                        print(f"Cell {cell_idx + 1}: {row.cells[cell_idx + 1].text}")
                    if cell_idx + 2 < len(row.cells):
                        print(f"Cell {cell_idx + 2}: {row.cells[cell_idx + 2].text}")
        print("-" * 100)
