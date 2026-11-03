# Claude — Manuscript Update Brief (November 1, 2026)
**For:** Claude's next session editing the manuscript .docx
**Manuscript file:** `CAPSTONE_LucidFrame_-_SMARTSPEND__5_.docx`
**Build scripts:** `build_ms4.py` + `build_ms4_lib.py` (same repo, docs/handsoff/)
**Supersedes:** all previous manuscript update notes

---

## What Kiro did to the markdown sources this session (already done)

- `smartspend-thesis-chapter-4.md` — FHS derivation expanded (CBA-MI basis, Lightweight Mode, Warning Decay); 73.4% tagged `[[PENDING]]`; Peso v3.1.2 section updated with tier ring + behavior caveat
- `smartspend-thesis-defense-script.md` — Verzola removed, Mangaoang DIT as adviser, TBA chairperson, Raposas/Mzana as panel
- `MANUAL_EDIT_GUIDE_v3.md` — Part 8 added (8 new tasks for Cyrille)
- `docs/capstone/FHS_Formula_Basis_Table.md` — NEW: 3 tables for adviser validation
- `docs/capstone/SmartSpend_Selected_Survey_Questions_FINAL.md` — NEW: 30-question finalized instrument

---

## P0 — Do these FIRST (blocks printing if skipped)

| # | Task | Where in .docx |
|---|------|----------------|
| 1 | **Replace 73.4%** → `[[PENDING — Q21/Q22 survey data]]` | Chapter IV, Objective 1 conclusion |
| 2 | **Fix title page adviser:** Ellen F. Mangaoang, DIT (NOT Verzola, NOT MIT) | Title page |
| 3 | **Approval Sheet:** Adviser = Ellen F. Mangaoang DIT; Chairperson = [TBA]; Panel = Shekiro R. Raposas + Mary-Ann Mzana | Approval Sheet page |
| 4 | **Fill or delete all [[PENDING]] tags** — only from real survey data. If no data → delete sentence entirely, never invent | All chapters |
| 5 | **Ctrl+F "[[" must find 0 results** before printing | Whole document |

---

## P1 — Add to Chapter III Objective 2 (FHS section)

| # | Task | Content source |
|---|------|---------------|
| 6 | **Add FHS Formula Derivation Table** (Table 3.X) after Table 3.2 | `docs/capstone/FHS_Formula_Basis_Table.md` → Table 1 |
| 7 | **Add FHS-to-Needs-Assessment Table** (Table 3.X+1) | `docs/capstone/FHS_Formula_Basis_Table.md` → Table 3 |
| 8 | **Add Lightweight Mode paragraph** | See Chapter 4 markdown Section 2, bullet "Dual-Mode FHS Design" |
| 9 | **Add Peso Companion System subsection** | See MANUAL_EDIT_GUIDE Part 8.7 — present as design feature only, NOT measured behavior change |

---

## P2 — Chapter III Objective 3 (SUS — waiting for data)

| # | Task | Notes |
|---|------|-------|
| 10 | **SUS results** — all `[[PENDING]]` | Do NOT fill until Google Forms data arrives |
| 11 | **When data arrives:** compute with `=((B2-1)+(5-C2)+(D2-1)+(5-E2)+(F2-1)+(5-G2)+(H2-1)+(5-I2)+(J2-1)+(5-K2))*2.5` | Use Bangor et al. (2009) for adjective rating |
| 12 | **Pick ONE grading scale** and be consistent — Bangor 2009 (80–89 = B) OR Sauro-Lewis (≥80.3 = A). State which one. | Chapter III + Chapter IV must match |

---

## P3 — Appendices

| # | Task | Content source |
|---|------|---------------|
| 13 | **Appendix A: Research Survey Instrument** — all 30 questions, formatted as proper questionnaire | `docs/capstone/SmartSpend_Selected_Survey_Questions_FINAL.md` |
| 14 | **Appendix B: SUS Instrument** — standard 10-item Brooke (1996) SUS with 1–5 scale | Standard SUS wording (already in Chapter III procedures) |

---

## Numbers to use throughout (v3.1.2, Nov 1)

| Metric | Value |
|--------|-------|
| Version | **v3.1.2** (pubspec: 3.1.2+110) |
| APK size | ~47.6 MB (arm64-v8a) |
| Screens | **45** |
| Services | **33** |
| Badges | **36** |
| AI providers | **9** (8 cloud + optional local) |
| Agentic actions | **34** |
| SQLite schema | v14, 26 tables |
| FHS Full Mode components | Savings Rate / Overspend Control / Budget Adherence / Logging Consistency |
| FHS Lightweight Mode | Spending Restraint / Category Balance / Logging Consistency / Habit Streak |
| Budget Adherence with 0 budgets | Auto-award 25 pts (NOT reweight) |
| RA 10173 redaction | 5 patterns: mobile numbers, GCash ref numbers (12–18 digits), OTPs, bank account numbers, 09XX format |
| License | Source Available (Non-Commercial) — NOT "open source" |

---

## What NOT to change (confirmed correct)

- FHS formula math (verified from `score_service.dart`, Oct 6 + Nov 1)
- Bills/Health/Education exemption in Category Balance component
- Warning Decay mechanism (−5 pts/day, max −15, discretionary only)
- The "Prototype Observed Financial Health Indicator" naming
- Bitrián, Buil & Catalán (2021) DOI correction (IJBM-02-2021-0074)
- Kahneman & Tversky (1979) in bibliography
- CBA-MI citation (Comerton-Forde et al., 2018, Technical Report No. 1)
- UNSGSA citation (Gubbins, Mazzotta & Rhyne, 2021)

---

## Open items Kiro cannot answer (need Brix to check)

1. Dean's full name and title for Approval Sheet — **Jeoffrey B. Layco, [title TBD]** — name and middle initial B. confirmed; exact degree title (MIS/MIT/BSCIS) needs Brix to reconfirm directly before printing
2. Chairperson name — ask Ms. Mangaoang
3. Are OCR accuracy numbers (91.2%/88.5%) and AI categorization (94.6%) from a real test? If not, these must be removed from Table 3.5
4. Gemini key's Cloud project billing status — check in Google AI Studio
5. Cerebras key still active? — try making a request

---

*Brief written: November 1, 2026 | App: v3.1.2+110 | Kiro session*
