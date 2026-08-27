**Comparative Analysis of Large Language Model APIs**

The selection of an appropriate large language model (LLM) API is a critical design decision for SmartSpend because it directly influences the accuracy, latency, and cost of natural language expense parsing and conversational assistance. Several providers currently offer high-performing LLMs via API, including OpenAI (GPT-4o), Google (Gemini 2.0 Flash), Anthropic (Claude Sonnet), and open-source model families such as LLaMA 3 hosted by third-party inference platforms (OpenAI, 2023, 2024; Meta AI, 2024). Each option presents trade-offs in terms of inference speed, pricing, context window size, and multilingual support. For a mobile financial assistant that must respond quickly to user input and operate under the constraints of academic and free-tier resources, low latency and predictable cost are especially important considerations in the selection process. Table 2.2 presents a comparative summary of these options.

**Table 2.2. Comparative Evaluation of LLM APIs for SmartSpend Integration**

| LLM API | Key Strength | Context Window | Cost | Fit for SmartSpend |
| :---- | :---- | :---- | :---- | :---- |
| Groq \+ LLaMA 3.1 8B (Meta AI, 2024\) | High inference speed, free tier, en-PH capable, modular design | 128K tokens | Free | SELECTED — speed, cost, swappable architecture |
| Gemini 2.0 Flash (Google) | Multimodal, native OCR, 2M token context | 2M tokens | Low | Strong alternative for future upgrade |
| GPT-4o (OpenAI) | Highest general accuracy, rich tooling ecosystem | 128K tokens | Medium | Backup option; higher cost |
| Mistral (open-source) | Privacy-preserving, self-hostable | 7B–80B param | Free/Low | Offline hybrid potential; lower en-PH accuracy |

The system implements a zero-shot prompting strategy for common parsing and advisory tasks, where the LLM receives a structured instruction and the raw user message, and responds with a JSON object containing extracted fields such as amount, category, merchant, and date. For more complex cases identified during testing, a small set of few-shot examples demonstrates how to handle informal Filipino-English phrasing and typical expense descriptions. User feedback — such as corrections to misclassified categories — can be used to refine prompts and improve reliability without requiring full model retraining (Dwivedi et al., 2021; OpenAI, 2024).

**Financial Health Score: Basis and Computation**

To move beyond simple expense summaries, SmartSpend introduces a Financial Health Score (FHS) ranging from 0 to 100 that provides users with a single, interpretable indicator of their recent budgeting behavior. The design of this score is informed by frameworks for measuring financial health proposed by the UNSGSA, which emphasize indicators related to spending, saving, borrowing, and planning (UNSGSA, 2021). The FHS focuses on factors that can be computed directly from the user's recorded data within the application. The score is bounded between 0 and 100, with 0 representing very poor financial behavior within the period and 100 representing excellent alignment with defined budgeting and saving goals.

The proposed FHS consists of four components, each contributing 25% to the total score:

(1) Savings Rate (25%). This component measures the ratio between the user's actual savings for the period and a target savings rate of 20% of income, based on the 50/30/20 budgeting rule commonly applied in personal finance literature (Hean et al., 2025). Users who save at or above the target receive a higher sub-score, while those who save less receive a proportionally lower sub-score.

(2) Overspend Control (25%). This component is based on the number of days within the evaluation period where the user's spending exceeded their daily or category-specific budget. The sub-score decreases as the number of overspend days increases, encouraging users to maintain consistent control over their daily spending.

(3) Budget Adherence (25%). Budget adherence measures the percentage of budget categories that remain within their configured limits at the end of the period. Users who keep most categories within budget receive a higher sub-score, while frequent overspending across multiple categories reduces this component.

(4) Logging Consistency (25%). This component reflects how consistently the user records expenses over time. It rewards users who log transactions regularly and reduces the score during periods with many unrecorded days, which often leads to incomplete data and poor awareness of actual spending.

The combined formula is expressed as:

Score \= 25% × (Savings Rate Sub-score) \+ 25% × (Overspend Control Sub-score) \+ 25% × (Budget Adherence Sub-score) \+ 25% × (Logging Consistency Sub-score)

The score is bounded at all times between 0 and 100 — it can never go below 0 or above 100 regardless of the computed value.

In addition to the base computation, SmartSpend introduces a consequence and escalation mechanism for users who ignore budget warnings. When the system issues a spending warning and the user continues to spend in that category without adjustment, the FHS incurs a decay penalty of 5 points per day for up to three consecutive days, with a minimum bound of 0\. This decay escalates across three tiers: (1) a gentle nudge notification on the first overspend day, (2) a stronger warning with a spending comparison summary on the second day, and (3) a critical alert with a projected monthly overspend figure on the third day. This graduated design increases the visible consequence of ignoring financial risk signals without creating alert fatigue.

To support reflection and planning, the application presents financial summaries across multiple time frames. Weekly summaries highlight category-level spending versus the proportional weekly budget target. Monthly summaries include total income, total expenses, savings rate, FHS trend, and top overspent categories. Yearly summaries provide a longitudinal view across all twelve months, including average FHS, total savings, and debt repayment progress. By combining a simple numeric score with visual trend summaries, SmartSpend aims to make financial behavior more tangible and easier to understand for parents and young professionals who may not be comfortable interpreting detailed financial statements. Beyond standard time-frame summaries, the Analytics module provides additional tools including a Period Comparison feature for side-by-side analysis of financial behavior across different time ranges, a Day-of-Week Heatmap to identify recurring spending patterns, and a Long-Range Forecast that projects cumulative spending over 3-, 6-, and 12-month horizons based on current trends. These features enable users to anticipate future financial outcomes and make more informed decisions.

**Other Additions:**

Confirm you have a saved copy of: the "Comparative Analysis of Large Language Model APIs" section, Table 2.2 (the 4-model comparison table with Key Strength / Context Window / Cost / Fit columns), and the zero-shot/few-shot prompting paragraph that followed it. These will become part of Chapter 3 under "Results of the LLM Benchmarking Evaluation." If you do not have this saved, copy it from an earlier version of the paper and paste it into a separate Google Doc labeled "SmartSpend Ch3+ Draft."

**Table 2.3. Agile Kanban Workflow Phases and Deliverables.**

| Phase | Key Tasks | Deliverable |
| :---- | :---- | :---- |
| Backlog | Define all features; conduct parent and young professional needs survey; review literature on PH financial gaps | Prioritized feature list |
| Requirements | Translate findings into specifications; draft survey questionnaire; submit to content validator for review; conduct comparative technical benchmarking of LLM APIs (Objective 2\)  | Validated questionnaire; LLM prompt specifications; LLM benchmarking evaluation matrix (for Chapter 3\)  |
| Design | Design database schema (SQLite); define FHS formula and weights; create UI wireframes and data flow diagrams | System architecture diagram; database schema; FHS formula documentation |
| Development | Build expense tracking module; integrate Groq LLaMA 3.1 API; add OCR, voice, barcode, Firebase sync; implement FHS computation and escalation system | Functional MVP; full-feature app build |
| Testing | Unit testing for LLM parsing accuracy; SUS evaluation with 30 respondents; qualitative interviews; bug documentation | SUS scores; parsing accuracy results; bug log |
| Deployment | Finalize APK build; prepare demo mode with sample data; complete project documentation | Release APK; project documentation; defense-ready demonstration |
| Done/Review  | Analyze SUS scores; review user feedback; identify improvements; document recommendations for future development  | Final evaluation report; recommendations for future development including: multi-wallet support for GCash, Maya, and bank balance tracking; backend API proxy for secure key management; PDF export of financial summaries; SQLite database encryption; and shared or family wallet functionality.  |

