# SmartSpend — Scale & Commercialization Risk Assessment
**Date:** October 9, 2026 | **Status:** Planning only — for v4.0+ commercialization
**Purpose:** Identify every wall we will hit when real users start using the app at scale, and plan mitigations before they become emergencies.

---

## 0 — Executive Summary

SmartSpend's current architecture is built for a single developer + capstone demo. It will work fine for 0–100 users. At 500+ concurrent daily users, several systems will hit hard walls simultaneously. The biggest ones, in order of danger:

1. **Shared Gemini API key** — a single AQ. key in Remote Config serves ALL users. It has a 1,000 RPD free limit. At 100 active AI users it's gone by morning.
2. **Firestore free quota** — 50K reads/day and 20K writes/day shared across ALL users. 200 active users can exhaust this in hours.
3. **Firebase Auth** — 50,000 Monthly Active Users free. This one is actually fine for a long time.
4. **Groq free tier** — 1,000 RPD per model per key. Shared key = same problem as Gemini.
5. **Cerebras free trial** — 5 RPM, 1M tokens/day. Even lower than Groq.
6. **Remote Config fetch quota** — 100,000 requests/day per project free. Surprisingly generous.

The good news: Firebase Blaze (pay-as-you-go) is cheap at realistic user counts, Gemini's paid tier is extremely affordable, and the local-first architecture (SQLite) means most app functionality doesn't touch Firestore at all.

---

## 1 — Real Quota Numbers (researched October 2026)

### 1.1 Firebase Firestore

| Metric | Free (Spark) | Paid (Blaze) cost |
|--------|-------------|------------------|
| Document reads | 50,000/day | $0.03 per 100,000 |
| Document writes | 20,000/day | $0.09 per 100,000 |
| Document deletes | 20,000/day | $0.01 per 100,000 |
| Storage | 1 GiB total | $0.000205/GiB/day |
| Network egress | 10 GiB/month | $0.12/GiB (APAC) |

**When we hit the wall:**  
Each user sync writes ~10–20 documents (expenses, budgets, goals). Each read = load user data on open.
- At 100 users × 20 writes/day = 2,000 writes (fine)  
- At 1,000 users × 20 writes/day = 20,000 writes = **exactly the free limit. Day 1 overages start.**
- At 1,000 users × 50 reads/day = 50,000 reads = **exactly the free limit on Day 1.**

**Cost on Blaze at 1,000 users:**  
- 1,000 users × 50 reads × 30 days = 1.5M reads/month → $0.45/month  
- 1,000 users × 20 writes × 30 days = 600K writes/month → $0.54/month  
- Total: ~₱1/month for Firestore at 1,000 users. **Negligible.**

**Cost on Blaze at 10,000 users:**  
- 10M reads + 6M writes/month → ~$9/month → ~₱500/month. Still very cheap.

**⚠️ Key insight:** Firestore is NOT a financial risk. The cost is trivially small. The risk is getting caught on the Spark free plan with no billing enabled and the app just stops syncing. **Solution: Enable Blaze billing with a $10/month spending cap before launch.**

### 1.2 Firebase Authentication

| Metric | Free (Spark) | Paid (Blaze) |
|--------|-------------|-------------|
| Monthly Active Users | 50,000 free | $0.0055 per MAU above 50K |
| Account creation | 100/hour per IP (rate limit) | Same |
| Registered users | **Unlimited** | Unlimited |

**When we hit the wall:**  
50,000 MAUs is enormous for a new app. Even viral growth rarely reaches this in the first year. **Firebase Auth is not a near-term concern.** Even at scale, 100,000 MAUs costs only $275/month.

**⚠️ Real risk:** The 100 account creations/hour per IP limit. If a school shares a WiFi IP and 100+ students try to sign up simultaneously, they'll get rate-limited. Mitigation: Allow demo mode (no account required) and encourage individual data connections.

### 1.3 Firebase Remote Config

| Metric | Free | Paid |
|--------|------|------|
| Fetch requests | 100,000/day per project | $0.000006/request above that |

**When we hit the wall:**  
Each app open fetches Remote Config (the Gemini API key). We cache for 1 hour minimum, so one user generates max 24 fetches/day.  
- 100,000/24 = **~4,166 daily active users** before we hit the free limit.  
- At 10,000 DAU × 24 fetches = 240,000 fetches → $0.084/day = $2.52/month. Negligible.

**Not a concern at realistic scale.**

### 1.4 Gemini API (Google AI Studio — Free Tier)

| Model | RPM | RPD | TPD |
|-------|-----|-----|-----|
| Gemini 3.5 Flash-Lite | 15 | **1,000** | 250,000 tokens |
| Gemini 3.5 Flash | 10 | **250** | - |
| Gemini 2.5 Flash | 10 | **250** | - |

**This is the #1 problem.**  
The exact free quota depends on your specific API key and project. **Verify in AI Studio → API Keys → Usage.** Third-party sources report Flash-Lite free tier anywhere from 500–1,000 RPD; the current numbers in this document may be out of date.  
- At 500 RPD: exhausted at ~16 users/day × 30 messages = **~16 daily AI users**
- At 1,000 RPD: exhausted at ~33 daily AI users (30 msg/day) or ~6 Pro users (150 msg/day)

**Privacy note (critical for launch):** Google's free Gemini API terms state that content submitted under the free (unpaid) quota **may be used to improve Google's products** and **may be reviewed by human reviewers**. Google explicitly advises developers not to submit sensitive, personal, or confidential information under the free tier. This means SmartSpend's default Cloud AI tier sends financial data to a service that may use it for product improvement. Paying for the Gemini API (Blaze plan) switches to the paid terms, which do not include this data-use policy. **Enabling Blaze billing is therefore both a quota fix AND a privacy fix.** This should be disclosed in the app's privacy policy and the Play Store data safety form.

The current architecture puts the AQ. key in Firebase Remote Config. Every user who sends an AI message shares from this pool.

**⚠️ This is the most critical scale issue in the entire app.**

**Cost on paid Gemini tier:**  
Gemini 3.5 Flash-Lite (paid): ~$0.075 per 1M input tokens, ~$0.30 per 1M output tokens.  
A typical SmartSpend AI message = ~2,000 tokens in + ~500 tokens out.  
- Cost per message: ~$0.00015 + ~$0.00015 = $0.0003 per message  
- 1,000 users × 30 messages/day × 30 days = 900,000 messages/month → $270/month  
- At ₱59/month pricing: 1,000 paying users = ₱59,000/month = ~$1,040/month revenue  
- AI cost = $270/month = 26% of revenue at 1,000 users. Tight but viable.  
- **At 10,000 paying users: ₱590,000 revenue vs $2,700 AI cost = 1.6% of revenue. Excellent.**

**Mitigation for launch period (before monetization):**  
Per-user keys via Remote Config. Each user gets their OWN Google AI Studio key (free tier). We provide instructions in Settings → Local AI → "Add your own Gemini key for unlimited AI." This distributes the quota.

### 1.5 Groq API

| Model | RPD (per key) |
|-------|--------------|
| openai/gpt-oss-120b | 1,000 |
| qwen/qwen3.6-27b | 1,000 |
| qwen/qwen3.8-27b | 1,000 |
| groq/compound-mini | 250 |

**The same shared-key problem as Gemini, but Groq is a fallback — not the primary.**  
At 100+ active AI users, the Groq fallback chain also exhausts quickly.

**Mitigation:** Same as Gemini — user-provided keys OR move to paid Groq tier ($0.05/1M tokens on gpt-oss-120b).

### 1.6 Cerebras API

| Tier | RPM | TPD |
|------|-----|-----|
| Free trial | 5 RPM | 1M tokens/day |
| Developer | 1,000 RPM | No daily cap |

**Cerebras is now a 30-day free trial only.** After the trial expires, it requires a paid Developer plan (~$50/month Code, ~$200/month Max). This is the "last resort" fallback and it will break for new users after the trial period.

**Mitigation:** Remove Cerebras from the fallback chain for new installs once the trial expires. Keep only for existing users who set it up during the trial period. Replace with a free OpenRouter fallback (see mitigations).

---

## 2 — The Critical Problem: Shared API Keys

This is the architectural debt that must be resolved before commercialization.

### Current architecture
```
All users → Remote Config → Single Gemini AQ. key → Google AI
```

### The failure mode
At 50+ daily AI users:
- Day starts at midnight, 1,000 RPD quota available
- By 8 AM PH time: ~300 messages sent, 700 remaining
- By noon: quota exhausted
- All AI features fail for ALL users for the rest of the day
- Users get error messages, complain, leave negative reviews

### Solutions (pick one based on scale)

**Option 1 — Per-user key (recommended for launch, free)**  
In Settings, prompt Pro users to add their own Gemini API key (free from aistudio.google.com). Store encrypted in local DB + Firestore. Use their key first, fall back to shared pool only if theirs fails.

```
User A → their own key (1,000 RPD free)
User B → their own key (1,000 RPD free)
User C → shared pool (only users who haven't set up their own key)
```

Pro: Zero infrastructure cost, scales to unlimited users.  
Con: User friction. Mitigate by making setup a one-step wizard with a direct link to AI Studio.

**Option 2 — Paid Gemini API key per environment**  
Enable billing on Google AI Studio, set the AQ. key to paid tier, set a monthly spending cap.  
Cost: ~$270/month at 1,000 active AI users. Affordable only once Pro subscriptions are flowing.

**Option 3 — Firebase Cloud Functions as a proxy (proper architecture)**  
Each user's AI request goes to a Cloud Function that:
1. Checks the user's auth token (Firebase Auth)
2. Checks their Pro entitlement (RevenueCat webhook)
3. Routes to the appropriate API with the server-side key
4. Enforces per-user message limits server-side

Pro: Secure (key never on device), proper rate limiting, per-user metering.  
Con: Requires Cloud Functions (Blaze plan), ~2-3 days to implement, ~$0.40/million function invocations (tiny).

**This is the right long-term solution for v4.0+.**

---

## 3 — SQLite & Local Data Scale Risks

### Current state
All financial data is stored in SQLite on the device. Firestore is only used for sync. This is actually an excellent architecture for scale because:
- **Zero Firestore reads for normal app use** — the app reads from SQLite, not Firestore
- Firestore is write-heavy only (on expense save) and read-heavy only on login/first load
- Offline works perfectly

### Risks
- SQLite has no hard size limit on Android — a user with 10,000 expenses over 3 years is fine
- DB v14 has 26 tables — queries remain fast because expense volume per user is bounded
- No concurrent write conflicts (single user per device)

**SQLite is not a scale risk. It's an architectural advantage.**

### DB migration risk at commercialization
When we release v4.0 with Pro gates and RevenueCat, the DB migration from v14 to v15 must be bulletproof. Any migration failure on a user's device = data loss = negative reviews.

**Mitigation:** Auto-backup before any migration (existing backup system). Add a `try/catch` around every migration block (already done). Seed a `whats_new` prompt to ask users to back up before major updates.

---

## 4 — RevenueCat Scale Risks

| Threshold | Cost |
|-----------|------|
| Up to $2,500 MTR/month | Free |
| Above $2,500 MTR | 1% of MTR |

**When we hit the paid tier:**  
RevenueCat charges 1% of MTR above $2,500/month. At ₱299/year (~$5.27/year):
- ~474 yearly purchases in a single month = $2,500 MTR (RevenueCat counts the full purchase amount in the purchase month)
- At that point: $25/month to RevenueCat on $2,500 revenue. That's 1% — very reasonable.

**Basis:** ₱299 ÷ ₱56.7/USD = $5.27. $2,500 / $5.27 = ~474 yearly purchases in one month.

**Not a concern. RevenueCat scales gracefully.**

---

## 5 — Play Store & Distribution Risks

### 5.1 App Check enforcement
Currently in debug mode (monitoring only). Must switch to Play Integrity before Play Store launch. If App Check enforcement is enabled without testing, legitimate users may get blocked.

**Mitigation:** Test Play Integrity on a real Play Store install (Internal Testing track) before switching enforcement mode.

### 5.2 Google Play review
Finance apps with AI features and payment processing are reviewed more carefully. Common rejection reasons:
- Missing privacy policy ✅ (we have one at zushikina-kun.github.io/smartspend-app/privacy.html)
- Missing financial disclaimer ✅ (about_screen.dart has the full disclaimer)
- Missing data safety form (must accurately declare all data collected/shared) ⚠️
- AI-generated content disclaimer missing from store listing ⚠️

### 5.3 Sideloaded APK key exposure
The AQ. Gemini key is in Remote Config, not the APK binary. But the APK does contain the Groq fallback key in `app_config.dart`. Sideloaders can extract this with tools like jadx.

**Mitigation for commercialization:** Move ALL keys to server-side (Cloud Functions proxy). This is Option 3 above.

### 5.4 Policy risks specific to finance apps
- RA 10173 (Data Privacy Act) — we handle financial data. No PII is sent to third parties without consent. ✅ PII is redacted from AI context (phone numbers stripped). ✅
- RA 11765 (Financial Consumer Protection Act) — AI advice disclaimer exists ✅
- BSP Open Finance framework — we do not access bank APIs (paste only). ✅ No regulatory license needed.

---

## 6 — Infrastructure Cost Model at Scale

### Scenario: 1,000 Monthly Active Users (500 Free + 500 Pro)

| Service | Cost/month | Notes |
|---------|-----------|-------|
| Firebase Auth | $0 | Well within 50K MAU free |
| Firestore | ~$1.00 | 1M reads + 600K writes |
| Remote Config | $0 | ~120K fetches (1,000 DAU × 4 fetches avg) |
| Firebase Storage | $0 | Profile photos — tiny |
| Gemini API (Pro users, 30 msg/day avg) | ~$135 | 500 Pro × 30 msg × 30 days × $0.0003/msg |
| Gemini API (Pro users, 150 msg/day cap) | ~$675 | 500 Pro × 150 msg × 30 days × $0.0003/msg |
| Gemini API (free users, per-user keys) | $0 | 500 Free use their own free-tier key |
| RevenueCat | $0 | Under $2,500 MTR |
| Cloud Functions proxy | ~$0.50 | 450K invocations × $0.40/M |
| **Total (30 msg/day avg)** | **~$137/month** | |
| **Total (150 msg/day cap)** | **~$677/month** | |
| **Revenue (500 Pro × ₱299/yr ÷ 12)** | **~$220/month** | At ₱56.7 per USD |

⚠️ **Note:** At ₱299/year, the **break-even point depends heavily on average AI usage**. At 30 messages/day average the margin is ~38%; at the 150/day cap the AI cost exceeds revenue. The 150 msg/day limit for Pro users should be treated as a hard ceiling, not an expected average. Actual usage from expense-tracking users is likely 10–30 messages/day — well within margin.

⚠️ **Verify Gemini quotas against your actual AI Studio project dashboard before publishing.** Third-party sources vary — some report Flash-Lite free tier as 500/day, some as 1,000/day. The exact number for your key is visible in AI Studio → API Keys → Usage.

**The math works well at 1,000 MAUs. Infrastructure is ~13% of revenue.**

### Scenario: 100 MAUs (early launch)

| Service | Cost/month |
|---------|-----------|
| Firebase (all) | $0 (within free tier) |
| Gemini API | $0 (per-user keys cover this) |
| All infrastructure | **$0** |

Early stage is completely free as long as per-user Gemini keys are used.

---

## 7 — Full Risk Register

| Risk | Severity | Likelihood | When | Mitigation |
|------|----------|-----------|------|-----------|
| Shared Gemini key exhausted | 🔴 Critical | Certain at 50+ AI users | Launch day | Per-user keys (Option 1) or paid key with cap (Option 2) |
| Shared Groq key exhausted | 🟠 High | Certain at 100+ users | Launch day | Per-user keys or remove from shared pool |
| Firestore free quota exhausted | 🟠 High | Certain at 1,000+ users | ~1,000 users | Enable Blaze with $10 spending cap. Cost is trivial. |
| Cerebras trial expires | 🟡 Medium | Certain (~30 days) | Now | Remove from chain for new users; flag in debug log |
| App Check enforcement blocking users | 🟡 Medium | Possible | Before Play Store | Test on Internal Testing track first |
| Play Store rejection (data safety form) | 🟡 Medium | Possible | Play Store submission | Fill data safety form carefully; declare AI data usage |
| Key extraction from APK (Groq key) | 🟡 Medium | Possible | Any time | Move to Cloud Functions proxy in v4.0 |
| Firebase Auth rate limit (100/hr per IP) | 🟡 Medium | Low | Only viral school-sharing scenarios | Demo mode mitigates (no account required) |
| SQLite migration failure | 🟡 Medium | Low | Each major version | Auto-backup before migration (existing). All ALTER TABLEs in try/catch. |
| RevenueCat costs | 🟢 Low | N/A until ~474 yearly purchases/month | ~500+ Pro users | 1% of revenue — acceptable |
| Firebase Auth MAU limits | 🟢 Low | N/A until 50,000 users | Far future | Not a concern |
| Groq model retirement | 🟢 Low | Ongoing | Models retire periodically | 9-provider chain provides redundancy |
| Google AI Studio policy change | 🟢 Low | Possible | Any time | Per-user keys distribute risk. Gemini paid tier as backup. |

---

## 8 — Immediate Action Items (before commercialization)

### Do now (before v4.0 launch)
1. **Enable Firebase Blaze billing** with a ₱500/month spending cap. This is the single most important infrastructure change. The Spark plan will block the app at 1,000+ users. Blaze is pay-as-you-go — it costs nothing until you hit the free tier limits, and then it's cheap.

2. **Add "Add your own AI key" setting** in Settings → AI → "Use your own Gemini key." One-time setup, stored encrypted. This is the free solution to the shared key problem for launch.

3. **Remove Cerebras from shared pool** for new users (or check trial status on init). Add a debug log entry when the trial is detected as expired.

4. **Fill out Google Play data safety form** before Play Store submission. Declare: financial data (local only), Firebase Auth (email/name), AI queries (sent to third-party API), no data sold.

### Do for v4.0 (with RevenueCat)
5. **Cloud Functions proxy for AI** — move the API key server-side. This eliminates the shared key problem permanently and enforces per-user message limits at the server level.

6. **Switch App Check to Play Integrity** — test on Internal Testing track first.

7. **Set up billing budget alerts** in Google Cloud Console — email alert at $5/month and $20/month.

---

## 9 — Architecture Roadmap for Scale

### v3.x (now) — Capstone demo / early users
```
SQLite (local) ←→ Firestore (sync)
Remote Config (shared Gemini key)
Fallback chain (shared keys)
RevenueCat: not yet
Scale: 0–100 users safely
```

### v4.0 — Freemium launch
```
SQLite (local) ←→ Firestore (Blaze billing enabled)
Remote Config (shared key + per-user key option)
Cloud Functions proxy (AI) — server-side key management
RevenueCat (IAP)
Scale: 100–5,000 users safely
```

### v5.0 — Growth phase
```
SQLite + Firestore (same)
Cloud Functions (AI proxy, per-user rate limiting, Pro enforcement)
Paid Gemini key (shared pool for Free users, per-user for Pro)
RevenueCat + analytics
Scale: 5,000–50,000 users
```

---

## 10 — Gaps & Oversights Outside Infrastructure

### 10.1 No email verification enforcement
Firebase Auth allows login with any email without verification. A user can sign up with a fake email and use the app. For the capstone this is fine. For commercialization, unverified emails mean no contact channel for support or subscription notifications.

**Mitigation:** Enable email verification in Firebase Auth settings (one config toggle). Show a banner to unverified users.

### 10.2 No rate limiting on sync
The app syncs to Firestore on every expense save. A user who rapid-fires 100 expense logs (e.g., via batch import) generates 100 Firestore writes instantly. At scale with many such users, this could spike costs.

**Mitigation:** Batch writes into groups of 10–20 using Firestore's `WriteBatch`. Already needed for batch import.

### 10.3 No abuse detection
A malicious user could use the AI chat to query the API indefinitely (within the 30/150 msg/day limit). Since the limit is per-device (SharedPreferences), a factory reset resets the counter.

**Mitigation for v4.0:** Move the daily limit counter to Firebase Auth user document (server-side) rather than SharedPreferences. Requires the Cloud Functions proxy.

### 10.4 No session analytics
We have no visibility into how many users are active, which features are used, how often AI is called, or what the actual Firestore read/write counts look like. Flying blind.

**Mitigation:** Firebase Analytics is already in the project (it's free forever). Add event tracking for: `ai_message_sent`, `pro_paywall_shown`, `pro_purchased`, `screenshot_import_used`.

### 10.5 The Gemini AQ. key rotation
AQ. keys are "permanent" according to Google (they don't expire). However, if the key is compromised (extracted from APK/Remote Config), it could be used by others, burning our quota.

**Mitigation:** App Check (Play Integrity) prevents non-Play-Store builds from accessing Remote Config. Already in the app — just needs switching from debug to enforcement mode.

### 10.6 No backup of Firestore security rules
The Firestore security rules are configured in the Firebase Console. If they're accidentally wiped or misconfigured, user data becomes either publicly accessible or completely inaccessible.

**Mitigation:** Export and commit `firestore.rules` to the repository. Add to HOWTORUN.md.

---

*Sources: Firebase pricing page (firebase.google.com/pricing, Oct 2026), Cloud Firestore pricing (cloud.google.com/firestore/pricing), Gemini API rate limits (ai.google.dev, aifreeapi.com Oct 2026), Groq free tier (localaimaster.com Aug 2026, laozhang.ai Oct 2026), Cerebras pricing (morphllm.com Jun 2026, freeapihub.com), RevenueCat pricing (revenuecat.com/pricing Oct 2026), Firebase Auth limits (firebase.google.com/docs/auth/limits). Content paraphrased for licensing compliance.*
