"""
Build printable validation PDF for the revised 13-question questionnaire.
Includes signature block for Ma'am Abby (financial management expert validator).
"""
import subprocess, os, sys
import markdown

html_body = """
<div class="title-block">
  <h1>SmartSpend Survey Questionnaire</h1>
  <h2>For Content Validation — Revised Version (13 Questions)</h2>
  <p class="subtitle">
    SmartSpend: An AI-Assisted Mobile Financial Tracking and Advisory Application<br>
    Lorma Colleges — College of Computer Studies and Engineering<br>
    Researchers: Directo, Brix A. · Rubis, Cyrille John M. · Madayag, Djaunathan Albert S.<br>
    Adviser: Ms. Ellen F. Mangaoang, DIT
  </p>
</div>

<div class="intro-box">
  <strong>Purpose:</strong> This questionnaire assesses the financial management practices, budgeting challenges, and expense tracking behaviors of parents (aged 35–55) and young professionals (aged 21–35) in San Fernando City, La Union. It supports Objective 1 of the study: to assess existing financial management practices.
  <br><br>
  <strong>Target respondents:</strong> 20 parents (ages 35–55) + 10 young professionals (ages 21–35) = N=30<br>
  <strong>Estimated time:</strong> 5–7 minutes
</div>

<h2>SECTION A. Respondent Profile</h2>

<div class="question">
  <p class="qnum">Q1. What is your age?</p>
  <div class="options-row">
    <span>○ 21–25</span><span>○ 26–30</span><span>○ 31–34</span><span>○ 35–40</span>
    <span>○ 41–45</span><span>○ 46–50</span><span>○ 51–55</span><span>○ Below 21 / Above 55 (not eligible)</span>
  </div>
</div>

<div class="question">
  <p class="qnum">Q2. Which category best describes you?</p>
  <div class="options">
    <div>○ Parent</div>
    <div>○ Young professional</div>
    <div>○ Both a parent and a young professional</div>
    <div>○ Neither</div>
  </div>
</div>

<div class="question">
  <p class="qnum">Q4. What is your current employment status?</p>
  <div class="options">
    <div>○ Employed full-time</div>
    <div>○ Employed part-time</div>
    <div>○ Self-employed / business owner</div>
    <div>○ Freelance / contractual</div>
    <div>○ Government employee</div>
    <div>○ Unemployed</div>
    <div>○ Other: _______________</div>
  </div>
</div>

<h2>SECTION B. Existing Financial Management Practices</h2>

<div class="question">
  <p class="qnum">Q8. Do you prepare a budget for your personal or household finances?</p>
  <div class="options-row">
    <span>○ Always</span><span>○ Often</span><span>○ Sometimes</span><span>○ Rarely</span><span>○ Never</span>
  </div>
</div>

<div class="question">
  <p class="qnum">Q11. Do you set aside money for savings before spending on other expenses?</p>
  <div class="options-row">
    <span>○ Always</span><span>○ Often</span><span>○ Sometimes</span><span>○ Rarely</span><span>○ Never</span>
  </div>
</div>

<h2>SECTION C. Common Budgeting Challenges</h2>

<div class="question">
  <p class="qnum">Q18. What are the main challenges you experience when managing your finances? <em>(Select all that apply.)</em></p>
  <div class="options-2col">
    <div>☐ Insufficient income</div>
    <div>☐ Increasing prices of basic goods and services</div>
    <div>☐ Unexpected medical or emergency expenses</div>
    <div>☐ Family responsibilities or dependents</div>
    <div>☐ Difficulty controlling discretionary spending</div>
    <div>☐ Debt or loan repayments</div>
    <div>☐ Irregular income</div>
    <div>☐ Lack of a clear budget</div>
    <div>☐ Difficulty recording expenses</div>
    <div>☐ Difficulty tracking several financial obligations</div>
    <div>☐ Lack of time to manage finances</div>
    <div>☐ Lack of knowledge about budgeting</div>
    <div>☐ I do not experience significant budgeting challenges</div>
    <div>☐ Other: _______________</div>
  </div>
</div>

<div class="question">
  <p class="qnum">Q19. What do you usually do when you realize that you have exceeded your budget? <em>(Select all that apply.)</em></p>
  <div class="options-2col">
    <div>☐ Reduce spending in other categories</div>
    <div>☐ Use savings</div>
    <div>☐ Delay nonessential purchases</div>
    <div>☐ Borrow money</div>
    <div>☐ Use credit</div>
    <div>☐ Seek additional income</div>
    <div>☐ Continue spending without adjusting the budget</div>
    <div>☐ Other: _______________</div>
  </div>
</div>

<div class="question">
  <p class="qnum">Q20. What would help you manage your budget more effectively? <em>(Select all that apply.)</em></p>
  <div class="options-2col">
    <div>☐ Automatic expense categorization</div>
    <div>☐ Budget limits for each category</div>
    <div>☐ Notifications when approaching a budget limit</div>
    <div>☐ Bill and payment reminders</div>
    <div>☐ Savings goal tracking</div>
    <div>☐ Monthly financial summaries</div>
    <div>☐ Spending trend reports</div>
    <div>☐ Debt and loan tracking</div>
    <div>☐ Financial education or budgeting tips</div>
    <div>☐ Other: _______________</div>
  </div>
</div>

<h2>SECTION D. Expense Tracking Behaviors</h2>

<div class="question">
  <p class="qnum">Q21. Do you currently record your personal or household expenses?</p>
  <div class="options-row">
    <span>○ Always</span><span>○ Often</span><span>○ Sometimes</span><span>○ Rarely</span><span>○ Never</span>
  </div>
</div>

<div class="question">
  <p class="qnum">Q22. How do you record your expenses? <em>(Select all that apply.)</em></p>
  <div class="options-2col">
    <div>☐ Notebook or diary</div>
    <div>☐ Spreadsheet</div>
    <div>☐ Mobile financial management application</div>
    <div>☐ Notes application</div>
    <div>☐ Receipts</div>
    <div>☐ Banking or e-wallet transaction history</div>
    <div>☐ Mental estimates or memory</div>
    <div>☐ I do not record expenses</div>
    <div>☐ Other: _______________</div>
  </div>
</div>

<div class="question">
  <p class="qnum">Q24. Which expenses do you usually track? <em>(Select all that apply.)</em></p>
  <div class="options-2col">
    <div>☐ Cash purchases</div>
    <div>☐ Debit card transactions</div>
    <div>☐ Credit card transactions</div>
    <div>☐ Bank transfers</div>
    <div>☐ E-wallet transactions</div>
    <div>☐ Online purchases</div>
    <div>☐ Recurring bills</div>
    <div>☐ Loan repayments</div>
    <div>☐ Savings contributions</div>
    <div>☐ All of the above</div>
    <div>☐ None of the above</div>
  </div>
</div>

<h2>SECTION E. Supplementary Profile and Feature Needs</h2>

<div class="question">
  <p class="qnum">Q30. Would you use an AI-powered financial assistant application to help manage your finances?</p>
  <div class="options-row">
    <span>○ Yes, definitely</span><span>○ Probably yes</span><span>○ Not sure</span><span>○ Probably not</span><span>○ No</span>
  </div>
</div>

<div class="question">
  <p class="qnum">Q31. Which digital wallets or banking platforms do you currently use that you want the AI assistant to help you track? <em>(Select all that apply.)</em></p>
  <div class="options-2col">
    <div>☐ GCash</div>
    <div>☐ Maya (formerly PayMaya)</div>
    <div>☐ GoTyme Bank</div>
    <div>☐ Traditional Online Banking (e.g., BDO, BPI, Metrobank)</div>
    <div>☐ E-Commerce Platforms (e.g., Shopee, Lazada)</div>
    <div>☐ Others (Please specify): _______________</div>
  </div>
</div>

<div class="summary-box">
  <strong>Questionnaire Summary:</strong> 13 questions across 5 sections |
  Section A: Q1, Q2, Q4 &nbsp;·&nbsp; Section B: Q8, Q11 &nbsp;·&nbsp;
  Section C: Q18, Q19, Q20 &nbsp;·&nbsp; Section D: Q21, Q22, Q24 &nbsp;·&nbsp;
  Section E: Q30, Q31
</div>

<div class="signature-block">
  <h2>CONTENT VALIDATOR CERTIFICATION</h2>
  <p>
    I hereby certify that I have reviewed this survey questionnaire and confirm that the questions are
    appropriate, valid, and relevant to the study on financial management practices among parents and
    young professionals in La Union, Philippines.
  </p>
  <table class="sig-table">
    <tr>
      <td class="sig-field">Validator's Name: <span class="sig-line">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></td>
      <td class="sig-field">Date: <span class="sig-line">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></td>
    </tr>
    <tr>
      <td class="sig-field">Designation / Position: <span class="sig-line">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></td>
      <td class="sig-field">Institution: <span class="sig-line">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></td>
    </tr>
    <tr>
      <td colspan="2" class="sig-field-full">Signature: <span class="sig-line-long">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span></td>
    </tr>
  </table>
</div>
"""

css = """
@page { size: A4; margin: 18mm 16mm 18mm 16mm; }
body { font-family: 'Times New Roman', serif; font-size: 11pt; color: #111; line-height: 1.45; }
.title-block { text-align: center; margin-bottom: 12pt; border-bottom: 2px solid #1a3a5c; padding-bottom: 10pt; }
.title-block h1 { font-size: 15pt; margin: 0 0 4pt 0; color: #1a3a5c; }
.title-block h2 { font-size: 12pt; margin: 0 0 6pt 0; color: #333; font-weight: normal; }
.subtitle { font-size: 10pt; color: #555; margin: 0; }
.intro-box { background: #f0f4ff; border-left: 4px solid #1a3a5c; padding: 8pt 10pt; margin: 10pt 0; font-size: 10pt; }
h2 { font-size: 12pt; font-weight: bold; background: #1a3a5c; color: white; padding: 4pt 8pt; margin: 14pt 0 6pt 0; page-break-after: avoid; }
.question { margin: 8pt 0 10pt 0; border: 1px solid #ddd; padding: 7pt 10pt; border-radius: 3pt; page-break-inside: avoid; }
.qnum { font-weight: bold; margin: 0 0 5pt 0; font-size: 11pt; }
.options { margin: 2pt 0 0 10pt; }
.options div { margin: 2pt 0; }
.options-row { display: flex; flex-wrap: wrap; gap: 8pt 16pt; margin: 2pt 0 0 10pt; }
.options-row span { white-space: nowrap; }
.options-2col { columns: 2; column-gap: 12pt; margin: 2pt 0 0 10pt; }
.options-2col div { margin: 2pt 0; break-inside: avoid; }
em { font-style: italic; font-size: 10pt; }
.summary-box { background: #f9f9f9; border: 1px solid #ccc; padding: 7pt 10pt; margin: 12pt 0; font-size: 10pt; }
.signature-block { border: 2px solid #1a3a5c; padding: 12pt 14pt; margin-top: 18pt; page-break-inside: avoid; }
.signature-block h2 { font-size: 12pt; background: #1a3a5c; color: white; padding: 5pt 8pt; margin: -12pt -14pt 10pt -14pt; }
.signature-block p { font-size: 10.5pt; margin: 0 0 12pt 0; }
.sig-table { width: 100%; border-collapse: collapse; }
.sig-field { padding: 6pt 4pt 10pt 0; font-size: 10.5pt; border-bottom: 1px solid #ccc; }
.sig-field-full { padding: 6pt 4pt 10pt 0; font-size: 10.5pt; }
.sig-line { border-bottom: 1px solid #333; display: inline-block; min-width: 200pt; }
.sig-line-long { border-bottom: 1px solid #333; display: inline-block; min-width: 380pt; }
"""

html = f"""<!DOCTYPE html>
<html><head><meta charset="utf-8"><style>{css}</style></head>
<body>{html_body}</body></html>"""

html_path = os.path.abspath('docs/tools/revised_q_temp.html')
pdf_path = os.path.abspath('docs/handsoff/FOR_MAAM_ELLEN/5_REVISED_QUESTIONNAIRE_FOR_VALIDATION.pdf')

with open(html_path, 'w', encoding='utf-8') as f:
    f.write(html)

edge_paths = [
    r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe',
    r'C:\Program Files\Microsoft\Edge\Application\msedge.exe',
]
edge = next((p for p in edge_paths if os.path.exists(p)), None)
if not edge:
    print("Edge not found"); sys.exit(1)

result = subprocess.run([
    edge, '--headless', '--disable-gpu', '--no-sandbox',
    f'--print-to-pdf={pdf_path}',
    '--print-to-pdf-no-header',
    f'file:///{html_path.replace(chr(92), "/")}'
], capture_output=True, text=True, timeout=30)

if os.path.exists(pdf_path) and os.path.getsize(pdf_path) > 5000:
    size_kb = os.path.getsize(pdf_path) // 1024
    print(f"PDF created: {pdf_path} ({size_kb} KB)")
    from pypdf import PdfReader
    r = PdfReader(pdf_path)
    print(f"Pages: {len(r.pages)}")
    t = r.pages[0].extract_text()
    for check in ['Q1', 'Q8', 'Q18', 'Q30', 'CONTENT VALIDATOR']:
        print(f"  {'✅' if check in r.pages[-1].extract_text() or any(check in r.pages[i].extract_text() for i in range(len(r.pages))) else '❌'} {check}")
else:
    print(f"Failed. stderr: {result.stderr[:200]}")

try: os.remove(html_path)
except: pass
