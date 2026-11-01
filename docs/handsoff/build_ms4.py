import sys, re, copy
sys.path.insert(0,'/home/claude')
import build_ms4_lib as L
from build_ms4_lib import *
from docx.oxml.ns import qn

init('/home/claude/cur.docx')
doc, ps = C.doc, C.ps
md = open('/home/claude/guide.md', encoding='utf-8').read().split('\n')

# ---------- templates (assert roles so a wrong index can't slip through)
T_chnum, T_chtitle, T_sub, T_body, T_cap, T_subsub = ps[216], ps[217], ps[225], ps[220], ps[234], ps[246]
for name,p,exp in [("chnum",T_chnum,"CHAPTER II"),("chtitle",T_chtitle,"DESIGN AND METHODOLOGY"),
                   ("cap",T_cap,"Table 2.1")]:
    assert p.text.strip().startswith(exp), (name, p.text[:40])
print("sub:", repr(T_sub.text[:40]), "| subsub:", repr(T_subsub.text[:40]), "| body:", repr(T_body.text[:40]))
T_TBL = doc.tables[1]._tbl

# ---------- md helpers
def strip_q(s): return re.sub(r'^>\s?', '', s)
def block(prefix):
    for i,l in enumerate(md):
        if strip_q(l).startswith(prefix):
            out=[strip_q(l)]; j=i+1
            while j < len(md) and md[j].strip() and not re.match(r'^(\d+b?\.\s|\*\*|>|#|\||---|- )', md[j].lstrip()):
                out.append(md[j].strip()); j+=1
            return ' '.join(x.strip() for x in out)
    raise SystemExit("md block not found: "+prefix)
def pend(s):
    s = re.sub(r'\[⚠️([^\]]*)\]', lambda m: '[[VERIFY:'+m.group(1)+']]', s)
    s = re.sub(r'\[(confirm[^\]]*)\]', lambda m: '[[VERIFY: '+m.group(1)+']]', s)
    s = re.sub(r'(?<!\[)\[((?:N|n|mean|SD|sd|min–max|adjective|After data collection:|Insert|Compare|Add|Keep|Until)[^\]]*)\](?!\])', r'[[\1]]', s)
    return s
def fixb(s):
    s = re.sub(r'\[{3,}', '[[', s); s = re.sub(r'\]{3,}', ']]', s)
    s = re.sub(r'(?<!\[)\[(state how[^\]]*|meeting / not meeting|accuracy)\](?!\])', r'[[\1]]', s)
    s = s.replace('[insert findings on expense tracking methods, budgeting frequency, and financial challenges]', '[[insert findings on expense tracking methods, budgeting frequency, and financial challenges]]')
    return s
def tablemap(s):
    return (s.replace('Table 2.2 presents','Table @@2 presents'))

# ---------- content builders
els = []   # new elements for Chapters III/IV in order
def H(tmpl, text, pb=False):
    e = mk(tmpl, text, page_break=pb)
    if tmpl is T_cap or tmpl is T_sub or tmpl is T_subsub: L._keep_next(e)
    els.append(e)
def B(text):  els.append(mk(T_body, md_segs(fixb(text))))
def P(text):  els.append(mk(T_body, [(text,None)]))

PEND_FIRST = "[[PENDING: after the surveys close, state whether the findings confirmed the challenges identified in the literature (manual effort, irregular tracking, no proactive feedback) and whether they support the need for an AI-assisted tool. Write only what the data show.]]"

# CHAPTER III
H(T_chnum, "CHAPTER III", pb=True)
H(T_chtitle, "RESULTS AND DISCUSSION")
B(block("This chapter presents the results of the study"))
H(T_sub, "Objective 1: Assessment of Financial Management Practices")
t = pend(block("The first objective was to assess"))
t = t.replace("Data was gathered through a structured questionnaire administered to the respondents prior to the SmartSpend system demonstration.",
              "Data are being gathered through a structured online questionnaire (Financial Management Practices survey) completed by respondents from the target groups.")
B(t)
t = block("A total of [N] respondents participated")
t = t.replace("[Insert Table 3.1 Respondent Profile here after data collection.]","[[PENDING: insert Table 3.1 (Respondent Profile) after data collection.]]")
t = pend(t)
B(t)
P(PEND_FIRST)

H(T_sub, "Objective 2: System Development and LLM Benchmarking")
B(block("The second objective was to design and develop"))
H(T_subsub, "Comparative Analysis of Large Language Model APIs")
t = block("The selection of an appropriate LLM API is a critical design decision").replace("Table 2.2 presents","Table 3.2 presents")
B(t)
H(T_cap, "Table 3.2. Comparative Evaluation of LLM APIs for SmartSpend Integration")
# LLM table from md
start = next(i for i,l in enumerate(md) if l.startswith("| Model | Provider |"))
rows=[]
for l in md[start+2:]:
    if not l.startswith('|'): break
    rows.append([c.strip() for c in l.strip().strip('|').split('|')])
assert len(rows)==20, len(rows)
def conv(c):
    for a,b in [('★★★★★','5/5'),('★★★★☆','4/5'),('★★★☆☆','3/5'),('★★☆☆☆','2/5'),('❓','TBD'),(' ⚠️','')]: c=c.replace(a,b)
    c = c.replace('✅ PRIMARY','Primary').replace('✅ Fallback','Fallback')
    c = c.replace('❌ RETIRED','Not used: retired').replace('❌ ','Not used: ')
    return c
rows = [[conv(c) for c in r] for r in rows]
hdr = ["Model","Provider","Context","Speed (t/s)","Filipino","Tool Use","Free Tier","Status"]
els.append(finish_table(mk_table(T_TBL, hdr, rows, [1450,900,1050,850,850,800,1590,1150], sz=18)))
P("Note. TBD = not yet measured in the team's own benchmark run. Free-tier request quotas are as reported by third-party sources in September 2026 and change often. [[VERIFY: confirm the quota figures in the Google AI Studio rate-limit dashboard before defense.]]")
B(block("Gemini 3.5 Flash-Lite was selected as the primary model").replace("strong Filipino-English multilingual performance among free-tier models", "good Filipino-English (Taglish) handling in the team trials"))
B(block("SmartSpend uses dynamic full-context injection rather than RAG"))

H(T_subsub, "Financial Health Score: Computation")
B(block("The Financial Health Score (FHS) is SmartSpend's core academic contribution"))
B(block("Equal weights that add up to 100"))
B("Full Mode (income tracking enabled; 4 components of 25 points, 100 maximum):")
for pref in ["1. **Savings Rate","2. **Overspend Control","3. **Budget Adherence","4. **Logging Consistency"]:
    B(block(pref))
B(block("**Lightweight Mode**"))
B(block("**Score Adjustments**"))

H(T_subsub, "System Development Results")
B(block("SmartSpend v3.1.0 was developed across seven Kanban phases").replace("seven Kanban phases","seven Kanban phases (Table 2.2)"))
for pref in ["Several Filipino-specific and usability features","Two further additions worth documenting",
             "The v2.9.97–3.1.0 releases","AI privacy is described as three tiers","From v3.0.5 to v3.1.0 the app's mascot",
             "These behaviours apply the same ideas","The optional local-LLM integration"]:
    B(pend(block(pref).replace("(Section 1.2 above)", "described above").replace("automatically falls back to the cloud provider chain if the local server becomes unreachable mid-session.", "falls back to the cloud provider chain if the local server becomes unreachable mid-session, unless the user has switched on Local-only mode.")))

H(T_sub, "Objective 3: System Usability Evaluation")
B(pend(block("The third objective was to evaluate the usability")))
B(block("SUS scores were computed using the standard formula"))
H(T_cap, "Table 3.3. System Usability Scale (SUS) Results by Respondent Group")
pf = "[[PENDING]]"
els.append(finish_table(mk_table(T_TBL, ["Respondent Group","N","Mean SUS Score","SD","Range","Adjective Rating"],
    [["Parents (35–55)",pf,pf,pf,pf,pf],["Young Professionals (21–35)",pf,pf,pf,pf,pf],["Combined",pf,pf,pf,pf,pf]],
    [2300,700,1300,900,1400,2040], sz=20)))
B(pend(block("[After data collection:] SmartSpend achieved an overall mean SUS score")))
P("[[PENDING: add a qualitative-themes paragraph only if open-ended answers were actually collected; summarize what respondents really wrote.]]")
H(T_subsub, "Technical Performance Benchmarks")
P("[[PENDING: confirm that a parsing-accuracy test on real receipts and screenshots was actually run. If it was, describe the test set (number and type of documents, how each field was scored) and insert Table 3.4 below with the measured results. If it was not run, run it and log each result, or delete this subsection.]]")
H(T_cap, "Table 3.4. SmartSpend Multimodal Import: Field-Level Parsing Performance")
els.append(finish_table(mk_table(T_TBL, ["Import Modality","N","Date (P/R)","Merchant (P/R)","Amount (P/R)","Category","End-to-End"],
    [["GCash Screenshots"]+[pf]*6,["Maya Receipts"]+[pf]*6,["Shopee/Lazada Invoices"]+[pf]*6,["Thermal Receipts (ML Kit)"]+[pf]*6,["Overall"]+[pf]*6],
    [1900,500,1250,1250,1250,1100,1390], sz=20)))
P("[[PENDING: summarize results only after Table 3.4 is filled with measured values; state whether the overall row is weighted by number of documents. Offline-to-cloud synchronization results may be reported only if a sync test was actually carried out.]]")

# CHAPTER IV
H(T_chnum, "CHAPTER IV", pb=True)
H(T_chtitle, "CONCLUSIONS AND RECOMMENDATIONS")
B(block("This chapter presents the findings of the study and provides recommendations"))
H(T_sub, "Conclusions")
P("For the first objective (assessment of financial management practices): [[PENDING: write after survey results are in; see Chapter III, Objective 1.]]")
B(pend(block("For the second objective").replace("of 15 LLM API providers", "of 20 candidate LLM models")))
P("For the third objective (usability evaluation): [[PENDING: after SUS data collection, report the mean score, its interpretation, and whether the target of 80 or above was met. Until then: usability evaluation with the System Usability Scale is in progress and will be reported on completion of data collection.]]")
B(block("Overall, SmartSpend demonstrates"))
H(T_sub, "Recommendations")
P("Based on the findings, development experience, and the usability evaluation, the following recommendations are proposed:")
n=0
for pref in ["1. **Safe-to-Spend","2. **15th and 30th","3. **Backend API proxy","4. **Play Store","5. **On-device AI","5b. **SQLite","6. **Couple","7. **OFW","8. **Open Finance"]:
    txt = block(pref)
    txt = re.sub(r'^\d+b?\.\s*', '', txt); n+=1
    els.append(mk(T_body, [(f"{n}. ",None)] + md_segs(txt)))
B(block("For future research, longitudinal studies"))

# ---------- Chapter II: Kanban table (Table 2.2) after para 275
kan_start = next(i for i,l in enumerate(md) if l.startswith("| Phase | Key Tasks"))
krows=[]
for l in md[kan_start+2:]:
    if not l.startswith('|'): break
    krows.append([c.strip().replace('(Table 2.2)','(Table 3.2)') for c in l.strip().strip('|').split('|')])
assert len(krows)==7
cap22 = mk(T_cap, "Table 2.2. Agile Kanban Workflow Phases and Deliverables")
k_els = [mk(T_body, "The phases of the Kanban workflow, together with their key tasks and deliverables, are summarized in Table 2.2."),
         L._keep_next(cap22) or cap22,
         finish_table(mk_table(T_TBL, ["Phase","Key Tasks","Deliverable"], krows, [1500,3800,3340], sz=22))]
anchor = ps[275]
assert anchor.text.startswith("Finally, in the Done/Review Phase")
cur = anchor._p
for e in k_els:
    cur.addnext(e); cur = e
# chapters III/IV after the Kanban table
for e in els:
    cur.addnext(e); cur = e

# ---------- edits to existing text
def find(prefix):
    for p in doc.paragraphs:
        if p.text.strip().startswith(prefix): return p
    raise SystemExit("not found: "+prefix)
# BSP paragraph
bsp = next(p for p in doc.paragraphs if "rose to 86%" in p.text)
set_text(bsp, md_segs(block("More recent data suggests this picture is beginning to shift"))[0][0])
# badges
bp = next(p for p in doc.paragraphs if "25 achievement badges" in p.text)
for r in bp._p.findall(qn('w:r')):
    for t in r.findall(qn('w:t')):
        if t.text and "25 achievement badges" in t.text: t.text = t.text.replace("25 achievement badges","36 achievement badges")
# abstract
abs3 = find("A core academic contribution is the Financial Health Score")
set_text(abs3, md_segs(block("> A core academic contribution") if False else "A core academic contribution is the Financial Health Score (FHS) — formally positioned as a Prototype Observed Financial Health Indicator (FHI), adapting ideas from the Commonwealth Bank of Australia and Melbourne Institute's (CBA-MI, 2018) Observed (transaction-data) scale and the Financial Health Network's FinHealth Score® pillars. It operates in two modes: Full Mode (Savings Rate, Overspend Control, Budget Adherence, Logging Consistency) and Lightweight Mode (Spending Restraint, Consistency, Category Balance, Habit Streak) — with Warning Decay and Logging Gap Detection mechanisms.")[0][0])
abs4 = find("The system was evaluated using the System Usability Scale")
set_text(abs4, "Usability is being evaluated with the System Usability Scale (SUS) using purposively selected respondents from the target groups; the results will be reported once data collection is complete.")
# UNSGSA reference title
un = next(p for p in doc.paragraphs if p.text.startswith("UNSGSA") and "framework for practitioners" in p.text)
for r in un._p.iter(qn('w:t')):
    if r.text and "A framework for practitioners" in r.text:
        r.text = r.text.replace("A framework for practitioners","Concepts and considerations")
    elif r.text and "framework for practitioners" in r.text:
        r.text = r.text.replace("framework for practitioners","concepts and considerations")

# ---------- references
NEWREFS = [
 "Ariely, D. (2008). Predictably irrational: The hidden forces that shape our decisions. HarperCollins.",
 "Bitrián, P., Buil, I., & Catalán, S. (2021). Making finance fun: The gamification of personal financial management apps. International Journal of Bank Marketing, 39(7), 1310–1332. https://doi.org/10.1108/IJBM-02-2021-0074",
 "Comerton-Forde, C., Ip, E., Ribar, D. C., Ross, J., Salamanca, N., & Tsiaplias, S. (2018). Using survey and banking data to measure financial wellbeing (Financial Wellbeing Scales Technical Report No. 1). Commonwealth Bank of Australia & Melbourne Institute.",
 "Consumer Financial Protection Bureau. (2017). CFPB Financial Well-Being Scale: Scale development technical report. consumerfinance.gov",
 "Duhigg, C. (2012). The power of habit: Why we do what we do in life and business. Random House.",
 "Faulkner, L. (2003). Beyond the five-user assumption: Benefits of increased sample sizes in usability testing. Behavior Research Methods, Instruments, & Computers, 35(3), 379–383.",
 "Financial Health Network. (2021). FinHealth Score® toolkit and methodology. finhealthnetwork.org",
 "Financial Health Network. (2026). From insight to impact: The next phase of financial health measurement. finhealthnetwork.org",
 "Groq. (2026). Groq API documentation and model deprecations.",
 "Kahneman, D., & Tversky, A. (1979). Prospect theory: An analysis of decision under risk. Econometrica, 47(2), 263–292.",
 "Li, Z., et al. (2024). A survey of large language models for financial applications. arXiv:2406.11903.",
 "Nielsen, J., & Landauer, T. K. (1993). A mathematical model of the finding of usability problems. Proceedings of INTERCHI '93, 206–213.",
 "Ramsey, D. (2003). Financial peace revisited. Viking.",
 "Thaler, R. H., & Sunstein, C. R. (2008). Nudge: Improving decisions about health, wealth, and happiness. Yale University Press.",
 "Wajid, F., et al. (2025). Gamification: Revolutionizing financial planning systems. World Journal of Advanced Engineering Technology and Sciences, 14(3), 399–409.",
 "Warren, E., & Tyagi, A. W. (2005). All your worth: The ultimate lifetime money plan. Free Press.",
]
def key(x): return re.sub(r'[^a-z0-9 ]','',x.lower()).strip()
def ref_paras():
    allp = doc.paragraphs
    s = next(i for i,p in enumerate(allp) if p.text.strip()=="References" and i>200)
    e = next(i for i,p in enumerate(allp) if p.text.startswith("ZXing"))
    return [p for p in allp[s+1:e+1] if p.text.strip() and not p.text.startswith("http")]
existing = {key(p.text)[:25] for p in ref_paras()}
added=[]
for txt in NEWREFS:
    if key(txt)[:25] in existing: continue
    cands = [p for p in ref_paras() if key(p.text) < key(txt)]
    pred = max(cands, key=lambda p: key(p.text))
    el = mk(pred, [(txt,None)])
    pred._p.addnext(el); added.append((txt[:40], pred.text[:30]))
print("references added:", len(added))
for a in added: print("  ", a)
for p in doc.paragraphs:
    if p.text.startswith("Bitrián") and "IJBM-09-2020-0491" in p.text:
        for t_ in p._p.iter(qn('w:t')):
            if t_.text and "IJBM-09-2020-0491" in t_.text: t_.text = t_.text.replace("IJBM-09-2020-0491","IJBM-02-2021-0074")
        print("fixed Bitrián DOI")
doc.save('/home/claude/ms4.docx')
print("saved ms4.docx; new top-level elements:", len(els)+len(k_els))
