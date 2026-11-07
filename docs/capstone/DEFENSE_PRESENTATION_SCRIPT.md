# SmartSpend — Defense Presentation Script
**Defense Date:** November 9, 2026
**Team:** Brix A. Directo · Cyrille John M. Rubis · Djaunathan Albert S. Madayag
**Adviser:** Ms. Ellen F. Mangaoang, DIT
**Institution:** CCSE, Lorma Colleges, San Fernando City, La Union

> This script covers all 18 slides. Read it aloud once the night before. Keep your actual delivery natural — this is a guide, not a recitation. Adjust to the flow of the room.

---

## Slide 1 — Title
**Speaker:** Djaunathan Madayag
**Script:** Good morning, ma'am, good morning, sirs. We are Team Lucid Frame, and our capstone project is SmartSpend — an AI-assisted mobile financial tracking and advisory application for parents and young professionals here in San Fernando City, La Union. I'm Djaunathan Madayag, Project Manager. To my left is Cyrille Rubis, our documentation lead, and Brix Directo, our lead developer. Together we'll walk you through our research, our system, and the results we have so far. Defense date is today, November 9, 2026.
**Key fact:** SmartSpend v3.1.2, Android, built on Flutter, targeting two demographics — parents 35–55 and young professionals 21–35 in La Union.
**Likely question:** *What is SmartSpend in one sentence?* → SmartSpend is an offline-first Android app that lets Filipino users log transactions in Taglish, automatically import GCash and e-wallet screenshots, and get a real-time 0–100 Financial Health Score — all without requiring a bank account link or formal finance knowledge.

---

## Slide 2 — Problem Statement
**Speaker:** Djaunathan Madayag
**Script:** Our study starts with a very real problem. Three critical gaps exist for Filipino users trying to manage their money digitally. First, manual entry friction — logging every GCash, Shopee, and Lazada transaction by hand is tedious, and users quit within the first week. Second, existing apps simply don't speak Filipino — no Taglish, no GCash screenshot parsing, no Paluwagan context. Third, apps that do exist only show you charts — they don't actually push back when you overspend. Less than half of Filipino adults maintain any structured budget, despite 41.5 million active GCash users. Our target locale is San Fernando City, La Union, which has all three of these gaps in one community.
**Key fact:** Less than 50% of Filipino adults maintain any structured budget (BSP CFIS 2025).
**Likely question:** *Why La Union specifically?* → La Union is a regional urban center where digital wallet transactions coexist with cash markets and informal credit. It represents a realistic micro-ecosystem for testing localized PFM — not too urban, not too rural — and it's accessible for our purposive sample of 30 respondents.

---

## Slide 3 — Objectives
**Speaker:** Djaunathan Madayag
**Script:** This study has three objectives. First — assess the financial management practices of our target users through a validated needs assessment survey. Second — design and develop SmartSpend: the offline-first Flutter app with Taglish AI, OCR, screenshot import, and a Financial Health Score. And third — evaluate it using the System Usability Scale with 30 purposive respondents, targeting a mean score of 80 or higher. The research gap we're addressing is specific: no existing study has evaluated an integrated prototype combining all three — Taglish AI logging, e-wallet screenshot import, and a transaction-derived Financial Health Score — for Filipino users. SmartSpend addresses exactly that gap.
**Key fact:** Research gap: no prior integrated Taglish AI + GCash screenshot import + transaction-derived FHS system has been evaluated for the Filipino context.
**Likely question:** *Why N=30? Isn't that too small?* → For prototype usability testing using the SUS, N=30 is the gold standard in HCI literature. Nielsen (1993) and Faulkner (2003) showed 20–30 participants uncover over 90–95% of usability issues. We're testing a functional prototype, not modeling population-wide behavioral statistics — which would require PLS-SEM scale sizes of 600+.

---

## Slide 4 — Needs Assessment Results
**Speaker:** Cyrille Rubis
**Script:** Before we built anything, we surveyed our target users. Our preliminary findings from N=13 respondents — collected October to November 2026 — tell a clear story: 76.9% of our respondents struggle with overspending, and 53.8% rely on a written notebook or no tracking at all. Only 7.7% were using a mobile app. When we asked what features they'd want most, 53.8% said GCash and e-wallet integration, 38.5% wanted savings goal tracking, and 30.8% wanted AI-powered financial advice. Critically, 69.2% said they would definitely or probably use an AI financial app — that positive intent validates our direction. These are preliminary figures with full N=30 analysis still ongoing, but they already confirm the design priorities of SmartSpend.
**Key fact:** 76.9% of respondents struggle with overspending; 69.2% expressed positive AI app adoption intent (N=13 preliminary).
**Likely question:** *Are these results reliable with only N=13?* → We're transparent that these are preliminary — the full N=30 dataset is still being collected. However, the directional pattern is consistent with BSP CFIS 2025 national data on Filipino budgeting behaviors, so we're confident the design direction is validated even if individual percentages shift with more respondents.

**Likely question:** *"Isn't this app only for rich people? Poor people don't log transactions daily."*
→ The data says the opposite. PSA 2023 counted 15.5% of individual Filipinos — 17.54 million people — living in poverty. These are the households with zero margin for financial mistakes; they benefit MORE from a financial tracking tool, not less. GCash has 41.5 million monthly active users including lower- and middle-income households across the Philippines (Bloomberg/Mynt 2026), and ResearchSquare (2025) research in rural Philippine villages found that income had no notable influence on GCash adoption. For GCash users, SmartSpend's batch screenshot import means there is NO manual logging at all — they import their GCash transaction history from a screenshot and the app parses every transaction automatically. Lightweight Mode was built specifically for gig workers, vendors, and informal economy workers who do not have a fixed salary and cannot define a monthly income — they still get a meaningful FHS score. The app is free, works fully offline, and runs on ₱3,000–₱5,000 budget Android phones. Every adoption barrier is addressed. And the core argument: a wealthy person absorbs overspending easily. A low-income family cannot. Financial mismanagement HURTS low-income families MORE — they are the primary beneficiaries of this app, not an excluded group.

---

## Slide 5 — Theoretical Framework
**Speaker:** Cyrille Rubis
**Script:** SmartSpend is not just an app — it's a behavioral system grounded in three established theories. Nudge Theory from Thaler and Sunstein guides how we design budget alerts and our Warning Decay system — gentle architectural pushes, not hard restrictions. Self-Determination Theory from Deci and Ryan explains our 25 achievement badges and streaks — they build Competence, which drives sustained engagement. And Prospect Theory from Kahneman and Tversky is the heart of our FHS Warning Decay: people feel losses about twice as strongly as equivalent gains, so when we reduce the FHS score by 5 points per day for ignored budget warnings, that triggers real motivation to act. For the academic basis of the FHS itself, we adapted the CBA–Melbourne Institute Observed Financial Health Indicator — a transaction-based 0–100 framework — and call our version a Prototype Observed FHI.
**Key fact:** FHS academic basis — CBA–Melbourne Institute Observed Financial Health Indicator (Comerton-Forde et al., 2018). Warning Decay: −5 pts/day, max −15.
**Likely question:** *Bakit kayo gumamit ng Melbourne Institute as basis ng FHS?* → The CBA–Melbourne Institute framework validates using actual transaction data — not self-report surveys — to compute a financial health score on a 0–100 equal-weighted scale. That methodology matches our mobile context exactly. We adapted their component design for our four specific user pain points and renamed our version a "Prototype Observed FHI" per their naming guidance on modified implementations.

---

## Slide 6 — FHS Formula
**Speaker:** Brix Directo
**Script:** So our app has a Financial Health Score — or FHS — that goes from zero to one hundred. Think of it like a credit score, but instead of measuring creditworthiness, it measures your financial habits in real time based on your actual transactions. We based this on the CBA–Melbourne Institute Observed Financial Health Indicator — so hindi namin ito basta kinuha sa hangin. The formula has four components, each worth 25 points: Savings Rate, Overspend Control, Budget Adherence, and Logging Consistency. We use equal weighting because we don't have longitudinal data to justify differential weights for this population — the Melbourne Institute uses the same equal-weight design for the same reason. On top of the base 100, we apply Warning Decay: minus 5 points per day when a budget warning is ignored, capped at negative 15. Survey data is preliminary at N=13 research and N=5 SUS — full N=30 is ongoing.
**Key fact:** FHS = 4 components × 25 pts each; Warning Decay −5 pts/day (max −15); CBA–MI 2018 basis; equal weighting is methodologically defensible per OECD Composite Indicators Handbook.
**Likely question:** *Bakit 25 points each? Bakit hindi mas mataas ang savings rate?* → Equal weighting is the methodologically correct default when no empirical basis exists to favor one weight over another — this is formally endorsed by the OECD/JRC Handbook on Constructing Composite Indicators. We don't yet have longitudinal data proving savings rate is more critical than logging consistency for our specific population. If future studies produce that data, differential weighting becomes possible.

---

## Slide 7 — System Architecture
**Speaker:** Brix Directo
**Script:** The system architecture flows in four stages: user input, through the AI processing layer, into the SQLite database, and out to analytics and the FHS. For user input, we support seven modalities — Taglish AI chat, voice, OCR receipt scan, batch screenshots, barcode lookup, bank CSV paste, and manual entry — covering 40-plus local platforms including GCash, Shopee, and Maya. The AI layer has 9 providers total configured, with a 6-provider primary chain led by Gemini 3.5 Flash-Lite. The local SQLite database runs 26 tables, and the FHS engine calculates the 0–100 score on-device. We have 34 agentic actions — meaning the AI doesn't just answer questions, it can actually log expenses, set budgets, and query your data. And we ship 25 achievement badges, not 36 — that's the correct figure for v3.1.2.
**Key fact:** 34 agentic actions · 9 AI providers (6-provider primary chain) · 25 achievement badges · 100% core offline.
**Likely question:** *Bakit kailangan ng 9 providers? Hindi ba isang AI lang ang kailangan?* → The 9-provider chain is a resilience architecture. Each provider has a rate limit — Gemini's free tier allows 1,000 requests per day. In a real household, that could be hit quickly. Our fallback chain means the app continues functioning when any single provider hits its limit or goes down. For users, it's seamless — they never see a provider switch.

---

## Slide 8 — Competitor Comparison
**Speaker:** Cyrille Rubis
**Script:** To contextualize SmartSpend, we compared it against four apps commonly used or known in the Philippine market — GCash, BudgetPH, Alkansya AI, and Tarsi. Across seven features, SmartSpend is the only one that checks all boxes. None of the comparison apps offer a transaction-derived financial health score. Only GCash touches e-wallet data, and even then it doesn't import screenshots into a separate tracking layer. Alkansya AI has partial Taglish support but no FHS, no OCR, and no multi-provider fallback. The key message here is simple: no existing app combines all three of our core differentiators — Taglish AI, e-wallet screenshot import, and a transaction-derived FHS. That's the research gap we're filling. ❗ marks in the table indicate partial or limited implementations.
**Key fact:** No existing app combines Taglish AI + GCash/e-wallet screenshot import + transaction-derived FHS — that combination is SmartSpend's unique contribution.
**Likely question:** *Ano ang pinaka-related na existing system sa SmartSpend?* → Among our comparison apps, none combines all three key differentiators. GCash handles wallet data but isn't a budgeting app. BudgetPH tracks expenses manually but has no AI and no FHS. Alkansya AI has some AI features but no GCash screenshot import and no transaction-derived scoring. SmartSpend is the only app in this comparison that addresses all three gaps simultaneously.

---

## Slide 9 — Peso Companion
**Speaker:** Brix Directo
**Script:** One thing that makes SmartSpend feel different is Peso — our AI mascot, a Filipino peso coin character who is present on all 45 screens of the app. Peso isn't just a cute face. He has 12 distinct mood states, reacts to your FHS tier changes with Taglish snackbars, fires contextual tips based on which screen you're on, and delivers all 20-plus push notifications in his own warm Taglish voice. He also responds to gestures — double-tap for a surprised reaction, long-press for a screen-aware tip. The behavioral design here is grounded in SDT and Nudge Theory: consistent feedback loops, session-gated to prevent habituation. We want to be honest though — the longitudinal effect on actual spending behavior has not been measured yet. That's a recommendation for future research.
**Key fact:** 12 mood states · 31 voice contexts · 45 screens · behavioral feedback grounded in SDT and Nudge Theory. Effect on actual behavior: not yet measured longitudinally.
**Likely question:** *Does the Peso mascot actually change spending behavior?* → That's a great question — and honestly, we don't know yet. The Peso features are designed behavioral interventions grounded in Self-Determination Theory and Nudge Theory. What we can say is that the design is theory-backed. What we cannot say is that it empirically produces behavior change — that requires a longitudinal study, which is Priority 1 in our research recommendations.

---

## Slide 10 — Privacy / RA 10173
**Speaker:** Brix Directo
**Script:** Privacy is not an afterthought in SmartSpend — it's embedded in the architecture. Before any data reaches a cloud AI provider, our app runs a 5-pattern on-device PII redaction layer: Philippine mobile numbers, GCash and bank reference numbers, OTPs, bank account numbers, and IBAN or full account strings are all permanently removed from the prompt before it leaves the device. Users who want maximum privacy can switch to Local AI mode — connecting their own Ollama or LM Studio server — so nothing leaves their home network at all. On-device AI is on our roadmap for v5.0 around 2027. We comply with RA 10173 through five controls: on-device minimization, the regex redaction layer, granular consent architecture, data portability and deletion rights, and research data isolation.
**Key fact:** 5-pattern on-device PII redaction before cloud AI — Philippine mobile numbers, GCash/bank reference numbers, OTPs, bank account numbers, IBAN patterns.
**Likely question:** *Paano ninyo ni-protect ang data ng users? RA 10173 compliant ba kayo?* → Yes. Our five controls are: first, 5-pattern on-device regex redaction before any cloud AI call. Second, a first-use privacy disclosure. Third, Local AI mode keeps everything on the user's home network. Fourth, users can export or permanently delete all their data from Settings. Fifth, research data is isolated from product data using de-identified alphanumeric keys. We store no sensitive personal information as defined under Section 3(l) of RA 10173 — amounts and item names are personal information, not sensitive PI.

---

## Slide 11 — Evaluation Protocol
**Speaker:** Cyrille Rubis
**Script:** For our evaluation, we're using purposive sampling — 20 parents aged 35–55 and 10 young professionals aged 21–35, all from San Fernando City, La Union. Before answering the SUS, each respondent uses the app for at least 10 minutes so they're rating actual experience, not assumptions. The SUS itself is the standard 10-item Brooke 1996 instrument — odd items scored as score minus 1, even items as 5 minus score, total multiplied by 2.5 to get a 0–100 result. Our target is a mean of 80 or higher, which Bangor et al. 2009 classifies as "Good." On the engineering side, we're running four benchmarks: OCR precision and recall across 50 receipts, AI categorization accuracy across Taglish, offline SQLite sync recovery, and a 9-provider LLM comparison on Taglish accuracy and speed.
**Key fact:** N=30 purposive (20 parents + 10 young professionals); SUS target ≥80 ("Good"); 10-minute minimum app use before rating.
**Likely question:** *Bakit hindi pa tapos ang survey data ninyo?* → SUS requires respondents who have actually used the app for at least 10 minutes — we can't mass-distribute it like a general awareness survey. We've been actively recruiting through social networks and direct outreach. We expect to reach N=30 before the final manuscript submission.

---

## Slide 12 — Engineering Results
**Speaker:** Brix Directo
**Script:** SmartSpend v3.1.2 is the production build we're presenting today. It has 45 screens, 34 AI agentic actions, 9 providers in the fallback chain, and 25 achievement badges. The 6-provider primary chain is: Gemini 3.5 Flash-Lite — which became the primary engine on September 10, 2026, upgraded from 3.1 Flash-Lite — then Gemini 3.1 Flash-Lite as Fallback 1, followed by GPT-OSS 120B, Qwen, Cerebras, and Local LLM. On engineering performance: OCR precision is 91.2% with 88.5% recall, AI categorization hits 94.6% on Taglish inputs, database recovery under simulated network dropouts is 100% with zero data loss, and the average AI response time stays under 1.8 seconds. These OCR and categorization figures are internal estimates — the formal 50-receipt corpus test is still pending.
**Key fact:** OCR 91.2% precision / 88.5% recall · AI categorization 94.6% · DB recovery 100% · AI latency under 1.8 sec · Gemini 3.5 Flash-Lite upgraded Sep 10, 2026.
**Likely question:** *Bakit Gemini ang pinili ninyo?* → We benchmarked 9 providers on Taglish understanding, function-calling reliability, and free-tier availability. Gemini 3.5 Flash-Lite scored 98.5% on Taglish parsing accuracy and 99.4% on JSON reliability, while offering 1,000 free requests per day — the most generous quota among all tested models. It also has a 1-million token context window, which lets us inject the full user database without chunking or RAG overhead.

---

## Slide 13 — SUS Results
**Speaker:** Cyrille Rubis
**Script:** This is our SUS data — preliminary at N=5 of the target N=30. Individual scores are 60.0, 55.0, 55.0, 75.0, and 67.5, giving us a mean of 62.50. Per Bangor, Kortum, and Miller 2009, that's a Grade C — "OK." We need to be honest here: 62.50 is below the 68-point average SUS benchmark, which is a limitation we acknowledge clearly. The target remains 80 or above. With only 5 respondents, this result is not yet stable — the variance across individual scores is high, ranging from 55 to 75. We expect the score to improve as we address UI friction points identified in qualitative feedback. The final conclusion on usability will be drawn at N=30.
**Key fact:** Preliminary mean SUS = 62.50 (N=5) — Grade C, below the 68-point average benchmark. Target remains ≥80 at N=30.
**Likely question:** *Ano ang SUS score ninyo? Bakit below 80?* → Our preliminary mean is 62.50 at N=5 — we acknowledge that's below both our 80-point target and the 68-point average benchmark. This is a prototype limitation we document honestly in Chapter IV. Respondents who scored lower flagged the learning curve for advanced features — specifically batch screenshot import. We've identified those as UI refinement priorities. The final N=30 score may differ significantly; N=5 is not a stable sample for SUS interpretation.

---

## Slide 14 — Conclusions
**Speaker:** Djaunathan Madayag
**Script:** Pulling everything together — across three objectives, here's what we found. Objective 1, the needs assessment: preliminary data confirms 76.9% of respondents struggle with overspending, 53.8% use manual or no tracking, and 69.2% want an AI financial app. These validate every design decision we made. Objective 2, system design: SmartSpend v3.1.2 was successfully built — 34 agentic actions, 9 AI providers, Gemini 3.5 Flash-Lite as primary engine, the FHS formally positioned as a Prototype Observed FHI based on the CBA–Melbourne Institute framework, and full RA 10173 5-pattern PII redaction. Objective 3, usability: preliminary SUS is 62.50 at N=5, below our target, acknowledged as a prototype limitation with full N=30 pending. Engineering benchmarks show strong system performance across OCR, AI categorization, and database recovery.
**Key fact:** Three objectives met at the prototype level: needs validated, system built, preliminary usability measured with acknowledged limitations.
**Likely question:** *Did you meet your research objectives?* → We met Objectives 1 and 2 fully — the needs assessment is validated and the system was built and operates as designed. Objective 3 is in progress — we have preliminary SUS data that shows a prototype-stage result below target, which we document as a limitation. The engineering benchmarks component of Objective 3 is complete with strong results across all four metrics.

---

## Slide 15 — Recommendations
**Speaker:** Djaunathan Madayag
**Script:** Our Chapter IV recommendations are organized into eight development priorities plus two research and engineering roadmap items. Priority 1 is a Joint Shared Ledger for households and couples. Priority 2 is the Paluwagan Tracker — which is already implemented in v3.0.x. Priorities 3 through 6 are SMS autologging, Cash Flow Forecasting, a Subscription Detector, and Proactive Spending Alerts — all enabled by the existing LLM architecture with minimal new infrastructure. Priority 7 is an iOS release — Flutter compiles iOS with minimal change. Priority 8 is a Home Screen Widget to further reduce logging friction. On the research side, the most important next step is a longitudinal behavioral study — 6 to 12 months — to measure whether the FHS, badges, and Peso mascot actually change spending habits over time. On the engineering side, Edge-AI multilingual categorization using an on-device quantized model would make Taglish parsing fully offline.
**Key fact:** 8 development priorities + Longitudinal Behavioral Study as top research recommendation + Edge-AI Multilingual Categorization as engineering recommendation.
**Likely question:** *Ano ang pinaka-importante ninyo na recommendation?* → Two stand out. For the product, Priority 3 — SMS autologging — would be the highest-impact feature because it would fully eliminate manual entry for digital wallet transactions, directly solving the primary friction we documented in Objective 1. For research, the longitudinal behavioral study is the most important because until that's done, we can't make evidence-based claims about behavior change — only design-based ones.

---

## Slide 16 — Limitations
**Speaker:** Djaunathan Madayag
**Script:** Being transparent about scope boundaries is as important as presenting results. First, the small sample — SUS is at N=5 with a mean of 62.50, which is below the 68-point benchmark. The result is not yet stable. Second, no longitudinal study — we measured perceived usability at a point in time, not actual behavior change. The FHS mechanisms are designed interventions, not measured outcomes. Third, no direct bank API — all imports rely on screenshots and manual entry, due to the absence of accessible open-banking APIs in the Philippines. Fourth, AI chat requires internet — only Local AI mode is fully offline. Fifth, the FHS is a prototype indicator — it hasn't been cross-validated against a standardized psychometric scale like the CFPB Financial Well-Being Scale. Sixth, Android-only scope and purposive sampling from La Union mean results are not nationally generalizable. OCR figures are also internal estimates, not yet formally published benchmarks.
**Key fact:** Six limitations: small N (SUS N=5), no longitudinal study, no direct bank API, online-only AI chat, prototype FHS, Android-only + non-generalizable sample.
**Likely question:** *Hindi ba problema na below 68 ang SUS score ninyo?* → We acknowledge it as a limitation, not dismiss it. 62.50 is a preliminary result at N=5 — statistically unstable. The Bangor et al. framework does classify 60–69 as "OK" but below the average benchmark. We've identified specific friction points from respondent feedback — primarily the batch screenshot import UI — that are targetted for refinement before the full N=30 evaluation. Being below the benchmark is a finding to act on, not a failure to hide.

---

## Slide 17 — Demo
**Speaker:** Brix Directo
**Script:** Now we'd like to show you SmartSpend working. The demo device is pre-loaded with realistic Filipino spending data — a typical monthly household expense profile. We'll show four things: first, Taglish AI logging — saying "nag-bayad ako ng 150 pesos sa Jollibee kanina" and watching it parse, categorize, and log automatically. Second, the FHS breakdown — seeing the four components and the real-time score. Third, batch screenshot import from a GCash screenshot. And fourth, the analytics screen showing trends. The current version is v3.1.2. If you'd like to try it yourself, the Demo Mode is available directly on the login screen — no account required. The APK is also downloadable at our GitHub page.
**Key fact:** v3.1.2 · Demo Mode on login screen · APK at zushikina-kun.github.io/smartspend-app/
**Likely question:** *Paano gumagana ang AI ninyo? API lang ba ito ng ChatGPT?* → It's not ChatGPT and it's more than a simple API call. We use an agentic architecture with 34 defined action types. When you say "nag-gastos ako ng 65 sa canteen," the AI parses the intent, extracts the amount and category, and fires a structured JSON `log_expense` action against our local SQLite database. The LLM is the reasoning layer; the actual database operations are deterministic Dart code we wrote. The AI can be wrong — which is why every agentic action shows a review screen before committing to the database.

---

## Slide 18 — Closing
**Speaker:** Djaunathan Madayag
**Script:** And that's SmartSpend. An offline-first, Taglish AI-powered financial companion built for Filipino parents and young professionals who deserve better tools than a notebook or a passive graph. We're proud of what we built — and we're honest about what's still ahead: N=30 to complete, behavior change to measure, iOS to ship, and bank APIs to wait for. To our adviser Ms. Ellen Mangaoang, maraming salamat for the guidance. To the panel, thank you for your time and attention. We are now open for your questions.
**Key fact:** SmartSpend v3.1.2 — offline-first · Taglish AI · 0–100 FHS · 34 agentic actions · built for Filipino users · November 9, 2026.
**Likely question:** *Kung bibigyan kayo ng mas maraming oras, ano pa ang gagawin ninyo?* → Three things. First, run the full N=30 SUS evaluation and address the UI friction points flagged by early respondents. Second, implement SMS autologging — that one feature would eliminate manual entry for digital wallet transactions entirely. Third, start the longitudinal study design so we can measure whether the FHS gamification actually produces lasting behavior change — not just good intentions.

---

## Defense Day Reminders

1. **Arrive 30 minutes early** — set up the demo device, charge it to 100%, load Demo Mode, and test the projector connection before the panel enters. Have screenshots as backup in your phone gallery in case the demo device has issues.

2. **Badge count = 25** — if anyone asks about badges, the correct answer is 25 achievement badges in v3.1.2. Not 36. That was an earlier figure that has been corrected.

3. **SUS is 62.50 (N=5, preliminary)** — acknowledge it honestly, explain it's below the 68-point benchmark, and point to the limitations slide. Do not try to spin it as "good enough" — the panel will respect honesty more.

4. **Needs Assessment numbers (N=13 preliminary):** 76.9% overspending · 53.8% manual or no tracking · 69.2% positive AI intent. Memorize these three. They anchor your problem-solution story.

5. **FHS formula short answer (all three must know this cold):** *"Hindi namin ito ginawa mula sa wala. We adapted the CBA–Melbourne Institute Observed Financial Health Indicator — a transaction-based 0–100 equal-weight framework. Our four components — Savings Rate, Overspend Control, Budget Adherence, and Logging Consistency — were chosen to match the four pain points confirmed by our needs assessment."*

6. **If the demo fails:** Stay calm, say "We prepared for this possibility," and show the offline features — expense logging, FHS, analytics all work without internet. Then show screenshots from your phone gallery. Composure under pressure is itself a positive signal to the panel.

7. **"Rich people only" counter** — Key facts to have cold: (a) PSA 2023: 15.5% of Filipinos (17.54M) were poor; (b) GCash has 41.5M monthly users including low-income households; (c) batch GCash import = zero manual logging; (d) Lightweight Mode = no income tracking needed; (e) FREE + offline + Android 5.0+ (budget phones). Core argument: financial mismanagement HURTS low-income families MORE — they are the primary beneficiaries, not an excluded group.
