# SmartSpend: Updated AI/LLM and Financial-App Competitive Research Dossier

**Research date:** 12 September 2026  
**Purpose:** Hand-off package for Claude, Kiro, Gemini Notebook, and human academic/technical reviewers.  
**Scope:** Current AI/LLM options for general and finance-related tasks; global, international, Philippine-national, and local personal-finance/financial-wellness applications; implications for SmartSpend research, system design, revisions, and competitive claims.

> **Evidence rule:** Product features, privacy labels, prices, downloads, rankings, quotas, models, and availability change quickly. Every conclusion in this dossier is dated. Treat app-store claims and developer statements as public claims unless independently tested. Treat project-specific SmartSpend results as `PROJECT-REPORTED` until raw evidence is reviewed.

## Instructions for the receiving AI

Use this dossier with the SmartSpend portfolio and raw project evidence. Re-search all entries on the day of review. For each claim, mark it `VERIFIED`, `PARTLY VERIFIED`, `PROJECT-REPORTED`, `NOT ESTABLISHED`, `CONTRADICTED`, `OUTDATED`, `MISATTRIBUTED`, or `LOW QUALITY`.

Required output:

1. Current official LLM/API comparison table with exact endpoint IDs, lifecycle, pricing, rate-limit tier, context, modalities, structured output/tool support, terms, and test date.
2. Finance-specialized LLM review distinguishing institutional/market uses from household personal-finance uses.
3. Global, regional/international, Philippine-national, and local competitor matrices.
4. Hands-on audit protocol and evidence log for every app.
5. A revised, evidence-safe SmartSpend research gap and contribution statement.
6. Exact redline list of claims to remove, revise, or preserve.
7. Verified APA 7 bibliography with stable official URLs and access dates.

Never claim that a model page proves SmartSpend performance. Never claim that an app does not have a feature merely because it was not found in a public listing. Use “not found in public review on [date]” instead.

# 1. Executive conclusion

The current market makes broad SmartSpend novelty claims untenable. Current global apps already combine AI financial chat, account aggregation, budgets, recurring/subscription detection, goals, forecasting, shared finance, transaction categorization, exports, and in some cases user-approved agentic actions. Philippine-focused products already provide salary-cycle budgeting, GCash/Maya context, paluwagan, utang/debt, local government contribution context, AI money coaching, offline-first tracking, business finance, and financial-score concepts.

SmartSpend’s defensible contribution is not “the first” or “the only.” It is a research-evaluated integration of:

- Philippine-context and Taglish-aware input workflows.
- Offline-first local ledger design.
- Transparent transaction-derived financial-pattern feedback, clearly not a validated financial-well-being or credit score.
- Multimodal entry evaluated on local documents and language.
- Bounded AI: model proposes, deterministic code validates, user confirms, application executes, audit trail records, and undo is available.
- Privacy-minimizing design and explicit evaluation among selected users in La Union.

# 2. Current AI/LLM landscape

## 2.1 General-purpose frontier and open models

| Provider/family | Current evidence or candidate | Relevant SmartSpend tasks | What must be verified before thesis use |
|---|---|---|---|
| Google Gemini | `gemini-3.1-flash-lite` | Low-latency multimodal extraction, Taglish chat, structured transaction proposals, function/tool workflows | Exact endpoint, API version, preview/stable status, account-tier quota, price, data terms, actual benchmark |
| Google Gemini | Gemini 3 family / higher-reasoning variants | Complex educational explanations, document analysis, research review | Cost, lifecycle, availability, safety and latency |
| OpenAI | GPT-5.6 family, GPT-6 Astra, GPT-Live-1 | Reasoning, coding, agents, voice interface | Exact endpoint/model ID, price, data retention, Philippines availability, task benchmark |
| Anthropic | Current Claude families | Long-form review, policy-sensitive explanations, coding, document work | Exact API ID and official docs; do not rely on nickname alone |
| Meta/open weights | Llama ecosystem | Local/private deployment experiments, edge inference | License, actual hardware viability, Filipino/Taglish performance, structured output reliability |
| Mistral | Hosted/open models, embeddings, agentic search tooling | Embeddings, document pipelines, EU/enterprise alternatives | Exact model, geography, price, terms, local task quality |
| DeepSeek | Hosted/open finance/coding candidates | Cost-sensitive batch extraction, coding, experimentation | Exact model, terms, data residency, safety, real Taglish test |
| Qwen/GLM/Kimi/open-weight families | Candidate open models | Local deployment and cost comparisons | License, endpoint, hardware, language performance, security |

### Google Gemini 3.1 Flash-Lite

Google currently documents `gemini-3.1-flash-lite` as a low-latency, cost-effective multimodal model for high-frequency lightweight tasks. Its page documents text, image, video, audio, and PDF inputs plus structured output, function calling, caching, file search, search grounding, and code execution. It lists a 1,048,576-token input limit and a 65,536-token output limit. [web:130]

Google’s Gemini 3 guide lists the 1M input / 64k output context and describes Gemini 3 models as preview at the page’s August 2026 update. Its deprecation/lifecycle material must be checked each time the thesis is revised because a future migration path to Gemini 3.5 Flash-Lite is documented. [web:134][web:136]

Google also documents JSON Schema-based structured outputs and the combination of structured outputs with tools. This supports schema-constrained transaction **proposals**; it does not validate business rules, arithmetic, deduplication, ledger integrity, or direct write authority. [web:131]

### OpenAI

OpenAI currently documents GPT-6 Astra for advanced business reasoning, computer use, web/research workflows, coding, and professional tasks. It documents GPT-Live-1 for low-latency full-duplex voice experiences and delegation to a reasoning/tool backend. These are possible research comparators, but routine personal-finance tracking should not depend on high-cost frontier models when deterministic code and low-cost extraction models suffice. [web:158][web:160][web:164]

### Anthropic

Anthropic release notes currently identify newer Claude-family launches. Any model label in the SmartSpend portfolio must be replaced by its exact API model ID, date, plan, provider URL, and measured test configuration. A product-family name by itself is not a reproducible technical method. [web:156]

### Model-selection principles

Choose models by task, not brand:

1. **Deterministic local code:** balances, currency math, budgets, financial-pattern indicators, duplicate handling, dates, IDs, permissions, audit logs, and deletion.
2. **Local/OCR rules:** first-pass receipt text, GCash/Maya patterns, merchant normalization, PII redaction, and common categories.
3. **Low-cost structured LLM:** only when rule confidence is low; returns typed proposed data, never directly writes data.
4. **Higher-reasoning model:** optional educational explanations, difficult document summaries, and developer/research support.
5. **Voice model:** only for audio capture/conversation; it does not replace ledger validation.
6. **Human confirmation:** required for create, edit, delete, category changes, budget changes, import commits, and external actions.

## 2.2 Financial-domain LLMs

Financial LLMs are frequently optimized for market news, filings, investor research, sentiment, risk, quantitative finance, and institutional document workflows. They are not automatically better for Philippine household budgeting, Taglish conversation, cash transactions, e-wallet screenshots, or personal financial advice.

| Financial LLM/approach | Typical focus | Potential SmartSpend use | Critical limitation |
|---|---|---|---|
| FinGPT | Open finance-language research | Literature baseline; financial-text experiments | Not proof of Taglish PFM quality or consumer safety |
| BloombergGPT | Institutional market/financial language | Design reference for domain adaptation | Proprietary and not a Philippine household-PFM solution |
| FinLlama and finance-tuned open models | Financial terminology/documents | Research comparator for finance classification | Must test licensing, accuracy, safety, and Filipino support |
| Frontier LLM + deterministic financial engine | Explanation, parsing, multilingual dialogue | Best likely architecture for SmartSpend | Requires tool constraints and privacy minimization |
| Rules/local classifier + LLM fallback | Categorization and normalization | Strong offline-first/low-cost architecture | Requires curated Philippine merchant and Taglish corpus |

A current ACM survey reviews financial LLM solutions and adoption guidance. Use it to frame task fit, risk, governance, and evaluation—not as evidence that a finance-tuned model should automatically advise consumers. [web:142]

# 3. Global personal-finance applications

## 3.1 Global competitor matrix

| Product | Publicly documented focus | Current relevance to SmartSpend | Evidence status |
|---|---|---|---|
| YNAB | Category planning, automatic payee categorization, exports | Zero-based/category budget comparator; user control and data portability | Official help documentation reviewed |
| Quicken Simplifi | Spending plan, projected cash flow, recurring transactions, reports, goals, net worth | Full-suite cash-flow and recurring-bill comparator | Official help documentation reviewed |
| Quicken AI Chat | AI with financial data, app tools, knowledge/reasoning and web search | Direct global AI financial-assistant comparator | Official help documentation reviewed |
| Monarch Money | Account aggregation, cash-flow, goals, categories/flex budgeting, household/pro collaboration | Shared-finance and planning comparator | Official help documentation reviewed |
| Copilot Money | Recurring expenses/subscriptions | Recurring-detection comparator | Official help documentation reviewed |
| Rocket Money | Subscriptions, budgets, financial goals, bill negotiation | Subscription/bill-management comparator | Official documentation reviewed |
| Rowan by Rocket Money | Text-based AI assistant; spending analysis; subscriptions, budgets, bills; user-approved actions | Strong agentic consumer-finance comparator | Official product pages reviewed |
| Goodbudget | Envelope budgeting | Manual/household budgeting comparator | Verify current official feature set |
| Monefy / Spendee / Money Manager | Manual tracking, categories, wallets | Lightweight-entry comparator | Verify current official feature set |
| Pengo | Local/offline PWA, import, recurring billing, goals, cash-flow analysis | Privacy/local-first architecture comparator | Public directory claim; verify official source |
| Tarsi | Offline-first PFM, voice/OCR/recurring/subscription claims | Local-first multimodal architecture comparator | App-store and official testing required |

YNAB documents automatic category suggestions based on payee history, with user control to disable automatic categorization; it also documents transaction and plan export. [web:171][web:172]

Quicken Simplifi documents recurring transactions, projected cash flow, a spending plan, reports, savings goals, income/bill tracking, and financial reporting. Quicken AI Chat says it combines user financial data, Simplifi tools, financial knowledge/reasoning, and real-time web search. [web:174][web:176][web:180][web:184]

Monarch documents budgeting, account connection, cash-flow planning, goals, partner/professional collaboration, recurring budgets, transfer handling, and downloadable transaction history. [web:186][web:188][web:189][web:190][web:194][web:195]

Rocket Money’s Rowan is a significant SmartSpend comparator. Rocket Money describes Rowan as an AI financial assistant that can discuss spending, help with subscriptions, warn about bills, and support financial actions. Its product pages say it scans account activity and can help users understand/act on financial data; any action must be separately verified for user approval and availability. [web:196][web:198][web:199][web:200]

# 4. Philippine-national and local competitor landscape

## 4.1 Direct Philippine and Filipino-context competitors

| Product/service | Current public features | SmartSpend relevance | Evidence qualification |
|---|---|---|---|
| Agila: Finance Coach | Personal/business finance, income/expenses, installments, savings, lending/collections, 50/30/20, wallets, reports, forecasting, chat/coach, inventory, invoices, CSV/JSON backup, local-first/offline claims | High-priority direct competitor | Official Apple/Google listings; developer privacy statements not independent audit |
| BudgetPH | Filipino salary/cutoff cycles, GCash/Maya CSV import, paluwagan, utang/loan, SSS/PhilHealth/Pag-IBIG context, shared household, score, installments/cards/bills | High-priority direct competitor | Official public feature pages |
| GCash Pera Coach | AI financial literacy/money guidance in GCash, conversational guidance, localized language support reported | Direct AI-coach competitor | GCash official/help source preferred; public reporting supports current launch |
| GCash ecosystem | Wallet history, payments, savings, loans, investment/services for verified users | Ecosystem baseline and integration context | Not equivalent to a neutral full PFM app |
| Maya ecosystem | E-wallet/banking/financial-service context | Must assess in hands-on local workflow audit | Verify current official features |
| Lista | Personal/business/freelance tracking, weekly/monthly/bi-monthly budgets, credit-score offers | Financial-management/credit-context comparator | Google Play listing; claims require direct app review |
| P1SO/PISO Budget Tracker | Philippine expense/budget context and offline claims | Local offline comparator | Verify official/app-store status |
| Hunter Vault | Manual cash/e-wallet/bank tracking, goals/debt/recurring/gamification/offline claims | Manual-first and gamification comparator | Verify official source before thesis use |
| Pocket Clear | PHP, GCash/Maya/cash manual tracking, offline, optional encrypted backup, partner mode claims | Privacy/manual local-first comparator | Developer/public blog claims; verify official policy/app |
| Kibo | AI category suggestions from text/receipt/banking alert and offline claims | AI-assisted entry comparator, though not necessarily Philippine-specific | Google Play listing; hands-on test needed |
| Tarsi | Offline-first tracker claim, local developer/public listings | Current Philippines-oriented offline competitor | Verify official listing and feature evidence |
| Global apps used in PH | YNAB, Goodbudget, Monefy, Spendee, Money Manager, Money Lover | Functional competitors available to local users | Country/store availability must be tested |

### Agila: Finance Coach

Agila’s current Google Play listing describes a personal and business finance tracker with income/expense tracking, installments/due dates, budgets, savings, cash-flow insights, sales/expenses, customer/collection tracking, quotes/invoices, inventory, CSV/JSON backup, a finance coach, and offline-first storage. Recent release notes list notification-based bank-alert auto logging, wallet categories/pockets, backup/restore improvements, and import improvements. [web:224]

Agila’s Apple listing describes it as an all-in-one personal/business finance app for Filipinos with chat-based transaction logging, salary/freelance/business/interest income, installments/recurring expenses, savings, lending/collections, a 50/30/20 dashboard, business inventory/customers/suppliers, wallets, forecasting, reports, and offline-first/no-mandatory-account/no-cloud-dependency claims. [web:225]

Do not cite developer-provided 30,000-download, ranking, or social-view claims as independently verified without store analytics/historical evidence.

### BudgetPH

BudgetPH publicly documents a dashboard for income, expenses, savings, extra funds, and budget health; household sharing; Filipino salary schedules including 15th/30th, monthly, bi-weekly and weekly pay; expected versus actual income; recurring bills/due dates; essential expenses; a 0–850 “Budget Credit Score”; paluwagan; installments; and credit-card tracking. [web:235][web:236][web:237][web:238][web:239][web:240][web:241][web:242][web:243]

BudgetPH’s own public positioning also mentions GCash/Maya CSV import, paluwagan, utang, and SSS/PhilHealth/Pag-IBIG context. [web:210]

### GCash Pera Coach

GCash Pera Coach is a direct national AI-guidance competitor. Public Philippine reporting describes it as an AI-powered conversational tool intended to make financial concepts and everyday budgeting/spending guidance easier to understand for Filipino users. Reporting also describes questions about spending decisions, salary budgeting, saving, and household expenses, with English, Tagalog, Taglish, and some local-language support. Treat media reporting as secondary evidence and obtain the current GCash Help Center/terms page for final thesis citations. [web:146][web:226][web:231]

### Lista

Lista’s Google Play listing presents weekly, monthly, and bi-monthly budgets for personal, freelance, and business users and advertises credit-score access/alerts through partner credit bureaus. It should be included as a finance-management and credit-context competitor, with hands-on review of availability, pricing, privacy, and actual scope. [web:217]

### Kibo

Kibo’s Google Play listing describes text entry, receipt scanning, pasted banking-alert input, AI-suggested categories, and offline logging. It is a current comparator for low-friction AI-assisted expense entry, although the retrieved source does not establish a Philippine-specific market focus. [web:218]

## 4.2 Market context

A September 2026 Similarweb ranking identifies GCash and Maya as the top Finance Android apps in the Philippines in the cited ranking, with MariBank PH also prominent. This supports treating e-wallet/bank ecosystems as the dominant local financial context rather than assuming standalone PFM apps are the only competition. Rankings are dynamic and should be rechecked on the audit date. [web:220]

Globe’s consumer guidance identifies GCash, Goodbudget, Money Lover, and other budgeting options available to Philippine users. Use it only as a discovery source; final evidence should be product documentation and hands-on tests. [web:219]

# 5. What SmartSpend can and cannot claim

## Claims to remove

- “First Filipino-English agentic financial app.”
- “Only offline financial tracker in the Philippines.”
- “No Philippine app has AI money coaching.”
- “No app offers 50/30/20, financial-health feedback, installment tracking, paluwagan, utang, GCash/Maya support, OCR, voice, or gamification” without narrowly defined, dated hands-on evidence.
- “Complete Data Privacy Act compliance.”
- “100% accurate reasoning,” “100% security,” “100% recovery,” or “zero risk.”
- Any vendor/model quota, pricing, latency, or capability number not tied to an official source and test date.

## Defensible SmartSpend contribution

> SmartSpend is an offline-first, Philippine-context personal-finance tracking prototype evaluated with selected users in La Union. It investigates the integration of Taglish-aware multimodal input, transparent recorded-financial-pattern feedback, deterministic local financial calculations, privacy-minimizing data handling, and bounded AI assistance in which proposed data actions are validated by software and explicitly confirmed by the user.

## Potential differentiators requiring hands-on proof

- Transparent formula, data-coverage status, and limitations for the transaction-derived indicator.
- Benchmark-backed Taglish transaction parsing, local receipt/screenshot extraction, and correction burden.
- Explicit human-in-the-loop confirmation, undo, audit trail, and policy-bound AI action model.
- Offline-first local ledger with optional cloud features separated by consent.
- Research-grade evaluation and documentation of limitations/fairness for variable-income users.

# 6. Required competitor audit protocol

For every product, record:

- Audit date/time and country storefront.
- Product name, developer/legal entity, platform, app version, pricing tier, login/verification state.
- Evidence URL and archived screenshot.
- Publicly claimed feature versus hands-on verified feature.
- Free/paid/beta/region-limited/verified-user-only status.
- Privacy label and privacy-policy date.
- Account/data export and deletion process.
- Offline behavior tested in airplane mode.
- Exact test inputs and observed results.

### Standard test cases

1. Enter “Nag-GCash ako ng ₱80 pamasahe sa tricycle kanina.”
2. Enter a mixed Taglish transaction with a merchant, amount, date, wallet, and category ambiguity.
3. Import a consented/redacted GCash/Maya screenshot containing multiple transactions.
4. Import a Shopee/Lazada invoice.
5. Create a 15th/30th salary cycle and a variable-income scenario.
6. Set a budget breach caused by necessary medicine or tuition; inspect how the app responds.
7. Create a recurring subscription and a missed installment.
8. Test loan/utang, paluwagan, shared household, and split-bill functions where advertised.
9. Use airplane mode to log/edit/delete entries, then reconnect.
10. Export, delete, restore, and examine whether data remains locally or in cloud backup.
11. Attempt prompt injection through a merchant string/screenshot text if AI is available.
12. Record evidence, limitations, errors, accessibility, correction burden, and support for Filipino/Taglish.

# 7. Required SmartSpend LLM benchmark

Use a fixed, versioned corpus and compare actual endpoints rather than marketing descriptions.

## Metrics

- JSON schema-valid response rate.
- Field-level precision/recall: amount, currency, date, merchant, source wallet, transaction direction, category, recurrence.
- End-to-end transaction accuracy.
- Taglish/Tagalog/English accuracy by language stratum.
- Correction rate and correction time.
- Tool-call proposal correctness.
- Prohibited-advice refusal rate.
- Prompt-injection resistance.
- Hallucinated-transaction/ID rate.
- Duplicate detection performance.
- Latency distribution, not only average latency.
- Token/cost accounting using actual account tier.
- Privacy review: what data entered the prompt and what data was redacted.

## Dataset strata

- English, Tagalog, Taglish, Ilocano/other local-language samples if in scope.
- Manual text, voice transcription, GCash/Maya screenshots, Shopee/Lazada invoices, thermal receipts, bank alerts.
- Clean and degraded document images.
- Cash, e-wallet, bank, transfer, refund, installment, savings, loan, debt, and recurring-payment scenarios.
- Variable-income, emergency expense, tuition, caregiving, shared-household, and no-spend-day FHS cases.

# 8. Technical and responsible-AI requirements

## Architecture

1. Application code computes balances, budgets, financial indicators, and currency math.
2. The LLM receives minimal derived facts and returns explanations/proposals only.
3. Structured output is schema-validated.
4. User previews every write/change/delete action.
5. Application code executes only after user confirmation.
6. Store append-only audit events and support undo.
7. Keep provider secrets server-side; do not distribute billable LLM keys in an APK or Firebase Remote Config.
8. Use local processing/redaction first; cloud features must be optional and consented.

## AI risk register

| Risk | Example | Required mitigation | Metric |
|---|---|---|---|
| Hallucination | Invented balance or financial rule | Deterministic calculations, source display, uncertainty, refusal | Factual/unsafe-response rate |
| Unauthorized action | AI changes/deletes transaction | Preview, confirmation, authorization, undo, audit | Zero unconfirmed write executions |
| Prompt injection | Screenshot tells model to export/delete | Treat imports as untrusted data; tool isolation | Injection test pass rate |
| Sensitive-data leakage | Raw receipt/chat to provider | Minimize, redact, consent, retention contract | Sensitive-field exposure rate |
| Bias/fairness | Variable-income user penalized | Scenario testing, configurable rules | Group error/score disparity |
| Automation bias | User relies on wrong AI answer | Limits/explanations, review prompts | Comprehension/correction rate |
| Sync failure | Duplicate/missing transaction | UUIDs, idempotency, outbox, conflict UI | Duplicate/missing/conflict rate |

# 9. Required revisions to SmartSpend’s FHS/FPI

Do not call the custom score validated by CFPB or FHN. Treat it as a prototype recorded-financial-pattern indicator.

Fix or investigate:

- Do not award full budget-adherence points when no budget is configured.
- Separate logging/data completeness from financial health.
- Do not assume no-spend days are frugality.
- Do not use an unvalidated 40% category-balance penalty for necessary costs.
- Avoid warning-decay penalties that can shame users facing emergencies or low income.
- Distinguish savings from transfers, withdrawals, debt repayment, and own-wallet movements.
- Show Full versus Lightweight mode prominently; do not compare scores across modes.
- Explain variables, weights, periods, exclusions, missing data, corrections, and uncertainty.

Recommended UI layers:

1. Data coverage/completeness.
2. Tracking behavior indicators.
3. Recorded financial-pattern indicators.
4. A clear non-credit/non-diagnostic disclaimer.

# 10. Source list to verify and cite

## AI/LLM

- Google Gemini 3.1 Flash-Lite: https://ai.google.dev/gemini-api/docs/models/gemini-3.1-flash-lite [web:130]
- Google Gemini 3 guide: https://ai.google.dev/gemini-api/docs/gemini-3 [web:134]
- Google structured outputs: https://ai.google.dev/gemini-api/docs/structured-output [web:131]
- Google rate limits: https://ai.google.dev/gemini-api/docs/rate-limits [web:101]
- Google deprecation schedule: https://ai.google.dev/gemini-api/docs/deprecations.md.txt [web:136]
- OpenAI GPT-6 Astra: https://openai.com/index/gpt-6-astra-next-generation-work/ [web:158]
- OpenAI GPT-Live-1: https://openai.com/index/introducing-gpt-live-1-in-the-api/ [web:160]
- OpenAI Agents API: https://openai.com/index/introducing-the-agents-api/ [web:164]
- Anthropic release notes: https://docs.anthropic.com/en/release-notes/claude-apps [web:156]
- Finance LLM survey: https://dl.acm.org/doi/abs/10.1145/3604237.3626869 [web:142]

## Global PFM

- YNAB categorization: https://support.ynab.com/en_us/categorizing-transactions-a-guide-HyRl60sks [web:171]
- YNAB export: https://support.ynab.com/en_us/how-to-export-plan-data-Sy_CouWA9 [web:172]
- Simplifi recurring/spending plan: https://support.simplifi.quicken.com/en/articles/4284318-getting-started-in-quicken-simplifi [web:174]
- Simplifi AI Chat: https://support.simplifi.quicken.com/en/articles/13929605-what-you-can-do-with-quicken-ai-chat-in-simplifi [web:184]
- Monarch budget: https://help.monarchmoney.com/hc/en-us/articles/360048883631-Understanding-Your-Budget-in-Monarch [web:186]
- Rocket Money Rowan: https://www.rocketmoney.com/rowan [web:198]

## Philippine/local PFM

- Agila Google Play: https://play.google.com/store/apps/details?id=com.janj.agila [web:224]
- Agila Apple App Store: https://apps.apple.com/us/app/agila-finance-coach/id6765464814 [web:225]
- BudgetPH home: https://budget.kindlyf.com/ [web:210]
- BudgetPH feature pages: https://budget.kindlyf.com/features/ [web:235][web:236][web:237][web:238][web:239][web:240][web:241][web:242][web:243]
- Lista Google Play: https://play.google.com/store/apps/details?id=com.listaPh [web:217]
- Kibo Google Play: https://play.google.com/store/apps/details?id=com.kibo.app [web:218]
- GCash Pera Coach reporting: [web:146][web:226][web:231]
- Philippines app-ranking context: [web:220]

# 11. Paste-ready research prompt

> Using this dossier and the attached SmartSpend portfolio, conduct a date-stamped research and verification study as of the day you run it. Verify every listed LLM and financial app through official provider, app-store, product, policy, and help-center pages. Build separate matrices for general LLMs, finance-specialized LLMs, global PFM apps, Philippine-national apps, and local Filipino apps. For every feature, distinguish official public claim, hands-on verified behavior, beta/limited feature, paid tier, verified-user-only function, unavailable feature, and not-found-in-public-review. Reassess SmartSpend’s novelty claims and rewrite them conservatively. Audit LLM architecture, provider secrets, privacy, DPA risks, Firestore sync, OCR/categorization benchmarks, FHS formula/fairness, and the study’s results provenance. Return a verified APA 7 bibliography, exact source quotations/URLs/access dates, a redline list, updated thesis sections, a competitor audit log, and a reproducible test plan. Never invent facts, model IDs, feature availability, scores, downloads, rankings, or citations.

# 12. Final handoff rule

This dossier is a research map, not a certification of legal compliance, security, model safety, product accuracy, or market uniqueness. The receiving AI must preserve uncertainty, identify evidence gaps, and distinguish project-reported results from independently verified evidence.
