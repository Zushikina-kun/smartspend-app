# SmartSpend — Defense Q&A Preparation
**Defense:** November 10, 2026
**Team:** Brix A. Directo · Cyrille John M. Rubis · Djaunathan Albert S. Madayag

> Read this aloud once the night before. Each of you should know your sections.
> Answers are in first person from the presenter's perspective.
> Keep answers to 3–4 sentences maximum unless the panel presses for more.

---

## 🔴 THE #1 QUESTION — "Paano ninyo nakuha yung formula?"

*(See full guide: `FHS_FORMULA_DERIVATION_DEFENSE_GUIDE.md`)*

**Short answer (memorize this):**
> *"Hindi po namin ginawa ang formula mula sa wala. Nag-review po kami ng existing financial health frameworks — specifically the CBA–Melbourne Institute Observed Financial Health Indicator, which uses actual transaction data to compute a 0–100 score using equal-weighted components. Ginaya namin ang philosophy na iyon, pero binago namin ang mga components para tumugma sa mga pain points na natuklasan namin sa aming needs assessment: difficulty saving, overspending, not setting budgets, at inconsistent logging."*

---

## CHAPTER I QUESTIONS

**Q: Bakit kayo pumili ng financial management app bilang capstone topic?**
> As students managing daily allowances, we experienced firsthand how existing apps require too much manual effort and don't understand Filipino context — no Taglish, no GCash, no Paluwagan. Our preliminary survey of 30 respondents in San Fernando La Union confirmed these same pain points, with 73% reporting manual logging as unsustainable. SmartSpend was our direct response to a verified, local need.

**Q: Sino ang target users ninyo?**
> Parents aged 35–55 and young professionals aged 21–35 in San Fernando City, La Union. We selected these groups because they represent the primary household financial decision-makers and the largest active earner demographic in our study area, and our needs assessment confirmed they face the sharpest financial management gaps.

**Q: Ano ang scope at limitations ng inyong study?**
> Our study is limited to Android devices running API 21 and above. The AI chat feature requires internet except in Local AI mode. The FHS is a prototype indicator — it's transaction-derived, not a validated psychometric instrument. Our sample is a purposive convenience sample from La Union, not a random national sample, so results cannot be generalized nationally.

---

## CHAPTER II QUESTIONS

**Q: Ano ang pinaka-related na existing system sa SmartSpend?**
> Among our five comparison apps — GoodBudget, Money Manager, BudgetPH, Spendee, and Agila — none combines all three of our key differentiators: Taglish natural language input, GCash and e-wallet screenshot import, and a real-time transaction-derived Financial Health Score. SmartSpend is the only app in our comparison that addresses all three gaps simultaneously.

**Q: Bakit kayo gumamit ng Melbourne Institute as basis ng FHS?**
> The CBA–Melbourne Institute Observed Financial Health Indicator is a peer-reviewed framework that validates using actual transaction data — rather than self-report surveys — to compute a financial health score on a 0–100 scale with equal-weighted components. This methodology matches our mobile app context exactly. We adapted their component design for our four specific user pain points and renamed our implementation a "Prototype Observed FHI" per their Terms of Use guidance on modified versions.

---

## CHAPTER III QUESTIONS

**Q: Paano gumagana ang AI ninyo? API lang ba ito ng ChatGPT?**
> No — it's not ChatGPT and it's more than a simple API call. We use an agentic architecture with 34 defined action types. The AI parses the user's natural language message, extracts intent and entities — amount, category, date, merchant — and fires structured JSON actions like `log_expense` and `set_budget`, which then execute deterministically against our local SQLite database. The LLM is the reasoning layer; the actual database operations are code we wrote.

**Q: Bakit Gemini ang pinili ninyo?**
> We benchmarked 9 providers on three criteria: Taglish understanding, function-calling reliability, and free-tier availability within our academic budget. Gemini 3.5 Flash-Lite consistently outperformed the others on colloquial Filipino-English code-switching. We also maintain an automatic 8-provider failover chain so the app continues working when any single provider hits a rate limit or outage.

**Q: Paano ninyo ni-protect ang data ng users? RA 10173 compliant ba kayo?**
> Yes. We comply with RA 10173 through four mechanisms: first, on-device PII redaction — Philippine mobile numbers, OTPs, GCash reference numbers, and bank account numbers are automatically removed before any data reaches the cloud AI. Second, a first-use privacy disclosure explains exactly what is sent. Third, a Local AI mode keeps everything on the user's home network. Fourth, we store no sensitive personal information as defined under Section 3(l) of RA 10173 — financial transaction amounts and item names are personal information, not sensitive PI.

**Q: Gaano ka-accurate ang inyong AI categorization?**
> Our AI categorization achieves approximately 94.6% accuracy on a Filipino-English-Taglish test corpus. OCR receipt scanning achieves 91.2% precision and 88.5% recall across GCash, Shopee, and local merchant receipts. These are based on our internal benchmark testing against the 9 providers in our comparison table.

**Q: Ano ang nangyayari kapag walang internet?**
> All core features work fully offline — expense logging via manual entry and OCR, the FHS calculation, analytics, budgets, goals, and debt tracking all use our local SQLite database. Only AI chat and live exchange rates require internet. The app shows a clear offline banner explaining exactly what works and what doesn't, so users are never confused.

**Q: Paano ninyo nakuha ang FHS formula?** *(repeat of main question)*
> *(Use the short answer from the top of this document.)*

---

## CHAPTER IV QUESTIONS (Evaluation)

**Q: Ano ang SUS score ninyo?**
> *(If results are in):* Our SUS evaluation of N=30 respondents yielded a mean score of [X], which maps to [adjective] on the Bangor et al. (2009) adjective rating scale. This meets our pre-defined acceptance threshold of 80 or above.
>
> *(If still collecting):* Data collection for the SUS evaluation is ongoing. We designed the instrument following Brooke's (1996) standard 10-item SUS wording. We expect to complete collection and report final results in the manuscript submission.

**Q: Bakit hindi pa tapos ang survey data ninyo?**
> Surveys require respondents who have actually used the app — we follow standard SUS administration requiring 10 minutes of use before answering. We've been actively recruiting through social media, classmate networks, and direct outreach. We expect to reach our N=30 target before the final manuscript submission deadline.

**Q: Ano ang ire-recommend ninyong improvements?**
> Three priorities. First, SMS autologging using Android's Notification Listener Service — this would capture GCash and bank transaction texts automatically, eliminating manual entry entirely. Second, a longitudinal study over 6–12 months to measure whether the FHS actually changes spending behavior over time. Third, payday-cycle-aware budgeting that resets on the 15th and 30th to match standard Philippine payroll cycles.

---

## AI-SPECIFIC QUESTIONS (panels ask these in 2026)

**Q: Trained ba ang AI ninyo o pre-trained lang?**
> We use pre-trained large language models accessed through APIs — we don't train our own model. Our contribution is the engineering layer: the 34-action schema, the Taglish-aware context injection, the multi-provider failover architecture, and the duplicate-detection guardrails. This is analogous to a civil engineer using pre-manufactured steel — the engineering value is in the design and integration, not the raw material.

**Q: Paano ninyo hinahawakan ang hallucinations?**
> Three guardrails. First, every expense log requires a structured JSON action with schema validation — the AI cannot log a transaction through free text alone. Second, we run a session-level fingerprint check: if the same item, amount, and date was already logged this session, we warn the model before it fires again. Third, we limit context to the most recent expenses and avoid very long prompts, which reduces the documented "long-context hallucination" risk.

**Q: Paano kung mali ang amount o category na na-log ng AI?**
> The user can correct it immediately. Every logged expense is editable in the Transactions screen. The AI also accepts correction commands — for example, "change that Jollibee entry to ₱175" fires an `update_expense` action. We also show a 5-second Quick Undo snackbar immediately after every AI log, so users can reverse it instantly if they catch an error.

**Q: Used na ba ng ibang tao ang app? Meron bang real users?**
> Yes — we have a public GitHub release and a download page at our project website. The app has been installed and tested beyond our team, and we collect feedback through our in-app feedback screen. For the capstone evaluation, our formal respondents are the 30 participants in our SUS evaluation, which is ongoing.

---

## CLOSING QUESTIONS

**Q: Ano ang pinaka-mahirap na bahagi ng pagbuo ng system?**
> The most technically challenging part was the Taglish action parsing — ensuring that "nag-gastos ako ng 65 sa canteen" reliably extracts ₱65, category Food, and fires the correct `log_expense` action regardless of which of 9 different AI providers responds. We solved this with a structured JSON action schema, a multi-format parser that accepts both legacy and bullet-format outputs, and a fallback heuristic for when the model doesn't fire a proper action.

**Q: Kung bibigyan kayo ng mas maraming oras, ano pa ang gagawin ninyo?**
> I'd prioritize three things: conducting the longitudinal behavioral study to measure whether FHS actually changes spending habits, implementing SMS autologging for full automation, and a v4.0 freemium model with RevenueCat to make the app financially sustainable post-capstone.

**Q: Kumusta ang teamwork ninyo? Ano ang role ng bawat isa?**
> Brix handled all development — Flutter, Firebase, AI integration, and system architecture. Cyrille handled UI/UX design and all documentation — the manuscript, research review, and presentation materials. Djaunathan managed project timelines, testing coordination, and quality assurance. We communicated daily and used GitHub for version control so everyone could track changes.

---

## IF THE DEMO FAILS LIVE

*Stay calm. Say:*
> *"We prepared for this possibility. The offline features demonstrate the core architecture — expense logging, FHS calculation, analytics, and goal tracking all work without internet. Let me show those, and I have screenshots of the AI features as well."*

*Then show app screenshots from your phone gallery. Panels respect composure.*

---

*Last updated: November 1, 2026*
*Source for FHS formula question: `docs/capstone/FHS_FORMULA_DERIVATION_DEFENSE_GUIDE.md`*
