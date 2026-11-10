# Merge Log: Groupmates Edits -> FINAL Manuscript

**Base (modified):** `1_MAIN_MANUSCRIPT_FINAL.docx` (784 paragraphs)
**Source of edits:** `1_MAIN_MANUSCRIPT_FINAL (groupmates).docx` (758 paragraphs)

## Summary

| Metric | Count |
|---|---|
| Paragraphs in OUR FINAL | 784 |
| Paragraphs in groupmates | 758 |
| Compared (aligned) pairs | 784 |
| UNCHANGED (matched equal / blank) | 686 |
| APPLY | 18 |
| APPLY_PARTIAL | 5 |
| REJECT (keep ours) | 42 |
| KEEP (our-only additions, kept) | 17 |
| NOT_ADDED (theirs-only, skipped) | 16 |

Total differing decisions (APPLY + APPLY_PARTIAL + REJECT + KEEP + NOT_ADDED) = 98

## Decision Detail

| Para# | OurText (excerpt) | GroupmatesText (excerpt) | Decision | Reason |
|---|---|---|---|---|
| 17 | Directo, Brix A. | Brix A. Directo | APPLY | Author name format: Last, F. M. -> F. M. Last |
| 18 | Rubis, Cyrille John M. | Cyrille John M. Rubis | APPLY | Author name format |
| 19 | Madayag, Djaunathan Albert S. | Djaunathan Albert S. Madayag | APPLY | Author name format |
| 42 | Shekiro R. Raposas Mary-Ann Mzana, MTS | Shekiro R. Raposas, MTS, MIS Mary-Ann Mzana, MTS | APPLY | Add credentials MTS, MIS to instructor in signature block (KNOWN APPLY) |
| 44 | (no match in ours) | a | REJECT | Theirs-only paragraph; not added to preserve our structure |
| 51 | Financial mismanagement remained a critical and documented challenge among Filipino househ… | Financial mismanagement remained a critical and documented challenge among Filipino househ… | REJECT | Abstract rewritten; removes structured 3-objective format & protected inline values; keep ours |
| 52 | The study employed a mixed-methods, developmental research design. Purposive sampling was … | SmartSpend integrated a multi-provider agentic large language model (LLM) architecture — w… | REJECT | Abstract rewritten; keep ours |
| 53 | The needs assessment revealed that 96.7% of respondents expressed positive intent to use a… | A core academic contribution was the Financial Health Score (FHS) — formally positioned as… | REJECT | Abstract rewritten; theirs drops 96.7%/93.3% & grade D; keep ours |
| 54 | The results indicated that SmartSpend showed promise as a prototype AI-assisted financial … | Usability was evaluated with the System Usability Scale (SUS) using 30 valid respondents f… | REJECT | Abstract rewritten; keep ours |
| 60 | The researchers also wished to thank their instructor in charge, Mr. Shekiro R. Raposas, M… | The researchers also wished to thank their instructor in charge, Dr. Janelli M. Mendez, fo… | REJECT | Wrong instructor name 'Dr. Janelli M. Mendez' (KNOWN REJECT); keep Mr. Shekiro R. Raposas, MTS, MIS |
| 61 | To the panelists — Mr. Jeoffrey B. Layco, MIS, Mr. Shekiro R. Raposas, MTS, MIS, and Ms. M… | To the panelists, enumerate the researchers expressed their gratitude for their time, effo… | REJECT | Stray word 'enumerate' + removed panelist names (KNOWN REJECT); keep ours |
| 62 | The researchers also acknowledged the College of Computer Studies and Engineering faculty … | The researchers also acknowledge the College of Computer Studies and Engineering faculty f… | REJECT | Reverts past 'acknowledged'->present 'acknowledge' & lowercases 'Information Technology'; keep ours |
| 67 | This study was dedicated to the people who have been a constant source of inspiration, sup… | This study was dedicated to the people who had been a constant source of inspiration, supp… | APPLY | Tense: have been -> had been (KNOWN APPLY) |
| 71 | Lastly, this study was dedicated to future researchers who may build upon this work and co… | Lastly, this study was dedicated to future researchers who might build upon this work and … | APPLY | Tense: may build -> might build (KNOWN APPLY) |
| 127 |  | (no match in groupmates) | KEEP | Our addition (figure/appendix/SUS row/blank) - kept |
| 140 |  | (no match in groupmates) | KEEP | Our addition (figure/appendix/SUS row/blank) - kept |
| 148 | Table 2.2. Agile Kanban Workflow Phases and Deliverables 42 | Table 2.2. Comparative Evaluation of LLM APIs for SmartSpend Integration 42 | REJECT | TOC renumbering (Table 2.2 Kanban -> LLM APIs) conflicts with body refs; keep ours |
| 149 | Table 3.1. Demographic Profile and Expense Tracking Methods of Respondents (N = 30) 44 | Table 3.1. Demographic Profile and Expense Tracking | REJECT | TOC entry fragment; keep ours |
| 148 | (no match in ours) | Methods of Respondents (N = 30) 44 | REJECT | Theirs-only paragraph; not added to preserve our structure |
| 151 | Table 3.2. Comparative Evaluation of LLM APIs for SmartSpend Integration 47 | Table 3.2. Comparative Evaluation of LLM APIs | REJECT | TOC renumbering; keep ours |
| 150 | (no match in ours) | for SmartSpend Integration 47 | REJECT | Theirs-only paragraph; not added to preserve our structure |
| 152 | (no match in ours) | Table 3.4. System Usability Scale (SUS) | REJECT | Theirs-only paragraph; not added to preserve our structure |
| 155 | Table 3.4. System Usability Scale (SUS) Results by Respondent Group 71 | Results by Respondent Group 71 | REJECT | TOC entry fragment; keep ours |
| 154 | (no match in ours) | Table 3.5. SmartSpend Multimodal Import: | REJECT | Theirs-only paragraph; not added to preserve our structure |
| 157 | Table 3.5. SmartSpend Multimodal Import: Field-Level Parsing Performance 72 | Field-Level Parsing Performance 72 | REJECT | TOC entry fragment; keep ours |
| 162 | This chapter presented the background of the study, including the context and motivation f… | This chapter presented the background of the study, including the context and motivation f… | APPLY | Tense: guides -> guided (present->past consistency) |
| 164 | Financial mismanagement was a documented and pressing problem in the Philippines. Accordin… | Financial mismanagement was a documented and pressing problem in the Philippines. Accordin… | REJECT | Reverts 'lacked'->'lack' (past->present) & introduces error 'lacked of'; keep ours |
| 165 | More recent data suggested this picture was beginning to shift, though unevenly. BSP's new… | More recent data suggested this picture was beginning to shift, though unevenly. BSP's new… | APPLY | Wording: adds 'now' (clarity, consistent with shift narrative) |
| 174 | Several existing applications demonstrated how mobile tools could support personal financi… | Several existing applications demonstrated how mobile tools could support personal financi… | APPLY_PARTIAL | Apply tense fixes prefer->preferred & does->did; keep our last sentence (table renumbering conflict) |
| 175 | Beyond the applications summarized in Table 1.2, several other Philippine-context finance … | Beyond the applications summarized in Table 1.2, several other Philippine-context finance … | APPLY | Tense: adds -> added (present->past within past paragraph) |
| 178 | Building on the gaps identified in the literature and the feature comparison above, SmartS… | Building on the gaps identified in the literature and the feature comparison above, SmartS… | REJECT | Typo 'addressesed' + reverts past 'addressed'->present; keep ours |
| 180 | Recent advancements in artificial intelligence, particularly Large Language Models (LLMs),… | Recent advancements in artificial intelligence, particularly Large Language Models (LLMs),… | APPLY | Tense: handle -> handled (present->past consistency in past narrative) |
| 182 | Beyond expense tracking, SmartSpend featured a conversational AI assistant capable of exec… | Beyond expense tracking, SmartSpend featured a conversational AI assistant capable of exec… | REJECT | Reverts 'was improving'->'is improving' (past->present); keep ours |
| 184 | The application used local SQLite storage via the sqflite package (version 11) for offline… | The application used local SQLite storage via the sqlite package (version 11) for offline … | REJECT | Wrong package name 'sqlite' (correct is 'sqflite'); keep ours |
| 202 | The system had several limitations. The performance of OCR text recognition depended on th… | The system had several limitations. The performance of OCR text recognition depended on th… | REJECT | Reverts 'was affected'->'will be affected' (past->future); keep ours |
| 207 | SmartSpend was designed as a mobile application that helps users manage their daily expens… | SmartSpend was designed as a mobile application that helped users manage their daily expen… | APPLY_PARTIAL | Apply helps->helped (past consistency); keep 'could respond' (reject could->can revert) |
| 227 | LLM API Integration. The system integrated a large language model (LLM) API as its AI engi… | LLM API Integration. The system integrated a large language model (LLM) API as its AI engi… | APPLY | Tense: is -> was (present->past consistency) |
| 230 | To maintain token efficiency without sacrificing conversational continuity, the system imp… | To maintain token efficiency without sacrificing conversational continuity, the system imp… | APPLY | Tense: implements -> implemented (present->past consistency) |
| 242 | This study applied a mixed methods research design, which integrated both qualitative and … | This study applied a mixed methods research design, which integrated both qualitative and … | REJECT | Reverts 'allowed'->'allows' (past->present) + double spaces; keep ours |
| 244 | On the other hand, the quantitative aspect of the study involved the use of validated stru… | On the other hand, the quantitative aspect of the study involved the use of validated stru… | REJECT | Reverts 'was a widely used'->'is' (past->present); keep ours |
| 245 | Moreover, this study adopted a descriptive-developmental research approach, which focused … | Moreover, this study adopted a descriptive-developmental research approach, which focuses … | REJECT | Reverts 'focused'->'focuses' (past->present); keep ours |
| 248 | The study was conducted in San Fernando City, La Union. The primary target population of t… | The study was conducted in San Fernando City, La Union. The primary target population of t… | REJECT | Reverts 'consisted'->'consists' (past->present) + double spaces; keep ours |
| 249 | A total of thirty (30) respondents were selected using purposive sampling. Thirteen (13) r… | A total of thirty (30) respondents were selected using purposive sampling. Thirteen (13) r… | APPLY_PARTIAL | Apply make->made (present->past); keep 'tracked' (reject tracked->track) |
| 251 | The survey questionnaire was reviewed by Susan C. Arquisal, a graduate of Bachelor of Scie… | The survey questionnaire was reviewed by Susan C. Arquisal, a graduate of Bachelor of Scie… | REJECT | Reverts 'were appropriate'->'are appropriate' (past->present); keep ours |
| 253 | The distribution of respondents was presented in Table 2.1: Distribution of Respondents an… | The distribution of respondents was presented in Table 2.1. | REJECT | Removes restated table title inline; keep ours |
| 255 | Table 2.1: Distribution of Respondents and Validators | Table 2.1. Distribution of Respondents | APPLY_PARTIAL | Caption colon->period (APA); keep 'and Validators' (table includes validators) |
| 256 | The survey questionnaire underwent content validation by Avigail Candevario, PFMe, a subje… | The survey questionnaire underwent content validation by a subject matter expert in financ… | REJECT | Removes validator name 'Avigail Candevario, PFMe' (protected); keep ours |
| 265 | For the second objective, no direct data gathering instrument was used for the design and … | For the second objective, no direct data gathering instrument was used for the design and … | APPLY | Fix inconsistency: 'six weighted criteria' -> 'four criteria' (only 4 listed) |
| 269 | The survey questionnaire was drafted by the research team and submitted to Avigail Candeva… | The survey questionnaire was drafted by the research team and submitted to a subject matte… | REJECT | Removes validator name 'Avigail Candevario, PFMe' (protected); keep ours |
| 296 | Finally, in the Done/Review Phase, the researchers evaluated the overall performance and e… | Finally, in the Done/Review Phase, the researchers evaluated the overall performance and e… | APPLY_PARTIAL | Apply are proposed->were proposed (past consistency); keep rest (reject had->has, included->include reverts) |
| 297 | The phases of the Kanban workflow, together with their key tasks and deliverables, were su… | The phases of the Kanban workflow, together with their key tasks and deliverables, were su… | REJECT | Removes restated table title inline; keep ours |
| 298 | Table 2.2: Agile Kanban Workflow Phases and Deliverables | Table 2.2. Agile Kanban Workflow Phases and Deliverables | APPLY | Caption colon -> period (APA) |
| 304 | Table 3.1 presents the demographic profile of the 30 respondents and the expense tracking … | Table 3.1 presented the demographic profile of the 30 respondents and the expense tracking… | APPLY | Tense: presents -> presented (present->past) |
| 307 | Note. Respondents could select more than one tracking method, so percentages were computed… | Note. Respondents could select more than one tracking method, so percentages were computed… | APPLY | Tense: do not sum -> did not sum (present->past) |
| 310 | Figure 3.14. Demographic Distribution of Needs-Assessment Respondents (N = 30). † The 3 re… | (no groupmates paragraph) | KEEP | Our content with no groupmates counterpart (figure caption/blank) - kept |
| 323 | The Financial Health Score (FHS) was SmartSpend's core academic contribution — formally po… | The Financial Health Score (FHS) was SmartSpend's core academic contribution — formally po… | APPLY | Tense: rescales -> rescaled (present->past) |
| 327 | 2. Overspend Control (25 pts): | 2. Overspend Control (25 pts):ed as a "soft" overspend day at half weight; a day with scat… | REJECT | Corrupted text ':(25 pts):ed as a...' (groupmates merge artifact); keep ours |
| 330 | Lightweight Mode | Lightweight Modewere excluded so essential fixed costs would not reduce the score; (4) Hab… | REJECT | Corrupted text 'Modewere excluded...'; keep ours |
| 331 | Score Adjustments | Score Adjustments — Warning Decay = min(15, 5 × decayDays), applying loss aversion theory … | REJECT | Corrupted text 'only fireded verified restraint...'; keep ours |
| 333 | SmartSpend v3.1.0 was developed across seven Kanban phases (Table 2.2: Agile Kanban Workfl… | SmartSpend v3.1.0 was developed across seven Kanban phases (Table 2.2). Platform: Android … | REJECT | Major rewrite/addition (platform details); keep ours (our structure intact) |
| 342 | Two further additions worth documenting as part of the system's development: first, a full… | Two further additions were worth documenting as part of the system's development: first, a… | APPLY | Add past verb 'were' (completes clause in past narrative) |
| 343 | The v2.9.97–3.1.0 releases added several usability and reliability capabilities. Earlier, … | The v2.9.97–3.1.0 releases added several usability and reliability capabilities. Earlier, … | REJECT | Reverts many past->present (stayed->stays, pushed->pushes, were stored->are now stored); keep ours |
| 344 | AI privacy was described as three tiers, only two of which existed at the time. (1) Cloud … | AI privacy was described as three tiers, only two of which exist today. (1) Cloud AI (defa… | REJECT | Reverts past->present throughout (existed->exist, stated->state, could->can); keep ours |
| 345 | From v3.0.5 to v3.1.0 the app's mascot, Peso, was developed from a static icon into a cont… | From v3.0.5 to v3.1.0 the app's mascot, Peso, was developed from a static icon into a cont… | REJECT | Reverts past->present (had->has, appeared->appears); keep ours |
| 346 | These behaviours applied the same ideas used for Warning Decay and the badge system — prom… | These behaviours apply the same ideas used for Warning Decay and the badge system — prompt… | REJECT | Reverts past->present (applied->apply, had not been->has not been); keep ours |
| 347 | The optional local-LLM integration described above shipped with a guided in-app setup flow… | The optional local-LLM integration described above ships with a guided in-app setup flow c… | REJECT | Reverts past->present (shipped->ships, fell->falls, became->becomes); keep ours |
| 365 | Respondents were required to use the SmartSpend application — either the full version or t… | Respondents were required to use the SmartSpend application — either the full version or t… | REJECT | Reverts 'might have taken part'->'may have' (past->present); keep ours |
| 370 | As shown in Table 3.3, SmartSpend obtained an overall SUS score of 61.83, a grade of D, an… | As shown in Table 3.3, SmartSpend obtained an overall SUS score of 61.83, a grade of D, an… | REJECT | Removes citation '(Sauro & Lewis, 2016)'; keep ours |
| 373 | Figure 3.12. SUS Score Distribution (N = 30). Individual scores sorted in ascending order.… | (no groupmates paragraph) | KEEP | Our content with no groupmates counterpart (figure caption/blank) - kept |
| 376 | Figure 3.13. SUS Scores by Respondent Group (N = 30). Parents (n = 10) scored M = 58.25 (S… | (no groupmates paragraph) | KEEP | Our content with no groupmates counterpart (figure caption/blank) - kept |
| 365 | (no match in ours) | As shown in Tables 3.3 and 3.4, SmartSpend achieved an overall mean SUS score of 61.83 (SD… | REJECT | Theirs-only paragraph; not added to preserve our structure |
| 380 | No formal open-ended Survey data was collected. The study used a structured quantitative s… | No formal open-ended Survey data was collected. The study used a structured quantitative s… | REJECT | Reverts 'were derived'->'are derived' (past->present); keep ours |
| 382 | Note: Multimodal import performance metrics (OCR precision/recall, AI categorization accur… | Note: Multimodal import performance metrics (OCR precision/recall, AI categorization accur… | REJECT | Reverts 'were based'->'are based' (past->present); keep ours |
| 384 | Note: Formal field evaluation of multimodal import performance using standardized test set… | Note: Formal field evaluation of multimodal import performance using standardized test set… | REJECT | Reverts 'were based'->'are based' & 'Recommendation 6'->'Priority 9'; keep ours |
| 385 | These results showed that the third objective of the study was partially achieved: usabili… | These results showed that the third objective of the study was achieved: the usability of … | REJECT | Removes 'partially' (our Objective 3 wording, protected); keep ours |
| 378 | (no match in ours) | SmartSpend obtained an overall mean SUS score of 61.83 (SD = 17.58, Median = 55.00) from N… | REJECT | Theirs-only paragraph; not added to preserve our structure |
| 395 | 1. Payday-cycle-aware budgeting. The researchers recommended that the developers implement… | 1. Payday-cycle-aware budgeting. The researchers recommended that the developers implement… | REJECT | Breaks subjunctive 'implement'->'implemented' after 'recommended that'; keep ours |
| 390 | (no match in ours) | Anthropic. (2024). Claude Sonnet model card. | REJECT | Theirs-only paragraph; not added to preserve our structure |
| 401 | (no match in ours) | Consumer Financial Protection Bureau. (2017). CFPB Financial Well-Being Scale: Scale devel… | REJECT | Theirs-only paragraph; not added to preserve our structure |
| 407 | (no match in ours) | Faulkner, L. (2003). Beyond the five-user assumption: Benefits of increased sample sizes i… | REJECT | Theirs-only paragraph; not added to preserve our structure |
| 409 | (no match in ours) | Financial Health Network. (2026). From insight to impact: The next phase of financial heal… | REJECT | Theirs-only paragraph; not added to preserve our structure |
| 425 | (no match in ours) | MaikuB. (2023). flutter_local_notifications: A cross-platform plugin for displaying local … | REJECT | Theirs-only paragraph; not added to preserve our structure |
| 426 | (no match in ours) | Meta AI. (2024). LLaMA 3: Open foundation and fine-tuned chat models. https://ai.meta.com/… | REJECT | Theirs-only paragraph; not added to preserve our structure |
| 428 | (no match in ours) | Nielsen, J., & Landauer, T. K. (1993). A mathematical model of the finding of usability pr… | REJECT | Theirs-only paragraph; not added to preserve our structure |
| 430 | (no match in ours) | OpenAI. (2024). GPT-4 technical report. https://arxiv.org/abs/2303.08774 | REJECT | Theirs-only paragraph; not added to preserve our structure |
| 442 | (no match in ours) | Wajid, F., et al. (2025). Gamification: Revolutionizing financial planning systems. World … | REJECT | Theirs-only paragraph; not added to preserve our structure |
| 772 | Bangor, A., Kortum, P. T., & Miller, J. T. (2008). An empirical evaluation of the System U… | (no match in groupmates) | KEEP | Our addition (figure/appendix/SUS row/blank) - kept |
| 773 | Deci, E. L., & Ryan, R. M. (2000). The "what" and "why" of goal pursuits: Human needs and … | (no match in groupmates) | KEEP | Our addition (figure/appendix/SUS row/blank) - kept |
| 774 | Sauro, J., & Lewis, J. R. (2016). Quantifying the user experience: Practical statistics fo… | (no match in groupmates) | KEEP | Our addition (figure/appendix/SUS row/blank) - kept |
| 775 | † Respondents who identified as both a parent and a young professional. | (no match in groupmates) | KEEP | Our addition (figure/appendix/SUS row/blank) - kept |
| 776 | Appendix D | (no match in groupmates) | KEEP | Our addition (figure/appendix/SUS row/blank) - kept |
| 777 | Content Validation Certificate (Survey Questionnaire) | (no match in groupmates) | KEEP | Our addition (figure/appendix/SUS row/blank) - kept |
| 778 |  | (no match in groupmates) | KEEP | Our addition (figure/appendix/SUS row/blank) - kept |
| 779 | Appendix E | (no match in groupmates) | KEEP | Our addition (figure/appendix/SUS row/blank) - kept |
| 780 | Content Validation Certificate (FHS Formula and Literature) | (no match in groupmates) | KEEP | Our addition (figure/appendix/SUS row/blank) - kept |
| 781 |  | (no match in groupmates) | KEEP | Our addition (figure/appendix/SUS row/blank) - kept |
| 782 |  | (no match in groupmates) | KEEP | Our addition (figure/appendix/SUS row/blank) - kept |
| 783 |  | (no match in groupmates) | KEEP | Our addition (figure/appendix/SUS row/blank) - kept |
