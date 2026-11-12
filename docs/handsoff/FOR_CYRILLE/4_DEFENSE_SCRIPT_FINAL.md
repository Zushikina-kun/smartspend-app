# SmartSpend Defense Script
**Defense Date:** Monday, November 16, 2026 — 3:00 PM  
**Panel:**  
- Chairperson: Dean Jeoffrey B. Layco, MIS  
- Member: Mr. Shekiro R. Raposas, MTS, MIS  
- Member: Ms. Mary-Ann Mzana, MTS  
**Adviser:** Dr. Ellen Flores Mangaoang, DIT  
**Validator:** Avigail Candevario, PFMe  
**Estimated speaking time:** ~15 minutes  

---

## SAY / DON'T SAY — Quick Reference

> Read this before you go in.

| ✅ SAY | ❌ DON'T SAY |
|--------|-------------|
| "quantitative descriptive developmental" | "mixed methods" |
| "random sampling was used" (for respondents) | "interviews were conducted" |
| "purposive sampling was used" (for content validator) | "proposed" (the app exists) |
| "16 parents and 14 young professionals" (needs assessment, 30 total) | "13 parents" (old count) |
| "10 parents and 20 young professionals" (SUS sample, 30 total, separate) | — |
| "partially achieved" for Objective 3 — always | "fully achieved" for Objective 3 |
| "61.83, below the 68 benchmark and the 80 target" | "passed the SUS threshold" |
| "Grade D, adjective OK" | "failed the usability test" |

---

## Slide-by-Slide Speaking Notes

---

### Slide 1 — Title

Good afternoon, Dean Layco, Sir Raposas, Ma'am Mzana, and Dr. Mangaoang. We are Cyrille John Rubis, Brix Directo, and Djaunathan Madayag, from the College of Computer Studies and Engineering here at LORMA Colleges. Our study is entitled *SmartSpend: An AI-Assisted Mobile Financial Tracking and Advisory Application for Personal Financial Management*, under the guidance of our adviser, Dr. Ellen Flores Mangaoang, DIT. We are grateful for this opportunity and we hope you find our work worthy of your consideration.

---

### Slide 2 — Opening Prayer

Before we begin, we would like to invite everyone to bow their heads as we offer a short opening prayer.

*(Deliver or lead the prayer here.)*

---

### Slide 3 — Problem

The Philippines continues to face a serious financial literacy challenge. According to the 2021 BSP Financial Inclusion Survey, only 2% of Filipino adults correctly answered all six basic financial literacy questions, and fewer than 50% reported keeping any household or personal budget. These numbers point to a real, documented gap — not just an assumption. In our own needs assessment of 30 respondents, only 10% reported that they already used a mobile app for budgeting. That means the vast majority of our target population — parents and young professionals — had no digital tool supporting their financial management. This is the problem SmartSpend was designed to address.

---

### Slide 4 — Gap Analysis

The gap we identified operates at three levels. At the international level, manual entry dominates most financial apps, and AI categorization breaks down when users input transactions in Filipino or Taglish — common in our target population. At the national level, existing Philippine apps lack conversational AI, spending behavior analysis, and financial health scoring. At the demographic level, parents specifically tend to abandon apps because of the effort required for manual entry, and existing warning systems have no consequence mechanism to reinforce behavior change. SmartSpend directly addresses each of these three gaps, as shown in Table 2 of our manuscript.

---

### Slide 5 — Feature Comparison (Table 2)

Table 2 compares SmartSpend against the most comparable existing applications — Tarsi, YNAB, Monarch, Copilot, BudgetPH, and Alkansya AI. We acknowledge other Philippine apps like Agila, PISO Budget Tracker, Lista, Kibo, BunnyWise, and GCash Pera Coach as related work. What the comparison shows is that no existing evaluated app combines offline mode, LLM chat, a Financial Health Score, OCR receipt scanning, Filipino-English AI, and batch screenshot import in one integrated prototype. SmartSpend does not claim to be the first or only app — it is an evaluated integrated prototype that fills specific gaps that our needs assessment confirmed.

---

### Slide 6 — Objectives

Three objectives guided this study. First, to assess the existing financial management practices, common budgeting challenges, and expense tracking behaviors of parents aged 35 to 55 and young professionals aged 21 to 35 in San Fernando City, La Union, through structured surveys. Second, to design and develop the SmartSpend mobile application with the integration of a suitable Large Language Model API. Third, to determine the usability of the SmartSpend application using the System Usability Scale. These three objectives map directly to our three chapters of results.

---

### Slide 7 — Conceptual Framework (IPO)

Our study used an Input-Process-Output framework. The inputs are user-provided financial data — text, voice, receipt images, barcodes, and transaction history. The process layer includes LLM parsing, OCR text recognition, barcode scanning, local SQLite storage, and Firebase cloud synchronization. The outputs are automatically recorded expenses, charts, budget alerts, financial insights, the Financial Health Score, and the AI question-and-answer assistant. This framework organized both the development of SmartSpend and the presentation of our results.

---

### Slide 8 — Research Design and Methodology

This study employed a **quantitative descriptive developmental research design**. The developmental component refers to the design and development of SmartSpend as a functional software prototype. The quantitative descriptive component refers to the use of validated structured survey instruments to assess needs and evaluate usability — no interviews were conducted. **Random sampling was used** for the needs assessment, which involved 30 respondents: 16 parents and 14 young professionals. **Random sampling was also used** for the SUS evaluation, which involved a separate group of 30 respondents: 10 parents and 20 young professionals. **Purposive sampling was used** for the content validator — Avigail Candevario, PFMe — a subject matter expert in personal financial management, whose expertise made her the appropriate choice to validate our survey instrument.

---

### Slide 9 — Objective 1 Results: Needs Assessment

Objective 1 asked us to assess the financial management practices of our target population, and the results validated the need for SmartSpend. Among the 30 respondents, **96.7% — that is, 29 of 30 — expressed positive intent to use an AI-powered financial application**. **93.3%, or 28 of 30, reported they already used GCash**, confirming that our target population is comfortable with mobile financial tools and validating our GCash-linked feature priorities. Only 10%, or 3 out of 30, already used a dedicated mobile app for budgeting — confirming the market gap. The most common tracking method was physical receipts at 90%, followed by mental estimates at 53.3%. These findings directly informed the features we built into SmartSpend and confirm that Objective 1 was **achieved**.

---

### Slide 10 — System Overview

SmartSpend version 3.1.0 is a working Android application built with Flutter for the UI and SQLite for local offline-first storage. At a glance: it has **34 autonomous AI actions**, **7 input modalities**, **26 SQLite tables**, **45 screens**, and **36 achievement badges**. The app supports 40-plus batch screenshot import platforms, 9 AI providers with failover, and 57 currencies. The APK is approximately 47.5 megabytes. It runs fully offline, syncing to Firebase when connectivity is available. The Financial Health Score is formally classified as a Prototype Observed Financial Health Indicator — a design choice, not a statistically validated instrument.

---

### Slide 11 — App Screenshots

Let me walk through five key screens. The Login and Demo Mode screen allows users to explore SmartSpend with pre-loaded Filipino sample data before committing to an account — this addresses the engagement barrier we identified in the needs assessment. The Home Dashboard gives an at-a-glance financial picture. The Expense Logging through Peso Chat shows natural-language input — users type or speak in Tagalog or English and the AI parses the transaction. Receipt Scanning supports both single-item and multi-item receipts via OCR. Finally, the Financial Health Score Breakdown shows users their composite score across four components, giving them a concrete number to work toward. Each of these screens maps back to a specific need identified in our survey.

---

### Slide 12 — LLM Selection

Selecting the right Large Language Model was a critical design decision. We evaluated 20 candidate models across six providers — assessing inference speed, response accuracy for Filipino-English natural language processing, context window capacity, and cost feasibility for a free-tier prototype. We selected **Gemini 3.5 Flash-Lite** because it offered a one-million-token context window, native function calling for all 34 AI actions, strong Taglish performance in our trials, and the highest free-tier request quota. The selection was systematic and comparative — not arbitrary.

---

### Slide 13 — Financial Health Score

The Financial Health Score is a prototype composite indicator on a 0-to-100 scale. It has four components: savings rate, overspend control, budget adherence, and logging consistency. Internally, the full computation uses eight sub-components, but we present four to users for clarity. We want to be transparent with the panel: this score is a **design choice** — it synthesizes financial behavior into a single motivating number. It has not been statistically validated as a measurement instrument, and we explicitly flag it as a prototype indicator and as a recommendation for future validation. It is a tool for user engagement, not a clinical financial assessment.

---

### Slide 14 — Privacy Tiers

SmartSpend implements **two current privacy tiers**. Tier 1 is Cloud AI mode — Gemini processes natural language requests, with on-device redaction of mobile numbers, reference numbers, and account patterns before data leaves the device. Users are limited to 150 AI requests per day, and a disclosure is shown before the first AI message. Tier 2 is Private Local Mode — the app routes all requests to a user-specified local server such as Ollama or LM Studio, with no cloud fallback. A third tier — **on-device AI processing running directly on the phone** — is a **recommendation for future work and is not yet implemented**. Most devices in our target population lack the RAM required to run a 2.6-gigabyte model, which is why we present it as Recommendation 4 rather than a current feature.

---

### Slide 15 — SUS Results (Objective 3)

The System Usability Scale was administered to **30 respondents** — 10 parents and 20 young professionals — as a separate group from the needs assessment. The mean SUS score is **61.83**, with a standard deviation of **17.58**, a median of **55.0**, and a range of **35.0 to 92.5**. Under the Bangor, Kortum, and Miller (2009) adjective scale, this corresponds to a **Grade D** with an adjective rating of **"OK"**. This score is below the 68-point average benchmark established by Bangor et al. and below our pre-established target of 80. For this reason, Objective 3 is **partially achieved** — usability was evaluated and the score provides actionable feedback, but the target was not met. This is not a failure of the study; it is an honest finding that drives our recommendations.

---

### Slide 16 — Limitations

We acknowledge several limitations of this study. The SUS score of 61.83 is below both the 68 benchmark and the 80 target — the specific UI/UX concerns raised by respondents inform Recommendation 1. The app currently runs on Android only. All AI features require an internet connection in Cloud AI mode. Security is at prototype level — the API key is managed via Firebase Remote Config rather than a true server-side proxy, and the local database is not encrypted; both are addressed in our recommendations. OCR and voice precision are based on developer testing at 91.2% and 88.5% respectively, not an independent audit. The gamification elements — Peso the mascot and the badge system — were added after the evaluation instrument was designed, so they were not reflected in the SUS items. And the sample of 30 respondents from one locale limits generalizability.

---

### Slide 17 — Conclusions

Three conclusions follow directly from our results.

**Objective 1 — Achieved.** The needs assessment successfully identified the financial management practices, budgeting challenges, and expense tracking behaviors of parents and young professionals. 96.7% of respondents expressed intent to use an AI-powered financial app, and 93.3% already used GCash, confirming the target population and feature priorities.

**Objective 2 — Achieved.** SmartSpend version 3.1.0 was successfully designed and developed as a working Android application, with 34 AI actions, 7 input modalities, offline-first SQLite storage, and a suitable LLM API selected through comparative technical evaluation of 20 candidates.

**Objective 3 — Partially achieved.** Usability was evaluated using the System Usability Scale with 30 valid respondents. The mean score of 61.83 falls below the 68-point benchmark and our 80 target. The app demonstrates promise as a prototype, but UI/UX improvements are needed before it reaches the target usability threshold.

---

### Slide 18 — Recommendations

In view of these results, we make the following nine recommendations for future development:

1. **Payday-cycle-aware budgeting.** Implement budgeting resets aligned with the semi-monthly 15th-and-30th salary cycle common in the Philippines to better match the financial rhythm of our target users.

2. **Backend API proxy and per-user keys.** Move LLM API key management to a server-side proxy — such as a Firebase Cloud Function — to remove device-side key exposure and enforce per-user message limits.

3. **Google Play release.** After the backend proxy and a privacy policy are in place, submit SmartSpend to the Google Play Store. The prototype is currently distributed as a downloadable APK.

4. **On-device AI tier.** Add an opt-in on-device model — for example, Gemma 4 E2B through Google's LiteRT-LM, approximately a 2.6-gigabyte download — for users who want fully offline AI without any network dependency.

5. **SQLite encryption.** Implement SQLCipher-based encryption for the local database in a future schema migration, since the current prototype database is not encrypted.

6. **Household and remittance features.** Add shared couple and family wallets and inbound OFW remittance tracking as a distinct income category to serve a broader range of Filipino household structures.

7. **Longitudinal evaluation.** Conduct a follow-up study measuring SmartSpend's effect on actual financial behavior over three to six months with a larger sample. The current evaluation measured usability at a single point in time and cannot establish behavioral impact.
8. **UI/UX refinement.** The SUS results flagged two specific items — Q6 on consistency and Q2 on unnecessary complexity — as the lowest-scoring areas. Future iterations should address these through targeted redesign and re-test with a new cohort.
9. **Formal parsing evaluation.** Develop a standardized benchmark of 50 or more receipt images covering different store formats and test OCR and AI parsing precision and recall systematically, rather than relying solely on overall usability ratings.

All nine are grounded in the specific limitations of the current prototype that our study revealed.

---

### Slide 19 — Closing

That concludes our presentation of SmartSpend. We sincerely thank Dr. Mangaoang for her guidance throughout this study, and we thank the panel — Dean Layco, Sir Raposas, and Ma'am Mzana — for your time and expertise today. We now open the floor for the panel's questions and comments.

---

---

## Frequently Asked Panel Questions

> Study these before the defense. Answers are scripted — feel free to shorten them in delivery.

---

### Q1 — Why only 61.83?

"Our SUS score of 61.83 falls below the 68-point benchmark established by Bangor, Kortum, and Miller and below our pre-established target of 80, which is precisely why Objective 3 is **partially achieved** rather than fully achieved. This is a prototype-stage finding — it tells us exactly where to improve. Specifically, respondents cited interface complexity and navigation consistency as concerns, which is directly addressed by **Recommendation 1**, which calls for a UI/UX redesign with simplified navigation and improved onboarding for first-time users."

---

### Q2 — Why quantitative and not mixed methods?

"Our study is **purely quantitative descriptive developmental**. We used validated structured survey questionnaires for both the needs assessment and the usability evaluation — no interviews were conducted, so there is no qualitative component. The surveys captured all the data we needed: frequency distributions of financial behaviors for the needs assessment, and SUS scores for usability evaluation. The 'developmental' component refers to the design and development of the SmartSpend prototype itself."

---

### Q3 — Why only 30 respondents?

"**Random sampling was used** for both samples. For a capstone-level developmental study, 30 respondents is an appropriate sample size to identify patterns, establish demographic profiles, and generate usability insights — consistent with published SUS evaluation practice. Our sample was also stratified across two demographics: parents aged 35 to 55, and young professionals aged 21 to 35. We acknowledge that this sample size limits generalizability, which is why **Recommendation 7** explicitly calls for a longitudinal evaluation with a larger sample."

---

### Q4 — What is the Financial Health Score?

"The Financial Health Score is a **prototype composite indicator** with four components — savings rate, overspend control, budget adherence, and logging consistency — combined on a 0-to-100 scale. It is a **design choice** to give users a quick, motivating wellness snapshot. It has **not been statistically validated** as a psychometric instrument, and we are transparent about that in the manuscript — we formally classify it as a Prototype Observed Financial Health Indicator. **Recommendation** in our study flags it for future validation using a larger sample and a more rigorous measurement framework."

---

### Q5 — Why is the score below 68? What caused it?

"Respondents specifically cited two concern areas in the SUS items: interface consistency — Question 6 — and perceived complexity — Questions 2 and 4. SmartSpend is feature-dense by design, because the needs assessment showed users needed AI chat, receipt scanning, budget tracking, health scoring, and gamification in one app. That density created a learning curve that the current onboarding flow does not fully resolve. **Recommendation 1** directly addresses this: a UI/UX redesign focused on simplified navigation and a more guided onboarding experience for new users."

---

### Q6 — What LLM did you use?

"We used **Gemini 3.5 Flash-Lite**. We evaluated 20 candidate models across six providers — including models from OpenAI, Anthropic, Groq, Mistral, and Google — and selected Gemini 3.5 Flash-Lite based on four criteria: response quality for Filipino-English input, inference latency on mobile, cost feasibility for a free-tier prototype, and context window capacity. It offered a one-million-token context window, native function calling for our 34 AI actions, and the highest free-tier request quota of all evaluated providers."

---

### Q7 — Is the app available on iOS?

"Currently, SmartSpend runs on **Android only**. It was built with Flutter, which supports both platforms, so an iOS port is technically feasible without a full rebuild. However, iOS support requires additional work including Apple Developer Program enrollment and App Store review compliance. It is implicitly covered under **Recommendation 3** — the Google Play release — as a next step after the backend proxy and privacy policy are in place."

---

### Q8 — Who validated the instrument?

"Our content validator was **Avigail Candevario, PFMe** — a subject matter expert in personal financial management, holding the Personal Finance Management Expert designation. **Purposive sampling was used** for her selection, because her specific expertise in personal finance made her the appropriate validator for a financial management survey instrument. She reviewed the needs-assessment questionnaire for content validity, ensuring the items accurately reflected the financial management concepts we were measuring."

---

### Q9 — Why is there a 75.0 score in Figure 16?

"Figure 16 in the manuscript shows a **sample computation** to illustrate how the SUS scoring formula works for a single hypothetical respondent. The 10 SUS items are scored on a 1-to-5 scale, the odd-item and even-item scores are summed according to Brooke's (1996) formula, and the result is multiplied by 2.5 to convert to a 0-to-100 scale. The 75.0 in that figure is just the example output for one illustrative case. The **61.83 is the actual mean** across all 30 valid respondents' individual scores."

---

### Q10 — What are your recommendations?

"We have **nine recommendations** for future development:

1. Payday-cycle-aware budgeting — resets aligned to the Philippine semi-monthly 15th-and-30th salary cycle.
2. Backend API proxy and per-user keys — move LLM key management server-side to remove device-side exposure.
3. Google Play release — after the proxy and privacy policy are in place.
4. On-device AI tier — an opt-in approximately 2.6-gigabyte model for users who want fully offline AI.
5. SQLite encryption — SQLCipher for the local database in a future schema migration.
6. Household and remittance features — shared wallets and OFW remittance as a distinct income category.
7. **Longitudinal evaluation.** Conduct a follow-up study measuring SmartSpend's effect on actual financial behavior over three to six months with a larger sample. The current evaluation measured usability at a single point in time and cannot establish behavioral impact.
8. **UI/UX refinement.** The SUS results flagged two specific items — Q6 on consistency and Q2 on unnecessary complexity — as the lowest-scoring areas. Future iterations should address these through targeted redesign and re-test with a new cohort.
9. **Formal parsing evaluation.** Develop a standardized benchmark of 50 or more receipt images covering different store formats and test OCR and AI parsing precision and recall systematically, rather than relying solely on overall usability ratings.

All nine are grounded in the specific limitations of the current prototype that our study revealed."

---

## End of Script

> **Reminders for delivery:**
> - Always say "partially achieved" for Objective 3.
> - Always cite "61.83, below 68 and 80" — never round up or gloss over.
> - If asked about sampling, say "random sampling" for respondents, "purposive sampling" for the validator.
> - The needs assessment had 16 parents + 14 young professionals = 30.
> - The SUS evaluation had 10 parents + 20 young professionals = 30 (separate group).
> - Don't say "mixed methods" — the study is purely quantitative.
> - Don't say "proposed" — SmartSpend is built and tested.
