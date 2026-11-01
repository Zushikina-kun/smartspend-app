# SmartSpend — Project Briefing + Safe Ad & Survey Copy (Oct 15, 2026)
**For:** Brix, and any AI helping with ads. It fills the gaps in the other AI's handoff, which did not know the
capstone side of the project. Everything here was checked against the live site, the GitHub repo and the project's own handoffs.
Where something is **[unconfirmed]**, don't state it publicly yet.

---

## 1. What the other AI's brief got right, and what it missed

**Right:** links, team roles, the features list, the competitor leads, the Philippine context, the instinct not to invent stats.
**Missed or wrong:**
1. The FHS "pillars" it copied from the site (Budget Setup) don't match the capstone formula (Overspend Control). **Do not name the four
   pillars in any ad** until Kiro confirms. Say "a 0–100 Financial Health Score" only.
2. The SUS survey needs people who **actually used the app**. The site banner says "whether you've used the app or not". That must change
   (details in section 4), otherwise the responses can't be used in the paper.
3. It doesn't say the capstone has real deadlines and rules: results go in the manuscript, so the survey wording, consent and sampling matter.
4. "Open source" and "free forever" are shaky: the README says "All rights reserved" and a paid tier is planned for v4.0. Say "free right now".
5. Its research stats: only these are verified: BSP CFIS 2025 literacy **74% (up from 69%)**; account ownership **50% (down from 56%)**;
   household financial access **85%** (Consumer Expectations Survey, up from 74%). The "62% online transactions" and "3 in 10 emergency savings"
   figures came from news/bank blogs and are **[unconfirmed]**; cite BSP's own report or leave them out.
6. IponBuddy is a lead I haven't verified (Product Hunt mirror only). Confirm on the Play Store before comparing. If it reads SMS automatically,
   note that Google Play restricts SMS permissions, which is a distribution risk for that approach (to be checked).
7. `docs/BENCHMARK.md` is **not** the verified comparison; part of it is stale. The verified one is `SmartSpend_Comparative_Research_Report.docx`.

## 2. Facts safe to use in public (all current as of v3.1.0)
- Android app, free right now, no ads, no account required ("Continue Without Account"); core features work offline; AI chat needs internet
  unless Local AI mode is used.
- Log expenses 7 ways: chat, voice, receipt photo, batch screenshots (40+ platforms), barcode, bank text/CSV paste, manual.
- Peso: AI companion that understands Taglish and Filipino; 34 AI actions (log, edit, split, set budgets, and more).
- Financial Health Score (0–100) with a breakdown; Safe-to-Spend; savings goals; installment and debt tracking; Paluwagan tracker;
  SSS / PhilHealth / Pag-IBIG and BIR estimates; wallets (Cash, GCash, banks); 36 badges, daily quests.
- Optional Local AI mode (Ollama, LM Studio, Jan on the user's PC). With **Local-only mode on**, Peso does not fall back to the cloud.
- Download page: https://zushikina-kun.github.io/smartspend-app/ · APK (arm64): the `releases/latest/download/SmartSpend-v3.1.0-arm64-v8a.apk` link.
- Team: Brix A. Directo (Lead Dev), Cyrille John M. Rubis (UI/UX & Documentation), Djaunathan Albert S. Madayag (Project Manager & QA);
  adviser Ellen F. Mangaoang, MIT; Lorma Colleges, La Union.

## 3. Don't claim (yet)
| Don't say | Why | Say instead |
|---|---|---|
| "Your data never leaves your phone/network" | True only in Local AI mode | "Local AI mode keeps chat on your own PC" |
| "Free forever / no premium tier" | Paid tier planned for v4.0 | "Free right now" |
| "The only Filipino finance app with local AI" | Unverifiable | "One of the few" or omit |
| Names of the 4 FHS pillars | Site and manuscript disagree | "A 0–100 health score with a breakdown" |
| "Peso reads your real data, never generic advice" | Cloud mode sends context to a third-party AI | "Peso answers using your logged expenses" |
| SUS scores, user counts, ratings, testimonials | None collected yet | nothing |
| "Works on 99% of phones", TOPS/token-speed figures | Unverified | "Android 5.0+" |
| Phone number (GCash) in ads | Personal number | link or QR only |
| "Ang AI ay hindi nag-iimbak ng data mo" | Not established for cloud providers | omit |

## 4. Survey fixes (do before pushing the survey links)
1. **Use-first rule.** Change the SUS banner and form text to: *"Try SmartSpend (or the Try Demo mode) for about 10 minutes first, then answer."*
2. Add a first question: *"Did you use SmartSpend for at least 10 minutes?"* (Yes/No). Only "Yes" counts as SUS data.
3. Add **18+** confirmation (ads on Facebook/TikTok reach minors).
4. Add a consent line at the top of both forms. Template:
   > *Participation is voluntary. We collect your answers for a Lorma Colleges capstone study on a personal finance app. We do not ask for your name
   > or bank details. Answers are used only for the research and reported in group form. You may stop at any time. Questions: [team email].*
5. "Anonymous" is true only if the form doesn't collect email addresses or require Google sign-in. Check Settings → Responses.
6. Add demographic items that match the study: age band, occupation (student / employed / freelancer / household manager), city or province,
   phone brand/RAM (useful for the on-device AI limitation section).
7. Be honest in the paper: people recruited from social posts are a **self-selected convenience sample**, not a random one. Tell the adviser before collecting.
8. Claude could not see the questions (the form is rendered by JavaScript). Paste the question text so the 10 SUS items can be checked against the standard wording.

## 5. Ad copy (safe claims). Image posts can't hold links, so put links in the caption.

**Post 1 — Meet Peso (1080×1080)**
- Headline: *Sabihin mo lang kung magkano ang gastos.*
- Subline: *Chat, voice, o picture ng resibo. Peso na ang mag-log.*
- Chips: *Taglish · GCash · Installments · Paluwagan · Gumagana offline*
- Buttons: *Download (Android)* · *Sagutan ang 2-min survey*
- Footer: *Libre ngayon · Walang ads · Android 5.0+*

**Caption (Taglish)**
> Libre ngayon ang SmartSpend — AI money buddy para sa Pinoy. Mag-log ng gastos sa Taglish, via chat, voice, o picture ng resibo. May Financial Health Score pa para makita kung kumusta ang pera mo. Walang ads, hindi kailangan ng account.
> 📲 Download (Android): [APK link]
> 🎓 Capstone namin ito sa Lorma Colleges. Kung natry mo na ang app, tulungan kami: [SUS survey link] (2 minuto lang).
> #SmartSpend #LucidFrame #LormaColleges #PinoyFinance

**Post 2 — Survey recruitment (1080×1080)**
- Headline: *Tulungan mo kaming matapos ang capstone.*
- Step line: *1) I-try ang SmartSpend ng ~10 minuto  2) Sagutan ang 2-min survey*
- Cards: *Usability survey (2 min)* · *Financial habits survey (3–5 min)* · *18+ lang po · Anonymous at para sa pag-aaral lang* (keep "anonymous" only if item 4–5 above is true)
- Footer: *Salamat sa tulong mo!*

**Caption**
> Kailangan namin ng respondents! 1) I-download at i-try ang SmartSpend (o gamitin ang "Try Demo") nang mga 10 minuto. 2) Sagutan ang 2-minute usability survey: [SUS link]. Para sa mga hindi pa nakakagamit, pwede ring sagutan ang financial habits survey (3–5 min): [Research survey link]. 18 pataas lang po. Salamat! 🙏

**Story — Download (1080×1920)**
- *Your money buddy, sa Taglish.*
- What you get: *7 ways mag-log · Financial Health Score · Safe-to-Spend · Local AI mode (optional)*
- Buttons: *Download* · *Survey*. Fine print: *Android 5.0+ · Libre ngayon*

**Post 3 idea — Local AI (use this one only after Kiro answers about cloud fallback and payload)**
- *Gusto ng extra privacy? May Local AI mode ang Peso — gumagana sa sarili mong PC (Ollama / LM Studio / Jan).* Footer: *Optional. Kailangan ng PC sa parehong WiFi.*

## 6. What I need from you (or Kiro) to finish the job
1. The **text of both Google Forms** (so I can check them).
2. Kiro's answer on the **FHS pillars** (so the ads and the paper agree).
3. A few **real v3.1.0 screenshots** and the Peso art (the current site screenshots are v3.0.4).
4. Whether you want me to **rebuild the 3 ads** with the corrected copy above, and in what form (HTML/PNG), since the other AI's design file is private to its account.
5. Your adviser's OK on the recruitment method and the reduced/honest sample.
6. The repo **LICENSE** type and your preferred wording (open source or not).
7. Current response counts, and the platforms the ads will run on.
