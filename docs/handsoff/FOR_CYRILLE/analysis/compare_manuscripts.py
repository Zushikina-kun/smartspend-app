"""
Comprehensive manuscript comparison script
Identifies all differences between versions and the FINAL manuscript
"""

from docx import Document
import os
from collections import defaultdict
from difflib import SequenceMatcher, unified_diff

def extract_all_content(docx_path):
    """Extract paragraphs, tables, and structure from a docx file"""
    try:
        doc = Document(docx_path)
        content = {
            'paragraphs': [],
            'tables': [],
            'headings': [],
            'toc_entries': []
        }
        
        # Extract all paragraphs with their style
        for i, para in enumerate(doc.paragraphs):
            text = para.text.strip()
            style = para.style.name if para.style else 'Normal'
            content['paragraphs'].append({
                'index': i,
                'text': text,
                'style': style,
                'is_heading': style.startswith('Heading') or style.startswith('Title')
            })
            
            if style.startswith('Heading') or style.startswith('Title'):
                content['headings'].append({
                    'index': i,
                    'text': text,
                    'level': style
                })
        
        # Extract tables
        for t_idx, table in enumerate(doc.tables):
            table_data = []
            for row in table.rows:
                row_data = [cell.text.strip() for cell in row.cells]
                table_data.append(row_data)
            content['tables'].append({
                'index': t_idx,
                'data': table_data,
                'rows': len(table.rows),
                'cols': len(table.columns) if table.rows else 0
            })
        
        return content
    except Exception as e:
        return {'error': str(e), 'paragraphs': [], 'tables': [], 'headings': []}

def find_paragraph_differences(base_content, compare_content, base_name, compare_name):
    """Find all differences between two documents"""
    differences = []
    
    base_paras = base_content['paragraphs']
    compare_paras = compare_content['paragraphs']
    
    # Count non-empty paragraphs
    base_count = sum(1 for p in base_paras if p['text'])
    compare_count = sum(1 for p in compare_paras if p['text'])
    
    differences.append({
        'type': 'PARAGRAPH_COUNT',
        'base': base_count,
        'compare': compare_count,
        'diff': compare_count - base_count,
        'description': f"{compare_name} has {compare_count} paragraphs vs {base_name} has {base_count} paragraphs (difference: {compare_count - base_count})"
    })
    
    # Build text comparison
    base_texts = [p['text'] for p in base_paras if p['text']]
    compare_texts = [p['text'] for p in compare_paras if p['text']]
    
    # Find unique paragraphs in compare version
    base_text_set = set(base_texts)
    compare_text_set = set(compare_texts)
    
    unique_in_compare = compare_text_set - base_text_set
    unique_in_base = base_text_set - compare_text_set
    
    if unique_in_compare:
        for idx, text in enumerate(unique_in_compare, 1):
            # Find location in compare document
            location = next((p['index'] for p in compare_paras if p['text'] == text), -1)
            differences.append({
                'type': 'ADDED_PARAGRAPH',
                'number': idx,
                'location': location,
                'text': text[:200] + ('...' if len(text) > 200 else ''),
                'full_text': text,
                'description': f"Paragraph found in {compare_name} but not in {base_name}"
            })
    
    if unique_in_base:
        for idx, text in enumerate(unique_in_base, 1):
            # Find location in base document
            location = next((p['index'] for p in base_paras if p['text'] == text), -1)
            differences.append({
                'type': 'REMOVED_PARAGRAPH',
                'number': idx,
                'location': location,
                'text': text[:200] + ('...' if len(text) > 200 else ''),
                'full_text': text,
                'description': f"Paragraph found in {base_name} but not in {compare_name}"
            })
    
    # Check for modified paragraphs (similar but not identical)
    for base_para in base_paras:
        if not base_para['text'] or base_para['text'] in compare_text_set:
            continue
        
        # Find similar paragraphs
        for compare_para in compare_paras:
            if not compare_para['text'] or compare_para['text'] in base_text_set:
                continue
            
            similarity = SequenceMatcher(None, base_para['text'], compare_para['text']).ratio()
            if similarity > 0.7 and similarity < 1.0:  # Similar but not identical
                differences.append({
                    'type': 'MODIFIED_PARAGRAPH',
                    'location_base': base_para['index'],
                    'location_compare': compare_para['index'],
                    'similarity': f"{similarity:.1%}",
                    'before': base_para['text'],
                    'after': compare_para['text'],
                    'description': f"Paragraph modified (similarity: {similarity:.1%})"
                })
    
    return differences

def compare_headings(base_content, compare_content):
    """Compare heading structures"""
    differences = []
    
    base_headings = [h['text'] for h in base_content['headings']]
    compare_headings = [h['text'] for h in compare_content['headings']]
    
    if base_headings != compare_headings:
        differences.append({
            'type': 'HEADING_STRUCTURE',
            'base_count': len(base_headings),
            'compare_count': len(compare_headings),
            'description': 'Heading structure differs'
        })
        
        # Find added/removed headings
        base_set = set(base_headings)
        compare_set = set(compare_headings)
        
        added = compare_set - base_set
        removed = base_set - compare_set
        
        if added:
            for heading in added:
                differences.append({
                    'type': 'ADDED_HEADING',
                    'text': heading,
                    'description': f"Heading added: {heading}"
                })
        
        if removed:
            for heading in removed:
                differences.append({
                    'type': 'REMOVED_HEADING',
                    'text': heading,
                    'description': f"Heading removed: {heading}"
                })
    
    return differences

def compare_tables(base_content, compare_content):
    """Compare tables"""
    differences = []
    
    base_tables = base_content['tables']
    compare_tables = compare_content['tables']
    
    if len(base_tables) != len(compare_tables):
        differences.append({
            'type': 'TABLE_COUNT',
            'base_count': len(base_tables),
            'compare_count': len(compare_tables),
            'description': f"Table count differs: {len(compare_tables)} vs {len(base_tables)}"
        })
    
    # Compare each table
    for idx in range(min(len(base_tables), len(compare_tables))):
        base_table = base_tables[idx]
        compare_table = compare_tables[idx]
        
        if base_table['rows'] != compare_table['rows'] or base_table['cols'] != compare_table['cols']:
            differences.append({
                'type': 'TABLE_SIZE',
                'table_index': idx,
                'base_size': f"{base_table['rows']}x{base_table['cols']}",
                'compare_size': f"{compare_table['rows']}x{compare_table['cols']}",
                'description': f"Table {idx+1} size differs"
            })
        
        if base_table['data'] != compare_table['data']:
            differences.append({
                'type': 'TABLE_CONTENT',
                'table_index': idx,
                'description': f"Table {idx+1} content differs"
            })
    
    return differences

def analyze_all_versions():
    """Main analysis function"""
    base_dir = r"c:\xampp\htdocs\smartspend_app\docs\handsoff"
    
    # Define all files to analyze
    files_to_check = {
        'FINAL': os.path.join(base_dir, 'FOR_CYRILLE', '1_MAIN_MANUSCRIPT_FINAL.docx'),
        'ROOT': os.path.join(base_dir, '1_MAIN_MANUSCRIPT.docx'),
        'GROUPMATE': os.path.join(base_dir, 'FOR_CYRILLE', '1_MAIN_MANUSCRIPT_FINAL(groupmates ver).docx'),
        'UNSORTED_LUCIDFRAME_5': os.path.join(base_dir, 'Unsorted', 'CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx'),
        'UNSORTED_CYRILLE_BACKUP': os.path.join(base_dir, 'Unsorted', 'CAPSTONE_LucidFrame_CYRILLE_VERSION_backup.docx'),
        'UNSORTED_UPDATED': os.path.join(base_dir, 'Unsorted', 'SmartSpend_Manuscript_updated.docx')
    }
    
    print("=" * 80)
    print("MANUSCRIPT COMPARISON ANALYSIS")
    print("=" * 80)
    print()
    
    # Load all documents
    print("Loading documents...")
    contents = {}
    for name, path in files_to_check.items():
        if os.path.exists(path):
            print(f"  ✓ Loading {name}: {path}")
            contents[name] = extract_all_content(path)
        else:
            print(f"  ✗ Missing {name}: {path}")
            contents[name] = None
    
    print()
    
    # Base comparison is FINAL version
    base_name = 'FINAL'
    base_content = contents.get(base_name)
    
    if not base_content or 'error' in base_content:
        print(f"ERROR: Cannot load base document (FINAL)")
        return
    
    # Prepare output
    output_lines = []
    output_lines.append("# MANUSCRIPT DIFFERENCES ANALYSIS")
    output_lines.append("")
    output_lines.append("**Analysis Date**: Generated by comparison script")
    output_lines.append(f"**Base Document**: FINAL version (758 paragraphs)")
    output_lines.append("")
    output_lines.append("---")
    output_lines.append("")
    
    total_differences = 0
    
    # Compare each version against FINAL
    for compare_name in ['ROOT', 'GROUPMATE', 'UNSORTED_LUCIDFRAME_5', 'UNSORTED_CYRILLE_BACKUP', 'UNSORTED_UPDATED']:
        compare_content = contents.get(compare_name)
        
        if not compare_content or 'error' in compare_content:
            output_lines.append(f"## {compare_name}")
            output_lines.append("")
            output_lines.append(f"**Status**: ❌ File not found or error loading")
            output_lines.append("")
            output_lines.append("---")
            output_lines.append("")
            continue
        
        print(f"Comparing {compare_name} against {base_name}...")
        
        output_lines.append(f"## {compare_name}")
        output_lines.append("")
        output_lines.append(f"**File**: `{files_to_check[compare_name]}`")
        output_lines.append("")
        
        # Find all differences
        all_diffs = []
        
        # Paragraph differences
        para_diffs = find_paragraph_differences(base_content, compare_content, base_name, compare_name)
        all_diffs.extend(para_diffs)
        
        # Heading differences
        heading_diffs = compare_headings(base_content, compare_content)
        all_diffs.extend(heading_diffs)
        
        # Table differences
        table_diffs = compare_tables(base_content, compare_content)
        all_diffs.extend(table_diffs)
        
        output_lines.append(f"**Total Differences Found**: {len(all_diffs)}")
        output_lines.append("")
        
        if not all_diffs:
            output_lines.append("✅ No differences found - identical to FINAL version")
        else:
            # Group differences by type
            by_type = defaultdict(list)
            for diff in all_diffs:
                by_type[diff['type']].append(diff)
            
            # Output by category
            for diff_type, diffs in by_type.items():
                output_lines.append(f"### {diff_type.replace('_', ' ').title()} ({len(diffs)})")
                output_lines.append("")
                
                for idx, diff in enumerate(diffs, 1):
                    if diff_type == 'PARAGRAPH_COUNT':
                        output_lines.append(f"{diff['description']}")
                        output_lines.append("")
                    
                    elif diff_type == 'ADDED_PARAGRAPH':
                        output_lines.append(f"**{idx}. Added at position {diff['location']}**")
                        output_lines.append(f"```")
                        output_lines.append(diff['full_text'][:500])
                        if len(diff['full_text']) > 500:
                            output_lines.append("... [truncated]")
                        output_lines.append(f"```")
                        output_lines.append("")
                    
                    elif diff_type == 'REMOVED_PARAGRAPH':
                        output_lines.append(f"**{idx}. Removed from position {diff['location']}**")
                        output_lines.append(f"```")
                        output_lines.append(diff['full_text'][:500])
                        if len(diff['full_text']) > 500:
                            output_lines.append("... [truncated]")
                        output_lines.append(f"```")
                        output_lines.append("")
                    
                    elif diff_type == 'MODIFIED_PARAGRAPH':
                        output_lines.append(f"**{idx}. Modified (Similarity: {diff['similarity']})**")
                        output_lines.append("")
                        output_lines.append(f"**Before** (position {diff['location_base']}):")
                        output_lines.append(f"```")
                        output_lines.append(diff['before'][:300])
                        if len(diff['before']) > 300:
                            output_lines.append("... [truncated]")
                        output_lines.append(f"```")
                        output_lines.append("")
                        output_lines.append(f"**After** (position {diff['location_compare']}):")
                        output_lines.append(f"```")
                        output_lines.append(diff['after'][:300])
                        if len(diff['after']) > 300:
                            output_lines.append("... [truncated]")
                        output_lines.append(f"```")
                        output_lines.append("")
                    
                    else:
                        output_lines.append(f"{idx}. {diff['description']}")
                        output_lines.append("")
        
        total_differences += len(all_diffs)
        output_lines.append("---")
        output_lines.append("")
    
    # Summary
    output_lines.insert(4, f"**Total Differences Across All Versions**: {total_differences}")
    output_lines.insert(5, "")
    
    # Write output
    output_path = os.path.join(base_dir, 'FOR_CYRILLE', 'analysis', 'DIFFERENCES_FOUND.md')
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write('\n'.join(output_lines))
    
    print()
    print("=" * 80)
    print(f"ANALYSIS COMPLETE")
    print(f"Total differences found: {total_differences}")
    print(f"Output written to: {output_path}")
    print("=" * 80)
    
    return total_differences, output_path

if __name__ == "__main__":
    analyze_all_versions()
