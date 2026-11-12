# SmartSpend Final Defense Script (v3 — 18 slides)

Rebuilt from `SmartSpend_Defense.pptx` (18 slides). Numbers match the FINAL manuscript after fixes applied.
Target time: about 12 minutes plus Q&A.
**Defense date: November 16, 2026**

**Panel:** Mr. Shekiro R. Raposas, MTS, MIS (Capstone Teacher-in-Charge); Chairperson: Dean Jeoffrey B. Layco, MIS; Ms. Mary-Ann Mzana, MTS
**Adviser:** Dr. Ellen Flores Mangaoang, DIT

---

## Say / don't say
- Say "source-available" for the repo. Never "open source."
- Say "designed with the Data Privacy Act in mind." Never "compliant."
- Say "the local database is not encrypted yet." Never "AES-256."
- Say "SUS 61.83, below our target and below the 68 average." Never call it acceptable.
- Say "partially achieved" for Objective 3.
- Say "stated intention," not "will use."
- Say "preliminary developer testing" for 91.2% / 88.5%.
- Say "Grade D on the Sauro and Lewis scale"; the "OK" adjective is from Bangor.
- Never read bracketed notes aloud. Never guess a number: say "that is in our appendix, let me check."

## Golden rules
1. **Own the weak points first.** Lead with SUS 61.83 below target, preliminary parsing accuracy, and unencrypted database before the panel asks.
2. **Three things per figure or table.** What it shows, what it means, what it cannot show.
3. **Objective 1 and 2 "achieved," Objective 3 "partially achieved."** Do not change this under pressure, even if the panel tries to push you to call Objective 3 a failure or a success.
4. **If they ask something outside the evidence,** say so and name the recommendation that addresses it.

---

## Slide 1: Title
"Good morning, respected members of the panel, Dean Layco, and guests. We are Brix Directo, Cyrille John Rubis, and Djaunathan Albert Madayag. We present SmartSpend, an AI-assisted mobile financial tracking and advisory application for personal financial management, developed under our adviser, Ma'am Ellen Mangaoang."

## Slide 2: Money is managed without a system
"The 2021 BSP Financial Inclusion Survey found that only 2% of Filipino adults answered all six basic financial literacy questions correctly, and fewer than half kept any budget. In our own needs assessment of 30 respondents, only 10% used a mobile app to track expenses. The newest BSP survey, CFIS 2025, shows a mixed picture. The share answering at least half of the six questions correctly rose from 69% to 74%, but formal account ownership fell from 56% to 50%."

## Slide 3: The gap exists at three levels
"We framed the gap at three levels. Internationally, manual entry dominates and AI categorization degrades for non-English transactions. Nationally, local apps lack LLM chat, spending-behavior analysis, and health scoring. Among parents and young professionals aged 21 to 35, apps are abandoned because of manual effort, and warnings are ignored because nothing happens when they are. SmartSpend answers with Filipino-English LLM parsing, conversational AI with a Financial Health Score, and automated input with a score-decay consequence."

## Slide 4: What existing apps leave out
"This table comes from our hands-on comparison of the apps in Table 1.2. We acknowledge other Philippine apps, such as Agila, PISO Budget Tracker, Lista, Kibo, BunnyWise, and GCash Pera Coach. We do not claim SmartSpend is the first or only app. Our contribution is an evaluated, integrated prototype that combines offline mode, LLM chat, a health score, OCR, Filipino-English voice, and batch screenshot import. And we are honest about one gap: BudgetPH supports the 15th and 30th payday cycle and we do not. That is Recommendation 6."

## Slide 5: Objectives
"Three objectives guided the study. First, assess the financial practices, budgeting challenges, and expense-tracking behaviors of parents aged 35 to 55 and young professionals aged 21 to 35 in San Fernando City. Second, design and develop SmartSpend, with an LLM API chosen through comparative technical evaluation. Third, evaluate usability and performance using the System Usability Scale and user feedback."

## Slide 6: IPO framework
"Our conceptual framework is Input-Process-Output. Inputs are text, voice, receipt images, barcodes, and user financial data. The process is LLM parsing, OCR, barcode recognition, SQLite storage, and Firebase sync. Outputs are auto-recorded expenses, charts, alerts, insights, the Financial Health Score, and AI question-and-answer."

## Slide 7: Methods
"We used mixed methods with Agile Kanban, using seven columns and work-in-progress limits. The needs assessment used 30 purposive respondents: 13 parents, 14 young professionals, and 3 who identified as both. Two experts validated the work. One validated the survey content and the Financial Health Score formula; both certificates are in Appendices D and E. One reviewed the technical system and the SUS process. For usability, a separate sample took the 10-item SUS after using the app, either the full version or Demo Mode, for at least 10 minutes. Of 36 responses, 30 were valid: 10 parents and 20 young professionals. We excluded 6: 5 for insufficient use time and 1 for straight-line answering."

## Slide 8: Objective 1 results
"For Objective 1, 96.7% of respondents — 29 of 30 — intend to use an AI-powered financial app, and 93.3% already use GCash. Today, 90% track expenses through receipts and 53.3% through mental estimates. Only 10% use a mobile app. This supports automated capture through receipt scanning and screenshot import. The first objective was achieved."
[CONFIRM: add top-challenge counts when the Google Form export is tabulated — see CONFIRM_CHECKLIST A9.]

## Slide 9: SmartSpend v3.1.0 at a glance
"The current build is version 3.1.0, a Flutter Android app of about 47.5 MB. It has 34 autonomous AI actions, 7 input modalities, 40-plus screenshot platforms, a 26-table SQLite database, 45 screens, 36 badges, 9 AI providers — 8 cloud plus a local option — and 57 currencies. Data is offline-first in SQLite with Firebase sync and authentication."
[CONFIRM: verify 45 screens, 57 currencies, 9 providers, 47.5 MB against the codebase — see CONFIRM_CHECKLIST B19.]

## Slide 10: The app in action
[Demo slide. Point to each screen.]
"Login with Demo Mode. The Home dashboard with the health score and our mascot Peso. Taglish chat. Receipt scanning with OCR. And batch screenshot import for GCash and other platforms. These correspond to Figures 3.4 to 3.7 in the manuscript."

## Slide 11: Choosing the AI engine
"We compared 20 candidate models on six weighted criteria: Filipino-English accuracy 25%, inference speed 20%, tool use and JSON reliability 20%, free-tier availability 15%, context window 10%, and financial reasoning 10%. Gemini 3.5 Flash-Lite is the primary model because of its 1-million-token context, native function calling for our 34 actions, strong Taglish in our trials, and a generous free tier. Seven fallback providers across Google, Groq, and Cerebras keep the assistant running if one is down or rate-limited. We use full-context injection, not RAG, because one user's data is only about 1,000 to 5,000 tokens. The chain totals eight cloud providers plus an optional private local model."

## Slide 12: Financial Health Score
"The score runs from 0 to 100. In Full Mode it has four equal components of 25 points: Savings Rate, Overspend Control, Budget Adherence, and Logging Consistency. Lightweight Mode, for users without income tracking, uses Spending Restraint, Logging Consistency, Category Balance, and Habit Streak. Warning Decay takes off up to 15 points, and the Gap Adjustment adds 2 for a no-spend day or subtracts 3 for an unlogged day. The score is clamped from 0 to 100. We call it a Prototype Observed Financial Health Indicator. The weights are a design choice, not a statistically derived result. That is why it is a prototype and not a validated instrument."

## Slide 13: Privacy by design
"There are three AI privacy tiers. First, Cloud AI is the default: mobile numbers, reference numbers, and account patterns are redacted on-device, a limit of 150 requests per user per day applies, and a disclosure is shown before the first AI message. Under Google's free tier, submitted content may be reviewed, so redaction reduces exposure but does not remove it. Second, Private Local Mode sends requests only to a model on the user's own PC, and a Local-only switch blocks cloud fallback. Third, on-device AI is planned, not built. SmartSpend is designed with the Data Privacy Act of 2012 in mind. It is a risk-reduction measure, not a certification of legal compliance."

## Slide 14: Objective 3 results
"The mean SUS score is 61.83, with a standard deviation of 17.58, a median of 55.0, and a range from 35.0 to 92.5, from 30 valid respondents out of 36. This is below the 68 average benchmark (Sauro & Lewis, 2016) and below our pre-set target of 80. It corresponds to an adjective rating of OK (Bangor et al., 2009) and Grade D on the Sauro and Lewis (2016) scale — in the marginal, not acceptable, band. Respondents showed strong intent to use the app often, 4.35 out of 5, and felt confident, 4.19. Their main concerns were consistency (Q6), complexity (Q2), and need for technical support (Q4)."
[CONFIRM: verify SUS numbers against the raw Form export before defending any figure — see CONFIRM_CHECKLIST A1.]

## Slide 15: Limitations
"We acknowledge six limitations. Usability is below target. The app is Android-only, and all AI features need internet. Security is prototype-grade: the API key comes via Remote Config, and the local database is not encrypted. Parsing accuracy of 91.2% precision and 88.5% recall comes from preliminary developer testing only, not a formal test set. The behavioral effect of Peso and the badges is unmeasured. And our sample is 30 purposive respondents from one locale, with only 10 parents in the usability sample, so results are not generalizable."
[CONFIRM: test set size n for the parsing figures — see CONFIRM_CHECKLIST B21.]

## Slide 16: Conclusions
"Objective 1 is achieved: 96.7% stated intention to use an AI finance app, and 93.3% use GCash. Objective 2 is achieved: a working Android app developed as SmartSpend v3.1.0 with 34 AI actions, Gemini 3.5 Flash-Lite with an eight-provider failover chain plus a local option, and the Financial Health Score. On-device AI, a backend proxy, and database encryption remain future work. Objective 3 is partially achieved: usability was evaluated, but the SUS of 61.83 is below the 68 benchmark and our 80 target, rated marginal under our criteria, and we identified UI/UX areas to improve."

## Slide 17: Recommendations
"Eight recommendations are proposed, each tied to a limitation. One, UI/UX refinement — address consistency (Q6), complexity (Q2), and technical support concerns (Q4). Two, formal parsing evaluation — test against at least 50 standardized receipts, replacing the preliminary 91.2% and 88.5% figures. Three, a backend API proxy with server-side keys and per-user limits, removing device-side key exposure. Four, SQLCipher encryption for the local database. Five, an opt-in on-device AI tier of about 2.6 GB for fully offline AI. Six, payday-cycle-aware budgeting aligned to the 15th and 30th salary cycle. Seven, shared household wallets and OFW remittance tracking. Eight, a longitudinal evaluation of three to six months with a larger sample to measure behavior change."

## Slide 18: Closing
"Salamat po. We welcome your questions. The source code is available on GitHub at github.com/Zushikina-kun/smartspend-app under a non-commercial source-available license."

---

# Likely hard questions (top 20 from the 58-question reviewer)

## SUS and Objective 3

**1. 61.83 is a failure, isn't it?**
It is below our target and below the 68 average benchmark, and under our criteria it is marginal, not acceptable. So we say partially achieved: we evaluated usability as planned, did not meet the target, and we identified what to fix in Recommendation 1.

**2. Why set the target at 80?**
Aspirational, set before data collection, not changed afterwards. Per Bangor's anchors, 80 sits between Good (about 71) and Excellent (about 85); we called it an aspirational threshold. We also report 68 as the secondary benchmark (Sauro & Lewis, 2016), and we fall short of that too.

**3. What do Grade D and "OK" mean?**
"OK" is the adjective anchor from Bangor and colleagues (2009). Grade D is from the Sauro and Lewis (2016) curved scale. Both indicate below average. They come from different frameworks and we report both.

**4. Your standard deviation is 17.58. What is the spread telling you?**
Opinions varied widely, from 35.0 to 92.5. Some users found it very usable and some did not. That range supports the need for Recommendation 1 and a larger sample. [CONFIRM stats from the raw Form export — CONFIRM_CHECKLIST A1.]

**5. Show me individual SUS scores.**
Appendix F lists all 30 respondents with raw answers and computed scores. [CONFIRM this appendix is built from the Form export — CONFIRM_CHECKLIST A2.]

**6. Parents scored 58.25 and young professionals 63.62. Is that significant?**
We did not test significance. It is a descriptive gap of 5.37 points with 10 versus 20 respondents, so we do not generalize it. That gap, and the small parent sub-sample, motivate Recommendation 8.

**7. Which items were worst?**
Consistency (Q6), complexity (Q2), and need for technical support (Q4). These feed directly into Recommendation 1.

**8. Did respondents really use it for 10 minutes?**
A screening question confirmed minimum use. Of 36 who attempted the survey, 31 confirmed sufficient use; we excluded 1 for straight-line answering, leaving 30 valid respondents. The other 5 were excluded for insufficient usage time.

**9. Which version did respondents evaluate, and did it include Peso and badges?**
They evaluated v3.1.0. [CONFIRM whether Peso and badges were in that build — see CONFIRM_CHECKLIST A6. Keep the answer consistent with the manuscript.]

**10. Why only SUS? What about task completion or time?**
SUS is a standardized, quick instrument suited to a first prototype evaluation. Task-based testing and a longitudinal study are future work (Recommendation 8).

## Security and privacy

**11. Is it private? You send financial data to Google.**
Mobile numbers, reference numbers, and account patterns are redacted on-device before any cloud call. A disclosure is shown before the first AI message. Under the free Gemini tier, content may be reviewed, so redaction reduces exposure but does not remove it. Private Local Mode with Local-only keeps data on the user's network. We designed with RA 10173 in mind. It is a risk-reduction measure, not a compliance certification.

**12. The API key is in the app.**
Correct. It comes via Remote Config, which a determined attacker could still extract. A backend proxy with server-side keys and per-user limits is Recommendation 3. Until then it is a prototype-grade risk we disclose.

**13. Is the local database encrypted?**
Not yet. SQLCipher is Recommendation 4. We do not claim encryption where there is none.

## System and AI

**14. What does "34 autonomous AI actions" mean? Is it really autonomous?**
It means the model can call 34 defined action types — record, edit, delete, budget, goal, and so on — through JSON function calls. It acts within those defined boundaries, with duplicate checks and an Undo option. It is not open-ended autonomy.

**15. How do you stop the AI from recording wrong data?**
Parsed entries go through duplicate detection; receipts show editable extracted text before sending; batch import shows items for review; and Undo is always available. Accuracy figures are preliminary (see Q16).

**16. 91.2% and 88.5%: where do they come from, and what is n?**
Preliminary developer testing against a small internal set; not a formal evaluation. Table 3.5 marks every modality as not formally measured. [Give n from your records.] Recommendation 2 is a 50-plus standardized receipt evaluation.

**17. What does the Financial Health Score do when no budgets are set?**
[CONFIRM from the code before the defense — see CONFIRM_CHECKLIST B11, B19. Do not guess.]

**18. Explain the Financial Health Score. Why 25 points each? Who validated it?**
Four equal components make the score easy to explain. The weights are a design choice, not statistically derived, so it is a prototype indicator, not a validated instrument. A content validator reviewed the formula (Appendix E). It follows the observed-data approach of the CBA–Melbourne Institute scale and the Spend, Save, Plan ideas of the FinHealth Score.

**19. What happens when Gemini is down?**
The chain falls back through seven providers: Gemini 3.5 Flash, then GPT-OSS 120B on Groq, Qwen 3.6, Qwen 3.8, GPT-OSS 20B, Groq Compound Mini, then GPT-OSS 120B on Cerebras. If Local-only is on, it never falls back to cloud.

**20. Is a free tier sustainable?**
For a prototype and demo, yes. At scale the shared free quota and the 150-per-day cap are limits, which is why we recommend a backend proxy before any Google Play release.

## Methods

**21. Why only 30 respondents? Is that enough?**
It is a purposive sample for a prototype needs assessment, not a representative survey. We state that results are not generalizable, and Recommendation 8 proposes a larger longitudinal study.

**22. What were the top budgeting challenges, in numbers?**
The most prevalent were rising prices, unexpected medical expenses, and family responsibilities. [Add exact counts from the Form export — see CONFIRM_CHECKLIST A9.]

**23. Does 96.7% mean they will use SmartSpend?**
No. It is stated intention to use an AI-powered financial app, from 30 purposive respondents in one locale. It supports the need; it does not predict behavior.

## Chapter IV

**24. Which objectives were achieved?**
Objectives 1 and 2 were achieved; Objective 3 was partially achieved. Objective 1: 96.7% stated intent and 93.3% GCash use confirmed the need. Objective 2: SmartSpend v3.1.0 was developed as a working Android prototype with the specified features. Objective 3: usability was evaluated but the SUS fell below both benchmarks.

**25. Are your recommendations based on your findings?**
Yes. Each maps to a limitation: UI/UX (SUS below target), parsing evaluation (preliminary accuracy), proxy (key exposure), encryption (unencrypted database), on-device AI (internet dependence), payday cycle (feature gap vs BudgetPH), household/remittance (scope), and longitudinal study (sample and behavior).

