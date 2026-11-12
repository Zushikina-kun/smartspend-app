# Maam Ellen Meeting Instructions — Extracted from Transcript
# Source: Recording 2026-11-12 144512 (defense consultation)
# Defense: Monday, 3:00 PM

---

## OBJECTIVES (0:00–0:48)
- Objectives are too long — SHORT LANG
- Only: "assess," "design and develop," "evaluate usability"
- Remove extra words, that's all

---

## SCOPE AND LIMITATIONS (0:48–5:12)
- Remove: "online and offline functionality", "using SQLite database to store", "optionally integrated Firebase" — these belong in the DISCUSSION/RESULTS section not scope
- Remove: LLM API key / Remote Config paragraph (too detailed, not scope)
- Remove: Data Privacy Act paragraph — not scope
- Format: ONE paragraph = scope, NEXT paragraph = limitations
- Scope = what's INCLUDED (what the app can do): Android only, 4 input methods, LLM, etc.
- Limitations = what it CANNOT do: OCR quality, voice accuracy, Android only, no banking integration
- Simple explanation: "meron siyang LLM mga ganun lang. kasimple lang"
- Remove citations from scope/limitations (why is Davis 1989 cited here?)
- "Purpose and Description" paragraph with "this conversational AI assistant was designed to respond to general financial inquiries..." → move relevant part to SCOPE, rest to discussion
- Gamification layer (achievements) → "pwede namang yan lang yung ilalagay mo" = just mention it briefly

---

## PURPOSE AND DESCRIPTION (6:28–7:21)
- Section is too long — "ang daming nilalagay kasi na pwede namang sa kabali ilalagay"
- Remove beneficiary subgroups (Parents, Budget-Conscious Individuals, Technology Enthusiasts, Demo Users, Researchers, Future Researchers) — this is bloated
- Keep only: how will THEY be benefited? Brief.

---

## TECHNICAL BACKGROUND (7:37–9:22)
- Remove "walang day" = no first person
- Enumerate what tools were used
- "paano niyo siya ginamit? Usually ganun lang naman" = describe HOW each tool was USED
- Keep it short — "pwede na siguro. Hanggang diyan lang"
- "yung iba ilagay niyo dun sa kung hindi appropriate" = cut excess

---

## RESEARCH DESIGN (9:26–11:12)
- Currently says "mixed methods" but NO interviews were conducted
- Change to: "quantitative descriptive developmental"
- Mixed methods = qualitative (interviews) + quantitative (surveys) — they only did surveys
- No qualitative → no mixed methods
- Maam Ellen: "Wala kayong qualitative. O ito ang population and local."

---

## POPULATION AND LOCALE (11:16–15:43)
- Table has BOTH parents (13 from needs assessment) AND parents (10 from SUS) = confusing
- Maam Ellen: "Ilan ba talaga dito? Bakit merong parents dito? Meron na namang parents sa ibaba."
- FIX: Separate the two samples clearly — needs assessment (13 parents, 14 YP, 3 both = 30) is DIFFERENT from SUS sample (10 parents, 20 YP = 30)
- Parents count in Table = 13 (not 16)
- Sampling technique: RANDOM sampling for parents and young professionals (not purposive)
  → "random sampling para kahit sino pwede as long as nami-meet yung criterion"
  → BUT content validator = PURPOSIVE sampling
- Maam Ellen: "Random sampling. Content validator purposive sampling."
- Explain WHY random, explain per objective WHO the respondents are
- Objective 1 and 3: parents and young professionals
- Do NOT mention validator name in the body text: "hwag mong sabihin yung pangalan"

---

## DATA GATHERING TOOLS AND PROCEDURE (20:05–26:33)
- Remove ALL step-by-step format (Step 1, Step 2, etc.)
- "Walang step. Walang step-step diyan."
- Format: explain per OBJECTIVE what was done and what tools were used
  - For objective 1: survey questionnaire, validated by content expert
  - For objective 2: Flutter, SQLite, Firebase, LLM — how they developed
  - For objective 3: SUS questionnaire
- First sentence: "data were gathered through a questionnaire survey. A questionnaire survey was used to collect quantitative data."
- Survey validated: "yung survey questionnaire was validated by uh financial management instructor" (don't name her)
- Technical benchmarking (LLM comparison) is part of Objective 2 — include it here

---

## LLM TABLE (38:47–41:11)
- Remove "not measured" rows — only keep the ones you ACTUALLY USED
- Remove "status" column — just list the ones used
- "kung ano yung ginamit niyo yun lang yung ilagay niyo dito yun lang idi-discuss niyo"
- Maam Ellen removed: LLaMA 4 Scout, LLaMA 3.3 70B, LLaMA 3.1 8B (retired), GPT-4o Mini, Claude, Grok, DeepSeek, Qwen, Fin-R1, Mistral, Gemma
- Keep only: models actually used in the app (Gemini Flash-Lite, Gemini Flash, GPT-OSS, Qwen, Groq Compound, Cerebras)
- Discuss WHY you chose Gemini Flash-Lite (best among candidates)

---

## SYSTEM OVERVIEW / PRODUCTION SCREENS (42:40–44:51)
- Flowchart: Move BEFORE the LLM table — "lagay mo doon yung flowchart ng system before ng LM"
- Screenshots: smaller size, must have DISCUSSION/DESCRIPTION under each
- Example format: "Figure 3 presents the dashboard of SmartSpend. [What it shows]. [How to use]."
- "huwag ganyan kalaki kasi may discussion pa"
- Maam Ellen: description should say what it shows and how to use it

---

## SUS RESULTS (47:28–51:47)
- Figure 2.1 (SUS interpretation) + Overall SUS table: keep
- Figure 3.12/3.13 (SUS distribution charts): "kailangan mo pa yung distribution? Tanggalin na lang"
  → Maam Ellen said remove these — they already explained the data in the table
- "Respondent group" table: keep (Table 3.4)
- Technical Performance Benchmarks section: "tanggalin na yan" — REMOVE entirely
- 75.0 score in SUS computation figure: Maam Ellen asked what it means → needs explanation
- "fell below the 68 point. Ibig sabihin pangit yung system niyo" → Maam Ellen acknowledged it's below average but OK for prototype
- User feedback analysis heading: remove — no formal feedback analysis was done

---

## CONCLUSIONS (51:47–52:14)
- "Okay siya" — Maam Ellen approved the conclusions
- Format: per objective
- Maam Ellen: "per objective per objective"

---

## RECOMMENDATIONS (52:14–52:34)  
- "add more" — add more recommendations
- "medyo mababa mo" — expand slightly

---

## FIGURE NUMBERING (32:13–32:52)
- Continuous: 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 — NO chapter prefix
- "walang 2.1.1 walang point-point"
- Same for tables: 1, 2, 3... not 1.1, 2.1, etc.

---

## OTHER NOTES
- No "proposed" language anywhere — already developed
- No comments visible in document ("walang comment na ganyan")
- Spacing: fix large spacing issues
- Print: 4 copies (adviser + 3 panel members) — FULL manuscript

---

## WHAT MAAM ELLEN SAID IS OK / APPROVED:
- System itself: "yung system okay na yung system ha. Working lahat."
- Conclusions: "Okay siya"
- LLM table structure (after removing unused models)
- SUS scores and interpretation
