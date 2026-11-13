# SmartSpend Final Defense Script (v3)

Matches `SmartSpend_Defense_v3.pptx` (35 slides). Final defense: **November 16, 2026**. Numbers follow the manuscript **after** you apply `1_MANUSCRIPT_FIX_GUIDE.md`. Items marked **[CONFIRM]** need a check in your records first. Italic lines are cues, not spoken.

**Panel:** Mr. Shekiro R. Raposas, MTS, MIS (confirm "Mr." or "Engr."); Chairperson: Dean Jeoffrey B. Layco, MIS; Ms. Mary-Ann Mzana, MTS
**Adviser:** Dr. Ellen Flores Mangaoang, DIT

## Say / don't say
- Say "source-available" for the repo. Never "open source."
- Say "designed with the Data Privacy Act in mind." Never "compliant."
- Say "the local database is not encrypted yet." Never "AES-256."
- Say "SUS 61.83, below our target and below the 68 average." Never call it acceptable. Say "partially achieved" for Objective 3.
- Say "stated intention," not "will use." Say "preliminary developer testing" for 91.2% / 88.5%.
- Say "Grade D on the Sauro and Lewis scale"; the "OK" adjective is from Bangor.
- Never read bracketed notes aloud. Never guess a number: say "that is in our appendix, let me check."

## Speaker plan (edit freely)
| Speaker | Slides | Part | Time |
|---|---|---|---|
| Cyrille | 1–9 | Opening, prayer, video, Chapter I | ~6 min |
| Djaunathan | 10–17 | Chapter II, Objective 1 | ~7 min |
| Brix | 18–28 | Objective 2 and the live demo | ~11 min + demo |
| Cyrille | 29–32 | Objective 3 and limitations | ~5 min |
| Djaunathan | 33–35 | Chapter IV, closing | ~3 min |

Total about 32 minutes plus video and demo. **If you get only 15 minutes:** skip slides 2–4, 11–14, 19, 21, 22, 24–25, 27; say slide 10's numbers in one sentence. Never cut 16–17, 20, 23, 28–32, 33–34: the panel focuses on Chapters III and IV and the app itself.

## Golden rules
1. Say the weak point before the panel does: SUS 61.83 is below target, parsing accuracy is preliminary, the database is not encrypted.
2. For every table or figure, say three things: what it shows, what it means, what it cannot show.
3. Objective 1 and 2 "achieved", Objective 3 "partially achieved". Do not change this under pressure.
4. If they ask something outside the evidence, say so and name the recommendation that fixes it.

---

# Part 1: Slide-by-slide script

## Slide 1: Title *(Cyrille, 30 sec)*
*Stand together, face the panel.*
"Good morning, respected members of the panel, Dean Layco, and guests. We are Brix Directo, Cyrille John Rubis, and Djaunathan Albert Madayag. We present SmartSpend, an AI-assisted mobile financial tracking and advisory application for personal financial management, developed under our adviser, Ma'am Ellen Mangaoang."

## Slide 2: Opening prayer *(Cyrille, 45 sec)*
*Pause; ask everyone to stand.* [Use your own prayer or the school's.]

## Slide 3: Pitch video *(Cyrille)*
*Play the video; do not talk over it.* After: "Thank you. Let us now walk through how we got there."

## Slide 4: Agenda *(Cyrille, 20 sec)*
"Our presentation has four parts: the introduction, our design and methodology, results and discussion, and conclusions and recommendations. We will also run a live demonstration of the app."

## Slide 5: Money is managed without a system *(Cyrille, 45 sec)*
"The 2021 BSP Financial Inclusion Survey found that only 2% of Filipino adults answered all six basic financial literacy questions correctly, and fewer than half kept any budget. In our own needs assessment of 30 respondents, only 10% used a mobile app to track expenses. The newest BSP survey, CFIS 2025, is a mixed picture: the share answering at least half of the questions correctly rose from 69% to 74%, but formal account ownership fell from 56% to 50%."

## Slide 6: The gap exists at three levels *(Cyrille, 45 sec)*
"We framed the gap at three levels. Internationally, manual entry dominates and AI categorization degrades for non-English transactions. Nationally, local apps lack LLM chat, spending-behavior analysis, and health scoring. Among parents and young professionals, apps are abandoned because of manual effort, and warnings are ignored because nothing happens when they are. SmartSpend answers with Filipino-English LLM parsing, conversational AI with a Financial Health Score, and automated input with a score-decay consequence."

## Slide 7: What existing apps leave out *(Cyrille, 45 sec)*
*Point to the SmartSpend column, then to the bottom row.*
"This table comes from our hands-on comparison of the apps in Table 1.2. We acknowledge other Philippine apps such as Agila, PISO Budget Tracker, Lista, Kibo, BunnyWise, and GCash Pera Coach. We do not claim SmartSpend is the first or only app. Our contribution is an evaluated, integrated prototype that combines offline mode, LLM chat, a health score, OCR, Filipino-English voice, and batch screenshot import. And we are honest about a gap: BudgetPH supports the 15th and 30th payday cycle and we do not. That is our Recommendation 6."

## Slide 8: Objectives *(Cyrille, 40 sec)*
"Three objectives guided the study. First, assess the financial practices, budgeting challenges, and expense-tracking behaviors of parents aged 35 to 55 and young professionals aged 21 to 35 in San Fernando City. Second, design and develop SmartSpend, with an LLM API chosen through comparative technical evaluation. Third, evaluate usability and performance using the System Usability Scale and user feedback."

## Slide 9: Input-Process-Output *(Cyrille, 40 sec)*
*Trace left to right with your hand.*
"Our conceptual framework is Input-Process-Output. Inputs are text, voice, receipt images, barcodes, and user financial data. The process is LLM parsing, OCR, barcode recognition, data structuring, SQLite storage, and Firebase sync. Outputs are auto-recorded expenses, charts, alerts, insights, the Financial Health Score, and AI question-and-answer. The loop at the bottom means continued use feeds new inputs."
*Hand over to Djaunathan: "Djaunathan will explain how we studied this."*

## Slide 10: Methods, who took part *(Djaunathan, 60 sec)*
"We used mixed methods. The needs assessment had 30 purposive respondents: 13 parents, 14 young professionals, and 3 who identified as both. For usability, a separate sample took the 10-item SUS after using the app, either the full version or Demo Mode, for at least 10 minutes. Of 36 responses, 30 were valid: 10 parents and 20 young professionals. We excluded 6: 5 for insufficient use time and 1 for straight-line answering. Two experts validated the work: one the survey content, one the technical system and SUS process. The two samples are separate, although some individuals may appear in both."
*If asked about the 3 "both": they belong only to the needs-assessment sample.*

## Slide 11: Instruments and procedure *(Djaunathan, 45 sec)*
"The needs-assessment questionnaire has 13 items in five sections: profile, practices, challenges, tracking behaviors, and feature needs. It was content-validated before distribution. The SUS is Brooke's 10-item scale, answered online after at least 10 minutes of use, with a screening question for the minimum time. The procedure ran in six steps: validate, obtain consent, distribute, benchmark the LLMs, use the app and answer the SUS, then tabulate and analyze."

## Slide 12: How the SUS was scored and judged *(Djaunathan, 60 sec)*
"For each odd item we subtract 1 from the rating; for each even item we subtract the rating from 5. We add the ten contributions and multiply by 2.5, giving 0 to 100. The study score is the mean of valid respondents. We judged it against four references. Our own target was 80, set before data collection as an aspirational standard. The average benchmark is 68, from Sauro and Lewis. The adjective anchors from Bangor and colleagues put OK near 51, Good near 71, and Excellent near 85. And their acceptability bands call below 51 not acceptable, 51 to 70 marginal, and 71 and above acceptable."

## Slide 13: Ethics and data privacy *(Djaunathan, 40 sec)*
"Respondents gave informed consent, participated voluntarily, and were free to withdraw. Results are reported in group form and used for academic purposes only. We told respondents not to enter account numbers or passwords. Inside the app, mobile numbers, reference numbers, and account patterns are redacted on-device before any cloud AI call. We designed with the Data Privacy Act of 2012 in mind. That is a risk-reduction measure, not a compliance certification."

## Slide 14: Agile Kanban *(Djaunathan, 40 sec)*
"We used Agile Kanban with seven columns and work-in-progress limits: Backlog, Requirements, Design, Development, Testing, Deployment, and Done or Review. Each column has key tasks and a deliverable, shown here. We chose Kanban because AI, OCR, voice, and cloud sync had to be integrated and refined continuously, so work could overlap and repeat instead of following a fixed sequence."

## Slide 15: Chapter III divider *(Djaunathan, 15 sec)*
"Chapter III presents the results for our three objectives."

## Slide 16: Objective 1, tracking behaviors *(Djaunathan, 75 sec)*
*Point to the longest bars, then to the 7.7 and 14.3 at the bottom.*
"For Objective 1, 29 of 30 respondents, 96.7%, intend to use an AI-powered financial app, and 93.3% already use GCash. This chart shows how each group tracks expenses today. Receipts lead in both groups: 84.6% of parents and 92.9% of young professionals. Mental estimates come next, 61.5% and 50.0%. Only 7.7% of parents and 14.3% of young professionals use a mobile app, 10% overall. So tracking is manual, and the app option is almost unused. What this cannot show is behavior: 96.7% is stated intention, from 30 purposive respondents in one locale."
*Prepare: be ready for "what were the top challenges, in numbers?" See Q&A and fix A9 of the guide.*

## Slide 17: Objective 1, findings shaped the design *(Djaunathan, 60 sec)*
"Each finding maps to a feature. Ninety percent track with receipts, so we built OCR scanning with a review screen. GCash use at 93.3% led to batch screenshot import and GCash text parsing. The 53.3% who rely on mental estimates, and the 10% who use an app, led to natural-language logging in Taglish, like 'nag-lunch ako 150 pesos'. And 96.7% intent supported a conversational assistant with 34 actions and a health score. The most prevalent challenges were rising prices, unexpected medical expenses, and family responsibilities. The first objective was achieved."
*Hand over to Brix: "Brix will show you what we built."*

## Slide 18: How SmartSpend processes an input *(Brix, 70 sec)*
*Trace the flowchart from the top.*
"This is Figure 3.1. Any input, whether voice, text, a receipt photo, or a GCash screenshot, is first redacted on the device: mobile, reference, and account numbers are masked before anything leaves the phone. Then routing. In Private Local Mode, requests go to a model on the user's own PC, and the Local-only switch blocks cloud fallback. Otherwise the cloud chain runs, Gemini 3.5 Flash-Lite first, and the next provider if one is down. The model returns one of 34 action types as a JSON function call. Duplicates are skipped and reported. Entries are saved in SQLite on the device, synced to Firestore for signed-in users, and feed the health score and Peso's advice."
*[CONFIRM the Fig 3.1 label fix from guide B12; if not fixed, say "the diagram simplifies the routing".]*

## Slide 19: System design views *(Brix, 30 sec)*
"Figure 3.2 is the use case: the user logs expenses, imports screenshots, chats with Peso, sets budgets and goals, and views analytics and the health score. The system calculates the score, sends notifications, and syncs. Figure 3.3 shows navigation: login, or try demo, then Home, which leads to Expenses, Budget, Savings, Analytics, AI Chat, Achievements, and Settings."

## Slide 20: Choosing the AI engine *(Brix, 75 sec)*
"We compared 20 candidate models on six weighted criteria: Filipino-English accuracy 25%, speed 20%, tool use and JSON reliability 20%, free-tier availability 15%, context window 10%, and financial reasoning 10%. Gemini 3.5 Flash-Lite is the primary model because of its 1-million-token context, native function calling for our 34 actions, strong Taglish in our trials, and a generous free tier. Seven fallback providers across Google and Groq, plus Cerebras last, keep the assistant running if one is down or rate-limited. We inject the user's full data into each request rather than using RAG, because one user's data is only about 1,000 to 5,000 tokens."

## Slide 21: LLM comparison *(Brix, 45 sec)*
"This is an excerpt of Table 3.2, which lists all 20 candidates. Some rows say 'Not measured' for Filipino accuracy: those models were outside our own benchmark run, and we say so rather than invent a score. Models like GPT-4o Mini and Claude Haiku were capable but had no free tier. DeepSeek V3 was weaker on Filipino. LLaMA 3.3 was retired by Groq. We report measured values per criterion; we did not compute a single weighted total per model. The free-tier quotas are third-party figures from September 2026 and change often."

## Slide 22: Financial Health Score *(Brix, 70 sec)*
"The score runs from 0 to 100. In Full Mode it has four components of 25 points: Savings Rate against a 20% target, Overspend Control, Budget Adherence, and Logging Consistency. Overspend Control separates habitual overspending, which counts fully, from one-off purchases, which count half. Lightweight Mode, for users without income tracking, uses Spending Restraint, Logging Consistency, Category Balance, and Habit Streak. Warning Decay takes off up to 15 points, the Gap Adjustment adds 2 for a no-spend day or subtracts 3 for an unlogged day, and the score is clamped to 0 to 100. We call it a Prototype Observed Financial Health Indicator. It follows the transaction-data approach of the CBA–Melbourne Institute scale and the Spend, Save, Plan ideas of the FinHealth Score. The weights are a design choice, not a statistically derived result, so it is a prototype and not a validated instrument."

## Slide 23: The score is explainable *(Brix, 60 sec)*
*Point to each row as you read.*
"Here is a real score breakdown from Demo Mode, Figure 3.8. Spending exceeds income, so Savings Rate is 0 of 25. Three of eight logged days exceeded the daily budget, two habitual and one one-off: 25 times one minus two and a half over eight is about 17. All nine budgets are on track: 25. Eight of nine days logged: about 22. Total: 64. The four components add up to the displayed score, so the formulas on the previous slide are what the app actually runs."
*Note: Fig 3.5 shows 96 in a different Demo Mode state; if asked, say the screens were captured at different times.*

## Slide 24: The app in action *(Brix, 45 sec)*
"These are the main screens. Login with Demo Mode, which uses sample data and needs no account. Home with the health score and our mascot Peso. A Taglish chat where 'nag-lunch ako 150 pesos' is recorded automatically. Receipt scanning, where the extracted text can be edited before sending. And batch screenshot import for GCash and other platforms: here, 8 images were processed into 26 items for review. These are Figures 3.4 to 3.7."

## Slide 25: Explainable score, budgets, private AI *(Brix, 40 sec)*
"Three more screens. The score breakdown shows each component's points and a focus area, so users see why the score moved. Budgets warns when total budgets exceed income, here 13,600 pesos of budgets against 6,600 of income. And Private Local Mode lets a user connect their own PC or Mac as the AI model, with a Local-only switch that blocks cloud fallback."

## Slide 26: Privacy by design *(Brix, 60 sec)*
"There are three AI privacy tiers. First, Cloud AI is the default. Mobile numbers, reference numbers, and account patterns are redacted on-device, a limit of 150 requests per user per day applies, and a disclosure is shown before the first AI message. Under Google's free tier, submitted content may be reviewed, so redaction reduces exposure but does not remove it. Second, Private Local Mode sends requests only to a model on the user's own PC, and Local-only blocks cloud fallback. Third, on-device AI is planned, not built. SmartSpend is designed with the Data Privacy Act in mind. It is a risk-reduction measure, not a certification of legal compliance. And the local database is not encrypted yet; that is Recommendation 4."

## Slide 27: v3.1.0 at a glance *(Brix, 40 sec)*
"The current build is version 3.1.0, a Flutter Android app of about 47.5 megabytes. It has 34 autonomous AI actions, 7 input modalities, 40-plus screenshot platforms, a 26-table SQLite database, 45 screens, 36 badges, 9 AI providers, 8 cloud plus a local option, and 57 currencies. Data is offline-first in SQLite with Firebase sync and authentication. Objective 2 is achieved: a working Android app, Gemini 3.5 Flash-Lite with failover, and the Financial Health Score."
*[CONFIRM each number against the code and the manuscript paragraph from guide B19.]*

## Slide 28: Live demonstration *(Brix, 4–5 min)*
*Follow the seven steps on the slide. Narrate what you tap and why.*
"We will now demonstrate SmartSpend on an Android phone." Steps: Try Demo; Home and the score ring; type "nag-lunch ako 150 pesos"; scan a receipt; batch import; open the score breakdown; Settings, Local AI, Local-only switch.
*Before the defense: test venue Wi-Fi, keep a screen recording as backup, charge the phone, turn on Do Not Disturb, and do not use a screen with real personal data.*
After: "Thank you. Cyrille will present the usability results."

## Slide 29: Objective 3, usability scored 61.83 *(Cyrille, 70 sec)*
"For Objective 3, the mean SUS score is 61.83, with a standard deviation of 17.58, a median of 55.0, and a range of 35.0 to 92.5, from 30 valid respondents out of 36. Parents averaged 58.25 and young professionals 63.62. That is an adjective rating of OK and Grade D on the Sauro and Lewis scale. It is below the 68 average benchmark and below our pre-set target of 80. Respondents showed strong intent to use the app often, 4.35 out of 5, and felt confident, 4.19."
*[CONFIRM all SUS numbers against the raw export (guide A1) before the defense.]*

## Slide 30: Reading the score honestly *(Cyrille, 60 sec)*
*Point to the red marker on the scale.*
"On the scale, 61.83 sits in the marginal band, between the OK and Good anchors, left of the 68 average and well left of our target of 80. We did not lower the target after seeing the result. Under our own criteria it is not acceptable, which is why Objective 3 is partially achieved: we did evaluate usability as planned, but the target was not met, and performance was assessed only preliminarily."

## Slide 31: What the results tell us *(Cyrille, 60 sec)*
"Strengths: intent to use often and confidence are high. Concerns: consistency, Question 6, complexity, Question 2, and needing technical support, Question 4. With 45 screens and 34 AI actions, the interface can feel heavy. Parents scored 5.37 points lower than young professionals; this is descriptive only, with 10 versus 20 respondents and no significance test. On technical performance, 91.2% precision and 88.5% recall come from preliminary developer testing, and Table 3.5 marks every modality as not formally measured. These findings feed Recommendations 1 and 2."

## Slide 32: Limitations *(Cyrille, 60 sec)*
"We acknowledge six limitations, each linked to a recommendation. Usability is below target: Recommendation 1. The app is Android-only and all AI features need internet: Recommendation 5. Security is prototype-grade, the API key arrives via Remote Config and the local database is not encrypted: Recommendations 3 and 4. Parsing accuracy is from developer testing, not a formal test set: Recommendation 2. The effect of Peso and the badges on behavior is unmeasured, and our sample is 30 purposive respondents from one locale, with only 10 parents in the usability sample, so results are not generalizable: Recommendation 8."
*Hand over: "Djaunathan will close with conclusions and recommendations."*

## Slide 33: Conclusions *(Djaunathan, 50 sec)*
"Objective 1 is achieved: 96.7% intent to use an AI finance app and 93.3% use GCash. Objective 2 is achieved: a working Android app with 34 AI actions, Gemini 3.5 Flash-Lite with failover, and the Financial Health Score. Objective 3 is partially achieved: usability was evaluated, but the SUS of 61.83 is below target, and we identified UI/UX areas to improve."

## Slide 34: Recommendations *(Djaunathan, 70 sec)*
"We recommend eight steps, each tied to a limitation. One, UI/UX refinement for the consistency and complexity concerns. Two, a formal parsing evaluation with at least 50 standardized receipts. Three, a backend API proxy with server-side keys and per-user limits, and only then a Google Play release. Four, SQLCipher encryption for the local database. Five, an opt-in on-device AI tier of about 2.6 gigabytes for fully offline AI. Six, payday-cycle-aware budgeting aligned to the 15th and 30th. Seven, shared household wallets and OFW remittance tracking. Eight, a longitudinal evaluation of three to six months with a larger sample, to measure behavior change."

## Slide 35: Closing *(Djaunathan, 20 sec)*
"Salamat po. We welcome your questions. The source code is available at github.com/Zushikina-kun/smartspend-app under a non-commercial source-available license."

---

# Part 2: Top Q&A (full reviewer is in `3_DEFENSE_REVIEWER.md`)

**Why is the SUS only 61.83, and is Objective 3 a failure?**
We evaluated usability as planned, so we call it partially achieved. The score is marginal: below the 68 average and our target of 80. The weak points are consistency, complexity, and need for technical support, and Recommendation 1 targets them. The sample is small.

**Why did you set the target at 80? Why not 68?**
It was set before data collection as an aspirational standard, and we did not change it after seeing results. We also report 68 as a secondary benchmark. Against either, we fall short, and we say so.

**Your target group is parents, but 20 of 30 SUS respondents are young professionals.**
That is a limitation. Parents scored lower, 58.25, than young professionals, 63.62. A larger parent sample is part of Recommendation 8.

**Where do 91.2% and 88.5% come from?**
Preliminary developer testing against a small internal test set, not a formal evaluation. Table 3.5 marks every modality as not formally measured. Recommendation 2 is a 50-plus standardized receipt evaluation. [CONFIRM the test size n.]

**Is the data private?**
Mobile numbers, reference numbers, and account patterns are redacted before cloud AI calls. Firestore sync is scoped to the user's UID. Under the free Gemini tier, content may be reviewed. Private Local Mode with Local-only keeps data on the user's own network. The local database is not encrypted yet.

**Is the Financial Health Score valid?**
It is a prototype indicator. It borrows the observed-data approach of the CBA–Melbourne Institute scale and Spend, Save, Plan ideas from the FinHealth Score. The weights are a design choice and it is not validated against a survey scale. That is future work.

**Does Peso or gamification change behavior?**
Not measured. We did not isolate their effect. [Use the version answer from guide A6: was Peso in the evaluated build?]

**The API key is in the client.**
Correct. It is delivered through Remote Config, which a determined attacker could still extract. The backend proxy is Recommendation 3.

**Did the SUS group see the same version you demo today?**
They used v3.1.0. [CONFIRM and align with guide A6.] Anything added later is outside the evaluation.

**Is a free tier sustainable?**
For a prototype and demo, yes. At scale the shared free quota and the 150-per-day cap are limits, which is why we recommend a backend proxy.

**What were the biggest budgeting challenges in your needs assessment?**
Rising prices, unexpected medical expenses, and family responsibilities were the most prevalent. [Add the counts from the Form export once guide A9 is done.]

---

# Part 3: Fix or check before the defense
- Apply `1_MANUSCRIPT_FIX_GUIDE.md` A1 to A9 first. If the raw SUS data changes any number, update slides 29–31 and 33, and this script.
- Confirm the evaluated build and whether Peso and the badges were in it (guide A6).
- Confirm "Mr." or "Engr." for Raposas.
- Confirm slide 27 numbers (45 screens, 57 currencies, 9 providers, 47.5 MB) in the code.
- Bring: printed manuscript, the raw Google Form exports, a charged phone with a screen recording, a charger, and a backup of the deck as PDF.
- Practice the demo three times on venue-like Wi-Fi, and once with Wi-Fi off to see what the app shows.
