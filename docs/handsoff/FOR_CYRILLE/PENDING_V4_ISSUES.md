# Issues Found in Latest V4 (from text paste, Nov 12 evening)
# Apply these when the new docx file drops in handsoff/

## ISSUES TO FIX (in order of priority)

### 1. Figure/Table numbering — REVERTED back to chapter-based (1.1, 1.2, 3.x)
LOF shows: 1.1, 1.2, 2.1, 2.2, 3.1–3.14 (old scheme)
LOT shows: 1.1, 1.2, 2.1, 2.2, 3.1–3.5 (old scheme)
Body text uses: "Figure 1:", "Table 1:", "Table 1.1 presented" etc (mixed)
FIX: Renumber to continuous 1–N after all other fixes applied

### 2. LOT has Table 3.5 (SmartSpend Multimodal Import) — this table was REMOVED
FIX: Delete Table 3.5 entry from List of Tables

### 3. LOF still has Figures 3.1, 3.2, 3.3 (dev diagrams we removed)
FIX: These should NOT be in LOF if images were removed from body
CHECK: If images still present in body, keep. If removed, delete LOF entries.

### 4. Chapter I heading says "proposed AI-powered financial assistant" (present tense)
Para: "technical background of the technologies used in the development of the proposed AI-powered financial assistant"
FIX: "proposed" → "developed"

### 5. Susan C. Arquisal still present (page 30 area, Population section)
Para: "The survey questionnaire was reviewed by Susan C. Arquisal..."
FIX: → "Avigail Candevario, PFMe"

### 6. Blank name validator duplicate still present
Para: "The survey questionnaire was reviewed by , a graduate of Bachelor of Science..."
FIX: DELETE this paragraph entirely

### 7. False technical validator sentence still present
Para: "The System Usability Scale (SUS) evaluation process and the overall technical functionality... reviewed by a subject matter expert in information technology, whose qualifications were documented in the Technical Validation Certificate."
FIX: DELETE these sentences (Maam Ellen confirmed: wala po, no tech validator)

### 8. Table 3 (Distribution) still has Parents = 16 (should be 13)
Also missing "Both Groups: 3" row
FIX: Parents → 13, add Both Groups = 3, remove Technical Validator row

### 9. Population blank sentence: "There are a total of __ respondents which comprise..."
FIX: Fill with actual text per earlier fix

### 10. "No surveys were conducted; qualitative insights..."
FIX: → "No interviews were conducted; qualitative insights..."

### 11. "Discuss how system was developed and tools" placeholder
FIX: Replace with actual development sentence

### 12. "EXPLAIN WHAT DID IN THE DESIGN AND DEVELOPMENT" ALL-CAPS placeholder
FIX: Replace with actual paragraph

### 13. "DISCUSSION" bare placeholder heading before Figures 3.1-3.3
FIX: DELETE

### 14. "DESCRIPTION" and "fIGURE 3 PRESENTS THE DASHBOARD..." under Figure 3.5
FIX: Replace with real description

### 15. "Ano meaning ng 7" leftover
FIX: DELETE

### 16. "Present Peso as a design feature... avoid phrases such as 'dopamine reinforcement'"
FIX: DELETE this sentence

### 17. Scope and Limitations: STILL the long 4-paragraph version
FIX: Replace with 2-paragraph condensed version (already written)

### 18. Technical Background: STILL the old long version (Firebase split, sqflite v11, etc.)
FIX: Replace with condensed 11-paragraph version (already written)

### 19. FHS "open item pending confirmation" note
FIX: DELETE

### 20. "This study proposed SmartSpend" → "This study developed SmartSpend"
FIX: Replace in Chapter I body text

### 21. "The proposed solution provided benefits to the following groups:" 
FIX: → "The developed application provided benefits to the following groups:"

### 22. Present tense leaks:
- "that can respond to user inputs" → "that responded to user inputs"
- "SmartSpend enables users" → "SmartSpend allowed users"
- "Voice recognition accuracy will be affected" → "would be affected"
- "that is not only technically functional" → "that was not only technically functional"
- "as it relied on" ← already past tense, OK

### 23. Table references still using old scheme in body:
- "Table 2.1 summarized" → "Table 1.2 summarized" (feature comparison table)
- "Table 3.2 presented" → should reference new table number
- "Tables 3.3 and 3.4" → should use new continuous numbers

### 24. "six-provider AI failover chain" in abstract
FIX: → "eight-provider cloud failover chain (Gemini 3.5 Flash-Lite as primary, seven fallbacks)"

### 25. Abstract: "Seven recommendations... including UI/UX refinement, a backend API proxy, on-device AI, SQLite encryption, formal parsing evaluation, and a longitudinal study"
FIX: List should match body Chapter IV recommendations (payday, backend+GooglePlay, AI, SQLite, household, longitudinal = 7 items. OR keep the abstract list as-is if approved by Maam Ellen since she edited this version)

### 26. Ariely reference has wrong URL: "https://www.anthropic.com/claude"
FIX: Remove that URL from Ariely (2008) reference

### 27. Three duplicate "Note: The 3 respondents..." footnotes after References
FIX: Keep 1, delete 2

### 28. Three stray references at end (Bangor 2008, Deci & Ryan, Sauro & Lewis)
FIX: Move to alphabetical position in main reference list

### 29. Conclusion paragraph 1 says "93.3% already use GCash" (present tense)
FIX: "already used GCash"

### 30. Conclusion says "below the ≥80 target but acceptable for a prototype system"
FIX: "acceptable" contradicts Table 7 which says "No (below the 68 benchmark)"
FIX: → "below both the 68-point average benchmark and the pre-established target of 80"

### 31. Conclusions missing Objective 1 conclusion paragraph
Current text jumps straight to Obj 2 conclusion after the opening paragraph
FIX: Add "The first objective was achieved..." paragraph

### 32. TOC still has "APPENDIX C: SUS Individual Scores" which doesn't exist in appendices
FIX: Remove or change to match actual Appendix C (SUS Questionnaire)

### 33. Photo Documentation heading with no content
FIX: Remove empty heading

### 34. "BAD / CJMR / DASM" author initials (at end of Dedication)
NOTE: These appear to be author initials/signatures — keep or remove based on school format

## WHAT'S ALREADY CORRECT IN THIS V4 (don't revert):
- Acknowledgements: panelists with em-dashes ← NOT present in this version, needs adding
- Conclusions Obj 2 and Obj 3: correctly written
- Recommendations: 7 items in correct order
- SUS data tables: 61.83, correct values
- Most Chapter III prose: correctly past tense
- Appendices A-E: present and correct

## WAIT FOR DOCX FILE
When the actual docx drops in handsoff/, run the same merge process:
1. Use new V4 as base
2. Apply all fixes above via python-docx
3. Verify protected values
4. Git commit and push
