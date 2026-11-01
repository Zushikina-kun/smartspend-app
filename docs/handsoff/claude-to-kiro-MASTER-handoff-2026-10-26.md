# Claude → Kiro — MASTER Handoff (Oct 26, 2026)
**Give Kiro only this file.** It supersedes `claude-to-kiro-FINAL-sync-2026-10-15.md` and every older sync note.
Written Oct 26 for use when Kiro resets on **Nov 1**. Everything below was checked against the live repo/site
(github.com/Zushikina-kun/smartspend-app, zushikina-kun.github.io/smartspend-app) or marked **[unverified]**.

---

## 0. Deadlines (from panelist Shekiro R. Raposas, Oct 26)
| Date | What |
|---|---|
| **Nov 6, 2026** | 3 printed copies of the manuscript submitted |
| before defense | Defense fee paid (computation comes from Sir Raposas) |
| by Nov 6 (assumed, confirm) | Pitch video; Certificate of Deployment **or** MOA |
| **Nov 9, 2026** | Final defense starts |

Kiro resets Nov 1, so only **Nov 1–5** is available. The manuscript can't be finished until Kiro's answers in §1 are in.
**Please answer §1 first, in a short file, before doing anything else.** Name it `kiro-to-claude-answers-2026-11-01.md`.

---

## 1. 🔴 P0 — Answers Claude needs to finish the manuscript (do these first, ~30 min)
Answer each with the exact value from code and the file/line it came from. No "I think".

1. **FHS pillars.** What does shipped v3.1.0 `score_service.dart` actually score, and what label text does the FHS breakdown dialog show?
   - Public site FAQ/caption/demo says: Savings Rate, Budget Adherence, **Budget Setup**, Logging Consistency (demo +25/+24/+25/+20). Site feature card says "savings rate, budget adherence, **debt load**, and spending control".
   - Manuscript, FHS doc and CAPSTONE_REFERENCE say: Savings Rate, **Overspend Control**, Budget Adherence, Logging Consistency.
   - Tip: `grep -rn "Overspend\|Budget Setup\|Budget Adherence\|debt" lib/services/score_service.dart lib/`.
   - If "Budget Setup" is real, tell Claude. The manuscript formula must be rewritten. If the site is stale, fix the site (§3).
2. **Budget Adherence with zero budgets:** skip, reweight, auto-25, or other? (Only open scoring question. Do not re-open Category Balance/Warning Decay: exemption is automatic for **Bills/Health/Education**, there is no emergency flag. Do not build one. Do not revert the docs.)
3. **RA 10173 redaction:** paste the actual patterns/targets from `ai_chat_service.dart`. Manuscript says "mobile numbers" only until confirmed.
4. **Cloud-AI payload:** list exactly what is sent to the provider (chat text, recent expenses, budgets, goals, system prompt, approx. tokens). The site FAQ says expense history is NOT sent; the manuscript says context injection sends it. One of them is wrong.
5. **Cerebras:** is the trial/key still active? (Affects the "9 providers" count and "last resort" wording.)
6. **Gemini quotas:** read the real RPD/RPM for the key's project from AI Studio (latest third-party figure: Flash-Lite ~500/day, Flash ~20/day; your docs said 1,000/250). Also confirm the key's Cloud project is on **paid** terms.
7. **Fake SUS numbers:** search `smartspend-thesis-chapter-4.md`, the defense script, DEFENSE_REVIEWER.md, PAPER_GUIDE.md and any docs for `82.5`, `82.50`, `N=30`, `Grade B`, "themes", "qualitative". Replace with "pending". Surveys are still open, so **no SUS results exist**. A defense script quoting results that don't exist is the biggest integrity risk in the project.
8. **50-receipt parsing test:** does a real, logged test run exist (files, dates, per-document-type results)? If yes, paste the log. If no, say so. Claude then leaves Table 3.4 blank.
9. **Local-mode backup folder:** `Android/data/<pkg>/files/` is deleted on uninstall and often unreachable on Android 11+. Test on a real Android 13 phone, and say whether share sheet / Downloads (MediaStore/SAF) works.
10. **Dean / chairperson / title page:** if any repo doc has the current Dean's name or the chairperson, paste it. Claude's manuscript has Dean "Jeoffrey B. Layco, MIS" from a draft (unverified), chairperson TBA.

---

## 2. 🔴 P0 — Repo fixes (panel can read these; ~15 min)
Verified on Oct 26:
- **LICENSE** is a custom *Source Available License (Non-Commercial)*: allows academic review, personal non-commercial study, PRs; prohibits commercial use, rebranding, plagiarism and app-store publishing without written permission; reserves future commercial rights. So:
  - README footer "All rights reserved" → "Source Available License (Non-Commercial). See LICENSE."
  - Everywhere "open source" appears (site, docs) → "source-available".
  - Decide: LICENSE bars store publishing without permission, while your v4.0 plan assumes Play Store. Fine for the owners (they hold the rights), but don't describe it as open source.
- **README is stale** (still v2.9.8). Update to current:

| README says | Current (verified Oct 15) |
|---|---|
| v2.9.8 | **v3.1.0** |
| 31 agentic actions | **34** |
| "Gemini 3.1 Flash-Lite" primary; Groq LLaMA 3.3 70B / 3.1 8B; Cerebras LLaMA 3.1 | **Gemini 3.5 Flash-Lite** → Gemini 3.5 Flash → GPT-OSS 120B → Qwen 3.6 → Qwen 3.8 → GPT-OSS 20B → Compound Mini → Cerebras (+ optional local LLM) = 9 providers (LLaMA models are retired) |
| 23 badges | **36** |
| sqflite v11 | **SQLite v14 / 26 tables** |
| 5 color themes | **11** |
| (screens/services not listed) | **45 screens, 33 services** |
- Mark `docs/MANUSCRIPT_FIXES.md` ("19 Google Docs fixes") **superseded by `MANUAL_EDIT_GUIDE_v3.md`** (Claude's) so Cyrille doesn't follow both. `docs/BENCHMARK.md` Part 6 is stale (dead LLaMA chain, 60/day limit); mark it stale, don't cite it.
- Team description everywhere: **Brix A. Directo (Lead Dev), Cyrille John M. Rubis (UI/UX & Documentation), Djaunathan Albert S. Madayag (Project Manager & QA)**; adviser Ellen F. Mangaoang, DIT. The official college name is **College of Computer Studies and Engineering** (per Lorma's format guide and approved manuscripts; the LICENSE matches). Use "Studies" everywhere.

---

## 3. 🟠 P1 — Public site fixes (GitHub Pages)
1. **FHS pillars** per your §1.1 answer (FAQ, screenshot caption, interactive demo, feature card).
2. **SUS banner** currently says "whether you've used the app or not, your responses count": **invalid for SUS**. Change to: *"Try SmartSpend (or the Try Demo mode) for about 10 minutes first, then answer."* (Brix can do this one-line edit himself **today**; the surveys are live now.)
3. Contradictions to remove:
   - "Completely free, forever, no premium tier" → "Free right now" (your v4.0 freemium plan conflicts).
   - "The only Filipino finance app with a built-in local AI mode" → "one of the few", or drop (unverifiable).
   - "Problem" list says cloud AI stores finances on foreign servers, yet default mode is cloud AI. Reword.
   - Privacy FAQ vs actual payload: make it match §1.4. Add Google's unpaid-tier disclosure if the key is on free terms (free-quota content may be used to improve Google products and read by reviewers; devs are told not to submit personal info).
   - "3rd-year Computer Science students" → "final-year BSIT students".
   - "open source" → "source-available".
4. Stale facts: AI chain lists "Compound"/"Compound Mini" and omits GPT-OSS 20B; "8-provider" vs 9; badge count "25" (two places) vs 36; screenshots are v3.0.4; Peso is on 34 of 45 screens (the site's own audit), not "all 45".
5. Unverified marketing numbers to remove or source: "45–60 TOPS", "20–50 tokens/second", "Snapdragon 8 Gen 5 / Tensor G6", "99% of phones". Pick one local-model story (Gemma 3/Phi-4/Qwen 3 on the site vs Gemma 4 E2B in your research doc).
6. Brix's personal GCash number is published (site, README, app). His call; a GCash QR avoids exposing a phone number.

---

## 4. 🟠 P1 — Survey (Brix can do the form edits himself now, no Kiro needed)
Forms are live (Google renders them in JS, so Claude couldn't read the questions). Needed fixes: use-first banner; first question "Did you use SmartSpend for at least 10 minutes?" (Yes/No; only Yes counts); 18+ confirmation; consent line (voluntary, purpose, what's collected, who sees it, contact); no email/sign-in collection if it says "anonymous"; demographics (age band, occupation, city/province, phone brand/RAM). Exact copy is in the "SmartSpend Defense Prep Pack" doc §4. Recruitment through social posts is a self-selected convenience sample; the adviser must be told.

---

## 5. 🟠 P1 — Things the app must support for the deliverables
1. **Pitch video (≈3 min):** needs a clean **v3.1.0** screen recording. Please prepare: a demo account/seed data (a realistic month), "Try Demo" working, FHS breakdown dialog visible, all 7 input methods demonstrable (chat Taglish, voice, receipt photo, batch screenshots, barcode, bank text paste, manual), Local AI mode + Local-only toggle screens. Record or hand Brix the steps. Script is in the Defense Prep Pack doc §3.
2. **Real v3.1.0 screenshots + Peso art** for the 3 ads and the site (current site shots are v3.0.4).
3. **Deployment proof (Certificate of Deployment / MOA requirement).** Brix recalls Sir Raposas saying no partner organization is needed as long as the app is deployed (Brix will confirm in writing). There is no Play Store release (new personal accounts need a 12-tester / 14-day closed test first), so the deployment is the **public release**: the GitHub Pages download site + a GitHub Release with the APK. Provide: the **APK (arm64) release link**, a one-page install + first-use guide in plain English/Taglish, and an in-app or first-run notice that says in cloud AI mode chat is processed by third-party AI providers. If a pilot organization is later needed, templates are in the "Certificate of Deployment and MOA Templates" doc.
4. **Make sure Release v3.1.0 exists on GitHub with the APK attached** (the repo page showed no releases in the fetched view; confirm). Verify the site's download button points to `releases/latest/download/SmartSpend-v3.1.0-arm64-v8a.apk` and that the file downloads and installs on a clean Android phone. Screenshot the Releases page and the download count for the deployment evidence.

---

## 6. Corrections Claude already made to Kiro's docs (don't regress)
- **Pricing/scale:** old claims ("87% margin / $1,082", "1.6% at 10k users") were wrong. Reference: 500 yearly Pro users at ₱299 ≈ **$220/month** revenue; Gemini cost for 500 users at the 150/day cap ≈ **$675/month** (≈$135 at 30/day); break-even ≈ 41 messages/day on the yearly plan. Freemium (₱59/₱299/₱799) is a planned v4.0, **not in the manuscript**. Don't add it.
- **On-device doc:** Pixel 9 uses **Tensor G4**, not Snapdragon; the ~55 tok/s figure matches Google's Galaxy S26 Ultra benchmark (≈47 CPU / ≈52 GPU); LiteRT-LM lists Flutter APIs; state Android 8+ (MediaPipe) vs 10+ (LiteRT-LM).
- **Law:** RA 10173 Sec. 3(l) does not list financial transaction data as sensitive PI. RA 11765 is a consumer-protection law, **not an AI law**. EY stat is not in Claude's report. Remove the "PhilPad" source.
- **Manuscript chapter map:** there is no Chapter 5. Manuscript = Ch. I–IV (Ch. III Results & Discussion, Ch. IV Conclusions & Recommendations).
- **16-bit quantization wording** and Local-LLM blocks: use the corrected text in `MANUAL_EDIT_GUIDE_v3.md` Part 6.
- **Citations:** Sharma/Gaba/Sharma (2026) removed (unverifiable DOI). Use Bitrián, Buil & Catalán (2021), *International Journal of Bank Marketing* 39(7), DOI 10.1108/IJBM-02-2021-0074; Wajid et al. (2025). CBA-MI = Comerton-Forde et al. (2018), Technical Report No. 1. UNSGSA note = Gubbins, Mazzotta & Rhyne (2021), "Measuring financial health: Concepts and considerations". Make sure `CAPSTONE_REFERENCE.md` no longer says "Measuring financial resilience" and add Kahneman & Tversky (1979) to its bibliography.
- **BSP figures:** household financial access **85%** (Consumer Expectations Survey, up from 74%); literacy 74% vs 69% and account ownership 50% vs 56% (CFIS 2025). "62% online transactions" and "3 in 10 emergency savings" are **unverified**. Don't use.
- **People:** adviser **Ellen F. Mangaoang, DIT**. Panel: **Shekiro R. Raposas, Mary-Ann Mzana**; chairperson TBA. **Verzola is a former adviser** and must not appear as current. "Jopher F. Reyes" / "Gelo Ryann M. Carbonell" in some of your docs are wrong.
- Replace your "locked" copies of `FHS_Basis_and_Verification.docx` and the comparative report with Claude's latest versions.

---

## 7. Verified numbers to use (v3.1.0)
34 AI actions · 36 badges · 11 themes · 45 screens · 33 services · SQLite v14 / 26 tables · 9 AI providers (8 cloud + optional local LLM) · APK ≈ 47.5 MB · 57 currencies · 7 input methods · 150 AI msgs/day cap · Peso on 34 of 45 screens.

**FHS (manuscript formula, pending §1.1):** 4 × 25. Savings Rate = 25·min(1, rate/0.20); Overspend Control = 25·(1 − (hard + 0.5·soft)/activeDays); Budget Adherence = 25·onBudget/budgeted; Logging Consistency = 25·logged/active. Lightweight mode: Spending Restraint, Category Balance (Bills/Health/Education excluded), Habit Streak (14 days). Warning Decay min(15, 5·days), discretionary only. Gap Adjustment +2/−3 per day (caps +10/−15). Named "Prototype Observed Financial Health Indicator" in the paper; "Financial Health Score" in the app UI.

---

## 8. Who does what
| Owner | Task | When |
|---|---|---|
| **Brix (now, no Kiro)** | Fix both Google Forms (§4); edit site SUS banner; get adviser OK on recruitment; start collecting responses; pick the deployment partner; read Sir Raposas about video length/format and MOA template | Oct 26–27 |
| **Brix (now)** | Optional shortcut for §1: open `score_service.dart` and `ai_chat_service.dart` locally and paste the relevant lines into the answers file | any time |
| **Kiro** | §1 answers file → §2 repo fixes → §3 site fixes → §5 demo/video support, screenshots, install guide | Nov 1–3 |
| **Claude** | When answers + real survey data arrive: fill every `[[PENDING]]`/`[[VERIFY]]` tag in `CAPSTONE_LucidFrame_-_SMARTSPEND__4_.docx` from real data only, update TOC/List of Tables, title page, rebuild; also pitch script, certificate/MOA, defense Q&A | Nov 2–4 |
| **Team** | Read-through in Word (Ctrl+F `[[` must find nothing), print 3 copies, pay fee | Nov 4–6 |

## 9. Rules for Kiro
1. **Never invent data.** No SUS scores, user counts, ratings, testimonials. Survey results come only from the real Google Form responses.
2. Do not change settled decisions (Oct 6): soft/hard overspend split, Bills/Health/Education exemption, no emergency flag.
3. Do not put freemium/pricing into the manuscript or the ads.
4. If you can't verify something, write "unverified" rather than a number.
5. Don't claim "your data never leaves your phone" (true only in Local-only mode), "free forever", "only Filipino app…", or SUS results.
6. Reply short and concrete. Put answers in one file; don't rewrite Claude's documents.

---

## 10. Claude's files (Brix carries these to Kiro if needed)
`CAPSTONE_LucidFrame_-_SMARTSPEND__4_.docx` (latest manuscript; 69 `[[PENDING]]/[[VERIFY]]` tags) · `MANUSCRIPT_4_UPDATE_NOTES.md` · `MANUAL_EDIT_GUIDE_v3.md` · `SmartSpend_Comparative_Research_Report.docx` · `FHS_Basis_and_Verification.docx` · `ads-and-survey-copy-pack-2026-10-15.md` · `HANDOUT_FOR_NEW_CHAT_2026-10-19.md` · Claude Docs: "SmartSpend Defense Prep Pack (Nov 9, 2026)", "Certificate of Deployment and MOA Templates".
