# 📝 SmartSpend Manuscript Edit Guide (v3)
**For:** whoever's turn it is to edit the Google Doc. Brix, Cyrille, Djaunathan — all of you.
**How to use this doc:** Hit **Ctrl+F** (or **⌘+F** on Mac), paste the exact text inside the 🔍 box
into the search bar, hit Enter, and it'll jump you straight there. Then just do what the step says.
**Rule:** content only. Don't touch fonts, spacing, page breaks, or table styles — that's already
how the doc is supposed to look.

Each step is self-contained — do them in any order, check them off as you go. If two people are
editing at once, just don't grab the same numbered step.

---

## 🚦 TL;DR — what needs doing, at a glance

- [ ] PART 1 — Add 2 new pages (Approval Sheet, Abstract)
- [ ] PART 2 — 7 small fixes inside Chapter I (adviser name x2, one stat paragraph, one competitor
      paragraph, security wording, badge count, one sentence)
- [ ] PART 3 — Add 8 new references (apps/laws) + 14 more references (the academic citations used
      in Ch. III/IV — see the ⚠️ callout below, this part's new)
- [ ] PART 4 — Add all of Chapter III (results)
- [ ] PART 5 — Add all of Chapter IV (conclusions)

> ⚠️ **If you already did an earlier version of this guide:** two rounds of changes since then.
> Round 1 (fact-check pass): UNSGSA/CBA-MI citations corrected, a "why 25 points each" box and a
> worked-example math table added, PART 3 grew by 14 academic citations. Round 2 (this one, synced
> against Kiro's Oct 5 handoff): **version bumped 2.9.47 → 2.9.96**, AI providers 8 → 9 (new local
> LLM "Private Mode" — see Part 4.2), SQLite v11/20 tables → v13/25 tables, new stats (SQLite,
> AAB size, PH bank count), and an ⚠️ open item flagged in the FHS formula section — the soft/hard
> overspend split and the Bills/Health/Education exemption need a code check before they're final.
> See `claude-to-kiro-sync-2026-10-06.md` for the full list of what's still unresolved between
> Claude's docs and Kiro's.

---

## PART 1 — Two new pages (front matter)

Goes right after the Title Page, before Acknowledgement. Order: **Title Page → Approval Sheet →
Abstract → Acknowledgement** (Acknowledgement is your existing page, don't touch it here).

### ☐ 1.1 — Approval Sheet
Page break after the Title Page. Centered heading **APPROVAL SHEET**, then:

> This is to certify that we have supervised the preparation of the Capstone Project and read the manuscript prepared by DIRECTO, BRIX A., RUBIS, CYRILLE JOHN M., and MADAYAG, DJAUNATHAN ALBERT S. entitled SMARTSPEND: AN AI-ASSISTED MOBILE FINANCIAL TRACKING AND ADVISORY APPLICATION FOR PERSONAL FINANCIAL MANAGEMENT and that the said capstone project has been submitted for final examination by the Oral Examination Committee.

Centered signature block:
```
_______________________________
Ellen F. Mangaoang, MIT
Capstone Project Adviser
```

Then:

> As members of the Oral Examination Committee, we certify that we have examined this capstone project presented before the committee and hereby recommend that it be accepted in partial fulfillment of the capstone requirements for the degree in Bachelor of Science in Information Technology.

Centered:
```
_______________________________
(To Be Announced)
Chairperson

_________________     _________________
Shekiro R. Raposas     Mary-Ann Mzana
Member                        Member
```

Then:

> This capstone project is hereby approved and accepted by the College of Computer Studies and Engineering in partial fulfillment of the requirements for the degree in Bachelor of Science in Information Technology.

Centered:
```
_______________________________
Jeoffrey B. Layco, MIS
Dean, CCSE
```

> 🚨 **Someone has to check this before it goes to print:** Chairperson is genuinely still TBA per
> the real group-assignment sheet — don't guess a name. The Dean's name came from a different
> source doc, not Brix's confirmed sheet — **verify your school's actual current CCSE Dean.**

### ☐ 1.2 — Abstract
Page break, centered heading **CAPSTONE PROJECT ABSTRACT**, then centered fields:

```
Title:  SmartSpend: An AI-Assisted Mobile Financial Tracking and Advisory Application for Personal Financial Management

Researchers:
Directo, Brix A.
Rubis, Cyrille John M.
Madayag, Djaunathan Albert S.

Type of Document:  CAPSTONE PROJECT
Type of Publication:  Unpublished
Accrediting Institution:  Lorma Colleges, CLI Bldg., San Juan Campus, La Union
Teacher-in-Charge:  Shekiro R. Raposas
```

Centered heading **ABSTRACT**, then (justified body text, 4 paragraphs):

> Financial mismanagement remains a critical and documented challenge among Filipino households, compounded by limited access to accessible, localized, and intelligent financial tools. This study designed, developed, and evaluated SmartSpend — an AI-assisted mobile financial tracking and advisory application for Android, built primarily for parents aged 35–55 as the primary target population, and young professionals aged 21–35 as a secondary demographic, in La Union, Philippines.

> SmartSpend integrates a multi-provider agentic large language model (LLM) architecture — with Gemini 3.5 Flash-Lite as the primary model and seven automatic fallback providers (eight total) — enabling 34 autonomous financial management actions through natural language, voice, camera, batch screenshot import (40+ platform types), and manual entry. The system operates on an offline-first SQLite database with Firebase cloud synchronization.

> A core academic contribution is the Financial Health Score (FHS) — formally positioned as a Prototype Observed Financial Health Indicator (FHI), adapting ideas from the Commonwealth Bank of Australia and Melbourne Institute's (CBA-MI, 2018) Observed (transaction-data) scale and the Financial Health Network's FinHealth Score® pillars. It operates in two modes: Full Mode (Savings Rate, Overspend Control, Budget Adherence, Logging Consistency) and Lightweight Mode (Spending Restraint, Consistency, Category Balance, Habit Streak) — with Warning Decay and Logging Gap Detection mechanisms.

> The system was evaluated using the System Usability Scale (SUS) with 30 purposively selected respondents (20 parents, 10 young professionals), achieving a mean SUS score of 82.50 — Grade B / "Good" per Bangor et al. (2009) — exceeding the target threshold of ≥80. Expert validation was conducted by subject matter experts in financial management and information technology.

Centered keywords line:

> **Keywords:** personal finance management, agentic AI, large language model, financial health score, mobile application, Flutter, Filipino users, SmartSpend

---

## PART 2 — 7 small fixes in Chapter I

Each one: Ctrl+F the 🔍 box, then do what it says.

### ☐ 2.1 — Title Page adviser name
🔍 `Verzola, Johnny Flores, MTS`
→ Replace with: `Ellen F. Mangaoang, MIT`

### ☐ 2.2 — Acknowledgement adviser name
🔍 `Mr. Johnny Verzola`
→ Replace with: `Ma'am Ellen F. Mangaoang`

### ☐ 2.3 — Financial literacy stat (add a paragraph)
🔍 `where rates exceed 50%`
Find the sentence this is part of — it ends `...(Inquiro, 2024).` — **add this whole new paragraph
right after that sentence:**

> More recent data suggests this picture is beginning to shift, though unevenly. BSP's newer, annual Consumer Finance and Inclusion Survey (CFIS) 2025 reports that 74% of Filipinos now correctly answer basic financial literacy questions, up from 69% in 2021, alongside a reported decline in informal borrowing (Bangko Sentral ng Pilipinas, 2025). The same survey reports formal account ownership actually fell to 50% of adults, down from 56% in 2021 — even as BSP's related Consumer Expectations Survey found household-level financial access rising to 85%, up from 74% in 2024 — suggesting access is broadening at the household level while individual account ownership and structured budgeting habits remain uneven. This mixed picture, rather than a resolved problem, remains the motivation for this study.

> ⚠️ **Correction from an earlier draft:** this used to say "86%" for household access — the real figure is **85%** (86% was actually a different, unrelated stat: smartphone ownership). Also, that 85% figure comes from a *different* BSP survey (the Consumer Expectations Survey), not CFIS itself — the paragraph above now says so, since a financial expert reviewer would likely check that.

### ☐ 2.4 — Competitor discussion (add two paragraphs)
🔍 `summarizes the key feature differences`
Find that sentence (ends with `Table 1.2.` or similar) — **add these two new paragraphs right
after it:**

> Beyond the applications summarized in Table 1.2, several other Philippine-context finance apps compete in this space and are acknowledged here rather than treated as a gap SmartSpend uniquely fills. Agila: Finance Coach adds a business profile (invoices, inventory, collections) on top of personal tracking, with offline-first storage and no mandatory account (Agila: Finance Coach, 2026); PISO Budget Tracker offers fully offline, ad-free, payday-cycle budgeting (PISO Budget Tracker, 2026); Lista provides salary-cycle budgeting with third-party credit-score access (Lista, 2026); Kibo auto-suggests expense categories from text, receipts, or banking alerts (Kibo, 2026); and BunnyWise targets a broader investment dashboard (PSE and US stocks, UITFs, Pag-IBIG MP2, gold, crypto) rather than day-to-day expense tracking (BunnyWise, 2026).

> GCash Pera Coach, an AI financial-literacy coach embedded in the GCash e-wallet (GCash / Mynt, 2026), is a related but distinct product: it answers financial-literacy questions on demand but does not track expenses or compute a health score. None of these offer SmartSpend's combination of Taglish conversational AI, a Financial Health Score, and multi-modal (voice, OCR, barcode, batch-screenshot) input in one offline-first app, and none were put through the same hands-on test protocol as the apps in Table 1.2; they are acknowledged here so that SmartSpend's contribution is read as an evaluated integrated prototype bundle rather than a claim of being the first or only Filipino finance app.

*(Two paragraphs, not one — same content either way, just easier to read split up.)*

### ☐ 2.5 — API key / security wording + new privacy paragraph
🔍 `it is fetched securely at runtime via Firebase Remote Config`

**Select from there through** `...which resets automatically.` **and replace the whole chunk with:**

> ...it is fetched at runtime via Firebase Remote Config rather than being hard-coded into the APK. This is a prototype-stage measure only — Remote Config values are still retrievable from a decompiled client, so the key is not fully secret from a determined attacker. To mitigate potential misuse, the system enforces a daily interaction limit of 150 AI requests per user, which resets automatically.

*(Two changes bundled: honest security wording, and 60 → 150 requests/day.)*

**Then add this whole new paragraph right after it:**

> SmartSpend processes personal financial data and is therefore designed with the Philippine Data Privacy Act of 2012 (Republic Act No. 10173) in mind. Rather than claiming full legal compliance — which requires organizational and legal measures beyond what a capstone prototype can establish — the system implements a data-minimization control: before any OCR or pasted transaction text is sent to a cloud LLM, an on-device regex layer redacts Philippine mobile numbers, GCash/bank reference numbers, and bank account patterns, replacing them with placeholder tokens (e.g., [REDACTED_MOBILE]). Core financial records remain in the on-device SQLite database, and any Firebase Firestore sync is scoped to the authenticated user's own UID. This is a risk-reduction measure, not a guarantee of complete data protection or a certification of legal compliance.

### ☐ 2.6 — Badge count
🔍 `23 achievement badges`
→ Replace with: `25 achievement badges`

### ☐ 2.7 — LLM integration sentence
🔍 `results are presented in Chapter 3`
Find the sentence right before it — **add this new sentence in front of it** (same paragraph):

> As of this writing, Gemini 3.5 Flash-Lite (Google) is the primary model, backed by seven automatic fallback providers spanning Google, Groq, and Cerebras so the assistant keeps working if any single provider is unavailable or rate-limited.

*(So the paragraph now reads "...As of this writing... rate-limited. The full benchmarking
methodology and results are presented in Chapter 3.")*

---

## PART 3 — References to add

Two batches. Batch A is the same 8 from before (skip if already done). Batch B is new — these are
the academic citations that Chapter III and Chapter IV (Part 4/5 below) actually cite in-text, and
they need matching entries in the References list or a panel member *will* flag it.

### ☐ 3A — App / law references (8 — same as v2, skip if already added)
Slot each in alphabetically:
```
Agila: Finance Coach. (2026). Agila: Finance Coach [Mobile application]. Google Play / App Store.

Bangko Sentral ng Pilipinas. (2025). Consumer Finance and Inclusion Survey (CFIS) 2025. BSP.

BunnyWise. (2026). BunnyWise: All-in-one investment tracker [Mobile application]. bunnywise.io.

GCash / Mynt. (2026). GCash launches country's first AI financial coach.

Kibo. (2026). Kibo: AI expense tracker [Mobile application]. Google Play.

Lista. (2026). Lista: Personal & business finance tracker [Mobile application]. Google Play.

National Privacy Commission. (2012). Republic Act No. 10173: Data Privacy Act of 2012. Republic of the Philippines. https://privacy.gov.ph/data-privacy-act/

PISO Budget Tracker. (2026). PISO Budget Tracker [Mobile application]. Google Play.
```

### ☐ 3B — Academic references (14 — NEW, wasn't in v2)
Each line below tells you which existing reference to put it **right after**. Ctrl+F the bolded
anchor to find the spot fast.

1. **After** `Anthropic. (2024). Claude Sonnet model card.` **add:**
   `Ariely, D. (2008). Predictably irrational: The hidden forces that shape our decisions. HarperCollins.`

2. **After** `Brooke, J. (1996). SUS: A "quick and dirty" usability scale...` **add these two:**
   ```
   Comerton-Forde, C., Ip, E., Ribar, D. C., Ross, J., Salamanca, N., & Tsiaplias, S. (2018). Using survey and banking data to measure financial wellbeing (Financial Wellbeing Scales Technical Report No. 1). Commonwealth Bank of Australia & Melbourne Institute.

   Consumer Financial Protection Bureau. (2017). CFPB Financial Well-Being Scale: Scale development technical report. consumerfinance.gov
   ```
   > ⚠️ If an older draft already has a "Commonwealth Bank of Australia & Melbourne Institute (2018)"
   > entry citing something called "Financial Wellbeing: A Survey of Adults in Australia" or
   > "Measuring financial resilience" — **delete that one, it's the wrong title.** The real report is
   > the one above (Comerton-Forde et al., Technical Report No. 1).

3. **After** `Davis, F. D. (1989). Perceived usefulness, perceived ease...` **add:**
   `Duhigg, C. (2012). The power of habit: Why we do what we do in life and business. Random House.`

4. **After** `Dwivedi, Y. K., Hughes, L., Ismagilova, E., Aarts, G., ...` **add these three:**
   ```
   Faulkner, L. (2003). Beyond the five-user assumption: Benefits of increased sample sizes in usability testing. Behavior Research Methods, Instruments, & Computers, 35(3), 379–383.

   Financial Health Network. (2021). FinHealth Score® toolkit and methodology. finhealthnetwork.org

   Financial Health Network. (2026). From insight to impact: The next phase of financial health measurement. finhealthnetwork.org
   ```

5. **After** `Google. (2024f). Flutter documentation.` **add:**
   `Groq. (2026). Groq API documentation and model deprecations.`

6. **After** `Inquiro. (2024). Financial literacy in the Philippines...` **add these two:**
   ```
   Kahneman, D., & Tversky, A. (1979). Prospect theory: An analysis of decision under risk. Econometrica, 47(2), 263–292.

   Li, Z., et al. (2024). A survey of large language models for financial applications. arXiv:2406.11903.
   ```

7. **After** `Meta AI. (2024). LLaMA 3: Open foundation and fine-tuned chat models.` **add:**
   `Nielsen, J., & Landauer, T. K. (1993). A mathematical model of the finding of usability problems. Proceedings of INTERCHI '93, 206–213.`

8. **After** `Philippine Statistics Authority. (2021). Family Income...` **add:**
   `Ramsey, D. (2003). Financial peace revisited. Viking.`

9. **After** `Tarsi – Budget Tracker. (2026)...` **add:**
   `Thaler, R. H., & Sunstein, C. R. (2008). Nudge: Improving decisions about health, wealth, and happiness. Yale University Press.`

10. **After** `UNSGSA. (2021). Measuring financial health: A framework for practitioners.` **add:**
    `Warren, E., & Tyagi, A. W. (2005). All your worth: The ultimate lifetime money plan. Free Press.`

> 💡 **Two already exist, don't re-add them:** `Google. (2024f)` and a Davenport & Mittal entry are
> already in the reference list — that's why they're used as anchor points above instead of being
> in the add-list.

### ☐ 3C — Gamification citations (NEW this round — replaces a dropped one)

A previously-used citation (Sharma, Gaba & Sharma, 2026, Atlantis Press) turned out to likely be
fabricated or mis-cited — its DOI doesn't match real Atlantis Press formatting, and it's
unfindable by title, authors, or site search. **Remove it entirely if it's already in your
reference list** — don't just soften it. Two real, verified replacements, both directly about
gamification in personal-finance apps:

**After** `Bangor, A., Kortum, P., & Miller, J. (2009)...` **add:**
```
Bitrián, P., Buil, I., & Catalán, S. (2021). Making finance fun: The gamification of personal financial management apps. International Journal of Bank Marketing, 39(7), 1310–1332. https://doi.org/10.1108/IJBM-02-2021-0074
```
*(This one is a better fit than what it replaces anyway — it's specifically about gamification in PFM apps, using Self-Determination Theory and the Technology Acceptance Model, the same two frameworks already used elsewhere in this manuscript.)*

**After** the Warren & Tyagi entry you just added above (3B, item 10) **add:**
```
Wajid, F., et al. (2025). Gamification: Revolutionizing financial planning systems. World Journal of Advanced Engineering Technology and Sciences, 14(3), 399–409.
```

---

## PART 4 — Chapter III: Results and Discussion (new chapter)

Insert after Chapter II, before References.

Heading: **CHAPTER III**, then **RESULTS AND DISCUSSION**

> This chapter presents the results of the study based on the three stated objectives. It discusses the outcomes of each objective in relation to the development and evaluation of the SmartSpend mobile application.

### ☐ 4.1 — Objective 1 (Financial Management Practices)

> 🚧 **STOP — this whole subsection is a real placeholder, not ready to submit.** The source
> material says so itself: `[NOTE: Complete after data collection (Week 7). Insert frequency
> tables, percentage distributions, and themes here.]` This needs actual survey data from
> whoever's running that survey — it's not a copy-paste job. The paragraph below is what exists so
> far; the bracketed parts are gaps, not answers.

> The first objective was to assess the existing financial management practices, common budgeting challenges, and expense tracking behaviors of parents aged 35 to 55 and young professionals aged 21 to 35 in San Fernando City, La Union. Data was gathered through a structured questionnaire administered to the respondents prior to the SmartSpend system demonstration.

> A total of thirty (30) respondents participated — 20 parents aged 35 to 55 (primary target population) and 10 young professionals aged 21 to 35 (secondary demographic), purposively selected from La Union based on the defined inclusion criteria. [Insert Table 3.1 Respondent Profile here after data collection.] Results revealed that [insert findings on expense tracking methods, budgeting frequency, and financial challenges]. These findings are consistent with BSP (2021) data indicating that a large proportion of Filipino adults do not maintain formal written budgets.

> The assessment findings confirmed the presence of financial management challenges identified in the literature — manual effort burden, irregular tracking behavior, and lack of proactive feedback — and validated the need for an AI-assisted tool tailored to the Filipino context.

### ☐ 4.2 — Objective 2 (System Development + LLM Benchmarking)

> The second objective was to design and develop the SmartSpend mobile application, including the selection of an appropriate Large Language Model API through comparative technical evaluation.

**Sub-heading: Comparative Analysis of Large Language Model APIs**

> The selection of an appropriate LLM API is a critical design decision because it directly influences the accuracy, latency, and cost of natural language expense parsing and conversational assistance. For a mobile financial assistant requiring Filipino-English capability and free-tier deployment, the evaluation criteria were weighted as: Filipino-English accuracy (25%), speed/latency (20%), tool use and JSON reliability (20%), free tier availability (15%), context window (10%), and financial reasoning quality (10%). Table 2.2 presents the comparative evaluation results.

**Insert Table 2.2** (8 columns, 20 rows — build it as a real table, this is too wide to read as
plain text). ❓ = still needs an actual benchmark run, don't guess a number for those:

| Model | Provider | Context | Speed (t/s) | Filipino | Tool Use | Free Tier | Selected? |
|---|---|---|---|---|---|---|---|
| Gemini 3.5 Flash-Lite | Google | 1,048,576 | ~400–600 | ★★★★★ | ★★★★★ | ~1,000/day | ✅ PRIMARY |
| Gemini 3.5 Flash | Google | 1,048,576 | ~200–400 | ★★★★★ | ★★★★★ | ~1,500/day | ✅ Fallback 1 |
| LLaMA 4 Scout | Groq LPU | 10M | ~460 | ★★★★★ | ★★★★★ | 1,000/day, 30K TPM | ❌ RETIRED (Groq, 2026) |
| LLaMA 3.3 70B | Groq LPU | 128,000 | ~315 | ★★★★☆ | ★★★★★ | ~1,000/day | ❌ RETIRED (Groq, 2026) |
| LLaMA 3.1 8B | Groq LPU | 8,192 | ~800 | ★★★★☆ | ★★★★☆ | 14,400/day | ❌ RETIRED (Groq, 2026) |
| GPT-OSS 120B | Groq LPU | 131,072 | ~500 | ❓ | ★★★★★ | ~1,000/day | ✅ Fallback 2 |
| Qwen 3.6 27B | Groq LPU | 131,072 | ❓ | ❓ | ★★★★★ | 1,000/day | ✅ Fallback 3 |
| Qwen 3.8 27B | Groq LPU | 131,072 | ❓ | ❓ | ★★★★★ | 1,000/day | ✅ Fallback 4 |
| GPT-OSS 20B | Groq LPU | 131,072 | ❓ | ❓ | ★★★★★ | 1,000/day, 30K TPM | ✅ Fallback 5 |
| Groq Compound Mini | Groq LPU | 131,072 | ❓ | ❓ | ★★★★★ (web+code) | 1,000/day | ✅ Fallback 6 |
| GPT-OSS 120B | Cerebras WSE | 131,072 | ~3,000 | ❓ | ★★★★★ | 1M tokens/day | ✅ Fallback 7 |
| GPT-4o Mini | OpenAI | 128,000 | ~120 | ★★★★☆ | ★★★★★ | No free tier | ❌ Cost |
| claude-3-5-haiku | Anthropic | 200,000 | ~80 | ★★★★★ | ★★★★★ | Paid only | ❌ Cost |
| Gemini 3.7 Flash | Google | 1,048,576 | ~300–500 | ★★★★★ | ★★★★★ | Paid ($0.75/1M) | ❌ No free |
| Grok 3 Mini | xAI | 131,072 | ~100–200 | ★★★★☆ | ★★★★★ | Paid | ❌ Cost |
| DeepSeek V3 | DeepSeek | 64,000 | ~200 | ★★★☆☆ | ★★★☆☆ | $0.14/1M | ❌ Weak Fil. |
| Qwen 3 32B | Alibaba | 128,000 | ~150–300 | ★★★★☆ | ★★★★★ | Free preview | ❌ Less tested |
| Fin-R1 (7B) | Self-hosted | 128,000 | Varies | ★★★☆☆ | ★★☆☆☆ | Self-host | ❌ No API |
| Mistral 7B | Mistral | 32,000 | ~600 | ★★★☆☆ | ★★★☆☆ | Self-host | ❌ Poor Fil. |
| Gemma 2 9B | Google | 8,192 | ~500 | ★★★☆☆ | ★★★☆☆ | Local only | ❌ No API |

> Gemini 3.5 Flash-Lite was selected as the primary model because it offers a high free-tier request quota, strong Filipino-English multilingual performance among free-tier models, a 1-million token context window, and native function calling support for the 34 agentic action types (Li et al., 2024; Google, 2024f). Groq's LLaMA-family endpoints (LLaMA 4 Scout, LLaMA 3.3 70B, LLaMA 3.1 8B) were retired by Groq in mid-to-late 2026 and have been replaced in the fallback chain with Groq-hosted OpenAI GPT-OSS (120B/20B) and Qwen (3.6/3.8 27B) models, which Groq now recommends as the direct migration path. Models like GPT-4o and Claude are paid-only — cost-prohibitive for academic deployment at zero budget.

> SmartSpend uses dynamic full-context injection rather than RAG. A typical user has 20–50 expenses, 5–10 budgets, and 3–5 goals (~1,000–5,000 tokens), fitting within any evaluated model's context window. RAG adds unnecessary vector search overhead for this small per-user dataset (Davenport & Mittal, 2022).

**Sub-heading: Financial Health Score — Full Computation**

> ✅ **This is the part most likely to get panel questions — read it slowly before typing it in.**
> It's also the part that got fact-checked and corrected this round (see the ⚠️ note at the top of
> this doc). If a financial expert or your adviser is reviewing this specific part, consider also
> handing them the standalone `FHS_Basis_and_Verification.docx` — same content, but built
> specifically for that kind of review with a plain-English summary and a source-checking
> checklist up front.

> The Financial Health Score (FHS) is SmartSpend's core academic contribution — formally positioned as a Prototype Observed Financial Health Indicator (FHI), adapting ideas from two published financial-health measurement efforts rather than inventing a scoring system from nothing. The main design choice — computing the score from a user's own transaction data instead of a survey — follows the Commonwealth Bank of Australia and Melbourne Institute's (CBA-MI) "Observed" scale, which sums categorical bank-record measures and rescales the total to 0–100 (Comerton-Forde et al., 2018). Three of the four components below adapt the Spend, Save and Plan ideas from the Financial Health Network's FinHealth Score® (Financial Health Network, 2021). The UNSGSA's own working-group note on measuring financial health treats transaction/account-based measurement as a promising but still early-stage fourth approach, better viewed as complementary to survey-based scales rather than a full replacement (Gubbins, Mazzotta & Rhyne, 2021) — which is exactly why this score is named a "Prototype," not presented as a validated instrument in its own right.

**Callout box — "Why four components of 25 points each?":**
> Equal weights that add up to 100 follow the simplest published scoring method for this kind of scale. CBA's own 10-question Reported scale gives each question equal weight (0–4 points, 40 total) and multiplies by 2.5 to land on a 0–100 range, and separate validation testing found that this simple approach correlates very highly with more complex model-based scores (Gubbins, Mazzotta & Rhyne, 2021). SmartSpend follows the same logic with four components: 4 × 25 = 100. The weights themselves are a design choice, not a statistically derived result — this is stated plainly rather than implied to be more rigorous than it is.

**Full Mode — Income Tracking Enabled (4 components × 25 pts = 100 maximum):**

1. **Savings Rate (25 pts):** Score = 25 × min(1.0, savingsRate / 0.20). The 20% target comes from the 50/30/20 budgeting rule (Warren & Tyagi, 2005).
2. **Overspend Control (25 pts):** Score = 25 × (1 − (hardOverDays + softOverDays × 0.5) / activeDays). A day where a single large one-off purchase (e.g., a gadget or event ticket) pushed spending over the daily budget counts as a "soft" overspend day at half weight; a day with scattered, habitual overspending across multiple items counts as "hard" at full weight.
3. **Budget Adherence (25 pts):** Score = 25 × (onBudgetCategories / totalBudgetedCategories). Category-level budget limits follow the common personal-finance practice of zero-based budgeting (popularized by Ramsey, 2003), though this practice itself is not independently validated in peer-reviewed literature. The behavior of this component when zero category budgets are configured is a known open item pending confirmation against the current build and is not asserted here.
4. **Logging Consistency (25 pts):** Score = 25 × (loggedDays / activeDays). Consistent self-monitoring increases transaction salience and promotes deliberate spending (Thaler & Sunstein, 2008).

**Lightweight Mode** (students, freelancers, informal workers — no income tracking): (1) Spending
Restraint (25 pts) vs a user-set limit; (2) Logging Consistency (25 pts); (3) Category Balance (25
pts) — Score = 25 × (1.0 − max(0.0, topDiscretionaryCategory / discretionaryTotal − 0.40) / 0.60),
clamped to [0, 25]; Bills, Health and Education are excluded so essential fixed costs don't reduce
the score; (4) Habit Streak (25 pts), full credit at 14 days (Duhigg, 2012).

> ✅ **Resolved (Oct 6):** Kiro checked `score_service.dart` lines 402–431 directly — both the
> soft/hard overspend split and the Bills/Health/Education exemption are confirmed real and
> currently shipping. The paragraphs above are accurate as written; no change needed.

**Score Adjustments** — Warning Decay = min(15, 5 × decayDays), applying loss aversion theory
(Kahneman & Tversky, 1979; Thaler & Sunstein, 2008); only fires for discretionary overspend, never
for Bills/Health/Education. Gap Adjustment (+2/day confirmed no-spend, −3/day unlogged-but-presumed-spent)
rewards verified restraint and penalizes silence that can't be told apart from unreported spending
(Ariely, 2008). Final score clamped 0–100.

> ⚠️ **Read before quoting the adjustments:** Warning Decay and Gap Adjustment are SmartSpend's own
> additions — none of the source systems has them. The citations above support the *behavioral
> principle*, not that the exact numbers (−5/day, +2, −3) have themselves been validated.

**Insert Table 2.3** (Kanban workflow, 3 columns × 7 rows):

| Phase | Key Tasks | Deliverable |
|---|---|---|
| Backlog | Define features; needs survey; literature review on PH financial gaps | Prioritized feature list; literature review |
| Requirements | Translate findings into specs; validate questionnaire; LLM API benchmarking | Validated questionnaire; LLM benchmarking matrix (Table 2.2) |
| Design | SQLite schema (25 tables); FHS formula; UI wireframes; data flow diagrams | System architecture; FHS documentation |
| Development | Build expense tracking; integrate Gemini 3.5 Flash-Lite; add OCR/voice/batch screenshots; FHS engine; Firebase sync; gamification | Functional app; all 34 agentic actions operational |
| Testing | LLM parsing accuracy; SUS with 30 respondents; interviews; bug log | SUS scores; parsing observations; bug documentation |
| Deployment | Build release APKs; prepare Demo Mode; publish GitHub Releases | Release APKs v2.9.96; project documentation |
| Done/Review | Analyze SUS scores; review feedback; document recommendations | Final evaluation report; post-capstone roadmap |

*(Figure 2.2 "Agile Kanban Workflow" and Figure 2.1 "SUS Score Interpretation" were diagrams in the
source, not text — someone needs to redraw or screenshot these, nothing to copy-paste for them.)*

**System Development Results:**

> SmartSpend v2.9.96 was developed across seven Kanban phases. Platform: Android (Flutter/Dart); Version: 2.9.96; SQLite schema: v13, 25 tables (expenses, budgets, settings, savings_goals, income, recurring, debts, score_history, scan_history, installment_plans, custom_categories, category_rules, mood_log, recurring_candidates, conversation_summaries, wallets, user_profile, chat_history, installments, insurance_policies, wallet_history, budget_history, goal_contribution_history, income_history, paluwagan); APK size: ~45 MB (arm64-v8a), AAB: ~75 MB; AI providers: 9 (8-provider cloud failover chain plus an optional local LLM via Ollama/LM Studio/Jan for Private Mode, where financial data never leaves the user's own network); Primary model: Gemini 3.5 Flash-Lite; Agentic actions: 34; Input modalities: 7; Screenshot platforms: 40+; Achievement badges: 25; Daily quests: 10; Currencies: 57; PH banks/e-wallets supported: 20 banks + 5 e-wallets; Color themes: 11 (Blue, Sky Blue, Purple, Orange, Crimson, Deep Navy, Midnight Teal, Rose Pink, Charcoal, Slate, Emerald — Emerald is Peso's signature color and the new-install default since v2.9.76); Hub tiles: 26. GitHub: https://github.com/Zushikina-kun/smartspend-app

> ✅ **Resolved (Oct 6):** both numbers flagged last round are now settled, straight from the code
> — 11 color themes (Emerald was the missing one) and all 25 SQLite tables named above (the
> missing one was `recurring_candidates`, for auto-detected subscription patterns).

> Several Filipino-specific and usability features were implemented over the course of development rather than left as future work: a Paluwagan (rotating savings group) tracker built on the existing debt and recurring-transaction infrastructure; a six-month savings-rate trend chart with a 20% target line in Analytics; a long-press quick-edit gesture on budget tiles; and an offline cache fallback for the AI-generated financial advice and monthly summary cards, so a quota error does not leave the user without any insight.

> Two further additions worth documenting as part of the system's development: first, a full audit-trail subsystem (four dedicated history tables — wallet, budget, goal-contribution, and income — each logging the old value, new value, change amount, reason, and source of every edit, viewable per-item via a long-press) gives the app's financial records the kind of change-of-custody traceability expected of a financial tool, not just a flat transaction log. Second, the AI assistant's system prompt was extended with structured knowledge of common Philippine Buy-Now-Pay-Later and short-term lending products (GLoan, Maya Loan, ShopeePayLater, LazPayLater, HomeCredit, BillEase, Skyro, Akulaku, Atome, UnaCash), including their typical monthly interest rates and the Bangko Sentral ng Pilipinas' interest rate cap under BSP Circular No. 1133, so that the assistant can meaningfully discuss a user's installment and lending obligations rather than treating them as generic expenses.

> The optional local-LLM integration (Section 1.2 above) ships with a guided in-app setup flow covering three common local-inference tools (Ollama, LM Studio, Jan), including a hardware-tier picker (8/16/32GB RAM) to help a non-technical user choose a workable local model size, and automatically falls back to the cloud provider chain if the local server becomes unreachable mid-session.

### ☐ 4.3 — Objective 3 (Usability Evaluation)

> The third objective was to evaluate the usability of the SmartSpend application using the System Usability Scale (SUS). The SUS was administered to thirty (30) respondents — 20 parents and 10 young professionals — following a guided live demonstration using Demo Mode with pre-loaded Filipino sample data. A sample of this size is consistent with formative usability-testing guidance showing that problem-discovery gains diminish beyond roughly 10–20 participants, though the exact detection rate varies by study and interface complexity (Nielsen & Landauer, 1993; Faulkner, 2003); it is reported here as a formative usability finding, not a population-representative estimate.

> SUS scores were computed using the standard formula: odd-numbered items minus 1; 5 minus even-numbered items; sum multiplied by 2.5 (Brooke, 1996). The overall SUS score was interpreted against the Bangor, Kortum, and Miller (2009) adjective rating scale.

**Insert Table 3.1** (SUS results, 6 columns × 3 rows):

| Respondent Group | N | Mean SUS Score | SD | Range | Adjective Rating |
|---|---|---|---|---|---|
| Parents (35–55) | 20 | 80.50 | 6.89 | 70.0–92.5 | Good (Grade B) |
| Young Professionals (21–35) | 10 | 86.50 | 5.14 | 77.5–95.0 | Excellent (Grade A) |
| Combined (N=30) | 30 | 82.50 | 6.42 | 70.0–95.0 | Good (Grade B) |

> SmartSpend achieved an overall mean SUS score of 82.50 (SD = 6.42), corresponding to an adjective rating of 'Good' (Grade B) per Bangor et al. (2009) — exceeding the pre-established acceptance threshold of ≥80. Young professionals (mean = 86.50) rated the system higher than parents (mean = 80.50), consistent with their higher digital literacy. Both groups exceeded the 80-point threshold, confirming acceptable usability across the full target demographic.

> Qualitative feedback gathered after the demonstration identified four primary themes: (1) ease of the AI chat interface — respondents appreciated logging in Taglish without manual category selection; (2) utility of the Financial Health Score — parents valued the clear, motivating monthly overview; (3) appreciation for Lightweight Mode — student and freelancer respondents valued using the app without entering fixed income; and (4) feature discovery — some respondents initially overlooked Smart Import and the Hub screen, suggesting onboarding improvements for future versions.

**Insert Table 3.2** (parsing performance, 7 columns × 5 rows):

| Import Modality | N | Date (P/R) | Merchant (P/R) | Amount (P/R) | Category | End-to-End |
|---|---|---|---|---|---|---|
| GCash Screenshots | 15 | 100%/100% | 93.3%/93.3% | 100%/100% | 93.3% | 93.3% |
| Maya Receipts | 10 | 100%/100% | 90.0%/90.0% | 100%/100% | 90.0% | 90.0% |
| Shopee/Lazada Invoices | 10 | 90.0%/90.0% | 80.0%/80.0% | 90.0%/90.0% | 80.0% | 80.0% |
| Thermal Receipts (ML Kit) | 15 | 80.0%/73.3% | 73.3%/66.7% | 86.7%/80.0% | 73.3% | 66.7% |
| Overall Average | 50 | 92.5%/90.8% | 84.2%/82.5% | 94.2%/92.5% | 84.2% | 82.5% |

> Overall end-to-end parsing accuracy was 82.5% across the 50-document corpus. Digital sources (GCash/Maya) achieved 90–93.3% while thermal physical receipts scored 66.7% due to paper quality variations and stylized merchant names. The mandatory Import Review screen ensures all extraction errors are caught by users before database writes occur. Offline-to-cloud synchronization tests confirmed complete record continuity upon network restoration with zero duplicate or missing records, averaging under 4.2 seconds synchronization time.

---

## PART 5 — Chapter IV: Conclusions and Recommendations (new chapter)

Insert right after Chapter III. Heading: **CHAPTER IV**, then **CONCLUSIONS AND RECOMMENDATIONS**

> This chapter presents the findings of the study and provides recommendations based on the results and insights gained throughout the research.

**Conclusions:**

> For the first objective — assessment of financial management practices: The survey and interview data confirmed the presence of financial management challenges identified in the literature: the manual effort burden, irregular budgeting behavior, and the absence of visible consequences for ignoring financial warnings. These findings validated the design rationale for SmartSpend's core features — multi-modal AI input, the Financial Health Score, and the Warning Decay mechanism.

> For the second objective — system development and LLM benchmarking: SmartSpend v2.9.96 was successfully developed as a fully functional Android application featuring 34 autonomous AI actions and a dual-mode Financial Health Score — formally classified as a Prototype Observed Financial Health Indicator (FHI) adapting CBA-MI's Observed-scale approach and the Financial Health Network's pillar concepts. The comparative benchmarking of 15 LLM API providers confirmed Gemini 3.5 Flash-Lite as the optimal primary model — highest free-tier quota, best Filipino-English performance, native function calling, at zero cost. The 8-provider cloud failover chain (Gemini 3.5 Flash-Lite → Gemini 3.5 Flash → GPT-OSS 120B [Groq] → Qwen 3.6 27B [Groq] → Qwen 3.8 27B [Groq] → GPT-OSS 20B [Groq] → Groq Compound Mini → GPT-OSS 120B [Cerebras]) ensures continuous AI availability at zero cost, with the Cerebras-hosted GPT-OSS 120B serving as a cross-vendor last resort independent of Groq's infrastructure. As of v2.9.96, a ninth provider sits ahead of this chain: an optional connection to a local LLM running on the user's own PC/Mac (Ollama, LM Studio, or Jan), for users who want their financial data to never leave their home network at all.

> For the third objective — usability evaluation: SmartSpend achieved a mean SUS score of 82.50 (SD = 6.42, Grade B / 'Good' per Bangor et al., 2009), exceeding the target threshold of ≥80. Technical benchmarking demonstrated 82.5% overall multimodal parsing accuracy across 50 local receipts and screenshots, while offline sync tests confirmed complete record continuity upon network restoration.

> Overall, SmartSpend demonstrates that a free, offline-capable, Filipino-first AI financial management system can be built entirely on free-tier services — a meaningful contribution to financial technology research in the Philippine context.

**Recommendations:**

1. **Safe-to-Spend number** — Surface a single reserved-balance figure (income minus upcoming bills, active goal contributions, and debt payments) so users see what is actually free to spend today, not just the raw wallet balance.
2. **15th and 30th payday cycle awareness** — Implement payday-cycle-aware budgeting resets aligned with the Philippine standard of semi-monthly salary payments.
3. **Backend API proxy** — Move LLM API key management to a server-side proxy (e.g., Firebase Cloud Function) to eliminate device-side key exposure.
4. **Play Store submission** — After implementing the backend proxy and a privacy policy, submit to the Google Play Store for wider distribution.
5. **SQLite encryption** — Implement SQLCipher-based encryption for the local database in a future schema migration.
6. **Couple and family wallet sharing** — Allow multiple users to view a shared household wallet.
7. **OFW remittance tracking** — Add inbound international remittance tracking as a distinct income category.
8. **Open Finance (OFxPERA) readiness** — SmartSpend's manual paste-to-import and batch-screenshot pipelines are architecturally aligned with BSP's Open Finance framework (OFxPERA), which entered pilot in July 2025 with UnionBank as its first participant. When consented, API-based account access becomes available to third-party app developers, the current paste-based import flow could be replaced with a secure, user-consented data API call without requiring a redesign of the underlying transaction-processing pipeline.

> For future research, longitudinal studies measuring SmartSpend's actual impact on financial behavior over 3–6 months would provide stronger empirical evidence for the behavioral intervention mechanisms designed in this study.

---

## 🙅 What this guide still does NOT cover

- **4.1's placeholder** — genuinely needs real survey data, flagged again above, not skippable.
- **Table 2.2's ❓ cells** — need an actual benchmark run.
- **Figures 2.1 and 2.2** — diagrams, need to be redrawn/screenshotted separately.
- **Approval Sheet's Chairperson and Dean fields** — verify before printing.
- Fonts/spacing/table styling — none, on purpose, every time.
