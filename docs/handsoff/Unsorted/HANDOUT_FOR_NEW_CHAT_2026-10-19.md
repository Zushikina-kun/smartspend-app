# SmartSpend capstone — handout for a fresh Claude chat (Oct 19, 2026)
Paste this file (and attach the files listed in §3) at the start of the new chat. It replaces the long history.

## 1. Who/what
- User: **Brix A. Directo** ("Brix"), lead dev of **SmartSpend** (Team Lucid Frame, Lorma Colleges, La Union, PH). Teammates: Cyrille John M. Rubis (UI/UX + documentation), Djaunathan Albert S. Madayag (PM + QA). Adviser: Ellen F. Mangaoang, MIT. Panel: Shekiro R. Raposas, Mary-Ann Mzana. Chairperson TBA. (Verzola is a former adviser — remove from anything current.)
- **Reply in English only, terse, direct, actionable.** No padding. He's frustrated by rate limits and delays; give finished files, short summaries.
- Kiro = his coding AI (keeps the app + its own docs in the repo). Claude = planning, research, QA, documents. Brix is the courier between them.
- App: Flutter/Android, offline-first SQLite + Firebase, 9 AI providers (8 cloud + optional local LLM), **v3.1.0** (Peso companion). Numbers: 34 AI actions, 36 badges, 11 themes, 45 screens, 33 services, SQLite v14 / 26 tables, APK ~47.5 MB, 57 currencies, 7 input methods.

## 2. HARD RULES
1. **Never change the manuscript's styles/formatting/quirks** — content-only edits, clone existing paragraph/table formatting. Never overwrite his originals; deliver new numbered copies.
2. **Never invent data.** Survey results do not exist yet; SUS and Objective-1 numbers must stay `[[PENDING]]` until they come from the real Google Form responses. Verify claims before stating them; say "unverified" when not.
3. Don't claim: "free forever", "only Filipino app…", "data never leaves" (true only in Local-only mode), unverified stats, SUS scores, exact FHS pillar names publicly (see §5.1).
4. The sandbox **resets between sessions**: /home/claude is wiped; only files in /mnt/user-data/outputs and uploads survive. Memory notes persist. Don't rely on old scripts being present.

## 3. Files (all in outputs; re-attach what you need)
| File | What it is |
|---|---|
| `CAPSTONE_LucidFrame_-_SMARTSPEND__4_.docx` | **Latest manuscript** (Chapters III–IV, Table 2.2, 16 refs, Abstract/BSP/badge fixes). Notes: `MANUSCRIPT_4_UPDATE_NOTES.md` |
| `build_ms4.py`, `build_ms4_lib.py` | Scripts that built __4_ from __3_ (paths: /home/claude/cur.docx, /home/claude/guide.md). Clone-based, python-docx |
| `MANUAL_EDIT_GUIDE_v3.md` | Copy-paste guide for teammates (Ctrl+F steps, Parts 1–7, defense Q&A, Kiro Local-LLM fixes) and the source text for Ch. III/IV |
| `FHS_Basis_and_Verification.docx` | Standalone FHS basis + verification checklist (corrected citations) |
| `SmartSpend_Comparative_Research_Report.docx` | Competitor + AI landscape + FHS lineage report (v3.1.0 numbers) |
| `claude-to-kiro-FINAL-sync-2026-10-15.md` | The ONE consolidated note to give Kiro (older sync notes are obsolete) |
| `ads-and-survey-copy-pack-2026-10-15.md` | Safe ad/caption copy, survey fixes, claims to avoid |
| `SmartSpend_Manuscript_FIXED.docx`, `CAPSTONE_LucidFrame_-_SMARTSPEND__3_.docx` | Older manuscripts; __3_ = base the group may have edited by hand |

## 4. Verified facts (keep using)
- **FHS** (manuscript formula): 4 components × 25: Savings Rate = 25·min(1, rate/0.20); Overspend Control = 25·(1 − (hard + 0.5·soft)/activeDays); Budget Adherence = 25·onBudget/budgeted; Logging Consistency = 25·logged/active. Lightweight mode swaps in Spending Restraint, Category Balance (Bills/Health/Education excluded), Habit Streak (14 days). Adjustments: Warning Decay min(15, 5·days) (discretionary only), Gap Adjustment +2/−3 per day (caps +10/−15). Soft/hard split and the Bills/Health/Education exemption were confirmed in `score_service.dart` (Oct 6). **Open: Budget Adherence with zero budgets.**
- **Basis:** CBA–Melbourne Institute Observed scale (Comerton-Forde et al., 2018, Technical Report No. 1) = transaction-based approach + equal-weight sum to 0–100; FinHealth Score® (Spend/Save/Plan); UNSGSA note (Gubbins, Mazzotta & Rhyne, 2021) calls transaction data an early-stage complement to surveys (not a replacement); Melbourne Institute Terms ask modified scales to use a different name → "Prototype Observed Financial Health Indicator". Warren & Tyagi (20% target), Kahneman & Tversky + Thaler & Sunstein (Warning Decay), Deci & Ryan (SDT), Davis (TAM), Bitrián, Buil & Catalán (2021, IJBM 39(7), DOI 10.1108/IJBM-02-2021-0074).
- **BSP CFIS 2025:** literacy 74% (69% in 2021); account ownership 50% (56%); household access **85%** (Consumer Expectations Survey, from 74%) — not 86%.
- **Google's unpaid Gemini terms:** free-quota content may be used to improve products and read by reviewers; don't submit personal info. Blaze billing does NOT by itself change this — depends on the key's Cloud project. Free quotas (one third-party source, Sept 2026): Flash-Lite 500/day, Flash ~20/day — verify in AI Studio.
- **RA 10173 Sec. 3(l)** does not list financial transaction data as sensitive PI (it lists government IDs, tax returns, health, etc.). RA 11765 is a consumer-protection law, not an AI law.
- Sharma, Gaba & Sharma (2026) citation = unverifiable → removed. SUS grading: Bangor (80–89 = B) vs Sauro–Lewis (≈80.3+ = A): pick one and cite it.
- Pricing/scale docs from Kiro had errors (87% margin/$1,082 claim wrong; real ≈$220/mo for 500 yearly Pro users; cost at the 150/day cap ≈$675/mo). Freemium (₱59/₱299/₱799) is planned v4.0, **not implemented → keep out of the manuscript.**

## 5. Open items (what's still needed)
1. **Kiro:** which 4 FHS pillars the app actually scores — the public site says Savings Rate, Budget Adherence, **Budget Setup**, Logging Consistency (conflicts with manuscript). Also: zero-budget behavior; exact RA 10173 redaction targets (manuscript says "mobile numbers" only until confirmed); exact cloud-AI payload; Cerebras key status; local-mode backup folder on Android 11+; licence type; check his chapter-4/defense-script files for fake SUS numbers.
2. **Survey:** two Google Forms are live; SUS site banner wrongly invites non-users. Fixes: use-first screening, 18+, consent line, no-email if "anonymous". Brix must paste the form questions so Claude can check them. Results go into `[[PENDING]]` spots only. Recruitment via social posts = self-selected sample; tell adviser.
3. **Manuscript:** update hand-typed TOC/List of Tables; title page "Proposal"/date; verify Dean/chair; unverified refs (FHN 2026, Groq 2026, Li 2024); confirm or run the 50-receipt parsing test (Table 3.4); benchmark run for 5 models (Table 3.2 "TBD" cells); Figures 1.1, 1.2, 2.1, 2.2 still need to be drawn.
4. **Ads:** another AI built 3 ads (private design file). Needs corrected copy (pack above), real v3.1.0 screenshots, Peso art; Brix decides whether Claude rebuilds them.
5. Personal GCash number is published on site/README/app — Brix's call (a QR avoids it).

## 6. Technical lessons (save time)
- LibreOffice **crashes on the manuscript's two floating tables** (Tables 1.1/1.2); Word is fine. To preview, make a *throwaway* copy with `w:tblpPr` removed, convert with soffice (poll with a timed loop; don't use `pkill -f` patterns that match your own command).
- python-docx edits that only change run text/clone paragraphs keep the package byte-identical except document.xml (verified by diffing parts). Insert `w:br` AFTER `w:rPr`; keep `w14:paraId` unique (continue sequence from max).
- Source .py files store `\uXXXX` as literal text; patch with double-escaped strings. Keep tool calls few; the user is hitting rate limits.
