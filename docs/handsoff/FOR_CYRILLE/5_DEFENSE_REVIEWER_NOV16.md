> Defense: **November 16, 2026**. Numbers match the FINAL manuscript after fixes applied. See CONFIRM_CHECKLIST_NOV16.md for items still needing verification.

# SmartSpend Defense Reviewer (Nov 16, 2026)

How to use: cover the answer, say yours out loud in 2–4 sentences, then compare. **[CONFIRM]** means check your records first. Difficulty: 🟢 likely, 🟡 probable, 🔴 expect a follow-up. Numbers assume `1_MANUSCRIPT_FIX_GUIDE.md` is applied and the raw SUS file confirms them.

---

## 0. Numbers to know cold
| Topic | Number |
|---|---|
| Needs assessment | 30 purposive: 13 parents, 14 young prof., 3 both |
| Intent to use AI finance app | 96.7% (29/30) |
| GCash users | 93.3% (28/30) |
| Tracking: receipts / mental / e-wallet / notes / notebook / app | 90.0 / 53.3 / 43.3 / 30.0 / 23.3 / 10.0 % |
| SUS sample | 36 responses → 30 valid (10 parents, 20 young prof.); 5 excluded for time, 1 straight-lining |
| SUS | mean 61.83, SD 17.58, median 55.0, range 35.0–92.5 |
| By group | parents 58.25 (SD 19.72), young prof. 63.62 (SD 16.65) |
| Benchmarks | 68 average (Sauro & Lewis 2016), target 80 (pre-set), Grade D (Sauro & Lewis), adjective OK (Bangor et al. 2009) |
| Items | Q1 4.35, Q9 4.19; concerns Q6, Q2, Q4 |
| Parsing | 91.2% precision, 88.5% recall (preliminary, developer testing) |
| LLM | 20 candidates, 6 weighted criteria (25/20/20/15/10/10), Gemini 3.5 Flash-Lite + 7 fallbacks = 8 cloud + 1 local |
| App | v3.1.0, 34 actions, 7 modalities, 26 tables, 45 screens, 36 badges, 9 providers, 57 currencies, ~47.5 MB |
| FHS | 4 × 25 pts; decay up to −15; gap +2 / −3; clamp 0–100 |
| Limits | 150 AI requests/user/day |
| Kanban | 7 columns |
| Panel | Raposas, Layco (Chair), Mzana; adviser Mangaoang |
| Defense date | November 16, 2026 |

---

## 1. Chapter III: Objective 1 (needs assessment)

**1. 🟢 Why only 30 respondents? Is that enough?**
It is a purposive sample for a prototype needs assessment, not a representative survey. We state that results are not generalizable, and Recommendation 8 proposes a larger sample.

**2. 🟡 Your target is parents 35–55, yet you had 13 parents and 14 young professionals. Why?**
Both groups were the defined targets (parents primary, young professionals secondary). We acknowledge parents are under-represented in the usability sample (10 of 30), which is a limitation.

**3. 🔴 What do the 3 "both" respondents mean for your tables?**
They are part of the 30 in the needs assessment and are shown as their own group in Table 3.1. They are not part of the SUS sample, which is separate. The dagger footnote in Table 3.1 explains the 10+20 SUS reclassification.

**4. 🔴 What were the top budgeting challenges, in numbers?**
The most prevalent were rising prices, unexpected medical expenses, and family responsibilities. [CONFIRM: add exact counts and percentages from the Form export — see CONFIRM_CHECKLIST A9.]

**5. 🟡 Does 96.7% mean they will use SmartSpend?**
No. It is stated intention to use an AI-powered financial app, from 30 purposive respondents. It supports the need; it does not predict behavior.

**6. 🟢 Why does 93.3% GCash use matter?**
It justified GCash/Maya text parsing and batch screenshot import, since many transactions already exist as screenshots or messages.

**7. 🟡 Only 10% use a tracking app. Doesn't that mean people don't want one?**
It means current options are not adopted. Combined with 96.7% stated intent and heavy reliance on receipts (90%) and mental estimates (53.3%), we read it as an automation gap, not a lack of demand. That is our interpretation.

**8. 🟡 Who validated your survey?**
One content validator reviewed the questionnaire and the FHS formula (certificates in Appendices D and E): Avigail Candevario, PFMe. A technical validator reviewed the system and SUS process. [CONFIRM the technical validation certificate exists — see CONFIRM_CHECKLIST A2 / A4.]

---

## 2. Chapter III: Objective 2 (the system)

**9. 🟢 Why Gemini 3.5 Flash-Lite?**
Highest fit on our six weighted criteria for a free-tier mobile prototype: 1M-token context, native function calling for 34 actions, strong Taglish in our trials, and a generous free tier.

**10. 🔴 Show me the weighted scores for the 20 models.**
We report measured values per criterion in Table 3.2 but did not compute a single weighted total. Some criteria were not measured for models outside our benchmark run, marked "Not measured". The weights justify what we prioritized; a formal weighted ranking is a refinement we did not do.

**11. 🟡 What happens when Gemini is down or rate-limited?**
The chain falls back through seven providers: Gemini 3.5 Flash, GPT-OSS 120B, Qwen 3.6, Qwen 3.8, GPT-OSS 20B, Groq Compound Mini, then GPT-OSS 120B on Cerebras. If Local-only is on, it never falls back to cloud.

**12. 🟡 Why full-context injection and not RAG?**
One user's data is only about 1,000–5,000 tokens, so it fits every evaluated context window. RAG would add complexity without benefit at this scale.

**13. 🔴 What does "34 autonomous AI actions" mean? Is it really autonomous?**
It means the model can call 34 defined action types (record, edit, delete, budget, goal, and so on) through JSON function calls. It acts within those defined actions, with duplicate checks and an Undo option; it is not open-ended autonomy.

**14. 🟡 How do you stop the AI from recording wrong data?**
Parsed entries go through duplicate detection, receipts show editable extracted text before sending, batch import shows items for review, and Undo is available. Accuracy figures are preliminary (see Q22).

**15. 🔴 Explain the Financial Health Score. Why 25 points each? Who validated it?**
Four equal components make the score easy to explain. The weights are a design choice, not statistically derived, so it is a prototype indicator, not a validated instrument. A content validator reviewed the formula (Appendix E). It follows the observed-data approach of the CBA–Melbourne Institute scale and the Spend, Save, Plan ideas of the FinHealth Score.

**16. 🟡 Walk me through a real score.**
Use slide 12: Savings 0, Overspend about 17, Budgets 25, Logging about 22, total 64.

**17. 🟡 What is the "Management Score 97/100" on the Home screen?**
[CONFIRM from the code and answer in one sentence; if it is separate from the FHS, say so — see CONFIRM_CHECKLIST B11.]

**18. 🔴 Figures 3.5 and 3.8 show 96 and 64. Which is right?**
Both are right: they were captured from Demo Mode at different times and data states.

**19. 🔴 What does the Financial Health Score do when no budgets are set?**
[CONFIRM from the code before the defense; do not guess — see CONFIRM_CHECKLIST B19.]

**20. 🟡 What is Peso, and does it help?**
Peso is the mascot and chat persona. It is a design feature. We did not measure its effect on behavior.

**21. 🟡 Is it really offline-first if all AI needs internet?**
Logging, storage, budgets, and the score work offline from SQLite. AI features need a connection. Recommendation 5 is an opt-in on-device AI tier.

**22. 🔴 91.2% and 88.5%: where from? What is n?**
Preliminary developer testing against a small internal set; not a formal evaluation. Table 3.5 marks every modality as not formally measured. [Give n — see CONFIRM_CHECKLIST B21.] Recommendation 2 is a 50-plus standardized receipt evaluation.

**23. 🟡 Your receipt OCR output in Figure 3.7 looks messy.**
Yes, OCR on photographed receipts is imperfect, which is why extracted text is editable before sending and why we recommend formal evaluation.

**24. 🔴 Is it private? You send financial data to Google.**
Mobile numbers, reference numbers, and account patterns are redacted on-device first, and a disclosure is shown before the first AI message. Under the free tier, content may be reviewed, so redaction reduces exposure but does not remove it. Private Local Mode with Local-only keeps data on the user's network. It is designed with the Data Privacy Act in mind, not certified compliant.

**25. 🔴 The API key is in the app.**
Correct: it comes via Remote Config, which an attacker could still extract. A backend proxy with server-side keys and per-user limits is Recommendation 3. Until then it is a prototype-grade risk we disclose.

**26. 🟡 Is the local database encrypted?**
Not yet. SQLCipher is Recommendation 4.

**27. 🟡 Why Android only?**
Scope and time. The Flutter codebase could support iOS later, but we only tested and built for Android.

**28. 🟡 How is the app different from GCash's Pera Coach, Tarsi, etc.?**
We do not claim to be the first. Table 1.2 shows our combination: offline mode, LLM chat, health score, OCR, Filipino-English voice, and batch screenshot import. We lack the payday-cycle feature that BudgetPH has (Recommendation 6).

**29. 🔴 Is the free tier sustainable? What does it cost to run?**
For a prototype and demo, yes. At scale the shared free quota and the 150 per user per day cap are limits, which is why the proxy and per-user limits matter before a Google Play release.

**30. 🟡 Does it work for Taglish?**
In our trials Gemini 3.5 Flash-Lite handled Taglish well; we have not published a formal accuracy figure for Taglish (Recommendation 2).

---

## 3. Chapter III: Objective 3 (SUS)

**31. 🔴 61.83 is a failure, isn't it?**
It is below our target and below the 68 average, and under our criteria it is marginal, not acceptable. So we say partially achieved: we evaluated usability as planned, did not meet the target, and we identified what to fix.

**32. 🔴 Why set the target at 80?**
Aspirational, set before data collection, not changed afterwards. We also report 68 as the secondary benchmark (Sauro & Lewis, 2016).

**33. 🟡 Is 80 "Good"?**
Per Bangor's anchors, Good is about 71 and Excellent about 85, so 80 sits between them. We called it an aspirational threshold, not an adjective anchor.

**34. 🟡 What do Grade D and "OK" mean?**
"OK" is the adjective anchor from Bangor and colleagues (2009). Grade D is from the Sauro and Lewis (2016) curved scale. Both say below average.

**35. 🔴 Your standard deviation is 17.58 on 30 people. What is the spread telling you?**
Opinions varied widely, from 35.0 to 92.5. Some users found it very usable and some did not, which supports Recommendation 1 and a larger sample. [CONFIRM stats from the raw file — CONFIRM_CHECKLIST A1.]

**36. 🔴 Show me individual SUS scores.**
Appendix F lists all 30 respondents with raw answers and computed scores. [CONFIRM this appendix is built — CONFIRM_CHECKLIST A2.]

**37. 🟡 Parents scored 58.25 and young professionals 63.62. Is that significant?**
We did not test significance. It is a descriptive gap of 5.37 points with 10 versus 20 respondents, so we do not generalize it.

**38. 🟡 Which items were worst?**
Consistency (Q6), complexity (Q2), and need for technical support (Q4). [Give item means from the Form export.]

**39. 🟡 What did people like?**
Intent to use frequently (Q1, 4.35) and confidence using it (Q9, 4.19).

**40. 🔴 Did respondents really use it for 10 minutes?**
A screening question confirmed minimum use. Of 36 who attempted the survey, 31 confirmed sufficient usage time; 1 of these was excluded for straight-line answering, leaving 30 valid respondents. The other 5 were excluded for insufficient usage time.

**41. 🟡 Did everyone use the full app?**
Respondents used either the full app or Demo Mode for at least 10 minutes. [State how many used each if you have it.]

**42. 🔴 Which version did they evaluate, and did it include Peso and badges?**
They evaluated v3.1.0. [CONFIRM whether Peso and badges were in that build — see CONFIRM_CHECKLIST A6. Keep the answer consistent with the manuscript.]

**43. 🟡 Why is "performance" in Objective 3 if you only measured usability?**
We assessed performance only through preliminary developer testing (Table 3.5), which is why we call the objective partially achieved and recommend a formal evaluation (Recommendation 2).

**44. 🟡 Why only SUS? What about task completion or time?**
SUS is a standardized, quick instrument suited to a first evaluation. Task-based testing and a longitudinal study are future work (Recommendation 8).

---

## 4. Chapter IV (conclusions and recommendations)

**45. 🟡 Which objectives were achieved?**
Objectives 1 and 2 were achieved; Objective 3 was partially achieved. Objective 1: needs confirmed the gap. Objective 2: working prototype built. Objective 3: usability evaluated but target not met.

**46. 🔴 Are your recommendations based on your findings?**
Yes: each recommendation maps to a limitation: UI/UX (SUS), parsing evaluation (preliminary accuracy), proxy (key exposure), encryption (unencrypted database), on-device AI (internet dependence), payday cycle (feature gap), household/remittance (scope), longitudinal study (behavior and sample).

**47. 🟡 What is your top priority recommendation and why?**
UI/UX refinement, because usability is the objective that fell short and affects every user. Security (proxy and encryption) comes before a Google Play release.

**48. 🟡 Are any recommendations already implemented?**
No. If a panelist points to one that is, say what exists today and what is missing. [Check the code before the defense — see CONFIRM_CHECKLIST B19.]

**49. 🔴 When would you release on Google Play?**
Only after the backend proxy and a privacy policy are in place, and after the usability concerns are addressed (Recommendations 1 and 3 at minimum).

**50. 🟡 What would you do with another 3 months?**
Fix the UI consistency issues, run the formal parsing evaluation, build the proxy, and run a three-to-six-month evaluation with more parents.

---

## 5. Methods, ethics, general

**51. 🟡 Why Agile Kanban? Why not Scrum?**
Work was continuous and overlapping (AI, OCR, voice, sync), so a continuous flow with WIP limits fit better than fixed sprints.

**52. 🟡 How did you protect respondents?**
Informed consent, voluntary participation, group reporting, no account numbers or passwords requested, and academic use only.

**53. 🟡 Is the app compliant with the Data Privacy Act?**
No claim of compliance. We designed with RA 10173 (National Privacy Commission, 2012) in mind through redaction, consent, a disclosure, and local-only options. It is a risk-reduction measure, not a certification.

**54. 🔴 One validator for both the survey and the FHS?**
Yes, one content validator reviewed both. We acknowledge that a second independent review would strengthen the work. [Make sure this matches Table 2.1.]

**55. 🟡 Who contributed what?**
Brix: lead developer (architecture, AI integration, app). Cyrille and Djaunathan: [fill in research, documentation, testing, UI contributions.]

**56. 🟡 What is original in your work?**
An evaluated, integrated prototype for Filipino-English finance: LLM function-calling for 34 actions, on-device redaction with a local-only option, and an explainable observed health score — not any single feature taken alone.

**57. 🟢 What was the hardest part?**
[Pick one real example: making Taglish parsing reliable across providers, handling batch screenshot variety, or keeping the AI within a free-tier quota.]

**58. 🟢 What did you learn?**
[Your own words: one technical, one research lesson.]

---

## 6. Live demo troubleshooting
- **No Wi-Fi:** use Demo Mode for the visual flow; show the recorded video for AI steps; say "AI features need internet, which is a stated limitation."
- **AI reply slow or rate-limited:** "This is the free-tier quota; the fallback chain would normally switch provider." Then move on.
- **App crashes:** restart; if it fails again, switch to the screen recording and continue.
- **Panel asks to type something unusual:** do it once; if the result is wrong, say "this is one of the parsing errors our 91.2% / 88.5% preliminary numbers allow for", correct it, and show Undo.
- **Panel asks to see settings or data:** do not open any screen with real personal data. Use Demo Mode.

---

## 7. Mock panel rounds (20 min each, one person plays panel)
1. **Round 1: Numbers.** Ask section 0 at random, 10 seconds per answer.
2. **Round 2: Hostile SUS.** Questions 31–44 back to back, no looking at notes.
3. **Round 3: Security and privacy.** Questions 24–26, 53, 29.
4. **Round 4: Methods challenge.** Questions 1–8, 51–54.
5. **Round 5: Demo under pressure.** Run slide 10 while a teammate interrupts with Q13, Q19, Q22.

## 8. Your three weakest points (own them first)
1. SUS 61.83 is below both benchmarks. Lead with it before they ask.
2. Parsing accuracy has no formal test set. Say "preliminary developer testing" every time.
3. Security is prototype-grade: key via Remote Config, unencrypted database.
