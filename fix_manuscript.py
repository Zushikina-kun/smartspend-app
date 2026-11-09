from docx import Document
from docx.shared import Inches
import re

doc_path = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\1_MAIN_MANUSCRIPT_FINAL.docx'
doc = Document(doc_path)

print('FIXING MANUSCRIPT ISSUES...')
print('='*80)

# Find paragraph with Figure 3.10 caption
for i, para in enumerate(doc.paragraphs):
    if 'Figure 3.10' in para.text and 'Local AI' in para.text:
        print(f'Found Figure 3.10 caption at paragraph {i}')
        
        # Insert image before the caption
        # Check if image already exists immediately before
        if i > 0:
            prev_para = doc.paragraphs[i-1]
            has_image = any(run.element.xpath('.//a:blip') for run in prev_para.runs)
            
            if not has_image:
                print('Inserting Figure 3.10 image...')
                # Insert a new paragraph before the caption for the image
                new_para = para.insert_paragraph_before()
                run = new_para.add_run()
                
                # Add the image
                fig_path = r'c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\FIGURES\Figure_3.10_Local_AI_Setup.jpg'
                run.add_picture(fig_path, width=Inches(5.0))
                
                # Center the image
                new_para.alignment = 1  # 1 = center
                
                print('✓ Figure 3.10 image inserted successfully')
            else:
                print('Image already present before caption')
        break

# Save the document
output_path = doc_path
doc.save(output_path)
print(f'\n✓ Document saved: {output_path}')
print('\nAll fixes applied successfully!')
