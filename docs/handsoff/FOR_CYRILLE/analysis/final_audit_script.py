"""
FINAL PRE-DEFENSE COMPREHENSIVE AUDIT SCRIPT
November 10, 2026 - Defense Day -1

Exhaustively verifies ALL defense materials for consistency, accuracy, and completeness.
Zero tolerance for errors.
"""

import json
import re
from pathlib import Path
from collections import defaultdict
from datetime import datetime

# Try importing document libraries
try:
    from pptx import Presentation
    PPTX_AVAILABLE = True
except ImportError:
    PPTX_AVAILABLE = False
    print("⚠️ python-pptx not available")

try:
    from docx import Document
    DOCX_AVAILABLE = True
except ImportError:
    DOCX_AVAILABLE = False
    print("⚠️ python-docx not available")

try:
    import PyPDF2
    PDF_AVAILABLE = True
except ImportError:
    try:
        import pdfplumber
        PDF_AVAILABLE = True
    except ImportError:
        PDF_AVAILABLE = False
        print("⚠️ PDF libraries not available")

# Expected canonical values (ZERO TOLERANCE)
CANONICAL_VALUES = {
    "sus_mean": "61.83",
    "sus_sd": "17.58",
    "sus_grade": "D",
    "sus_adjective": "OK",
    "sample_size": "30",
    "sample_total": "36",
    "excluded_count": "6",
    "excluded_time": "5",
    "excluded_bias": "1",
    "score_range_min": "35.0",
    "score_range_max": "92.5",
    "benchmark": "68",
    "parents_count": "10",
    "parents_ages": "35-55",
    "young_prof_count": "20",
    "young_prof_ages": "21-35",
    "app_version": "v3.1.2",
    "badge_count": "36",
    "ai_actions": "34",
    "survey_period": "October-November 2026",
    "survey_year": "2026",
    "defense_date": "November 2026",
    "cv_dates": "2026",
}

# Forbidden methods (we did NOT use these)
FORBIDDEN_METHODS = [
    r"\binterview(?:s|ed|ing)?\b",  # interviews
    r"\bfocus group(?:s)?\b",       # focus groups
    r"\bN\s*=\s*5\b",               # preliminary N=5 data in results
    r"\bpending\b",                 # pending language
    r"\bto be determined\b",        # TBD language
    r"\bTODO\b",                    # TODO markers
    r"\bFIX(?:ME)?\b",              # FIX markers
    r"\bplaceholder\b",             # placeholder text
    r"\b2025\b(?!.*historical)",    # wrong year (unless historical context)
]

# Required methods (we DID use these)
REQUIRED_METHODS = [
    "purposive sampling",
    "Google Forms",
    "SUS questionnaire",
    "thematic analysis",
]

class AuditFinding:
    """Represents a single audit finding"""
    def __init__(self, severity, category, location, issue, expected=None, found=None, suggestion=None):
        self.severity = severity  # CRITICAL, HIGH, MEDIUM, LOW
        self.category = category
        self.location = location
        self.issue = issue
        self.expected = expected
        self.found = found
        self.suggestion = suggestion
    
    def to_dict(self):
        return {
            "severity": self.severity,
            "category": self.category,
            "location": self.location,
            "issue": self.issue,
            "expected": self.expected,
            "found": self.found,
            "suggestion": self.suggestion,
        }

class FinalAudit:
    """Comprehensive final audit system"""
    
    def __init__(self, base_path):
        self.base_path = Path(base_path)
        self.findings = []
        self.stats = {
            "critical": 0,
            "high": 0,
            "medium": 0,
            "low": 0,
        }
        self.value_occurrences = defaultdict(lambda: defaultdict(list))
        
    def add_finding(self, severity, category, location, issue, expected=None, found=None, suggestion=None):
        """Add a finding to the audit report"""
        finding = AuditFinding(severity, category, location, issue, expected, found, suggestion)
        self.findings.append(finding)
        self.stats[severity.lower()] += 1
        
    def audit_presentation(self, pptx_path):
        """Exhaustively audit the PowerPoint presentation"""
        print(f"\n📊 Auditing Presentation: {pptx_path.name}")
        
        if not PPTX_AVAILABLE:
            self.add_finding("HIGH", "TOOL_ERROR", str(pptx_path), 
                           "python-pptx not available, cannot audit presentation")
            return
        
        try:
            prs = Presentation(str(pptx_path))
            total_slides = len(prs.slides)
            print(f"   Total slides: {total_slides}")
            
            if total_slides != 18:
                self.add_finding("HIGH", "STRUCTURE", f"{pptx_path.name} (slide count)",
                               f"Expected 18 slides for defense presentation, found {total_slides}",
                               expected="18 slides", found=f"{total_slides} slides")
            
            # Extract all text from all slides
            slide_texts = []
            for i, slide in enumerate(prs.slides, 1):
                slide_text = []
                for shape in slide.shapes:
                    if hasattr(shape, "text"):
                        slide_text.append(shape.text)
                slide_full_text = "\n".join(slide_text)
                slide_texts.append((i, slide_full_text))
                
                # Check for forbidden terms
                for pattern in FORBIDDEN_METHODS:
                    matches = re.finditer(pattern, slide_full_text, re.IGNORECASE)
                    for match in matches:
                        # Exception: "N=5" is OK if it's in a historical/preliminary context
                        if "N=5" in match.group() or "N = 5" in match.group():
                            # Check if it's clearly marked as preliminary
                            context = slide_full_text[max(0, match.start()-100):min(len(slide_full_text), match.end()+100)]
                            if "preliminary" not in context.lower() and "initial" not in context.lower():
                                self.add_finding("CRITICAL", "FORBIDDEN_METHOD", 
                                               f"{pptx_path.name} → Slide {i}",
                                               f"Found N=5 data without preliminary marking: '{match.group()}'",
                                               expected="N=30 final data only",
                                               found=match.group(),
                                               suggestion="Remove N=5 data or clearly mark as preliminary")
                        elif "2025" in match.group():
                            # Check if it's a historical reference (curriculum, BSP survey, etc.)
                            context = slide_full_text[max(0, match.start()-50):min(len(slide_full_text), match.end()+50)]
                            if "curriculum" not in context.lower() and "historical" not in context.lower():
                                self.add_finding("HIGH", "DATE_ERROR",
                                               f"{pptx_path.name} → Slide {i}",
                                               f"Found 2025 instead of 2026: '{match.group()}'",
                                               expected="2026", found="2025",
                                               suggestion="Change to 2026")
                        else:
                            self.add_finding("CRITICAL", "FORBIDDEN_METHOD",
                                           f"{pptx_path.name} → Slide {i}",
                                           f"Found forbidden method reference: '{match.group()}'",
                                           found=match.group(),
                                           suggestion="Remove this reference - we did not use this method")
                
                # Track canonical value occurrences
                for key, value in CANONICAL_VALUES.items():
                    if value in slide_full_text:
                        self.value_occurrences[key]["presentation"].append(f"Slide {i}")
            
            # Check for specific demographic mentions
            for i, slide_text in slide_texts:
                # Check for demographic inversion (20+10 instead of 10+20)
                if "20 parents" in slide_text.lower() or "20 (parents)" in slide_text.lower():
                    self.add_finding("CRITICAL", "DEMOGRAPHIC_ERROR",
                                   f"{pptx_path.name} → Slide {i}",
                                   "Demographic inversion detected: shows 20 parents instead of 10",
                                   expected="10 parents (ages 35-55), 20 young professionals (ages 21-35)",
                                   found="20 parents mentioned",
                                   suggestion="Correct to 10 parents, 20 young professionals")
            
            print(f"   ✅ Presentation audit complete: {len(prs.slides)} slides analyzed")
            
        except Exception as e:
            self.add_finding("HIGH", "TOOL_ERROR", str(pptx_path),
                           f"Error reading presentation: {str(e)}")
    
    def audit_manuscript_docx(self, docx_path):
        """Exhaustively audit the manuscript DOCX"""
        print(f"\n📄 Auditing Manuscript DOCX: {docx_path.name}")
        
        if not DOCX_AVAILABLE:
            self.add_finding("HIGH", "TOOL_ERROR", str(docx_path),
                           "python-docx not available, cannot audit manuscript")
            return
        
        try:
            doc = Document(str(docx_path))
            total_paragraphs = len(doc.paragraphs)
            print(f"   Total paragraphs: {total_paragraphs}")
            
            full_text = "\n".join([p.text for p in doc.paragraphs])
            
            # Check for forbidden methods
            for pattern in FORBIDDEN_METHODS:
                matches = list(re.finditer(pattern, full_text, re.IGNORECASE))
                for match in matches:
                    # Find which paragraph
                    para_num = self._find_paragraph_number(doc.paragraphs, match.start(), full_text)
                    
                    # Exception handling
                    if "N=5" in match.group() or "N = 5" in match.group():
                        context = full_text[max(0, match.start()-150):min(len(full_text), match.end()+150)]
                        if "preliminary" not in context.lower() and "initial" not in context.lower() and "developer testing" not in context.lower():
                            self.add_finding("CRITICAL", "FORBIDDEN_METHOD",
                                           f"{docx_path.name} → Paragraph ~{para_num}",
                                           f"Found N=5 data in final results without preliminary marking",
                                           expected="N=30 final data only",
                                           found=match.group(),
                                           suggestion="Remove N=5 or clearly mark as preliminary/developer testing")
                    elif "2025" in match.group():
                        context = full_text[max(0, match.start()-100):min(len(full_text), match.end()+100)]
                        if "curriculum" not in context.lower() and "historical" not in context.lower() and "BSP" not in context.upper():
                            self.add_finding("HIGH", "DATE_ERROR",
                                           f"{docx_path.name} → Paragraph ~{para_num}",
                                           f"Found 2025 instead of 2026",
                                           expected="2026", found="2025",
                                           suggestion="Change to 2026")
                    elif "interview" in match.group().lower():
                        # Check if it's in references or related work (OK to mention others' methods)
                        context = full_text[max(0, match.start()-200):min(len(full_text), match.end()+200)]
                        if "Chapter II" not in context and "literature" not in context.lower() and "related work" not in context.lower():
                            self.add_finding("CRITICAL", "FORBIDDEN_METHOD",
                                           f"{docx_path.name} → Paragraph ~{para_num}",
                                           f"Found interview reference in methodology/results: '{match.group()}'",
                                           suggestion="Remove - we only used surveys, not interviews")
                    else:
                        self.add_finding("CRITICAL", "FORBIDDEN_METHOD",
                                       f"{docx_path.name} → Paragraph ~{para_num}",
                                       f"Found forbidden method reference: '{match.group()}'",
                                       found=match.group())
            
            # Track canonical value occurrences
            for key, value in CANONICAL_VALUES.items():
                pattern = re.escape(value)
                matches = list(re.finditer(pattern, full_text))
                if matches:
                    self.value_occurrences[key]["manuscript_docx"] = [f"Found {len(matches)} times"]
            
            # Check for demographic inversion
            if "20 parents" in full_text.lower():
                self.add_finding("CRITICAL", "DEMOGRAPHIC_ERROR",
                               f"{docx_path.name}",
                               "Demographic inversion detected: mentions 20 parents instead of 10",
                               expected="10 parents (ages 35-55), 20 young professionals (ages 21-35)",
                               found="20 parents mentioned")
            
            # Check for required sections
            required_sections = [
                "Abstract", "Acknowledgment", "Chapter I", "Chapter II", "Chapter III",
                "Chapter IV", "Chapter V", "References", "Appendix"
            ]
            for section in required_sections:
                if section not in full_text:
                    self.add_finding("HIGH", "MISSING_SECTION",
                                   f"{docx_path.name}",
                                   f"Required section '{section}' not found",
                                   suggestion=f"Verify {section} exists (may be formatting issue)")
            
            # Check for placeholder/TODO markers
            if "[TODO]" in full_text or "[FIX]" in full_text or "PLACEHOLDER" in full_text.upper():
                self.add_finding("CRITICAL", "INCOMPLETE",
                               f"{docx_path.name}",
                               "Found TODO/FIX/PLACEHOLDER markers - document incomplete",
                               suggestion="Complete all pending sections")
            
            print(f"   ✅ Manuscript DOCX audit complete: {total_paragraphs} paragraphs analyzed")
            
        except Exception as e:
            self.add_finding("HIGH", "TOOL_ERROR", str(docx_path),
                           f"Error reading manuscript DOCX: {str(e)}")
    
    def audit_manuscript_pdf(self, pdf_path):
        """Audit the manuscript PDF"""
        print(f"\n📕 Auditing Manuscript PDF: {pdf_path.name}")
        
        if not PDF_AVAILABLE:
            self.add_finding("MEDIUM", "TOOL_ERROR", str(pdf_path),
                           "PDF libraries not available, skipping PDF audit")
            return
        
        try:
            # Try PyPDF2 first
            try:
                with open(pdf_path, 'rb') as f:
                    pdf_reader = PyPDF2.PdfReader(f)
                    total_pages = len(pdf_reader.pages)
                    print(f"   Total pages: {total_pages}")
                    
                    full_text = ""
                    for page in pdf_reader.pages:
                        full_text += page.extract_text()
            except:
                # Fall back to pdfplumber
                import pdfplumber
                with pdfplumber.open(pdf_path) as pdf:
                    total_pages = len(pdf.pages)
                    print(f"   Total pages: {total_pages}")
                    full_text = ""
                    for page in pdf.pages:
                        full_text += page.extract_text() or ""
            
            # Track canonical values
            for key, value in CANONICAL_VALUES.items():
                if value in full_text:
                    self.value_occurrences[key]["manuscript_pdf"] = ["Present"]
            
            # Basic checks (PDF is backup, DOCX is source of truth)
            if "61.83" not in full_text:
                self.add_finding("HIGH", "CONSISTENCY",
                               f"{pdf_path.name}",
                               "SUS score 61.83 not found in PDF",
                               suggestion="Regenerate PDF from DOCX")
            
            if "N=30" not in full_text and "N = 30" not in full_text:
                self.add_finding("HIGH", "CONSISTENCY",
                               f"{pdf_path.name}",
                               "Sample size N=30 not found in PDF",
                               suggestion="Regenerate PDF from DOCX")
            
            print(f"   ✅ Manuscript PDF audit complete: {total_pages} pages analyzed")
            
        except Exception as e:
            self.add_finding("MEDIUM", "TOOL_ERROR", str(pdf_path),
                           f"Error reading manuscript PDF: {str(e)}")
    
    def audit_script(self, script_path):
        """Audit the defense script"""
        print(f"\n📝 Auditing Defense Script: {script_path.name}")
        
        try:
            with open(script_path, 'r', encoding='utf-8') as f:
                script_text = f.read()
            
            lines = script_text.split('\n')
            print(f"   Total lines: {len(lines)}")
            
            # Count slide references
            slide_refs = re.findall(r'##\s*Slide\s+(\d+)', script_text)
            print(f"   Slide references found: {len(slide_refs)}")
            
            if len(slide_refs) != 18:
                self.add_finding("HIGH", "STRUCTURE",
                               f"{script_path.name}",
                               f"Script has {len(slide_refs)} slide references, expected 18",
                               expected="18 slides", found=f"{len(slide_refs)} slides",
                               suggestion="Verify script matches 18-slide presentation")
            
            # Check for canonical values
            for key, value in CANONICAL_VALUES.items():
                if value in script_text:
                    self.value_occurrences[key]["script"] = ["Present"]
            
            # Check for forbidden methods
            for pattern in FORBIDDEN_METHODS:
                matches = list(re.finditer(pattern, script_text, re.IGNORECASE))
                for match in matches:
                    line_num = script_text[:match.start()].count('\n') + 1
                    
                    if "2025" in match.group():
                        context = script_text[max(0, match.start()-100):min(len(script_text), match.end()+100)]
                        if "curriculum" not in context.lower() and "historical" not in context.lower():
                            self.add_finding("HIGH", "DATE_ERROR",
                                           f"{script_path.name} → Line {line_num}",
                                           f"Found 2025 instead of 2026",
                                           expected="2026", found="2025")
                    elif "interview" in match.group().lower():
                        self.add_finding("CRITICAL", "FORBIDDEN_METHOD",
                                       f"{script_path.name} → Line {line_num}",
                                       f"Found interview reference: '{match.group()}'",
                                       suggestion="Remove - we only used surveys")
            
            # Check for demographic inversion
            if "20 parents" in script_text.lower():
                self.add_finding("CRITICAL", "DEMOGRAPHIC_ERROR",
                               f"{script_path.name}",
                               "Demographic inversion: mentions 20 parents instead of 10",
                               expected="10 parents, 20 young professionals")
            
            print(f"   ✅ Script audit complete: {len(lines)} lines, {len(slide_refs)} slides")
            
        except Exception as e:
            self.add_finding("HIGH", "TOOL_ERROR", str(script_path),
                           f"Error reading script: {str(e)}")
    
    def _find_paragraph_number(self, paragraphs, char_position, full_text):
        """Find paragraph number for a character position in full text"""
        current_pos = 0
        for i, para in enumerate(paragraphs, 1):
            current_pos += len(para.text) + 1  # +1 for newline
            if current_pos > char_position:
                return i
        return len(paragraphs)
    
    def check_cross_document_consistency(self):
        """Check that all documents agree on canonical values"""
        print("\n🔍 Checking cross-document consistency...")
        
        for key, value in CANONICAL_VALUES.items():
            docs_with_value = list(self.value_occurrences[key].keys())
            
            if len(docs_with_value) == 0:
                self.add_finding("MEDIUM", "CONSISTENCY",
                               "Cross-document",
                               f"Canonical value '{key}' ({value}) not found in ANY document",
                               expected=f"Present in all documents",
                               suggestion="Verify this value should appear")
            elif len(docs_with_value) < 3:
                missing_docs = set(["presentation", "manuscript_docx", "script"]) - set(docs_with_value)
                self.add_finding("HIGH", "CONSISTENCY",
                               "Cross-document",
                               f"Canonical value '{key}' ({value}) missing from: {', '.join(missing_docs)}",
                               expected="Present in all documents",
                               found=f"Only in: {', '.join(docs_with_value)}")
    
    def generate_report(self, output_path):
        """Generate the final audit report"""
        print(f"\n📋 Generating audit report: {output_path.name}")
        
        report = []
        report.append("# FINAL PRE-DEFENSE COMPREHENSIVE AUDIT REPORT")
        report.append(f"**Date:** {datetime.now().strftime('%B %d, %Y %H:%M')}")
        report.append(f"**Defense Date:** November 10, 2026")
        report.append(f"**Audit Type:** Exhaustive Final Verification (Zero Tolerance)")
        report.append("")
        report.append("---")
        report.append("")
        
        # Executive Summary
        total_issues = sum(self.stats.values())
        report.append("## Executive Summary")
        report.append("")
        report.append(f"**Total Issues Found:** {total_issues}")
        report.append(f"- 🔴 CRITICAL: {self.stats['critical']}")
        report.append(f"- 🟠 HIGH: {self.stats['high']}")
        report.append(f"- 🟡 MEDIUM: {self.stats['medium']}")
        report.append(f"- 🔵 LOW: {self.stats['low']}")
        report.append("")
        
        # Defense Readiness Status
        if total_issues == 0:
            report.append("## ✅ DEFENSE READY CERTIFICATION")
            report.append("")
            report.append("**Status:** ✅ **CERTIFIED DEFENSE READY**")
            report.append("")
            report.append("All defense materials have passed exhaustive verification:")
            report.append("- ✅ No numerical inconsistencies found")
            report.append("- ✅ No methodological contradictions found")
            report.append("- ✅ No forbidden method references found")
            report.append("- ✅ No demographic inversions found")
            report.append("- ✅ No date errors found")
            report.append("- ✅ No missing sections found")
            report.append("- ✅ All canonical values consistent across documents")
            report.append("")
            report.append("**Recommendation:** Proceed with defense as scheduled.")
        elif self.stats['critical'] > 0:
            report.append("## ❌ NOT DEFENSE READY")
            report.append("")
            report.append(f"**Status:** ❌ **CRITICAL ISSUES FOUND** ({self.stats['critical']} critical)")
            report.append("")
            report.append("**URGENT ACTION REQUIRED:** Critical issues must be fixed before defense.")
            report.append("")
            report.append("**Recommendation:** DO NOT proceed until all CRITICAL issues resolved.")
        elif self.stats['high'] > 0:
            report.append("## ⚠️ DEFENSE READY WITH CAUTION")
            report.append("")
            report.append(f"**Status:** ⚠️ **HIGH-PRIORITY ISSUES FOUND** ({self.stats['high']} high)")
            report.append("")
            report.append("**Action Required:** High-priority issues should be fixed before defense.")
            report.append("")
            report.append("**Recommendation:** Fix high-priority issues or prepare explanations.")
        else:
            report.append("## ✅ DEFENSE READY (Minor Issues)")
            report.append("")
            report.append(f"**Status:** ✅ **READY** ({self.stats['medium']} medium, {self.stats['low']} low issues)")
            report.append("")
            report.append("**Recommendation:** Proceed with defense. Address minor issues if time permits.")
        
        report.append("")
        report.append("---")
        report.append("")
        
        # Detailed Findings
        if total_issues > 0:
            report.append("## Detailed Findings")
            report.append("")
            
            for severity in ["CRITICAL", "HIGH", "MEDIUM", "LOW"]:
                severity_findings = [f for f in self.findings if f.severity == severity]
                if severity_findings:
                    icon = {"CRITICAL": "🔴", "HIGH": "🟠", "MEDIUM": "🟡", "LOW": "🔵"}[severity]
                    report.append(f"### {icon} {severity} Issues ({len(severity_findings)})")
                    report.append("")
                    
                    for i, finding in enumerate(severity_findings, 1):
                        report.append(f"#### {severity}-{i:02d}: {finding.category}")
                        report.append(f"**Location:** {finding.location}")
                        report.append(f"**Issue:** {finding.issue}")
                        if finding.expected:
                            report.append(f"**Expected:** {finding.expected}")
                        if finding.found:
                            report.append(f"**Found:** {finding.found}")
                        if finding.suggestion:
                            report.append(f"**Suggestion:** {finding.suggestion}")
                        report.append("")
        
        # Cross-Document Value Matrix
        report.append("---")
        report.append("")
        report.append("## Cross-Document Value Consistency Matrix")
        report.append("")
        report.append("| Value | Expected | Presentation | Manuscript DOCX | Manuscript PDF | Script |")
        report.append("|-------|----------|--------------|-----------------|----------------|--------|")
        
        for key, value in CANONICAL_VALUES.items():
            pres = "✅" if "presentation" in self.value_occurrences[key] else "❌"
            docx = "✅" if "manuscript_docx" in self.value_occurrences[key] else "❌"
            pdf = "✅" if "manuscript_pdf" in self.value_occurrences[key] else "❌"
            script = "✅" if "script" in self.value_occurrences[key] else "❌"
            report.append(f"| {key} | {value} | {pres} | {docx} | {pdf} | {script} |")
        
        report.append("")
        report.append("---")
        report.append("")
        
        # Files Audited
        report.append("## Files Audited")
        report.append("")
        report.append("1. ✅ `SmartSpend_Defense.pptx` (18-slide defense presentation)")
        report.append("2. ✅ `1_MAIN_MANUSCRIPT_FINAL.docx` (manuscript DOCX)")
        report.append("3. ✅ `1_MAIN_MANUSCRIPT_FINAL.docx.pdf` (manuscript PDF)")
        report.append("4. ✅ `4_DEFENSE_SCRIPT_FINAL.md` (defense script)")
        report.append("")
        
        # Sign-off
        report.append("---")
        report.append("")
        report.append("## Audit Sign-Off")
        report.append("")
        report.append(f"**Audit Completed:** {datetime.now().strftime('%B %d, %Y at %H:%M')}")
        report.append(f"**Auditor:** Kiro AI Final Audit System")
        report.append(f"**Audit Method:** Exhaustive automated verification with zero-tolerance criteria")
        report.append(f"**Total Checks Performed:** {len(self.findings) + len(CANONICAL_VALUES) * 4}")
        report.append("")
        
        if total_issues == 0:
            report.append("✅ **CERTIFIED READY FOR DEFENSE: November 10, 2026**")
        
        # Write report
        with open(output_path, 'w', encoding='utf-8') as f:
            f.write('\n'.join(report))
        
        print(f"   ✅ Report written: {output_path}")
    
    def generate_issues_json(self, output_path):
        """Generate structured issues JSON"""
        if len(self.findings) == 0:
            print("   No issues to write to JSON")
            return
        
        issues = {
            "audit_date": datetime.now().isoformat(),
            "defense_date": "2026-11-10",
            "total_issues": len(self.findings),
            "by_severity": {
                "critical": self.stats['critical'],
                "high": self.stats['high'],
                "medium": self.stats['medium'],
                "low": self.stats['low'],
            },
            "findings": [f.to_dict() for f in self.findings],
        }
        
        with open(output_path, 'w', encoding='utf-8') as f:
            json.dump(issues, f, indent=2)
        
        print(f"   ✅ Issues JSON written: {output_path}")

def main():
    """Main audit execution"""
    print("=" * 80)
    print("FINAL PRE-DEFENSE COMPREHENSIVE AUDIT")
    print("Defense Date: November 10, 2026")
    print("=" * 80)
    
    base_path = Path(r"c:\xampp\htdocs\smartspend_app\docs\handsoff\FOR_CYRILLE")
    audit = FinalAudit(base_path)
    
    # Audit all documents
    audit.audit_presentation(base_path / "SmartSpend_Defense.pptx")
    audit.audit_manuscript_docx(base_path / "1_MAIN_MANUSCRIPT_FINAL.docx")
    audit.audit_manuscript_pdf(base_path / "1_MAIN_MANUSCRIPT_FINAL.docx.pdf")
    audit.audit_script(base_path / "4_DEFENSE_SCRIPT_FINAL.md")
    
    # Cross-document consistency check
    audit.check_cross_document_consistency()
    
    # Generate outputs
    analysis_path = base_path / "analysis"
    audit.generate_report(analysis_path / "FINAL_AUDIT_REPORT_NOV10.md")
    
    if len(audit.findings) > 0:
        audit.generate_issues_json(analysis_path / "ISSUES_FOUND_NOV10.json")
    
    # Final summary
    print("\n" + "=" * 80)
    print("AUDIT COMPLETE")
    print("=" * 80)
    total_issues = sum(audit.stats.values())
    print(f"Total Issues Found: {total_issues}")
    print(f"  - CRITICAL: {audit.stats['critical']}")
    print(f"  - HIGH: {audit.stats['high']}")
    print(f"  - MEDIUM: {audit.stats['medium']}")
    print(f"  - LOW: {audit.stats['low']}")
    
    if total_issues == 0:
        print("\n✅ DEFENSE READY - No issues found")
        return 0
    elif audit.stats['critical'] > 0:
        print(f"\n❌ NOT READY - {audit.stats['critical']} critical issues must be fixed")
        return 1
    elif audit.stats['high'] > 0:
        print(f"\n⚠️ CAUTION - {audit.stats['high']} high-priority issues found")
        return 2
    else:
        print(f"\n✅ READY - Only minor issues found")
        return 0

if __name__ == "__main__":
    exit(main())
