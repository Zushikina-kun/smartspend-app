#!/usr/bin/env python3
"""Insert all 8 figures into the PowerPoint presentation"""

from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.enum.text import PP_ALIGN
from pptx.enum.shapes import MSO_SHAPE
import os

# Paths
script_dir = os.path.dirname(os.path.abspath(__file__))
pptx_path = os.path.join(script_dir, '3_PRESENTATION.pptx')
figures_dir = os.path.join(script_dir, 'FIGURES')

print(f"Opening PowerPoint: {pptx_path}")
prs = Presentation(pptx_path)

print(f"Total slides in presentation: {len(prs.slides)}\n")

# Figure placements based on inspection:
# Slide 6: System Architecture (Figures 3.4, 3.5, 3.7, 3.9)
# Slide 7: Peso Companion (Figures 3.6, 3.8)
# Slide 8: Privacy (Figure 3.10)
# Slide 11: Results/SUS (Figure 3.11)

placements = [
    # (slide_index, figure_file, left, top, width, caption)
    (5, 'Figure_3.4_Login_Demo_Mode.jpg', 0.5, 4.8, 2.2, 'Figure 3.4: Login with Demo mode'),
    (5, 'Figure_3.5_Home_Dashboard.jpg', 3.0, 4.8, 2.2, 'Figure 3.5: Home Dashboard (FHS 96/100)'),
    (5, 'Figure_3.7_Batch_Import_GCash.jpg', 5.5, 4.8, 2.2, 'Figure 3.7: Batch Import (GCash)'),
    (5, 'Figure_3.9_Budgets_Savings_Goals.jpg', 8.0, 4.8, 2.2, 'Figure 3.9: Budgets & Savings Goals'),
    
    (6, 'Figure_3.6_Peso_Chat_Expense_Logging.jpg', 1.5, 4.5, 2.5, 'Figure 3.6: Peso Chat (Taglish logging)'),
    (6, 'Figure_3.8_FHS_Breakdown.jpg', 7.5, 4.5, 2.5, 'Figure 3.8: FHS Breakdown'),
    
    (7, 'Figure_3.10_Local_AI_Setup.jpg', 3.5, 4.5, 3.0, 'Figure 3.10: Local AI Setup in Settings'),
    
    (10, 'Figure_3.11_SUS_Computation_Table.png', 1.0, 4.5, 8.0, 'Figure 3.11: SUS Computation Table (sample calculation)'),
]

inserted_count = 0

for slide_idx, fig_file, left, top, width, caption in placements:
    fig_path = os.path.join(figures_dir, fig_file)
    
    if not os.path.exists(fig_path):
        print(f"❌ Figure not found: {fig_file}")
        continue
    
    if slide_idx >= len(prs.slides):
        print(f"⚠️  Slide {slide_idx + 1} doesn't exist, skipping {fig_file}")
        continue
    
    slide = prs.slides[slide_idx]
    
    try:
        # Add picture
        pic = slide.shapes.add_picture(
            fig_path,
            Inches(left),
            Inches(top),
            width=Inches(width)
        )
        
        # Calculate caption position (below image)
        caption_top = top + (pic.height / 914400)  # Convert EMU to inches
        
        # Add caption as text box
        text_box = slide.shapes.add_textbox(
            Inches(left),
            Inches(caption_top + 0.05),
            Inches(width),
            Inches(0.25)
        )
        text_frame = text_box.text_frame
        text_frame.text = caption
        text_frame.word_wrap = True
        
        # Format caption
        para = text_frame.paragraphs[0]
        para.alignment = PP_ALIGN.CENTER
        para.font.size = Pt(9)
        para.font.name = 'Segoe UI'
        
        # Try to set color (gray) - may not work on all systems
        try:
            from pptx.dml.color import RGBColor
            para.font.color.rgb = RGBColor(158, 173, 184)
        except:
            pass
        
        print(f"✅ Inserted {fig_file} into slide {slide_idx + 1}")
        inserted_count += 1
        
    except Exception as e:
        print(f"❌ Error inserting {fig_file} into slide {slide_idx + 1}: {e}")

# Save the modified presentation
output_path = pptx_path  # Overwrite original
prs.save(output_path)

print(f"\n✅ Successfully inserted {inserted_count}/8 figures into PowerPoint")
print(f"   Output: {output_path}")
