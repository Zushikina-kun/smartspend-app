# SmartSpend — Competitor Analysis & Feature Ideas
**Research Date:** May 20, 2026 | **Version:** 2.7.0
**Sources:** PCMag, NerdWallet, Cleo, YNAB, Monarch Money, Copilot, Rocket Money, Bright Money, Wally, Monefy, Era, BSP CFIS 2025, behavioral finance research

---

## COMPETITOR FEATURE MATRIX

| Feature | SmartSpend | Cleo | YNAB | Monarch | Copilot | Rocket Money | Bright | Wally | Monefy |
|---------|-----------|------|------|---------|---------|--------------|--------|-------|--------|
| AI Chat Assistant | ✅ 25 actions | ✅ Snarky AI | ❌ | ❌ | ✅ Basic | ❌ | ✅ | ✅ AI | ❌ |
| Voice Input | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| OCR Receipt Scan | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Barcode Scan + Lookup | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Bank Sync (auto) | ❌ (manual import) | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ✅ | ❌ |
| Offline Mode | ✅ Full | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ |
| Filipino-English AI | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Financial Health Score | ✅ 4-component | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Subscription Detection | ✅ | ✅ | ❌ | ✅ | ✅ | ✅ Auto-cancel | ❌ | ❌ | ❌ |
| Bill Negotiation | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ |
| Round-Up Savings | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Debt Payoff Strategy | ✅ AI | ✅ | ❌ | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ |
| Investment Tracking | ❌ | ❌ | ❌ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Couple/Family Sharing | ❌ | ❌ | ❌ | ✅ | ❌ | ❌ | ❌ | ✅ | ❌ |
| Net Worth Tracking | ✅ | ❌ | ✅ | ✅ | ✅ | ✅ | ❌ | ❌ | ❌ |
| Cash Flow Forecast | ✅ | ✅ | ❌ | ✅ | ✅ | ❌ | ❌ | ❌ | ❌ |
| Gamification | ✅ 16 badges | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Mood Tracking | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Insurance Tracker | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| PH Banks Database | ✅ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ | ❌ |
| Free (no subscription) | ✅ | Freemium | $14.99/mo | $9.99/mo | $10.99/mo | $6-12/mo | $7.99/mo | Freemium | $2 one-time |

---

## FEATURES COMPETITORS HAVE THAT WE DON'T (Implementable)

### 🔴 HIGH IMPACT — Should Implement

#### 1. Smart Round-Up Savings (from Bright Money)
**What:** Every expense is rounded up to nearest ₱10 or ₱50, difference auto-added to savings goal.
**Example:** Spend ₱43 on jeepney → round to ₱50 → ₱7 goes to Emergency Fund.
**Implementation:** Add setting "Round-up savings" → on each expense log, calculate difference, add to a designated savings goal. No bank integration needed — just virtual tracking.
**Effort:** Small (1-2 hours)
**Panel appeal:** "The AI automatically saves spare change for you"

#### 2. Spending Streaks & Challenges (from Cleo + gamification research)
**What:** "No-spend day" streaks, "Under budget for 7 days" challenges, weekly spending challenges.
**Research:** Gamification boosts saving habits by 22% (Juniper Research 2026).
**Implementation:** Track consecutive days under daily limit. Show streak counter on home screen. Award badges for 3/7/14/30 day streaks.
**Effort:** Small (already have daily limit + achievements system)
**Panel appeal:** "Behavioral nudge theory applied to spending discipline"

#### 3. AI Proactive Insights (from Cleo 3.0 "Autopilot")
**What:** AI sends unprompted messages like "You've spent 40% more on Food this week than usual" or "Your GCash is running low — you have 3 days until payday."
**Implementation:** On app open, check for notable patterns and show as a card on home screen (not just startup alerts, but positive insights too).
**Effort:** Medium (extend startup_alerts_service with positive insights)

#### 4. "Can I Afford This?" Quick Calculator (from Cleo)
**What:** User asks "Can I afford a ₱5,000 monitor?" → AI checks remaining budget, upcoming bills, savings goals, and gives a yes/no with reasoning.
**Implementation:** Already partially done via `analyze_goal_feasibility` action. Could add a dedicated quick-access button.
**Effort:** Small (UI only — logic exists)

#### 5. Spending Personality Profile (from behavioral finance)
**What:** Categorize user as "Saver", "Spender", "Planner", "Impulse Buyer" based on actual spending patterns. Update monthly.
**Implementation:** Analyze Want vs Need ratio, budget adherence, savings rate → assign personality type with tips.
**Effort:** Small (analytics calculation + card)
**Panel appeal:** "Behavioral finance profiling for personalized intervention"

---

### 🟡 MEDIUM IMPACT — Good Additions

#### 6. Weekly Money Report (Email/Notification Style)
**What:** Every Sunday, a formatted summary: "This week you spent ₱X. Top category: Food. You saved ₱Y. FHS: 72/100."
**Implementation:** Already have weekly notification. Enhance it to be a rich card shown on Monday app open.
**Effort:** Small (extend startup alerts)

#### 7. Bill Due Date Countdown on Home Screen
**What:** "Netflix due in 3 days (₱299)" shown prominently, not buried in recurring screen.
**Implementation:** Already have overdue recurring chips. Add "upcoming in 3 days" chips too.
**Effort:** Small

#### 8. Shared Expenses / Split Bills (from Monarch, Wally)
**What:** Mark an expense as "shared with [person]" → tracks who owes what.
**Implementation:** Add optional "split_with" field to expenses. Show in debt tracker.
**Effort:** Medium

#### 9. Financial Milestones Timeline (from behavioral finance)
**What:** Visual timeline showing: "First ₱1K saved", "First month under budget", "Debt-free date", "Emergency fund complete".
**Implementation:** Track milestone dates, show as a vertical timeline in Profile or Analytics.
**Effort:** Medium

#### 10. Price Memory (from scanning)
**What:** Remember prices of frequently bought items. "Last time you bought Lucky Me it was ₱14. Today it's ₱16 (+14%)."
**Implementation:** Store item_name + amount pairs. On new expense with same name, compare to historical average.
**Effort:** Small (DB query on insert)

---

### 🟢 LOW IMPACT / FUTURE

#### 11. Couple/Family Mode
**What:** Share budgets and expenses with a partner. See combined spending.
**Effort:** High (requires multi-user Firestore architecture)

#### 12. Investment Portfolio Tracking
**What:** Track stocks, crypto, mutual funds alongside expenses.
**Effort:** High (needs market data API, complex UI)

#### 13. Credit Score Simulation
**What:** "If you pay off this debt, your credit score could improve by X points."
**Effort:** Medium (PH doesn't have a universal credit score system yet)

---

## GAPS IN COMPETITORS THAT SMARTSPEND FILLS

| Gap | Who Has It | SmartSpend Advantage |
|-----|-----------|---------------------|
| No offline mode | Cleo, YNAB, Monarch, Copilot, Rocket Money | ✅ Full offline with SQLite |
| No Filipino language | All international apps | ✅ Filipino-English AI |
| No voice input | All except SmartSpend | ✅ Speech-to-text expense logging |
| No receipt OCR | All except SmartSpend | ✅ ML Kit OCR + AI parsing |
| No barcode lookup | All apps | ✅ Open Food Facts + local PH DB |
| Requires bank integration | Cleo, Monarch, Copilot, Rocket Money | ✅ Works without bank API (PH has no open banking) |
| Expensive subscriptions | YNAB $15/mo, Monarch $10/mo, Copilot $11/mo | ✅ Completely free |
| No PH-specific knowledge | All international apps | ✅ SSS, PhilHealth, Pag-IBIG, PH banks, peso context |
| No mood-spending correlation | All apps | ✅ Daily mood + spending pattern analysis |
| No insurance tracking | All apps | ✅ Premium due dates + overdue alerts |

---

## BEHAVIORAL FINANCE INSIGHTS (from research)

### BSP CFIS 2025 Key Findings:
- Filipino account ownership dropped to 50% (from 56% in 2021)
- 74% correctly answered financial literacy questions (up from 69% in 2021)
- E-wallet adoption is the primary driver of financial inclusion
- "Come-what-may" attitude toward financial planning persists

### Behavioral Nudge Techniques That Work:
1. **Default opt-in** — auto-enable savings features (round-ups, budget alerts)
2. **Loss aversion framing** — "You'll lose ₱X from your laptop fund" > "Save ₱X"
3. **Social comparison** — "Users like you save 15% of income" (anonymous)
4. **Streak mechanics** — consecutive days of good behavior (no-spend days, under-budget days)
5. **Micro-commitments** — small daily actions that compound (₱10/day = ₱3,650/year)
6. **Progress visualization** — progress bars, milestone celebrations, confetti
7. **Timely interventions** — nudge at the moment of decision (impulse pause)

### What SmartSpend Already Does Well:
- ✅ Loss aversion (budget alerts linked to savings goals)
- ✅ Impulse pause mechanic
- ✅ Progress visualization (goal progress bars, FHS score)
- ✅ Streak mechanics (daily quests, achievements)
- ✅ Timely interventions (startup alerts, budget warnings)

### What We Could Add:
- Round-up savings (micro-commitments)
- No-spend day streaks (streak mechanics)
- "Users like you" comparisons (social proof — anonymous, aggregated)
- Spending personality profiling (self-awareness nudge)
- Price memory alerts (loss aversion — "this costs more than last time")

---

## IMPLEMENTATION PRIORITY (What to Build Next)

| # | Feature | Effort | Impact | Panel Appeal |
|---|---------|--------|--------|--------------|
| 1 | **Round-Up Savings** | Small | High | "AI-driven micro-savings" |
| 2 | **No-Spend Day Streaks** | Small | High | "Behavioral nudge gamification" |
| 3 | **Price Memory** | Small | Medium | "Smart price tracking" |
| 4 | **Spending Personality** | Small | High | "Behavioral finance profiling" |
| 5 | **Proactive AI Insights** | Medium | High | "Anticipatory AI coaching" |
| 6 | **Weekly Money Report Card** | Small | Medium | "Automated financial review" |
| 7 | **Bill Countdown on Home** | Small | Medium | "Proactive bill management" |
| 8 | **Shared Expenses** | Medium | Medium | "Collaborative finance" |
| 9 | **Financial Milestones** | Medium | Medium | "Achievement-based motivation" |
| 10 | **"Can I Afford This?" Button** | Small | Medium | "Real-time affordability check" |

---

*Research compiled from: PCMag 2026, NerdWallet 2026, Cleo 3.0 blog, Rocket Money features, Bright Money round-ups, BSP CFIS 2025, Juniper Research gamification study, Forbes fintech behavioral analysis, behavioral finance academic literature.*
