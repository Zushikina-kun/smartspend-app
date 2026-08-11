# SmartSpend Manuscript — Fix Guide
## Step-by-step corrections for the Google Docs manuscript
**Prepared by Kiro | August 2026**
**Apply these fixes one by one in your Google Docs. Each fix shows exactly what to find (CTRL+F) and what to replace it with.**

---

## FIX 1 — Achievement Badges count
**Where:** Chapter 1, Purpose and Description section
**How to find it (CTRL+F):** `16 achievement badges`

**CURRENT TEXT (find this):**
> A gamification layer featuring 16 achievement badges and spending streak tracking further reinforces positive financial habits

**REPLACE WITH:**
> A gamification layer featuring 23 achievement badges and spending streak tracking further reinforces positive financial habits

---

## FIX 2 — Backup version number (first occurrence)
**Where:** Chapter 2, Software Methodology / Development Phase description
**How to find it (CTRL+F):** `version 8 format`

**CURRENT TEXT (find this):**
> All financial data — including expenses, budgets, savings goals, income, recurring transactions, debts, wallet balances, mood log, and installment plans — is exported as a structured JSON file (version 8 format) that can be shared via any installed application or saved to local storage.

**REPLACE WITH:**
> All financial data — including expenses, budgets, savings goals, income, recurring transactions, debts, wallet balances, mood log, and installment plans — is exported as a structured JSON file (version 9 format) that can be shared via any installed application or saved to local storage.

---

## FIX 3 — API key security statement
**Where:** Chapter 2, Scope and Limitations section
**How to find it (CTRL+F):** `The LLM API key is embedded within the application package`

**CURRENT TEXT (find this):**
> The LLM API key is embedded within the application package as part of the free-tier academic deployment. To mitigate potential misuse, the system enforces a daily interaction limit of 60 AI requests per user, which resets automatically. A backend proxy server for secure API key management is planned as a post-capstone enhancement to align with production-level security practices.

**REPLACE WITH:**
> The LLM API key is not embedded within the application package. Instead, it is fetched securely at runtime via Firebase Remote Config, ensuring the key is never stored in the APK binary or exposed in the source code repository. To mitigate potential misuse, the system enforces a daily interaction limit of 60 AI requests per user, which resets automatically. A backend proxy server for fully server-side API key management is planned as a post-capstone enhancement to further align with production-level security practices.

---

## FIX 4 — Multi-wallet system status
**Where:** Chapter 2, Done/Review Phase (last paragraph of Software Methodology section)
**How to find it (CTRL+F):** `A multi-wallet system enabling separate tracking`

**CURRENT TEXT (find this):**
> A multi-wallet system enabling separate tracking of GCash, Maya, and bank balances requires significant database schema extensions and is targeted for future development.

**REPLACE WITH:**
> A multi-wallet system enabling separate tracking of GCash, Maya, and bank balances has been fully implemented in the current version. The system supports 30+ Philippine banks and e-wallets (GCash, Maya, GrabPay, ShopeePay, BDO, BPI, Metrobank, and more), with automatic balance deduction upon expense logging and wallet-to-wallet transfer functionality.

---

## FIX 5 — App Lock description in Technical Background
**Where:** Chapter 1, Technical Background section (near the end, under Firebase Authentication)
**How to find it (CTRL+F):** `biometric authentication (fingerprint or face unlock) as a convenience layer after the user's first successful login`

**CURRENT TEXT (find this):**
> Firebase Authentication will support secure login methods including email/password, Google Sign-In via OAuth 2.0, and biometric authentication (Google, 2024a).

*(Note: the app lock description appears again in local_auth section)*

**Also find (CTRL+F):** `biometric authentication (fingerprint or face unlock) as a login option after the user's first successful login`

**CURRENT TEXT (find this exact sentence):**
> The local\_auth package will enable biometric authentication (fingerprint or face unlock) as a login option after the user's first successful login, using the device's enrolled biometrics with a PIN fallback (The Flutter Authors, 2013).

**REPLACE WITH:**
> The local\_auth package enables biometric authentication (fingerprint or face unlock) as a security option during application startup. The lock screen appears only on cold start when a PIN is configured, and does not interrupt the user during normal use. This approach mirrors the authentication behavior of major Filipino financial applications such as GCash and Maya, where users authenticate once on open and are not repeatedly prompted during the session.

---

## FIX 6 — Financial Health Score — add Lightweight Mode
**Where:** Chapter 1, Technical Background section, Financial Health Score paragraph
**How to find it (CTRL+F):** `four equally weighted components: Savings Rate, Overspend Control, Budget Adherence, and Logging Consistency`

**CURRENT TEXT (find this):**
> SmartSpend introduces a Financial Health Score ranging from 0 to 100 that provides users with a single, interpretable indicator of their budgeting behavior. The score is computed from four equally weighted components: Savings Rate, Overspend Control, Budget Adherence, and Logging Consistency — each contributing 25% to the total score. The detailed formula, component weights, and consequence mechanism are fully documented in Chapter 3: Results and Discussion.

**REPLACE WITH:**
> SmartSpend introduces a Financial Health Score ranging from 0 to 100 that provides users with a single, interpretable indicator of their budgeting behavior. The score operates in two modes depending on the user's settings. In **Full Mode** (income tracking enabled), it is computed from four equally weighted components: Savings Rate, Overspend Control, Budget Adherence, and Logging Consistency — each contributing 25% to the total score. In **Lightweight Mode** (income tracking disabled), the four components are: Spending Restraint (vs. a user-defined spending limit), Logging Consistency, Category Balance (preventing any single category from dominating spending), and Habit Streak (consecutive days of expense logging). This dual-mode design makes the system usable for individuals who do not have a fixed income, such as students and informal workers, without penalizing them for not setting income data. The detailed formula, component weights, and consequence mechanism are fully documented in Chapter 3: Results and Discussion.

---

## FIX 7 — Table 1.2 Feature Comparison (add missing features)
**Where:** Chapter 1, after the feature comparison table
**How to find it (CTRL+F):** `General financial Q&A`

**In the table, find the last row which says:**
> | General financial Q&A | No | No | No | No | Yes |

**ADD these new rows AFTER "General financial Q&A"** (insert before the closing line of the table):

| Feature | Tarsi | YNAB | Monarch | Copilot | SmartSpend |
|---|---|---|---|---|---|
| Batch screenshot import (40+ platforms) | No | No | No | No | Yes |
| Multi-period spending limits (daily/weekly/monthly/yearly) | No | No | No | No | Yes |
| Lightweight Mode (no income required) | No | No | No | No | Yes |
| Logging gap detection with FHS adjustment | No | No | No | No | Yes |
| AI model selector (5 LLM providers) | No | No | No | No | Yes |

*(In Google Docs, place your cursor at the end of the last row and press Tab to add new rows, then type the content above)*

---

## FIX 8 — Backup version in Technical Background (second occurrence if present)
**Where:** Chapter 1 or 2, Backup and Restore section
**How to find it (CTRL+F):** `version 8`

If you find any other occurrence of "version 8" referring to the backup format, change it to **version 9**.

---

## FIX 9 — Update the gamification count in Purpose and Description beneficiaries section
**Where:** Chapter 1, Beneficiaries / Purpose and Description
**How to find it (CTRL+F):** `16 achievement badges`

*(This may be a second occurrence — replace it with 23 achievement badges just like Fix 1)*

---

## FIX 10 — Input methods count (optional upgrade)
**Where:** Chapter 1, Project Context / Purpose and Description
**How to find it (CTRL+F):** `voice input, receipt OCR, barcode, and manual text as input methods`

**CURRENT TEXT:**
> supports voice, receipt OCR, barcode, and manual text as input methods

**REPLACE WITH (optional — adds the newer Smart Import feature):**
> supports voice, receipt OCR, barcode scanning, manual text, AI chat, and a unified Smart Import system — including batch screenshot import that automatically detects 40+ platform types (GCash, Shopee, Steam, Lazada, GrabFood, and more) — as input methods

---

## SUMMARY CHECKLIST

Use this to track your progress in Google Docs:

- [ ] Fix 1 — "16 achievement badges" → "23 achievement badges"
- [ ] Fix 2 — "version 8 format" → "version 9 format" (backup)
- [ ] Fix 3 — API key security statement (not in APK, uses Remote Config)
- [ ] Fix 4 — Multi-wallet "future" → "fully implemented"
- [ ] Fix 5 — App lock description (cold-start only, like GCash/Maya)
- [ ] Fix 6 — FHS section (add Lightweight Mode explanation)
- [ ] Fix 7 — Table 1.2 (add 5 new rows for newer features)
- [ ] Fix 8 — Any other "version 8" backup references → version 9
- [ ] Fix 9 — Any second occurrence of "16 achievement badges" → 23
- [ ] Fix 10 — (Optional) Input methods list — add Smart Import

---

## NOTES FOR CHAPTER 3 (when you write it)

These things from the actual app should be in Chapter 3:

1. **LLM selection justification** — Primary: Gemini 3.1 Flash-Lite (1,000/day FREE, 1M context, Filipino-English excellent). Fallback chain: Gemini 3.5 Flash → Groq LLaMA 3.3 70B → Groq LLaMA 3.1 8B → Cerebras LLaMA 3.1. Reason for NOT using GPT-4o: paid only, not viable for academic deployment.

2. **FHS formula** — Both modes. Use the exact tables from `docs/SmartSpend_Capstone2_Documentation_Reference.md` Section 4.

3. **Architecture quote** (ready to paste into paper):
   > "SmartSpend implements a multi-provider agentic AI system using dynamic full-context injection from a local SQLite database, enabling autonomous financial data management without the infrastructure overhead of traditional RAG pipelines. The multi-provider routing architecture ensures continuous AI availability through automatic failover across five free-tier LLM providers, with task-based routing to match query complexity with model capability."

4. **Why not RAG** — per-user data (20-50 expenses, 5-10 budgets, 3-5 goals) fits entirely in the model's context window. No vector search needed.

5. **29 agentic actions** — list is in `docs/SmartSpend_Capstone2_Documentation_Reference.md` Section 3.

---

*Fix guide prepared by Kiro — based on comparing the manuscript against the actual v2.9.1 build*
*For questions: refer to `docs/SmartSpend_Capstone2_Documentation_Reference.md` for all accurate numbers*
