# Claude → Kiro — Consolidated Sync (Oct 15, 2026)
**Give Kiro only this file.** It replaces the earlier notes (sync-2026-10-06, -07, -10, -11, -12): resolved items are
dropped, still-open items are merged here. Claude checked the live site (zushikina-kun.github.io/smartspend-app), the
GitHub README, the SUS form and Kiro's Oct 9–13 handoffs. Items are ordered by risk for the defense.

---

## 1. 🔴 FHS pillars on the public site ≠ the manuscript (needs one answer from you)
- Site FAQ, screenshot caption and interactive demo say the four pillars are **Savings Rate, Budget Adherence, Budget Setup,
  Logging Consistency** (demo: +25 / +24 / +25 / +20). The site's feature card says "savings rate, budget adherence, **debt load**,
  and spending control".
- The manuscript, the FHS verification doc and your CAPSTONE_REFERENCE use **Savings Rate, Overspend Control, Budget Adherence,
  Logging Consistency** (soft/hard overspend confirmed in `score_service.dart` lines 402–431 on Oct 6).
- **Question:** what does the shipped v3.1.0 `score_service.dart` actually score, and what labels does the FHS breakdown dialog
  show? If "Budget Setup" is real, the manuscript formula is wrong or incomplete and Claude must rewrite it. If the site is stale,
  fix the site (FAQ, caption, demo, feature card). The panel and the financial-expert validator can read the public site.
- Still the only open scoring question from the old list: **Budget Adherence with zero budgets** (skip/reweight/auto-25/other).
  The Category Balance and Warning Decay items you keep re-listing were settled Oct 6: exemption is automatic
  **Bills/Health/Education**; there is no emergency flag. Do not build one and do not revert the docs.

## 2. 🔴 SUS survey validity and results
- Your Oct 13 handoff says SUS results come "after 30 respondents complete the survey". So **no results exist yet**. The manuscript
  numbers (SUS 82.50, N=30, group means, "qualitative themes") were not collected data. Claude has replaced them with blanks in
  the guide. **Please check `smartspend-thesis-chapter-4.md` and the defense script for the same numbers** (search 82.5, 82.50,
  N=30, "Grade B", "themes") and replace with "pending". A defense script quoting results that don't exist is the biggest
  integrity risk in the project.
- Website banner says "Whether you've used the app or not — your responses count." **A SUS answer from someone who never used the
  app is not valid.** Change the SUS banner to "Try the app (or the demo) for about 10 minutes first, then answer." Add a form
  question "Did you use SmartSpend for at least 10 minutes?" and exclude "No" answers. The SUS form intro says "first impression of
  the app" but does not tell people to use it first. Add an 18+ confirmation and a short Data Privacy Act consent statement
  (purpose, what is collected, who sees it, contact). "Anonymous" is only true if the form does not collect emails or require sign-in.
- Claude could not see the form questions (Google renders them in JavaScript). Brix should paste or export them so the 10 SUS items
  can be checked against the standard wording and the demographic items against the target groups (parents 35–55, young professionals 21–35).
- Recruitment through public social posts gives a self-selected convenience sample. The manuscript says "purposively selected"; it
  will be reworded to match what actually happens once the responses are in.

## 3. 🔴 Privacy and "free" claims on the public site
- **Google's unpaid Gemini terms** (ai.google.dev/gemini-api/terms): content on the free quota may be used to improve Google
  products and read by reviewers; developers are told not to submit personal information. The site says only "conversation text is
  sent". Disclose it in the privacy policy and the first-AI-message disclosure. Firebase **Blaze billing does not by itself switch the key to
  paid terms**: the terms follow the Cloud project the key belongs to. Check the key's project shows paid tier in AI Studio.
- FAQ says "the conversation text (not your full expense history) is sent". The manuscript describes context injection (recent expenses,
  budgets, goals in the system prompt, roughly 1,000–5,000 tokens). **List exactly what the cloud payload contains** and make the FAQ
  match it.
- The "Problem" list says cloud AI "stores your financial conversations on foreign servers", yet the default mode is cloud AI. Reword
  or the page contradicts itself.
- "Completely free, forever. No subscriptions, no premium tier" conflicts with your own v4.0 freemium plan. Use "free right now".
- "The only Filipino finance app with a built-in local AI mode" cannot be verified; use "one of the few" or drop it.
- README footer says "© 2026 Lucid Frame. All rights reserved"; the site says "open source". What licence is in `LICENSE`?
- Site says "3rd-year Computer Science students"; the manuscript says BSIT, final year, College of Computer Studies and Engineering. One version.
- Brix's personal GCash number is published on the site, README and app. His call; a GCash QR avoids exposing a phone number.
- Still unverified marketing numbers: "45–60 TOPS", "20–50 tokens/second", "Snapdragon 8 Gen 5 / Tensor G6", "99% of phones".
  Site names Gemma 3 / Phi-4 / Qwen 3 as candidates while your research doc plans Gemma 4 E2B. Pick one story.

## 4. 🟠 Stale facts on the site and README
- Site AI chain lists "Compound" and "Compound Mini" and omits GPT-OSS 20B, says "8-provider" while the changelog says 9 providers.
  Manuscript chain: Gemini 3.5 Flash-Lite → Gemini 3.5 Flash → GPT-OSS 120B → Qwen 3.6 → Qwen 3.8 → GPT-OSS 20B → Compound Mini → Cerebras (+ local).
- Site badge counts: "25 badges" in two places, "36" in the changelog and counter. Current = 36.
- Screenshots are v3.0.4 (site says so). Peso is on 34 of 45 screens (site's own audit), not "all 45" as in your Oct 13 handoff.
- README: v2.9.8, "31 agentic actions", "Gemini 3.1 Flash-Lite", retired Groq LLaMA models, "23 badges", "sqflite v11", "5 color themes".
  Current: v3.1.0, 34 actions, Gemini 3.5 Flash-Lite, 36 badges, SQLite v14 / 26 tables, 11 themes, 45 screens, 33 services.
- Repo `docs/MANUSCRIPT_FIXES.md` ("19 Google Docs fixes") predates Claude's `MANUAL_EDIT_GUIDE_v3.md`. Mark it superseded so Cyrille does
  not follow both. `docs/BENCHMARK.md` Part 6 is still stale (dead LLaMA chain, 60/day limit).

## 5. 🟠 Carry-over items still open from earlier rounds
1. **RA 10173 redaction extent:** paste the actual targets from `ai_chat_service.dart`. The manuscript says "mobile numbers" only until then.
2. **Gemini free quotas:** read the real numbers from AI Studio. Latest source found (Sept 2026, third-party): 500 requests/day Flash-Lite,
   about 20/day Flash. Your docs said 1,000 / 250.
3. **Pricing/scale doc:** confirm the corrected figures. Reference: 500 yearly Pro users at ₱299 ≈ $220/month revenue; Gemini cost for 500 users at the 150/day cap ≈ $675/month
   (≈$135 at 30/day); break-even average usage ≈ 41 messages/day on the yearly plan.
4. **Cerebras trial:** if expired, the 9-provider count and the "last resort" wording need a footnote.
5. **Local-mode backup folder:** `Android/data/<pkg>/files/` is deleted on uninstall and often unreachable from the Files app on Android 11+ (stricter on 13+).
   Prefer the share sheet or Downloads via MediaStore/SAF; test on a real Android 13 phone.
6. **On-device doc:** Pixel 9 uses Tensor G4, not Snapdragon; the ~55 tok/s figure matches Google's Galaxy S26 Ultra benchmark
   (≈47 CPU / ≈52 GPU); LiteRT-LM now lists Flutter APIs; state Android 8+ (MediaPipe) vs 10+ (LiteRT-LM).
7. **Manuscript Local-LLM blocks:** use the corrected wording in Part 6 of `MANUAL_EDIT_GUIDE_v3.md` (chapter map, 16-bit quantization, RA 10173
   Sec. 3(l) does not list financial data as sensitive, RA 11765 is not an AI law, EY stat not in Claude's report, remove "PhilPad" source).

## 6. What Claude has that your docs lack
- **FHS lineage with corrected citations:** CBA-Melbourne Institute (Comerton-Forde et al., 2018, Technical Report No. 1) for the Observed bank-record scale and equal-weight sum
  to 0–100; FinHealth Score® for Spend/Save/Plan ideas; UNSGSA note (Gubbins, Mazzotta & Rhyne, 2021) calls transaction data an early-stage complement to surveys;
  Melbourne Institute's Terms ask that modified scales get a different name. Make sure `CAPSTONE_REFERENCE.md` no longer says "Measuring financial resilience",
  and add Kahneman & Tversky (1979) to its bibliography.
- **BSP figures:** household financial access 85% (Consumer Expectations Survey, up from 74%), not 86%. Literacy 74% vs 69% and account ownership 50% vs 56% are from CFIS 2025.
- **Citations replaced:** Sharma/Gaba/Sharma (2026) removed (unverifiable DOI). Use Bitrián, Buil & Catalán (2021), International Journal of Bank Marketing 39(7); Wajid et al. (2025).
- **Replace your "locked" copies** of `FHS_Basis_and_Verification.docx` and the comparative report with Claude's latest (v3.1.0 numbers, corrected citations, quota notes).
- **Numbers Claude now uses:** v3.1.0; SQLite v14 / 26 tables; 9 providers; 34 actions; 36 badges; 11 themes; 45 screens; 33 services; APK ≈ 47.5 MB.
- Freemium/pricing is deliberately **not** in the manuscript text.

## 7. Needed from Kiro (short list)
1. Which four FHS pillars are scored and labelled in v3.1.0 (item 1).
2. Budget Adherence behaviour with zero budgets.
3. Exact RA 10173 redaction targets; exact cloud-AI payload contents.
4. Chapter 4 / defense-script search for SUS numbers (item 2).
5. Licence type; Cerebras status; AI Studio quota numbers; backup-folder test result.
