# SmartSpend Defense Script
**Defense Date:** Monday, November 16, 2026 — 3:00 PM
**Panel:**
- Chairperson: Dean Jeoffrey B. Layco, MIS
- Member: Mr. Shekiro R. Raposas, MTS, MIS
- Member: Ms. Mary-Ann Mzana, MTS

**Adviser:** Dr. Ellen Flores Mangaoang, DIT
**Validator:** Avigail Candevario, PFMe
**Estimated speaking time:** ~15 minutes

> Every number and claim in this script is taken from the manuscript (Chapters I–IV, Tables 1–9, Figures 1–17). If a panelist asks about something that is not in the manuscript, say so honestly and do not improvise a number.

---

## SAY / DON'T SAY — Quick Reference

| ✅ SAY | ❌ DON'T SAY |
|--------|-------------|
| "quantitative descriptive developmental" | "mixed methods" (no interviews were conducted) |
| "random sampling was used" (respondents) | "stratified sampling" |
| "purposive sampling was used" (content validator only) | "interviews were conducted" / "respondents said…" (no open-ended data was collected) |
| "16 parents and 14 young professionals" (needs assessment, 30 total; includes 3 "both" counted with parents) | "13 parents" (old count) |
| "10 parents and 20 young professionals" (SUS sample, 30 valid of 36, separate group) | "failed" for Objective 3 |
| "partially achieved" for Objective 3 — always | "fully achieved" / "passed the SUS threshold" |
| "61.83, below the 68 benchmark and the 80 target" | "acceptable for a prototype" |
| "Grade D, adjective OK" | "seven recommendations" (there are 9) |
| "ten candidate models from four providers" | "20 candidate models" / "eight candidate models" |
| "eight-model cloud failover chain (Gemini 3.5 Flash-Lite primary, seven fallbacks)" | "eight-provider chain" |
| "Gemini 3.5 Flash-Lite had a high free-tier quota" | "the highest free-tier quota" (Table 6: Groq and Cerebras are higher) |
| "offline-first; core features work offline; cloud AI needs internet" | "fully offline" |
| "UI/UX refinement is Recommendation 8" | "Recommendation 1" for UI/UX |
| "proposed" only for future work | "proposed" for the app (the app exists) |

---

## Slide-by-Slide Speaking Notes

---

### Slide 1 — Title

Good afternoon, Dean Layco, Sir Raposas, Ma'am Mzana, and Dr. Mangaoang. We are Brix Directo, Cyrille John Rubis, and Djaunathan Madayag, from the College of Computer Studies and Engineering here at LORMA Colleges. Our study is entitled *SmartSpend: An AI-Assisted Mobile Financial Tracking and Advisory Application for Personal Financial Management*, under the guidance of our adviser, Dr. Ellen Flores Mangaoang, DIT. We are grateful for this opportunity and we hope you find our work worthy of your consideration.

---

### Slide 2 — Opening Prayer

Before we begin, we would like to invite everyone to bow their heads as we offer a short opening prayer.

*(Deliver or lead the prayer here.)*

---

### Slide 3 — Problem

The Philippines continues to face a serious financial literacy challenge. According to the 2021 BSP Financial Inclusion Survey, only 2% of Filipino adults correctly answered all six basic financial literacy questions, and fewer than half reported keeping any household or personal budget. More recent BSP data from 2025 shows a mixed picture: basic literacy rose from 69% to 74%, but formal account ownership fell from 56% to 50%. In our own needs assessment of 30 respondents, only 10% reported that they already used a mobile app to track expenses. Most of our target population, parents and young professionals, relied on receipts and mental estimates instead. This is the problem SmartSpend was designed to address.

---

### Slide 4 — Gap Analysis

The gap we identified operates at three levels, as shown in Table 1 of our manuscript. At the international level, manual entry dominates, and AI categorization degrades for non-English transactions. At the national level, existing Philippine apps lack conversational AI, spending behavior analysis, and financial health scoring. At the demographic level, parents tend to abandon apps because of the effort of manual entry, and warnings are ignored when there is no consequence. SmartSpend answers each gap with LLM-based parsing for Filipino-English input, conversational AI with a Financial Health Score, and automated input with a score-decay consequence system.

---

### Slide 5 — Feature Comparison (Table 2)

Table 2 compares SmartSpend against Tarsi, YNAB, Monarch, Copilot, BudgetPH, and Alkansya AI. We also acknowledge other Philippine apps, such as Agila, PISO Budget Tracker, Lista, Kibo, BunnyWise, and GCash Pera Coach, as related work. The comparison shows that none of the apps we tested combines offline mode, LLM chat, a Financial Health Score, OCR receipt scanning, Filipino-English AI, and batch screenshot import in one app. We are not claiming to be the first or only Filipino finance app. SmartSpend is an evaluated, integrated prototype. We are also transparent that it has no bank synchronization and no 15th-and-30th payday cycle yet; the payday cycle is our Recommendation 1.

---

### Slide 6 — Objectives

Three objectives guided this study. First, to assess the existing financial management practices, common budgeting challenges, and expense tracking behaviors of parents aged 35 to 55 and young professionals aged 21 to 35 in San Fernando City, La Union, through structured surveys. Second, to design and develop the SmartSpend mobile application with the integration of a suitable Large Language Model API. Third, to determine the usability of the application using the System Usability Scale. Each objective has its own section in Chapter III, and each section ends by stating whether the objective was achieved.

---

### Slide 7 — What is SmartSpend?

Before we dive into the methodology and results, let me briefly explain what SmartSpend is. SmartSpend is an AI-powered Android mobile application for personal financial management, specifically built for Filipino parents and young professionals who struggle with manual expense tracking. It supports natural language expense logging in Taglish — users can type or speak "nag-lunch ako 150 pesos" and the app records it automatically. The app offers multi-modal input: voice, text, OCR receipt scanning, and batch screenshot import from over 40 platforms such as GCash, Maya, and Shopee. At its core is a Financial Health Score from 0 to 100 that motivates users toward better spending habits. The app is offline-first, meaning core features work without internet and sync to the cloud when connected.

---

### Slide 8 — Conceptual Framework (IPO)

Our study used an Input-Process-Output framework. The inputs are text, voice, receipt images, barcode scans, and the user's financial data. The process layer includes LLM parsing, OCR, barcode recognition, data structuring, local SQLite storage, and Firebase synchronization. The outputs are automatically recorded expenses, financial summaries, charts, alerts, AI-generated insights, the Financial Health Score from 0 to 100, and AI-powered financial assistance such as general financial Q&A, market price estimates, and financial product guidance.

---

### Slide 9 — Research Design and Methodology

This study employed a **quantitative descriptive developmental research design**. The developmental component refers to the design and development of SmartSpend as a working prototype, built using an Agile Kanban workflow. The quantitative descriptive component refers to validated structured survey instruments used to assess needs and to evaluate usability. No interviews were conducted. **Random sampling was used** for the needs assessment, which involved 30 respondents: 16 parents and 14 young professionals. Three of the 16 parents answered "both" in the survey and were counted with the parent group by their age bracket. A separate group completed the SUS evaluation: 30 valid responses out of 36, made up of 10 parents and 20 young professionals, after using the app for at least 10 minutes. **Purposive sampling was used** only for the content validator, Avigail Candevario, PFMe, who was chosen for her expertise in personal finance and financial education to validate our survey instrument.

---

### Slide 9 — Objective 1 Results: Needs Assessment

Objective 1 asked us to assess the financial management practices of our target population. Among the 30 respondents, **96.7%, or 29 of 30, expressed positive intent to use an AI-powered financial application**. **93.3%, or 28 of 30, already used GCash**, which supports our focus on e-wallet transaction import. Only 10%, or 3 of 30, already used a dedicated mobile app to track expenses. The most common tracking method was physical receipts at 90%, followed by mental estimates at 53.3% and e-wallet transaction history at 43.3%. These results informed the receipt scanning, natural-language logging, and screenshot import features we built, and they confirm that Objective 1 was **achieved**.

---

### Slide 11 — System Overview

SmartSpend version 3.1.0 is a working Android application built with Flutter, with offline-first SQLite storage. At a glance: **34 autonomous AI actions**, a 12-mood Peso mascot, batch screenshot import for **40-plus platforms**, a **26-table** SQLite schema, support for 20 Philippine banks and 5 digital banks, **36 achievement badges**, and 31 Taglish situations that Peso can respond to. The AI side has eight cloud models in a failover chain, plus the optional Private Local Mode, for nine AI options in total. Core features work without internet and sync to Firebase when connected; the AI features need a connection unless the user runs a local model. The Financial Health Score is formally classified as a Prototype Observed Financial Health Indicator, which is a design choice, not a statistically validated instrument.

---

### Slide 12 — App Screenshots

Let me walk through five key screens, Figures 9 to 13 in the manuscript. The Login and Demo Mode screen lets users explore SmartSpend with pre-loaded Filipino sample data, or continue without an account, before committing. The Home Dashboard shows the Financial Health Score, budgets, and a spending summary at a glance, with the Peso chat input at the bottom. Expense Logging Through Peso Chat shows natural-language input: here the user typed "nag-lunch ako 150 pesos" and Peso recorded it in one step. Receipt Scanning shows OCR text that the user can review and edit before sending it to the AI. Finally, the Financial Health Score Breakdown shows the overall score and the four scored components, with tips where a component needs work. The manuscript also includes the Budgets screen, Figure 14, and the Local AI setup screen, Figure 15, if the panel would like to see them.

---

### Slide 13 — LLM Selection

Selecting the right LLM was a critical design decision. We evaluated **ten candidate models from four providers** against six weighted criteria: Filipino-English accuracy at 25%, speed at 20%, tool use and JSON reliability at 20%, free-tier availability at 15%, context window at 10%, and financial reasoning quality at 10%. These results are in Table 6. We selected **Gemini 3.5 Flash-Lite** because it offered a one-million-token context window, native function calling for our 34 actions, good Taglish handling in our trials, and a high free-tier request quota. Our fallback chain adds seven more models across Google, Groq, and Cerebras, so the assistant keeps working if one is down or rate-limited. We also used full-context injection rather than RAG, because a typical user's data is only about 1,000 to 5,000 tokens.

---

### Slide 14 — Financial Health Score

The Financial Health Score is a prototype indicator on a 0-to-100 scale. It has two modes. In Full Mode, which needs income tracking, it has four equally weighted components of 25 points each: Savings Rate, Overspend Control, Budget Adherence, and Logging Consistency. In Lightweight Mode, for users without a fixed income, it uses Spending Restraint, Logging Consistency, Category Balance, and Habit Streak. Two adjustments apply: a Warning Decay of up to 15 points for discretionary overspending, and a Gap Adjustment of plus 2 for a confirmed no-spend day and minus 3 for an unlogged day. The final score is clamped between 0 and 100. We want to be transparent with the panel: the equal weights are a design choice, not a statistically derived result, and the score is formally classified as a Prototype Observed Financial Health Indicator, not a validated measurement instrument.

---

### Slide 15 — Privacy Tiers

SmartSpend has three AI privacy tiers, and two are implemented. Tier 1 is Cloud AI, the default. Mobile numbers, reference numbers, and account patterns are redacted on the device before a request is sent, and a one-time privacy disclosure appears before the first AI message. We are honest that our primary provider runs on Google's free Gemini quota, whose terms say content may be used to improve Google's products. Redaction reduces that exposure but does not remove it. Tier 2 is Private Local Mode: requests go only to a model on the user's own PC or Mac, using tools such as Ollama, LM Studio, or Jan. If the local server is unreachable, the app falls back to the cloud, unless the user switches on Local-only mode, in which case the AI simply stops responding instead of falling back. Tier 3, an on-device model running on the phone itself, is **not implemented**. A roughly 2.6-gigabyte model is not yet feasible on the 4 GB phones common among Filipino students, so it is Recommendation 4.

---

### Slide 16 — SUS Results (Objective 3)

The System Usability Scale was administered to **30 valid respondents**, 10 parents and 20 young professionals, as a separate group from the needs assessment. Six of the 36 who attempted the survey were excluded: five for insufficient usage time and one for straight-line responding. The mean SUS score is **61.83**, with a standard deviation of **17.58**, a median of **55.0**, and a range of **35.0 to 92.5**. Under the Bangor, Kortum, and Miller (2009) adjective scale, this is **Grade D, adjective "OK"**. It is below the 68-point average benchmark and below our pre-established target of 80. Parents averaged 58.25 and young professionals 63.62, and both groups were below the benchmark and the target. Respondents scored high on intent to use the system frequently, at 4.35 out of 5, and on confidence, at 4.19 out of 5. The weaker items were consistency, Question 6, and complexity, Questions 2 and 4. For this reason, Objective 3 is **partially achieved**. This is not a failure of the study; it is an honest finding that drives Recommendation 8.

---

### Slide 17 — Limitations

We acknowledge several limitations. The SUS score of 61.83 is below both the 68 benchmark and the 80 target. SmartSpend is Android only, and its cloud AI features need an internet connection. Security is at prototype level: the API key is stored on the device because there is no server-side proxy yet, and the local database is not encrypted. These are addressed in Recommendations 2 and 5. Parsing accuracy in Table 9 comes from development-phase testing, not an independent audit: overall amount accuracy was 88.2%, and date accuracy was the weakest at 70.4%. The gamification elements, Peso and the badges, were added after the evaluation instrument was designed, so their effect on behavior has not been measured. And the 30 SUS respondents came from one locale, which limits generalizability.

---

### Slide 18 — Conclusions

Three conclusions follow directly from our results.

**Objective 1 — Achieved.** The needs assessment identified the financial management practices, budgeting challenges, and expense tracking behaviors of parents and young professionals. 96.7% expressed intent to use an AI-powered financial app, and 93.3% already used GCash.

**Objective 2 — Achieved.** SmartSpend version 3.1.0 was designed and developed as a working Android application with multi-modal expense input, offline-first storage, 34 AI actions, and a Financial Health Score. A comparative evaluation of ten candidate models from four providers led to Gemini 3.5 Flash-Lite as the primary model, supported by an eight-model failover chain.

**Objective 3 — Partially achieved.** Usability was evaluated with the System Usability Scale using 30 valid respondents. The mean score of 61.83 is below the 68-point benchmark and below our 80 target, so UI/UX improvements are needed.

---

### Slide 19 — Recommendations

In view of these results, we make nine recommendations.

1. **Payday-cycle-aware budgeting.** Budgeting resets aligned with the semi-monthly 15th-and-30th salary cycle common in the Philippines.
2. **Backend API proxy and per-user keys.** Move LLM key management to a server-side proxy, such as a Firebase Cloud Function, to remove device-side key exposure and enforce per-user message limits, because the free-tier quotas are shared by every user of the prototype.
3. **Google Play release.** After the backend proxy and a privacy policy are in place. The prototype is currently distributed as a downloadable APK.
4. **On-device AI tier.** An opt-in on-device model, for example Gemma 4 E2B through Google's LiteRT-LM, about a 2.6-gigabyte download, for users who want fully offline AI.
5. **SQLite encryption.** SQLCipher-based encryption for the local database in a future schema migration.
6. **Household and remittance features.** Shared couple and family wallets, and inbound OFW remittance tracking as a distinct income category.
7. **Longitudinal evaluation.** Measure SmartSpend's effect on financial behavior over three to six months with a larger sample, since this study measured usability at a single point in time.
8. **UI/UX refinement.** Address the main SUS concerns, system consistency in Question 6 and complexity in Question 2, through interface redesign.
9. **Formal parsing evaluation.** Evaluate OCR and AI parsing accuracy using standardized test receipts across multiple platforms to establish a reliable baseline.

All nine come from the specific limitations of the current prototype.

---

### Slide 20 — Closing

That concludes our presentation of SmartSpend. We sincerely thank Dr. Mangaoang for her guidance throughout this study, and we thank the panel, Dean Layco, Sir Raposas, and Ma'am Mzana, for your time and expertise today. We now open the floor for the panel's questions and comments.

---

---

## Frequently Asked Panel Questions

> Study these before the defense. Answers are scripted; feel free to shorten them in delivery.

---

### Q1 — Why only 61.83?

"Our SUS score of 61.83 is below the 68-point benchmark and below our pre-established target of 80, which is why Objective 3 is **partially achieved** rather than fully achieved. This is a prototype-stage finding, and it tells us where to improve. The weaker SUS items were system consistency, Question 6, and complexity, Questions 2 and 4. Recommendation 8 addresses these through interface redesign. Respondents also scored high on intent to use the system frequently, at 4.35 out of 5, and on confidence, at 4.19 out of 5."

---

### Q2 — Why not mixed methods? Why is it purely quantitative?

"Our study is **quantitative descriptive developmental**. We used validated structured survey questionnaires for both the needs assessment and the usability evaluation, and no interviews or open-ended data were collected, so there is no qualitative component. The surveys gave us frequencies and percentages for the needs assessment, and SUS scores for usability. The 'developmental' part refers to the design and development of the SmartSpend prototype itself."

---

### Q3 — Why only 30 respondents?

"**Random sampling was used** for our respondents. For a capstone-level developmental study, 30 respondents is a common sample size for identifying patterns in a needs assessment and usability issues in a prototype. We acknowledge that it limits generalizability, because the SUS respondents came from one locale. That is why Recommendation 7 calls for a longitudinal evaluation with a larger sample."

---

### Q4 — What is the Financial Health Score?

"The Financial Health Score is a **prototype indicator** on a 0-to-100 scale. In Full Mode it has four equally weighted components of 25 points: savings rate, overspend control, budget adherence, and logging consistency. Lightweight Mode, for users without income tracking, uses spending restraint, logging consistency, category balance, and habit streak. We adapted ideas from the CBA-MI Observed scale and the Financial Health Network's FinHealth Score. The weights are a design choice, not a statistically derived result, and we formally classify the score as a Prototype Observed Financial Health Indicator, not a validated instrument."

---

### Q5 — Why is the score below 68? What caused it?

"The SUS items point to two areas: system consistency, Question 6, and complexity, Questions 2 and 4. Our study did not collect open-ended feedback, so we cannot say with certainty why. Our interpretation is that SmartSpend is feature-dense, with AI chat, multi-modal input, budgeting, scoring, and badges in one app, and that can create a learning curve. Recommendation 8 targets consistency and complexity directly through interface redesign."

---

### Q6 — What LLM did you use?

"We used **Gemini 3.5 Flash-Lite**. We evaluated **ten candidate models from four providers**: Google, Groq, Cerebras, and Mistral. The criteria were weighted: Filipino-English accuracy 25%, speed 20%, tool use and JSON reliability 20%, free-tier availability 15%, context window 10%, and financial reasoning quality 10%. Gemini 3.5 Flash-Lite offered a one-million-token context window, native function calling for our 34 actions, good Taglish handling in our trials, and a high free-tier request quota. We also built an eight-model failover chain across Google, Groq, and Cerebras."

---

### Q7 — Is the app available on iOS?

"Currently, SmartSpend runs on **Android only**, and our Scope and Limitations state that it was designed exclusively for Android. It was built with Flutter, so an iOS version is technically possible, but iOS support is not one of our nine recommendations and was outside the scope of this study. Our Google Play release, Recommendation 3, is the planned next distribution step."

---

### Q8 — Who validated the instrument?

"Our content validator was **Avigail Candevario, PFMe**, a subject matter expert in financial management and business operations. **Purposive sampling was used** for her selection, because her expertise in personal finance and financial education made her an appropriate validator for a financial management survey. She reviewed the needs-assessment questionnaire for relevance, clarity, and appropriateness. Her validation certificate is in Appendix D."

---

### Q9 — Why is there a 75.0 score in Figure 16?

"Figure 16 is a **sample computation** that shows how the SUS formula works for one illustrative respondent. Each of the 10 items is scored on a 1-to-5 scale. Odd items contribute the response minus 1, even items contribute 5 minus the response, and the sum is multiplied by 2.5, following Brooke (1996). The 75.0 is only the example output. The **61.83 is the actual mean** across all 30 valid respondents."

---

### Q10 — What are your recommendations?

"We have **nine recommendations**:

1. Payday-cycle-aware budgeting, aligned to the 15th-and-30th salary cycle.
2. Backend API proxy and per-user keys, to remove device-side key exposure.
3. Google Play release, after the proxy and a privacy policy are in place.
4. On-device AI tier, an opt-in model of about 2.6 gigabytes for fully offline AI.
5. SQLite encryption using SQLCipher.
6. Household and remittance features: shared wallets and OFW remittance as a distinct income category.
7. Longitudinal evaluation over three to six months with a larger sample.
8. UI/UX refinement, addressing consistency in Q6 and complexity in Q2.
9. Formal parsing evaluation, using standardized test receipts across multiple platforms.

All nine come from the limitations of the current prototype."

---

### Q11 — Why are there 16 parents and 14 young professionals if three respondents identified as both?

"Three of our 30 respondents answered 'Both a parent and a young professional' in Question 2 of the survey. For analysis and reporting, we counted them with the parent group based on their Q1 age bracket, which was 35 to 55. This is stated in the notes to Table 3 and Table 5 and in the Figure 5 footnote. The SUS evaluation was a separate group, where respondents identified their own group on the SUS form, giving 10 parents and 20 young professionals."

*(Before the defense, confirm in your raw data that all three "both" respondents are in the 35–55 age bracket. If not, say so honestly and change this answer.)*

---

### Q12 — Your parsing accuracy looks low for dates. What is the evidence?

"Table 9 reports development-phase observations only. Overall field-level accuracy was 88.2% for amount, 79.9% for description, 70.4% for date, and 83.4% for category. We say plainly that this is not a formal benchmark. Recommendation 9 proposes a formal evaluation using standardized test receipts across multiple platforms."

---

### Q13 — Is your data private? Your primary AI provider is a free tier.

"Yes, we are upfront about this. In Cloud AI mode, mobile numbers, reference numbers, and account patterns are redacted on the device first, and a disclosure appears before the first AI message. But the free Gemini quota's terms say content may be used to improve Google's products, so redaction reduces the exposure but does not remove it. Users with sensitive details can use Private Local Mode, where requests go only to their own PC. The local database is not encrypted, which is Recommendation 5."

---

## End of Script

> **Reminders for delivery:**
> - Always say "partially achieved" for Objective 3.
> - Always say "61.83, below 68 and 80". Never round up or gloss over.
> - Sampling: "random sampling" for respondents, "purposive sampling" for the validator only. Never "stratified".
> - Needs assessment: 16 parents (including 3 "both") + 14 young professionals = 30.
> - SUS evaluation: 10 parents + 20 young professionals = 30 valid of 36 (separate group).
> - Always say "quantitative descriptive developmental". No interviews, so never say "respondents said" or "respondents cited". Say "the SUS items showed".
> - Don't say "proposed" about the app. It is built and tested.
> - "Ten candidate models from four providers" and "eight-model failover chain".
> - Gemini had "a high free-tier quota", not "the highest".
> - Rec 8 = UI/UX refinement, Rec 9 = Formal parsing evaluation.
> - Don't quote stats that are not in the manuscript (requests per day, APK size, screen count, currencies, precision/recall).
