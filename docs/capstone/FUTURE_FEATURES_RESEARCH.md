# SmartSpend — Future Features Research & Recommendations

**Document purpose.** This file documents recommended future features for SmartSpend, gathered from 2026 AI budgeting-app trends and the Philippine fintech context. It is organized by priority tier so that the team can sequence work after the capstone defense. Each item notes the rationale, the technical approach, and where it plugs into the existing v3.1.x architecture (offline-first Flutter, on-device SQLite, Firebase Firestore per-UID sync, multi-provider LLM with direct full-context injection, and the programmatic 0–100 Financial Health Score).

Features already shipped in v3.0.x (Paluwagan tracker, Peso mascot companion system, FHS tier-change announcements, streak milestones, contextual tips, Taglish push notifications) are noted as implemented and discussed only for extension.

---

## Priority 1 — High Impact, Philippine Context

Features specific to Filipino users that global budgeting apps do not address. These are the strongest differentiators for a locally-built product.

**1. GCash/Maya SMS Autologging.**
On-device SMS parsing for automatic transaction capture from e-wallet and bank alerts, eliminating manual entry entirely. The Objective 1 needs assessment confirmed manual-logging friction as the primary reason users abandon tracking (53.8% rely on manual or no tracking). Implementation uses Flutter telephony/SMS-listener permissions plus a regex pipeline to normalize GCash, Maya, and bank alert text into structured transactions, routed through the existing categorization engine. Privacy is preserved on-device: parsed transactions land in the local SQLite store and the client-side redaction layer (mobile numbers, reference numbers) runs before any cloud AI step, consistent with RA 10173 data-minimization. *Status: planned (Priority 3 in the Chapter IV roadmap).*

**2. Paluwagan (ROSCA) Digital Manager.**
Rotating savings and credit association tracking for the Filipino *paluwagan*. Already implemented in v3.0.x (Chapter IV Priority 2). Extension opportunities: contribution-cycle tracking, payout-schedule enforcement, member management, and default warnings — all layered on the existing debt-tracking and recurring-transaction infrastructure. Future work could add fairness-aware payout ordering and a shared ledger so members can independently verify their position without exposing others' balances.

**3. SSS / PhilHealth / Pag-IBIG Contribution Tracker.**
Government-mandated contribution tracking is already present in-app with AI-assisted computation. Future work: automated computation keyed to official salary-bracket schedules, deadline reminders via the existing push-notification channel, and contribution-history charts so users can see gaps or missed periods. The static calculation parameters are good candidates for prompt caching (see Chapter IV LLMOps roadmap), keeping API cost low.

**4. 15th / 30th Payroll Budgeting Mode.**
A dedicated mode for semi-monthly payroll budgeting common to Filipino employees and teachers, where salary lands twice a month. The mode would split the budget cycle into two sub-cycles with independent "safe-to-spend" pools, bill due-date alignment to each cutoff, and a FHS evaluation window tuned to the 15-day cadence rather than the default monthly window. This directly serves the Lightweight Mode user (students and informal workers are served by the existing dual-mode FHS, but semi-monthly salaried workers are not yet).

**5. Shared / Household Ledger.**
Multi-user shared expenses for households, couples, and families, built on the Firebase Firestore sync already in the architecture. Personal transactions stay private under the existing per-UID scoping; shared pots are opt-in per ledger. This is Chapter IV Priority 1 (Joint/Shared Ledger Allocation) and is the foundation for bill-splitting (Priority 3 item 6) and group paluwagan verification.

---

## Priority 2 — AI / LLM Enhancements

Features that leverage the existing multi-provider LLM architecture (Gemini 3.5 Flash-Lite primary, direct full-context injection, 34 agentic actions). These keep SmartSpend competitive with 2026 AI budgeting agents such as Monarch Money, Simplifi, and Bountisphere, which all combine categorization with forecasting and conversational guidance.

**1. Cash Flow Forecasting.**
Predict a "safe to spend" figure for the rest of the month from the current spending pattern plus known recurring income. Because SmartSpend already injects the user's full transaction context into the LLM (~1,000–5,000 tokens), a forecast is a prompt extension, not a new subsystem: the model reasons over logged cadence and upcoming income to estimate sustainable discretionary spend before the next payday. This is the defining 2026 AI budgeting feature.

**2. Subscription / Recurring Charge Detector.**
AI identifies recurring charges in expense history and flags forgotten or unused subscriptions (dormant streaming, app-store debits, auto-renewing memberships). Industry survey data (Self Financial, 2026) found roughly 60% of adults hold at least one unused paid subscription, averaging ~2.6 idle services per person — a measurable, recurring waste stream. Built on the existing categorization engine; output is a "recurring charges" view grouped by merchant, amount, and last-charged date.

**3. Proactive Spending Alerts.**
Not budget-threshold warnings, but pattern-based, contextual prompts. Example: *"You usually spend ₱800 on weekends — you've already spent ₱600 today."* Delivered in Peso's Taglish voice through the existing `PesoContextService` and push-notification infrastructure. Grounded in the cognitive-nudge mechanism validated by Sharma, Gaba, and Sharma (2026): a salient, comparative nudge outperforms a bare threshold breach at redirecting behavior. Session-gating (already used for contextual tips) prevents notification fatigue.

**4. Natural Language Budget Setting.**
"Set my food budget to ₱3000 this month" via chat, extending the existing 34 agentic actions with a budget-mutation action. The function-calling accuracy already benchmarked for categorization carries over here; the risk is ledger integrity, mitigated by the same 120-transaction batch discipline (Chapter IV LLMOps roadmap) applied to any action that reads history before writing.

**5. Financial Goal Coach.**
AI converses about savings goals, breaks them into weekly targets, and sends reminders when a user falls off-track. Pairs naturally with the FHS Savings Rate component and the Peso streak-milestone celebration system — a goal becomes a long-running streak with mid-point nudges rather than a single end-state reward.

---

## Priority 3 — UX & Engagement

**1. iOS version.**
SmartSpend is currently Android-only. Flutter compiles an iOS target with minimal architectural change (the SQLite store, Firestore sync, and LLM network layer are platform-agnostic), broadening the respondent demographic for a more representative usability N and enabling cross-platform sync. The main porting work is platform permissions (SMS parsing, biometrics) and Apple App Store compliance, not business logic.

**2. Widget support.**
A home-screen widget showing the current FHS score, tier ring, and a quick-log button. This reduces logging friction further — the same friction barrier confirmed in Objective 1 — without forcing the user to open the full app. Android app widgets and iOS home-screen widgets are both reachable from a single Flutter widget via platform channels.

**3. Dark / light mode.**
The app currently uses a fixed color scheme. A theme toggle is low-risk, high-polish, and improves accessibility in low-light conditions; the Peso mascot and tier-ring colors already have semantic mappings (green/orange/red) that adapt cleanly to a dark surface.

**4. Biometric login.**
SmartSpend already has a PIN lock. Adding fingerprint/face unlock (Android BiometricPrompt / iOS LocalAuthentication) reduces login friction and raises perceived security, both of which the SUS feedback flagged.

**5. Export to Google Sheets.**
Many Filipino users keep budgets in Google Sheets. A one-tap export (CSV/XLSX or direct Sheets API write) bridges the gap between SmartSpend's structured data and the tool users already trust, lowering the switching cost for users who are not ready to abandon their spreadsheet entirely.

**6. Bill splitting.**
Split shared expenses with friends or family and track who owes what. Builds on the Shared/Household Ledger (Priority 1 item 5); the novelty is the settlement view (net balances + a "mark as settled" action) rather than the shared store itself.

---

## Priority 4 — Research / Academic Extensions

These extend the capstone's scholarly contribution rather than the product, and are the basis for follow-on thesis or journal work.

**1. Longitudinal behavioral study.**
A 6–12 month study measuring whether the FHS gamification (score decay, tier-change announcements, streak milestones) actually changes savings behavior. The current evaluation is cross-sectional SUS only; behavioral change claims require a longitudinal, randomized cohort with a pre-registered primary outcome (e.g., change in Savings Rate component over 6 months). The Peso mascot features are designed interventions awaiting this validation — they should not be described as evidence of behavior change until measured.

**2. PLS-SEM analysis.**
Validate Perceived Algorithm Transparency (PAT) as a moderator on the path from Sustainable Financial Intentions (SFI) to Digital Financial Well-being (DFWB), following the model in Sharma, Gaba, and Sharma (2026) (PAT as an active moderator, β = 0.14, t = 2.95). SmartSpend's explainable, full-context-injection design is a natural test bed because the user can see the transactions the model reasons over.

**3. Differential weight calibration.**
With longitudinal data, determine whether one FHS component deserves more than its current 25 points for this population. The FHS uses equal weighting (adapted from the CBA–Melbourne Institute Observed FHI) precisely because differential-weight data does not yet exist; once it does, the weights can be empirically tuned.

**4. iOS / cross-platform release.**
Reaching a broader demographic (iOS users, who skew different in income and behavior from the Android-only sample) yields a more representative N for the above studies.

---

## Literature Supporting These Recommendations

The following 2025–2026 sources anchor the recommendations above. All four are already verified in the Chapter IV bibliography; they are restated here for self-containment.

1. **Hean, Saha, & Saha (2025).** *Can AI help with your personal finances?* Applied Economics, 57(14), 1832–1846. https://doi.org/10.1080/00036846.2025.2450384 — Peer-reviewed empirical study on whether AI meaningfully assists personal financial decisions. Supports the Priority 2 AI/LLM enhancements (cash flow forecasting, recurring-charge detection, natural-language budget setting), establishing that LLM-assisted personal finance is a tractable, evidence-backed direction rather than marketing.

2. **Sharma, Gaba, & Sharma (2026).** *Can cognitive nudges in gamified digital payments foster digital financial well-being?* In Proceedings of the 13th International Youth Conference (IYC 2026), Atlantis Press, pp. 262–281. https://doi.org/10.2991/978-94-6463-IYC-2026_28 — Validates cognitive nudges and Perceived Algorithm Transparency (PAT) as a moderator on the SFI → DFWB path. Supports Priority 2 item 3 (proactive spending alerts), Priority 3 engagement work, and Priority 4 item 2 (PLS-SEM moderation analysis).

3. **Flores (2025).** *Financial freedom of Filipinos in personal finance management.* Pantao: The International Journal of the Humanities and Social Sciences, 4(1). https://pantaojournal.com/2025/01/27/v4-i1-7/ — Studies Filipino personal-finance behaviors and gaps. Supports the Priority 1 Philippine-context features (GCash/Maya autologging, SSS/PhilHealth/Pag-IBIG tracking, semi-monthly payroll budgeting) by documenting the local practices these features serve.

4. **Bangko Sentral ng Pilipinas (2025).** *Consumer Finance Inclusion Survey 2025.* BSP. https://www.bsp.gov.ph/ — Documents digital-payment and e-wallet penetration across Filipino households. Anchors the Philippine fintech context underpinning the localized recommendations: the scale of GCash/Maya use justifies SMS autologging as a high-impact target, and the semi-monthly payroll patterns justify the 15th/30th budgeting mode.
