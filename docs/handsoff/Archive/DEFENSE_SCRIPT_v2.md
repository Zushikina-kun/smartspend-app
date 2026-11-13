# SmartSpend Final Defense Script (v2)

Rebuilt from `SmartSpend_Defense.pptx` (18 slides). Numbers match the manuscript. Target time: about 12 minutes plus Q&A.

**Panel:** Shekiro R. Raposas, Mary-Ann Mzana, Chairperson [CONFIRM name]
**Adviser:** Ellen F. Mangaoang, DIT

**Say / don't say**
- Say "source-available" for the repo. Never "open source."
- Say "designed with the Data Privacy Act in mind." Never "compliant."
- Say "the local database is not encrypted yet." Never "AES-256."
- Say "SUS 61.83, below our target." Don't call it acceptable.
- Never read bracketed notes aloud.

---

## Slide 1: Title
"Good morning, respected members of the panel, Dean Layco, and guests. We are Brix Directo, Cyrille John Rubis, and Djaunathan Albert Madayag. We present SmartSpend, an AI-assisted mobile financial tracking and advisory application for personal financial management, developed under our adviser, Ma'am Ellen Mangaoang."

## Slide 2: Money is managed without a system
"The 2021 BSP Financial Inclusion Survey found that only 2% of Filipino adults answered all six basic financial literacy questions correctly, and fewer than half kept any budget. In our own needs assessment of 30 respondents, only 10% used a mobile app to track expenses. The newest BSP survey, CFIS 2025, shows a mixed picture. The share answering at least half of the six questions correctly rose from 69% to 74%, but formal account ownership fell from 56% to 50%."

## Slide 3: The gap exists at three levels
"We framed the gap at three levels. Internationally, manual entry dominates and AI categorization degrades for non-English transactions. Nationally, local apps lack LLM chat, spending-behavior analysis, and health scoring. Among parents and young professionals, apps are abandoned because of manual effort, and warnings are ignored because nothing happens when they are. SmartSpend answers with Filipino-English LLM parsing, conversational AI with a Financial Health Score, and automated input with a score-decay consequence."

## Slide 4: What existing apps leave out
"This table comes from our hands-on comparison of the apps in Table 1.2. We acknowledge other Philippine apps, such as Agila, PISO Budget Tracker, Lista, Kibo, BunnyWise, and GCash Pera Coach. We do not claim SmartSpend is the first or only app. Our contribution is an evaluated, integrated prototype that combines offline mode, LLM chat, a health score, OCR, Filipino-English voice, and batch screenshot import."

## Slide 5: Objectives
"Three objectives guided the study. First, assess the financial practices, budgeting challenges, and expense-tracking behaviors of parents aged 35 to 55 and young professionals aged 21 to 35 in San Fernando City. Second, design and develop SmartSpend, with an LLM API chosen through comparative technical evaluation. Third, evaluate usability and performance using the System Usability Scale and user feedback."

## Slide 6: IPO framework
"Our conceptual framework is Input-Process-Output. Inputs are text, voice, receipt images, barcodes, and user financial data. The process is LLM parsing, OCR, barcode recognition, SQLite storage, and Firebase sync. Outputs are auto-recorded expenses, charts, alerts, insights, the Financial Health Score, and AI question-and-answer."

## Slide 7: Methods
"We used mixed methods with Agile Kanban, using seven columns and work-in-progress limits. The needs assessment used 30 purposive respondents: 13 parents, 14 young professionals, and 3 who identified as both. Two experts validated the work. One validated the survey content. One reviewed the technical system and the SUS process. For usability, a separate sample took the 10-item SUS after using the app, either the full version or Demo Mode, for at least 10 minutes. Of 36 responses, 30 were valid: 10 parents and 20 young professionals."

## Slide 8: Objective 1 results
"For Objective 1, 96.7% of respondents, 29 of 30, intend to use an AI-powered financial app, and 93.3% already use GCash. Today, 90% track expenses through receipts and 53.3% through mental estimates. Only 10% use a mobile app. This supports automated capture through receipt scanning and screenshot import. The first objective was achieved."

## Slide 9: SmartSpend v3.1.0 at a glance
"The current build is version 3.1.0, a Flutter Android app of about 47.5 MB. It has 34 autonomous AI actions, 7 input modalities, 40-plus screenshot platforms, a 26-table SQLite database, 45 screens, 36 badges, 9 AI providers (8 cloud plus a local option), and 57 currencies. Data is offline-first in SQLite with Firebase sync and authentication."

## Slide 10: The app in action
[Demo slide. Point to each screen.] "Login with Demo Mode. The Home dashboard with the health score. Taglish chat with our mascot, Peso. Receipt scanning with OCR. And batch screenshot import for GCash and other platforms. These correspond to Figures 3.4 to 3.7 in the manuscript."

## Slide 11: Choosing the AI engine
"We compared 20 candidate models on six weighted criteria. Filipino-English accuracy was 25%, speed 20%, tool use and JSON reliability 20%, free-tier availability 15%, context window 10%, and financial reasoning 10%. Gemini 3.5 Flash-Lite is the primary model because of its 1-million-token context, native function calling for our 34 actions, strong Taglish in our trials, and a generous free tier. Seven fallback providers across Google, Groq, and Cerebras keep the assistant running if one is down or rate-limited. We use full-context injection, not RAG, because one user's data is only about 1,000 to 5,000 tokens."

## Slide 12: Financial Health Score
"The score runs from 0 to 100. In Full Mode it has four equal components of 25 points: Savings Rate, Overspend Control, Budget Adherence, and Logging Consistency. Lightweight Mode, for users without income tracking, uses Spending Restraint, Logging Consistency, Category Balance, and Habit Streak. Warning Decay takes off up to 15 points, and the Gap Adjustment adds 2 for a no-spend day or subtracts 3 for an unlogged day. The score is clamped from 0 to 100. We call it a Prototype Observed Financial Health Indicator. It follows the transaction-data approach of the CBA–Melbourne Institute 'Observed' scale, with Spend, Save, and Plan ideas from the FinHealth Score. The weights are a design choice, not a statistically derived result. That is why it is a prototype and not a validated instrument."

## Slide 13: Privacy by design
"There are three AI privacy tiers. First, Cloud AI is the default. Mobile numbers, reference numbers, and account patterns are redacted on-device, a request limit of 150 per user per day applies, and a disclosure is shown before the first AI message. Under Google's free tier, submitted content may be reviewed, so redaction reduces exposure but does not remove it. Second, Private Local Mode sends requests only to a model on the user's own PC, and a Local-only switch blocks cloud fallback. Third, on-device AI is planned, not built. SmartSpend is designed with the Data Privacy Act of 2012 in mind. It is a risk-reduction measure, not a certification of legal compliance."

## Slide 14: Objective 3 results
"The mean SUS score is 61.83, with a standard deviation of 17.58, a median of 55, and a range from 35 to 92.5, from 30 valid respondents out of 36. This is below the 68 average benchmark and below our pre-set target of 80. It sits between the OK and Good anchors, in the marginal range, a grade of D. Respondents showed strong intent to use the app often, 4.35 out of 5, and felt confident, 4.19. Their main concerns were consistency, Question 6, and complexity, Questions 2 and 4."

## Slide 15: Limitations
"We acknowledge six limitations. Usability is below target. The app is Android-only, and all AI features need internet. Security is prototype-grade: the API key comes via Remote Config, and the local database is not encrypted. Parsing accuracy of 91.2% precision and 88.5% recall comes from preliminary developer testing, not a formal test set. Peso and the badges were added after the evaluation was designed, so their behavioral effect is unmeasured. And our sample is 30 purposive respondents from one locale, with only 10 parents in the usability sample, so results are not generalizable."

## Slide 16: Conclusions
"Objective 1 is achieved: 96.7% intent to use an AI finance app, and 93.3% use GCash. Objective 2 is achieved: a working Android app with 34 AI actions, Gemini 3.5 Flash-Lite with failover, and the Financial Health Score. Objective 3 is partially achieved: usability was evaluated, but the SUS of 61.83 is below target, and we identified UI/UX areas to improve."

## Slide 17: Recommendations
"We recommend seven steps. One, payday-cycle budgeting aligned to the 15th and 30th. Two, a backend API proxy with server-side keys and per-user limits, followed by a Google Play release once a privacy policy is in place. Three, an opt-in on-device AI tier, about 2.6 GB. Four, SQLCipher encryption for the local database. Five, UI/UX refinement for consistency and complexity. Six, a formal parsing evaluation with 50 or more standardized receipts. Seven, a longitudinal study of 3 to 6 months with a larger sample to measure behavior change."

## Slide 18: Closing
"Salamat po. We welcome your questions. The source code is available on GitHub at github.com/Zushikina-kun/smartspend-app under a non-commercial source-available license."

---

# Likely hard questions (short answers)

1. **Why is SUS only 61.83, and is Objective 3 a failure?** We evaluated usability as planned, so we call it partially achieved. The score is marginal, below the 68 average and our 80 target. The weak points are consistency and complexity, and Recommendation 5 targets them. Our sample is small.
2. **Why did you set the target at 80?** It was set in advance as an aspirational standard. We did not change it after seeing the results. We also report the 68 average as a secondary benchmark.
3. **Your target group is parents, but 20 of 30 SUS respondents are young professionals.** That is a limitation. Parents scored lower (58.25) than young professionals (63.62). A larger parent sample is part of the longitudinal recommendation.
4. **Where do 91.2% and 88.5% come from?** [CONFIRM N and method.] They are preliminary developer testing, not a formal evaluation. Table 3.5 marks every modality as not formally measured.
5. **Is the data private?** Mobile numbers, reference numbers, and account patterns are redacted before cloud AI calls. Firestore sync is scoped to the user's UID. Under the free Gemini tier, content may be reviewed. Private Local Mode with Local-only keeps data on the user's network. The local database is not encrypted yet.
6. **Is the FHS valid?** It is a prototype indicator. It borrows the observed-data approach of CBA–Melbourne Institute and Spend/Save/Plan ideas from the FinHealth Score. The weights are a design choice. It is not validated against a survey scale. That is future work.
7. **Is a free tier sustainable?** For a prototype and demo, yes. At scale, the shared free quota and the 150-per-day cap are a limit. That is why we recommend a backend proxy.
8. **Does Peso or gamification change behavior?** Not measured. They were added after the evaluation was designed.
9. **The API key is in the client.** Correct. It is delivered through Remote Config, which a determined attacker could still extract. The proxy is Recommendation 2.
10. **Did the SUS group see the same version?** [CONFIRM the build tested, and say so.]
