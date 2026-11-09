"""
Generate comprehensive implementation plan from analysis results
"""

import json
from pathlib import Path
from datetime import datetime

ANALYSIS_DIR = Path(r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE\analysis")
ANALYSIS_FILE = ANALYSIS_DIR / "comprehensive_analysis.json"
OUTPUT_FILE = ANALYSIS_DIR / "IMPLEMENTATION_PLAN.md"

def load_analysis():
    """Load the analysis JSON"""
    with open(ANALYSIS_FILE, 'r', encoding='utf-8') as f:
        return json.load(f)

def generate_plan(data):
    """Generate the implementation plan markdown"""
    
    plan = f"""# SmartSpend Defense Documents - Comprehensive Implementation Plan

**Generated:** {datetime.now().strftime("%Y-%m-%d %H:%M:%S")}  
**Analysis Source:** comprehensive_analysis.json  
**Task:** Fix all defense documents for final defense consistency

---

## EXECUTIVE SUMMARY

### Documents Analyzed
- **4 Presentations:**
  - FINAL (FOR_CYRILLE/3_PRESENTATION_FINAL.pptx) - 16 slides, 2.2 MB
  - NEW_DEFENSE (FOR_CYRILLE/SmartSpend_Defense.pptx) - 18 slides, 4.0 MB ⭐
  - AI_POWERED (handsoff/SMARTSPEND AI-Powered...) - 21 slides, 855 KB
  - AI_ASSISTED (handsoff/SmartSpend An AI-Assisted...) - 22 slides, 1.1 MB

- **Manuscript:** 1_MAIN_MANUSCRIPT_FINAL.docx (648 paragraphs, 9 tables)
- **Manuscript PDF:** 1_MAIN_MANUSCRIPT_FINAL.docx.pdf (123 pages)
- **Script:** 4_DEFENSE_SCRIPT_FINAL.md (403 lines, 5208 words)

### Critical Findings Summary

"""
    
    # Add presentation comparison
    pres = data["presentations"]
    plan += f"""
#### Presentation Comparison

| Presentation | Slides | File Size | Images | Issues | Fonts |
|-------------|--------|-----------|--------|---------|-------|
| FINAL | {pres['FINAL']['slide_count']} | {pres['FINAL']['file_size']:,} bytes | {pres['FINAL']['has_images']} | {len(pres['FINAL']['issues_found'])} | {len(pres['FINAL']['fonts_used'])} |
| NEW_DEFENSE | {pres['NEW_DEFENSE']['slide_count']} | {pres['NEW_DEFENSE']['file_size']:,} bytes | {pres['NEW_DEFENSE']['has_images']} | {len(pres['NEW_DEFENSE']['issues_found'])} | {len(pres['NEW_DEFENSE']['fonts_used'])} |
| AI_POWERED | {pres['AI_POWERED']['slide_count']} | {pres['AI_POWERED']['file_size']:,} bytes | {pres['AI_POWERED']['has_images']} | {len(pres['AI_POWERED']['issues_found'])} | {len(pres['AI_POWERED']['fonts_used'])} |
| AI_ASSISTED | {pres['AI_ASSISTED']['slide_count']} | {pres['AI_ASSISTED']['file_size']:,} bytes | {pres['AI_ASSISTED']['has_images']} | {len(pres['AI_ASSISTED']['issues_found'])} | {len(pres['AI_ASSISTED']['fonts_used'])} |

**RECOMMENDATION:** {data['comparison']['recommendation']}

**Reasons:**
"""
    
    for reason in data['comparison'].get('reasons', []):
        plan += f"- {reason}\n"
    
    # Critical values verification
    plan += f"""

### Critical Numerical Values Check

**Target Values:**
- SUS Mean: 61.83 (Grade D - "OK")
- Demographics: 10 parents (35-55) + 20 young professionals (21-35) = N=30
- Total Participants: 30
- Survey Period: Oct-Nov 2026

"""
    
    # Issues found
    plan += """
### Issues Summary

#### FINAL Presentation Issues
"""
    for issue in pres['FINAL']['issues_found']:
        plan += f"- **Slide {issue['slide']}** - {issue['issue_type']}: `{issue['text'][:80]}...`\n"
    
    plan += """
#### NEW_DEFENSE Presentation Issues
"""
    for issue in pres['NEW_DEFENSE']['issues_found']:
        plan += f"- **Slide {issue['slide']}** - {issue['issue_type']}: `{issue['text'][:80]}...`\n"
    
    plan += f"""
#### Manuscript DOCX Issues
Total issues found: {len(data['manuscript_docx']['issues_found'])}
"""
    
    for issue in data['manuscript_docx']['issues_found'][:10]:  # Show first 10
        plan += f"- **Paragraph {issue['paragraph']}** - {issue['issue_type']}: `{issue['text'][:80]}...`\n"
    
    if len(data['manuscript_docx']['issues_found']) > 10:
        plan += f"- ... and {len(data['manuscript_docx']['issues_found']) - 10} more issues\n"
    
    plan += f"""
#### Manuscript PDF Issues
Total issues found: {len(data['manuscript_pdf']['issues_found'])}

#### Script Issues
"""
    
    for issue in data['script']['issues_found']:
        plan += f"- **{issue['issue_type']}**: {issue['count']} occurrences\n"
    
    # Slide references in script
    plan += f"""
#### Script Slide References
The script references these slide numbers: {', '.join(map(str, data['script']['slide_references']))}
"""
    
    # Now the implementation plan
    plan += """

---

## IMPLEMENTATION PLAN

### Phase 1: Choose Base Presentation [HIGH PRIORITY]

**Decision Required:** Select between FINAL (16 slides) and NEW_DEFENSE (18 slides)

**Analysis:**
- NEW_DEFENSE has MORE content (18 vs 16 slides)
- NEW_DEFENSE has LARGER file size (4 MB vs 2.2 MB) - likely more assets
- FINAL has FEWER issues (1 vs 2)
- NEW_DEFENSE appears to be the groupmate's revised version (from context)

**RECOMMENDATION:** Use **NEW_DEFENSE** as the base, selectively merge missing content from FINAL

**Rationale:**
1. NEW_DEFENSE is newer (file timestamp: Nov 9, 10:17 PM vs FINAL: Nov 9, 2:26 PM)
2. More comprehensive (18 slides covers more ground)
3. User context suggests this is the "revised" version by the groupmate
4. Reference presentations (AI_POWERED, AI_ASSISTED) have 21-22 slides, suggesting more content is better

---

### Phase 2: Presentation Fixes [HIGH PRIORITY]

#### 2.1 Content Verification
- [ ] **Verify SUS score: 61.83** appears consistently across all slides mentioning results
- [ ] **Verify demographics: 10 parents + 20 young professionals = 30 total** 
- [ ] **Verify Grade D rating** is correctly stated
- [ ] **Check all dates are 2026** (found "2025" in FINAL slide 2)
- [ ] **Remove any "preliminary" or "pending" language**

#### 2.2 Cross-Reference with Reference Presentations
- [ ] **Compare layouts** from AI_POWERED and AI_ASSISTED
- [ ] **Check for missing logos** (Lorma Colleges, CCSE, etc.)
- [ ] **Verify all figures are properly labeled** (Figure 3.4, Figure 3.5, etc.)
- [ ] **Check if methodology slides need enhancement** from reference decks
- [ ] **Verify all charts/tables are high resolution**

#### 2.3 Slide-by-Slide Audit (NEW_DEFENSE as base)
"""
    
    # Add slide-by-slide checklist for NEW_DEFENSE
    for slide in pres['NEW_DEFENSE']['slides'][:10]:  # First 10 slides
        plan += f"""
##### Slide {slide['slide_number']}: {slide['layout_name']}
- Layout: {slide['layout_name']}
- Shapes: {slide['shapes_count']}
- Has Title: {'✓' if slide['has_title'] else '✗'}
- Has Images: {'✓' if slide['has_images'] else '✗'}
- Content check: {''.join(slide['text_content'][:2])[:100]}...
"""
    
    plan += """

---

### Phase 3: Manuscript Consistency [HIGH PRIORITY]

#### 3.1 Verify PDF vs DOCX Alignment
- [ ] **Page count matches** (PDF: 123 pages)
- [ ] **All figures present in both versions**
- [ ] **No content missing in PDF export**
- [ ] **Formatting preserved** (headings, tables, figures)

#### 3.2 Fix Issues in DOCX
"""
    
    # Group issues by type
    docx_issues_by_type = {}
    for issue in data['manuscript_docx']['issues_found']:
        issue_type = issue['issue_type']
        if issue_type not in docx_issues_by_type:
            docx_issues_by_type[issue_type] = []
        docx_issues_by_type[issue_type].append(issue)
    
    for issue_type, issues in docx_issues_by_type.items():
        plan += f"""
##### Fix: {issue_type.upper()} ({len(issues)} occurrences)
- [ ] Review all {len(issues)} instances of "{issue_type}"
- [ ] Paragraphs: {', '.join([str(i['paragraph']) for i in issues[:10]])}{'...' if len(issues) > 10 else ''}
"""
    
    plan += """

#### 3.3 Numerical Data Verification
- [ ] **SUS Mean: 61.83** - search entire manuscript
- [ ] **Sample size: N=30** - verify all mentions
- [ ] **Demographics breakdown: 10 parents, 20 young professionals** - check consistency
- [ ] **All percentages** match between manuscript and presentation
- [ ] **All statistics** have proper citations

---

### Phase 4: Script Alignment [MEDIUM PRIORITY]

#### 4.1 Slide Number Verification
Script references slides: """
    
    plan += ', '.join(map(str, data['script']['slide_references']))
    
    plan += """

**Action Items:**
- [ ] **Map each script slide reference** to actual slide numbers in NEW_DEFENSE
- [ ] **Update script** if slide numbers changed
- [ ] **Verify all slide content** matches what the script says to present
- [ ] **Check timing** - script should fit within defense time limit

#### 4.2 Content Consistency
- [ ] **All numbers in script** match manuscript and presentation
- [ ] **All claims in script** are backed by manuscript content
- [ ] **Taglish examples** in script match app functionality
- [ ] **Demo sections** in script align with current app version (v3.1.2)

#### 4.3 Fix Script Issues
"""
    
    for issue in data['script']['issues_found']:
        plan += f"- [ ] Fix **{issue['issue_type']}**: {issue['count']} occurrences\n"
    
    plan += """

---

### Phase 5: Reference Deck Integration [MEDIUM PRIORITY]

#### 5.1 Extract Best Practices from AI_POWERED
- [ ] **Review layout templates** (21 slides, different structure)
- [ ] **Check for better visualizations** of data
- [ ] **Look for additional context** we might be missing
- [ ] **Identify any logos/branding** we should use

#### 5.2 Extract Best Practices from AI_ASSISTED  
- [ ] **Review layout templates** (22 slides, most comprehensive)
- [ ] **Check methodology presentation** style
- [ ] **Look for better ways** to present FHS formula
- [ ] **Identify missing sections** in our deck

#### 5.3 Merge Improvements
- [ ] **Create comparison matrix** of all 4 presentations
- [ ] **Identify best slide** for each topic
- [ ] **Merge layouts and content** into NEW_DEFENSE base
- [ ] **Maintain consistency** in fonts, colors, spacing

---

### Phase 6: Final Quality Checks [HIGH PRIORITY]

#### 6.1 Visual Quality
- [ ] **All images are high resolution** (min 300 DPI)
- [ ] **No pixelated screenshots** or logos
- [ ] **Consistent font sizes** across slides
- [ ] **Proper alignment** of all elements
- [ ] **Color scheme consistency** throughout

#### 6.2 Content Quality  
- [ ] **No typos or grammar errors**
- [ ] **All acronyms defined** on first use
- [ ] **All citations complete** and properly formatted
- [ ] **All figures numbered** and referenced in text
- [ ] **All tables formatted** consistently

#### 6.3 Cross-Document Consistency
- [ ] **Presentation title** matches manuscript
- [ ] **All authors listed** consistently (order, names, roles)
- [ ] **Adviser name** consistent everywhere (Ms. Ellen F. Mangaoang, DIT)
- [ ] **Defense date** consistent (November 9, 2026)
- [ ] **All statistics match** across all documents

#### 6.4 Technical Verification
- [ ] **All formulas render** correctly in presentation
- [ ] **All links work** (if any)
- [ ] **Presentation displays** correctly on projection screen
- [ ] **PDF exports** without errors
- [ ] **File sizes reasonable** for sharing

---

## VERIFICATION CHECKLIST

### Critical Values Present and Consistent

| Value | Manuscript | Presentation | Script | Status |
|-------|-----------|--------------|--------|--------|
| SUS Mean: 61.83 | ⏳ | ✓ | ⏳ | VERIFY |
| Grade: D (OK) | ⏳ | ✓ | ⏳ | VERIFY |
| N = 30 | ✓ | ✓ | ⏳ | VERIFY |
| 10 parents (35-55) | ✓ | ✓ | ⏳ | VERIFY |
| 20 young prof (21-35) | ✓ | ✓ | ⏳ | VERIFY |
| Survey: Oct-Nov 2026 | ✓ | ✓ | ⏳ | VERIFY |
| App version: v3.1.2 | ⏳ | ✓ | ⏳ | VERIFY |

### Issues Fixed

| Issue Type | Count | Priority | Status |
|-----------|-------|----------|--------|
| "preliminary" | TBD | HIGH | ⏳ |
| "pending" | TBD | HIGH | ⏳ |
| "placeholder" | TBD | HIGH | ⏳ |
| Old dates (2024/2025) | 1+ | HIGH | ⏳ |
| Missing logos | TBD | MEDIUM | ⏳ |
| Low-res images | TBD | MEDIUM | ⏳ |
| Formatting issues | TBD | LOW | ⏳ |

### Documents Ready

- [ ] **NEW_DEFENSE.pptx** - Final presentation ready
- [ ] **1_MAIN_MANUSCRIPT_FINAL.docx** - All issues fixed
- [ ] **1_MAIN_MANUSCRIPT_FINAL.pdf** - Regenerated from fixed DOCX
- [ ] **4_DEFENSE_SCRIPT_FINAL.md** - Aligned with presentation
- [ ] **All files backed up** before final defense
- [ ] **Printed copies prepared** if required
- [ ] **Demo app tested** and ready

---

## PRIORITY RANKING

### 🔴 CRITICAL (Must fix before defense)
1. **Choose base presentation** (NEW_DEFENSE recommended)
2. **Verify all numerical data** (SUS 61.83, N=30, demographics)
3. **Fix date inconsistencies** (change 2025 to 2026)
4. **Remove "preliminary/pending" language**
5. **Verify PDF matches DOCX**
6. **Update script slide numbers** to match final presentation

### 🟡 HIGH (Should fix)
1. **Add missing logos** from reference presentations
2. **Fix all manuscript issues** (35 instances found)
3. **Improve image quality** where needed
4. **Verify all citations** are complete
5. **Check cross-document consistency**

### 🟢 MEDIUM (Nice to have)
1. **Merge best layouts** from reference decks
2. **Enhance visualizations** based on AI_POWERED/AI_ASSISTED
3. **Improve slide transitions**
4. **Polish formatting** across all documents

### ⚪ LOW (Optional)
1. **Consider color scheme** improvements
2. **Add more visual elements** if time permits
3. **Create backup versions** in different formats

---

## NEXT STEPS

1. **DECISION POINT:** Confirm using NEW_DEFENSE as base presentation
2. **RUN DETAILED AUDIT:** Open both presentations side-by-side and compare slide-by-slide
3. **CREATE MERGE PLAN:** Document which slides need content from FINAL or reference decks
4. **FIX CRITICAL ISSUES:** Start with numerical consistency and dates
5. **UPDATE SCRIPT:** Align with final presentation slide numbers
6. **FINAL REVIEW:** Have all team members review before defense

---

## TOOLS NEEDED

- **Python scripts:** Already created for analysis
- **PowerPoint:** For presentation editing
- **Word:** For manuscript editing
- **PDF comparison tool:** To verify PDF vs DOCX
- **Image editor:** If images need enhancement
- **Spell checker:** For final proofreading

---

## ESTIMATED EFFORT

- **Phase 1:** 30 minutes (decision + initial comparison)
- **Phase 2:** 2-3 hours (presentation fixes)
- **Phase 3:** 2-3 hours (manuscript consistency)
- **Phase 4:** 1-2 hours (script alignment)
- **Phase 5:** 1-2 hours (reference integration)
- **Phase 6:** 1-2 hours (final quality checks)

**Total: 7-13 hours** (can be parallelized across team members)

---

## NOTES

- This plan is generated from automated analysis of all documents
- Some issues may require manual inspection to determine severity
- Prioritize fixes that affect defense presentation quality
- Keep original files backed up before making changes
- Test presentation on actual defense setup before the day

---

**Analysis complete. Begin implementation with Phase 1 decision.**
"""
    
    return plan

def main():
    """Main function"""
    print("Loading analysis data...")
    data = load_analysis()
    
    print("Generating implementation plan...")
    plan = generate_plan(data)
    
    print(f"Writing plan to {OUTPUT_FILE}...")
    with open(OUTPUT_FILE, 'w', encoding='utf-8') as f:
        f.write(plan)
    
    print(f"\n✓ Implementation plan generated successfully!")
    print(f"  Output: {OUTPUT_FILE}")
    print(f"  Size: {len(plan)} characters")

if __name__ == "__main__":
    main()
