"""
merge_manuscript.py
===================
Merges Ellen's V4 (base) with accuracy corrections from our fixed version,
plus Maam Ellen's Google Docs comment revisions:
  - Comment 1: Data Gathering Tools restructured per objective
  - Comment 2: Research Design qualitative-sounding sentence rewritten
  - Comment 3: Technical Background rewritten to focus on SmartSpend usage

Saves result to: c:/xampp/htdocs/smartspend_app/docs/handsoff/1_MAIN_MANUSCRIPT_FINAL.docx

Run:
    python merge_manuscript.py
"""

import re
from docx import Document

# ── Paths ──────────────────────────────────────────────────────────────────────
ELLEN_V4    = (r"c:/xampp/htdocs/smartspend_app/docs/handsoff"
               r"/Maam ELLEN fix and comments/1_MAIN_MANUSCRIPT_FINAL(MAIN_V4).docx")
OUTPUT      = (r"c:/xampp/htdocs/smartspend_app/docs/handsoff"
               r"/1_MAIN_MANUSCRIPT_FINAL.docx")

# ══════════════════════════════════════════════════════════════════════════════
# CONTENT BLOCKS
# ══════════════════════════════════════════════════════════════════════════════

# ── Abstract (from our accurate version, verbatim) ────────────────────────────
ABSTRACT_PARAGRAPHS = [
    (
        "Financial mismanagement remained a critical and documented challenge among Filipino "
        "households, compounded by limited access to accessible, localized, and intelligent "
        "financial tools. This study aimed to: (1) assess the financial management practices, "
        "budgeting challenges, and expense-tracking behaviors of parents aged 35\u201355 and young "
        "professionals aged 21\u201335 in San Fernando City, La Union; (2) design and develop "
        "SmartSpend, an AI-assisted mobile financial tracking and advisory application for "
        "Android; and (3) evaluate the usability of the developed system using the System "
        "Usability Scale (SUS)."
    ),
    (
        "The study employed a quantitative descriptive developmental research design. A validated "
        "survey questionnaire was administered to assess financial practices and technology "
        "acceptance. SmartSpend was developed using an Agile Kanban methodology, integrating a "
        "multi-provider large language model (LLM) architecture with Gemini 3.5 Flash-Lite as "
        "the primary model, enabling 34 autonomous financial management actions. Usability was "
        "evaluated using the 10-item Brooke (1996) SUS instrument administered after respondents "
        "used the application for at least 10 minutes."
    ),
    (
        "The needs assessment revealed that 96.7% of respondents expressed positive intent to "
        "use an AI-powered financial application, and 93.3% already used GCash, validating the "
        "target features. SmartSpend version 3.1.0 was successfully developed as an offline-first "
        "Android application with multi-modal expense input, a Financial Health Score (FHS) "
        "formally classified as a Prototype Observed Financial Health Indicator, and an "
        "eight-provider cloud failover chain (Gemini 3.5 Flash-Lite as primary, seven fallbacks). "
        "Usability evaluation yielded a mean SUS score of 61.83 (SD = 17.58), corresponding to a "
        "grade of D and an adjective rating of \u201cOK\u201d under the Bangor et al. (2009) scale below "
        "the 68-point benchmark (Sauro & Lewis, 2016) and the pre-established target of 80."
    ),
    (
        "The results indicated that SmartSpend showed promise as a prototype AI-assisted "
        "financial tool for the target demographic, though the below-target usability score "
        "highlighted areas for UI/UX refinement. The study contributed a locally contextualized, "
        "evaluated prototype that addressed gaps in existing Philippine personal finance "
        "applications, particularly the absence of Filipino-English LLM integration, offline-first "
        "operation, and behavioral health scoring. Nine recommendations were identified for "
        "future development, including UI/UX refinement, a backend API proxy, on-device AI, "
        "SQLite encryption, formal parsing evaluation, and a longitudinal study."
    ),
]

# ── Recommendations 8 & 9 ─────────────────────────────────────────────────────
REC_8 = (
    "8. UI/UX refinement. The researchers recommended that the developers address the main "
    "usability concerns identified in the SUS results \u2014 particularly system consistency (Q6) "
    "and complexity (Q2) \u2014 through interface redesign in a future iteration to improve the "
    "overall usability score."
)
REC_9 = (
    "9. Formal parsing evaluation. The researchers recommended that future researchers conduct "
    "a formal evaluation of the OCR and AI parsing accuracy using standardized test receipts "
    "across multiple platforms to establish a reliable performance baseline for the multimodal "
    "import features."
)

# ── Table 3 note ──────────────────────────────────────────────────────────────
TABLE3_NOTE = (
    "Note. The content validator participated separately and is not included in "
    "the respondent total of 30."
)

# ── Comment 2: Research Design rewrite ───────────────────────────────────────
# The old qualitative-sounding sentence to find (partial match):
RESEARCH_DESIGN_OLD = (
    "structured survey questionnaires were used to collect respondents' views regarding "
    "the features and functionality of the developed application. The survey responses "
    "provided descriptive information that guided the design and improvement of the application."
)
RESEARCH_DESIGN_NEW = (
    "A validated structured survey questionnaire was used to collect quantitative data on the "
    "financial management practices, budgeting challenges, and expense tracking behaviors of "
    "the target population. The collected data were analyzed using frequency and percentage to "
    "identify patterns and trends that guided the development of system features."
)

# ── Comment 3: Technical Background rewrites (SmartSpend-focused) ─────────────
# Each entry: (paragraph_start_marker, full_replacement_text)
# We match the beginning of the paragraph to identify which one to replace.
TECH_BG_REWRITES = [
    (
        # Flutter — currently ends abruptly after one sentence
        "Flutter. Flutter was an open-source UI framework developed by Google that was used to "
        "build the SmartSpend Android application.",
        (
            "Flutter. Flutter was used to build the SmartSpend Android application, targeting "
            "Android devices with a single cross-platform codebase. The framework provided a "
            "consistent and responsive user interface across different screen sizes. All "
            "SmartSpend screens, navigation flows, and interactive components \u2014 including the "
            "chat interface, analytics charts, and onboarding flow \u2014 were implemented as "
            "Flutter widgets. The application was compiled to a native Android APK and deployed "
            "directly to respondents\u2019 devices during the evaluation phase."
        )
    ),
    (
        # SQLite — already decent, minor enhancement for SmartSpend specificity
        "SQLite. The application used SQLite as its primary local database via the sqflite "
        "package (version 11), storing all financial data including expenses, budgets, savings "
        "goals, income, recurring transactions, debts, and chat history directly on the device.",
        (
            "SQLite. SQLite was used as SmartSpend\u2019s primary local database through the "
            "sqflite package (version 11). Every expense, budget, savings goal, income record, "
            "recurring transaction, debt entry, and AI chat message was stored locally on the "
            "device. This offline-first approach ensured that all core features remained fully "
            "functional without an internet connection. Data was persisted across app restarts "
            "and merged with Firebase cloud data upon reconnection."
        )
    ),
    (
        # Firebase Firestore — currently only one sentence
        "Firebase Firestore. Firebase Firestore was used for bidirectional cloud synchronization "
        "of user financial data.",
        (
            "Firebase Firestore. Firebase Firestore was used to synchronize user financial data "
            "across sessions and devices. Every expense, budget, and savings goal saved locally "
            "in SmartSpend was pushed to Firestore when the device was online and retrieved upon "
            "login to merge with local records. This bidirectional sync ensured that users did "
            "not lose data when switching devices or reinstalling the application (Google, 2024c)."
        )
    ),
    (
        # Firebase Authentication — has comment "change this"
        "Firebase Authentication. Firebase Authentication handled user identity management, "
        "supporting email/password login, Google Sign-In via OAuth 2.0, and biometric "
        "authentication (fingerprint or face unlock) as a convenience layer after the user's "
        "first successful login (Google, 2024a). - change this",
        (
            "Firebase Authentication. Firebase Authentication was used to manage user accounts "
            "in SmartSpend. It supported three login methods: email and password, Google "
            "Sign-In via OAuth 2.0, and biometric authentication (fingerprint or face unlock) "
            "as a convenience option after the user\u2019s first successful login. Authentication "
            "state was persisted locally so that users remained logged in between sessions "
            "without re-entering credentials (Google, 2024a)."
        )
    ),
    (
        # Firebase Crashlytics — keep mostly but reframe usage
        "Firebase Crashlytics. Firebase Crashlytics was integrated for real-time crash "
        "reporting. It captured Flutter framework errors and asynchronous exceptions and "
        "reported them to the Firebase Console for monitoring and debugging (Google, 2024b).",
        (
            "Firebase Crashlytics. Firebase Crashlytics was integrated into SmartSpend to "
            "monitor application stability during the development and evaluation phases. It "
            "automatically captured Flutter framework errors, unhandled exceptions, and "
            "asynchronous faults, then reported them to the Firebase Console with device "
            "metadata and stack traces. This allowed the researchers to identify and fix "
            "critical bugs before distributing the application to evaluation respondents "
            "(Google, 2024b)."
        )
    ),
    (
        # LLM API Integration
        "LLM API Integration. The system integrated a large language model (LLM) API as its "
        "AI engine, selected through a comparative technical evaluation of available providers "
        "based on inference speed, response accuracy for Filipino-English natural language "
        "processing, context window capacity, and cost feasibility for academic deployment. "
        "At the time of writing, Gemini 3.5 Flash-Lite (Google) was the primary model, backed "
        "by seven automatic fallback providers spanning Google, Groq, and Cerebras so the "
        "assistant kept working if any single provider was unavailable or rate-limited.",
        (
            "LLM API Integration. SmartSpend integrated a large language model (LLM) API to "
            "power its AI financial assistant, Peso. The primary model used was Gemini 3.5 "
            "Flash-Lite, selected after a comparative evaluation of eight providers based on "
            "inference speed, Filipino-English (Taglish) handling, context window capacity, and "
            "free-tier feasibility. An eight-provider cloud failover chain (Gemini 3.5 "
            "Flash-Lite as primary, seven fallbacks across Google, Groq, and Cerebras) was "
            "implemented so the assistant continued functioning if any single provider was "
            "unavailable or rate-limited. The LLM was responsible for 34 autonomous actions "
            "including natural language expense parsing, budget recommendations, and financial "
            "health insights delivered in conversational Filipino-English."
        )
    ),
    (
        # Speech-to-Text
        "Speech-to-Text. The speech_to_text package was used to implement voice input for "
        "expense recording. The system automatically detected the Filipino English (en_PH) "
        "locale, with a fallback to en_US, and supported a 15-second listening window with "
        "automatic pause detection (Sloane, 2022).",
        (
            "Speech-to-Text. The speech_to_text package was used in SmartSpend to enable voice "
            "input for recording expenses hands-free. When a user spoke an expense \u2014 for "
            "example, \u201cGastos ko ng 150 sa pagkain\u201d \u2014 the spoken text was transcribed and "
            "passed to the LLM for structured expense parsing. The system automatically "
            "detected the Filipino English (en_PH) locale, with a fallback to en_US, and "
            "supported a 15-second listening window with automatic pause detection (Sloane, 2022)."
        )
    ),
    (
        # Google ML Kit OCR — keep detail, reframe focus
        "Google ML Kit Text Recognition (OCR). Google ML Kit's Latin script text recognizer "
        "was used to extract text from receipt images.",
        (
            "Google ML Kit Text Recognition (OCR). Google ML Kit\u2019s Latin script text "
            "recognizer was used in SmartSpend to extract text from receipt images captured "
            "by the user\u2019s camera or selected from the gallery. The extracted text was cleaned "
            "and routed based on content: single-item receipts were passed directly to the "
            "AI chat interface for automatic expense recording, while multi-item receipts were "
            "routed to a dedicated import review screen where each item was parsed individually. "
            "Users could review, edit categories, assign Want or Need classifications, and "
            "selectively confirm items before importing (Google, 2024e)."
        )
    ),
    (
        # Mobile Scanner
        "Mobile Scanner (Barcode). The mobile_scanner package was used for barcode scanning. "
        "Each scan was saved to a local scan history, and a prompt asked the user to describe "
        "the product before AI parsing. The scanner included a torch toggle and a visual "
        "overlay guide frame (Bociek, 2023; ZXing, 2023).",
        (
            "Mobile Scanner (Barcode). The mobile_scanner package was used in SmartSpend to "
            "scan product barcodes as an alternative expense input method. After a successful "
            "scan, the user was prompted to describe or confirm the product, and the LLM "
            "parsed the entry into a structured expense record. Each scan was saved to a local "
            "scan history for reference. The scanner included a torch toggle and a visual "
            "overlay guide frame to assist with low-light scanning (Bociek, 2023; ZXing, 2023)."
        )
    ),
    (
        # fl_chart
        "fl_chart. The fl_chart package was used to render interactive charts in the Analytics "
        "screen, including a pie chart for category breakdown, a bar chart for monthly spending "
        "trends, and a line chart for the 30-day Financial Health Score history "
        "(Flutter 4 Fun, 2022).",
        (
            "fl_chart. The fl_chart package was used to render SmartSpend\u2019s Analytics screen "
            "visualizations. It powered three interactive charts: a pie chart showing expense "
            "breakdown by category, a bar chart displaying monthly spending trends, and a line "
            "chart showing the user\u2019s 30-day Financial Health Score history. These charts "
            "updated in real time as the user logged new expenses (Flutter 4 Fun, 2022)."
        )
    ),
    (
        # local_auth
        "local_auth. The local_auth package enabled biometric authentication (fingerprint or "
        "face unlock) as a login option after the user's first successful login, using the "
        "device's enrolled biometrics with a PIN fallback (The Flutter Authors, 2013).",
        (
            "local_auth. The local_auth package was used to add biometric login to SmartSpend "
            "as a faster alternative to entering email and password on subsequent app launches. "
            "After the user\u2019s first successful credential-based login, biometric authentication "
            "(fingerprint or face unlock) became available using the device\u2019s enrolled biometrics, "
            "with a PIN fallback for devices without biometric hardware (The Flutter Authors, 2013)."
        )
    ),
    (
        # Financial Health Score
        "Financial Health Score (FHS). SmartSpend introduced a Financial Health Score ranging "
        "from 0 to 100 that provided users with a single, interpretable indicator of their "
        "budgeting behavior.",
        (
            "Financial Health Score (FHS). SmartSpend introduced a Financial Health Score (FHS) "
            "ranging from 0 to 100 as the application\u2019s core academic contribution and primary "
            "user-facing summary metric. The FHS gave each user a single, interpretable number "
            "reflecting their current budgeting behavior. It operated in two modes: Full Mode "
            "(income tracking enabled) computed the score from four equally weighted components "
            "\u2014 Savings Rate, Overspend Control, Budget Adherence, and Logging Consistency \u2014 each "
            "contributing 25 points. Lightweight Mode (income tracking disabled) used an "
            "alternative set of four components \u2014 Spending Restraint, Logging Consistency, "
            "Category Balance, and Habit Streak \u2014 to remain useful for users without a fixed "
            "income. The FHS was formally classified as a Prototype Observed Financial Health "
            "Indicator and its full formula, component weights, and consequence mechanism were "
            "documented in Chapter III."
        )
    ),
]

# ── Comment 1: Data Gathering Tools restructured per objective ────────────────
DATA_GATHERING_NEW_PARAGRAPHS = [
    # Intro / overview
    (
        "This section describes the data gathering tools and procedures used for each of the "
        "three study objectives. Each objective required a distinct instrument and procedure "
        "aligned with its specific purpose."
    ),
    # Objective 1
    (
        "For the first objective \u2014 assessing the financial management practices, budgeting "
        "challenges, and expense tracking behaviors of the target population \u2014 a validated "
        "structured survey questionnaire (see Appendix A) was used as the primary data "
        "gathering tool. The questionnaire was administered to thirty (30) respondents "
        "comprising parents aged 35 to 55 and young professionals aged 21 to 35 in San "
        "Fernando City, La Union. It covered financial habits, budgeting methods, common "
        "challenges, and technology acceptance. Prior to distribution, the questionnaire "
        "underwent content validation by Avigail Candevario, PFMe, a graduate of Bachelor of "
        "Science in Commerce major in Management and an active business owner with experience "
        "in financial management and business operations. Survey responses were tallied and "
        "analyzed using frequency and percentage to identify patterns and trends in the "
        "financial behaviors of the respondents."
    ),
    # Objective 2
    (
        "For the second objective \u2014 designing and developing the SmartSpend mobile application "
        "\u2014 the results of the first objective served as the primary basis for feature "
        "identification and system design. The specific financial challenges and technology "
        "preferences identified in the needs assessment directly shaped the application\u2019s "
        "feature set, including multi-modal expense input, conversational AI assistance, "
        "offline-first local storage, and the Financial Health Score. SmartSpend was built "
        "using the Flutter framework targeting Android, with SQLite (sqflite v11) for local "
        "storage, Firebase Firestore for cloud synchronization, Firebase Authentication for "
        "user identity management, and Gemini 3.5 Flash-Lite as the primary LLM API for AI "
        "features. Development followed an Agile Kanban methodology with iterative feature "
        "delivery across structured phases: Backlog, Requirements, Design, Development, "
        "Testing, Deployment, and Done/Review."
    ),
    # Objective 3
    (
        "For the third objective \u2014 evaluating the usability of the developed system \u2014 the "
        "10-item System Usability Scale (SUS) questionnaire (see Appendix C) was administered "
        "as the evaluation instrument. Respondents were required to use the SmartSpend "
        "application (the full version or the built-in Demo Mode) for a minimum of 10 minutes "
        "before completing the SUS. A screening question confirmed that each respondent had "
        "met this usage threshold. SUS scores were computed using the standard Brooke (1996) "
        "formula: for odd-numbered items, the item score minus 1 was used; for even-numbered "
        "items, 5 minus the item score was used; the sum of all adjusted scores was then "
        "multiplied by 2.5 to yield a score out of 100. Individual scores were averaged to "
        "produce the overall mean SUS score, which was interpreted against the Bangor et al. "
        "(2009) adjective rating scale and the pre-established acceptance threshold of 80."
    ),
]

# ── Figure / Table renaming maps ──────────────────────────────────────────────
FIGURE_MAP = {
    "Figure 3.13": "Figure 22",
    "Figure 3.12": "Figure 21",
    "Figure 3.11": "Figure 20",
    "Figure 3.10": "Figure 19",
    "Figure 3.9":  "Figure 18",
    "Figure 3.8":  "Figure 17",
    "Figure 3.7":  "Figure 16",
    "Figure 3.6":  "Figure 15",
    "Figure 3.5":  "Figure 14",
    "Figure 3.4":  "Figure 13",
    "Figure 3.3":  "Figure 12",
    "Figure 3.2":  "Figure 11",
    "Figure 3.1":  "Figure 10",
    "Figure 2.7":  "Figure 9",
    "Figure 2.6":  "Figure 8",
    "Figure 2.5":  "Figure 7",
    "Figure 2.4":  "Figure 6",
    "Figure 2.3":  "Figure 5",
    "Figure 2.2":  "Figure 4",
    "Figure 2.1":  "Figure 3",
    "Figure 1.2":  "Figure 2",
    "Figure 1.1":  "Figure 1",
}

TABLE_MAP = {
    "Table 3.5": "Table 9",
    "Table 3.4": "Table 8",
    "Table 3.3": "Table 7",
    "Table 3.2": "Table 6",
    "Table 3.1": "Table 5",
    "Table 2.2": "Table 4",
    "Table 2.1": "Table 3",
    "Table 1.1": "Table 1",
}

# ══════════════════════════════════════════════════════════════════════════════
# Replacement counters
# ══════════════════════════════════════════════════════════════════════════════
COUNTS = {
    "mixed_methods": 0,
    "purposive_sampling_respondents": 0,
    "purposive_sampling_preserved": 0,
    "seven_recommendations": 0,
    "six_provider": 0,
    "five_fallbacks": 0,
    "proposed_smartspend": 0,
    "proposed_system": 0,
    "will_be_developed": 0,
    "validator_blank_filled": 0,
    "population_blank": 0,
    "figure_renumbered": 0,
    "table_renumbered": 0,
    "abstract_replaced": 0,
    "rec_8_9_added": 0,
    "table3_note_added": 0,
    "research_design_rewritten": 0,
    "tech_bg_rewritten": 0,
    "data_gathering_rewritten": 0,
}


# ══════════════════════════════════════════════════════════════════════════════
# Utilities
# ══════════════════════════════════════════════════════════════════════════════
def merge_counts(a, b):
    return {k: a.get(k, 0) + b.get(k, 0) for k in set(a) | set(b)}


def set_para_text(para, new_text):
    """Replace all runs in a paragraph with new_text in the first run."""
    if not para.runs:
        return
    para.runs[0].text = new_text
    for run in para.runs[1:]:
        run.text = ""


def apply_replacements(text):
    """Apply all accuracy-correction text replacements. Returns (new_text, counts)."""
    local = {k: 0 for k in COUNTS}

    # 1. Research design
    for pat in [
        r"mixed[- ]methods developmental research",
        r"mixed[- ]methods research",
        r"mixed[- ]method research",
        r"mixed[- ]methods",
        r"mixed[- ]method",
    ]:
        new, n = re.subn(pat, "quantitative descriptive developmental", text, flags=re.IGNORECASE)
        local["mixed_methods"] += n; text = new

    # 2. Sampling (context-aware)
    validator_markers = ["avigail", "content validator", "content validation"]
    has_validator_ref = any(m in text.lower() for m in validator_markers)
    if has_validator_ref:
        local["purposive_sampling_preserved"] += text.lower().count("purposive sampling")
    else:
        new, n = re.subn(r"purposive sampling", "random sampling", text, flags=re.IGNORECASE)
        local["purposive_sampling_respondents"] += n; text = new

    # 3. Recommendations count
    new, n = re.subn(r"seven recommendations", "nine recommendations", text, flags=re.IGNORECASE)
    local["seven_recommendations"] += n; text = new
    new, n = re.subn(r"\b7 recommendations\b", "9 recommendations", text, flags=re.IGNORECASE)
    local["seven_recommendations"] += n; text = new

    # 4. Failover chain
    new, n = re.subn(r"six[- ]provider", "eight-provider", text, flags=re.IGNORECASE)
    local["six_provider"] += n; text = new
    new, n = re.subn(
        r"\(Gemini 3\.5 Flash-Lite as primary,\s+five fallbacks\)",
        "(Gemini 3.5 Flash-Lite as primary, seven fallbacks)",
        text, flags=re.IGNORECASE
    )
    local["five_fallbacks"] += n; text = new
    new, n = re.subn(r"\bfive fallbacks\b", "seven fallbacks", text, flags=re.IGNORECASE)
    local["five_fallbacks"] += n; text = new
    new, n = re.subn(r"\b5 fallbacks\b", "seven fallbacks", text, flags=re.IGNORECASE)
    local["five_fallbacks"] += n; text = new

    # 5. Tense corrections
    new, n = re.subn(r"\bproposed SmartSpend\b", "developed SmartSpend", text)
    local["proposed_smartspend"] += n; text = new
    new, n = re.subn(r"\bproposed system\b", "developed system", text, flags=re.IGNORECASE)
    local["proposed_system"] += n; text = new
    new, n = re.subn(r"\bthe proposed\b", "the developed", text, flags=re.IGNORECASE)
    local["proposed_system"] += n; text = new
    new, n = re.subn(r"\bwill be developed\b", "was developed", text, flags=re.IGNORECASE)
    local["will_be_developed"] += n; text = new

    # 6. Validator blank
    new, n = re.subn(
        r"reviewed by\s*,?\s*a graduate",
        "reviewed by Avigail Candevario, PFMe, a graduate",
        text, flags=re.IGNORECASE
    )
    local["validator_blank_filled"] += n; text = new

    # 7. Population blank
    new, n = re.subn(
        r"There are a total of _+\s*respondents",
        "A total of thirty (30) respondents participated",
        text, flags=re.IGNORECASE
    )
    local["population_blank"] += n; text = new
    new, n = re.subn(
        r"total of _+\s*respondents",
        "total of thirty (30) respondents",
        text, flags=re.IGNORECASE
    )
    local["population_blank"] += n; text = new

    # 8. Figure renumbering (sorted longest-first to avoid partial matches)
    for old, new_fig in sorted(FIGURE_MAP.items(), key=lambda x: -len(x[0])):
        escaped = re.escape(old)
        new, n = re.subn(escaped + r"\.", new_fig + ".", text)
        local["figure_renumbered"] += n; text = new
        new, n = re.subn(escaped + r"(?![\d.])", new_fig, text)
        local["figure_renumbered"] += n; text = new

    # 9. Table renumbering
    for old, new_tbl in sorted(TABLE_MAP.items(), key=lambda x: -len(x[0])):
        escaped = re.escape(old)
        new, n = re.subn(escaped + r"\.", new_tbl + ":", text)
        local["table_renumbered"] += n; text = new
        new, n = re.subn(escaped + r"(?![\d.])", new_tbl, text)
        local["table_renumbered"] += n; text = new

    return text, local


def replace_in_paragraph(para):
    """Apply replacements to a paragraph's text, preserving run formatting."""
    if not para.runs:
        return {k: 0 for k in COUNTS}
    full_text = "".join(run.text for run in para.runs)
    if not full_text.strip():
        return {k: 0 for k in COUNTS}
    new_text, local = apply_replacements(full_text)
    if new_text != full_text:
        set_para_text(para, new_text)
    return local


def process_all_paragraphs(doc):
    """Apply replacements to every paragraph and table cell."""
    total = {k: 0 for k in COUNTS}
    for para in doc.paragraphs:
        total = merge_counts(total, replace_in_paragraph(para))
    for table in doc.tables:
        for row in table.rows:
            for cell in row.cells:
                for para in cell.paragraphs:
                    total = merge_counts(total, replace_in_paragraph(para))
    return total


def insert_para_after(doc, anchor_elem, text, style="normal"):
    """Create a new paragraph with text and insert it after anchor_elem in the body."""
    new_p = doc.add_paragraph(text, style=style)
    new_elem = new_p._element
    doc.element.body.remove(new_elem)
    anchor_elem.addnext(new_elem)
    return new_elem


# ══════════════════════════════════════════════════════════════════════════════
# Step 1 — Replace abstract
# ══════════════════════════════════════════════════════════════════════════════
def replace_abstract(doc):
    abstract_start = None
    abstract_end = None
    for i, para in enumerate(doc.paragraphs):
        txt = para.text.strip()
        if txt.upper() == "ABSTRACT":
            abstract_start = i
        elif abstract_start is not None and abstract_end is None:
            if txt.upper() in ("ACKNOWLEDGEMENT", "ACKNOWLEDGMENT", "TABLE OF CONTENTS"):
                abstract_end = i
                break
    if abstract_start is None:
        print("  WARNING: Abstract not found")
        return 0
    if abstract_end is None:
        abstract_end = abstract_start + 10

    print(f"  Abstract found: paragraphs {abstract_start}–{abstract_end-1}")
    body = doc.element.body
    all_paras = doc.paragraphs
    for para in all_paras[abstract_start + 1 : abstract_end]:
        para._element.getparent().remove(para._element)

    header_elem = doc.paragraphs[abstract_start]._element
    for abs_text in reversed(ABSTRACT_PARAGRAPHS):
        new_p = doc.add_paragraph(abs_text, style="normal")
        elem = new_p._element
        body.remove(elem)
        header_elem.addnext(elem)
    return 1


# ══════════════════════════════════════════════════════════════════════════════
# Step 2 — Comment 2: Rewrite qualitative Research Design sentence
# ══════════════════════════════════════════════════════════════════════════════
def rewrite_research_design_sentence(doc):
    """
    Find and replace the qualitative-sounding survey sentence in Research Design.
    Operates on paragraph full text (run-collapsed) to handle split runs.
    Handles both straight and curly apostrophes.
    """
    # Match a fragment that avoids the apostrophe variant issue
    target_fragment = "structured survey questionnaires were used to collect respondents"
    replaced = 0
    for para in doc.paragraphs:
        full = "".join(r.text for r in para.runs)
        if target_fragment.lower() in full.lower():
            set_para_text(para, RESEARCH_DESIGN_NEW)
            replaced += 1
            print("  Rewritten Research Design qualitative sentence")
    return replaced


# ══════════════════════════════════════════════════════════════════════════════
# Step 3 — Comment 3: Rewrite Technical Background entries
# ══════════════════════════════════════════════════════════════════════════════
def rewrite_technical_background(doc):
    """Replace each Technology paragraph with its SmartSpend-focused rewrite."""
    replaced = 0
    for old_start, new_text in TECH_BG_REWRITES:
        # Match by first ~60 chars of the old text
        marker = old_start[:60].lower()
        for para in doc.paragraphs:
            full = "".join(r.text for r in para.runs)
            if full.lower().startswith(marker[:40]):
                set_para_text(para, new_text)
                replaced += 1
                label = old_start[:50]
                print(f"  Rewritten Tech BG: {label}...")
                break
    return replaced


# ══════════════════════════════════════════════════════════════════════════════
# Step 4 — Comment 1: Restructure Data Gathering Tools and Procedure
# ══════════════════════════════════════════════════════════════════════════════
def restructure_data_gathering(doc):
    """
    Find the Data Gathering Tools and Procedure section and replace
    its content with the per-objective structure.
    """
    section_idx = None
    section_end_idx = None

    for i, para in enumerate(doc.paragraphs):
        txt = para.text.strip()
        if re.match(r"^Data Gathering Tools and Procedure\s*$", txt, re.IGNORECASE):
            section_idx = i
        elif section_idx is not None and section_end_idx is None:
            # Next major section header ends this block
            if re.match(r"^(Software Methodology|Ethical Considerations|CHAPTER|Population|Research Design)\s*",
                        txt, re.IGNORECASE) and len(txt) < 80 and i > section_idx + 1:
                section_end_idx = i
                break

    if section_idx is None:
        print("  WARNING: Data Gathering Tools and Procedure section not found")
        return 0

    if section_end_idx is None:
        section_end_idx = section_idx + 12  # fallback

    print(f"  Data Gathering section: {section_idx}–{section_end_idx-1}")

    all_paras = doc.paragraphs
    body = doc.element.body

    # Remove old content paragraphs (keep the header itself)
    old_content = all_paras[section_idx + 1 : section_end_idx]
    for para in old_content:
        elem = para._element
        parent = elem.getparent()
        if parent is not None:
            parent.remove(elem)

    # Re-fetch anchor (the section header paragraph element)
    # Need to find it again since indices shifted
    anchor_elem = None
    for para in doc.paragraphs:
        if re.match(r"^Data Gathering Tools and Procedure\s*$", para.text.strip(), re.IGNORECASE):
            anchor_elem = para._element
            break

    if anchor_elem is None:
        print("  WARNING: Could not re-find section header after removal")
        return 0

    # Insert new paragraphs in reverse order after the header
    for new_text in reversed(DATA_GATHERING_NEW_PARAGRAPHS):
        new_p = doc.add_paragraph(new_text, style="normal")
        new_elem = new_p._element
        body.remove(new_elem)
        anchor_elem.addnext(new_elem)

    return 1


# ══════════════════════════════════════════════════════════════════════════════
# Step 5 — Add recommendations 8 & 9 if missing
# ══════════════════════════════════════════════════════════════════════════════
def add_missing_recommendations(doc):
    rec_section_idx = None
    has_rec_8 = False
    has_rec_9 = False
    last_rec_elem = None

    for i, para in enumerate(doc.paragraphs):
        txt = para.text.strip()
        if re.match(r"^Recommendations?\s*$", txt, re.IGNORECASE):
            rec_section_idx = i
        if rec_section_idx is not None and i > rec_section_idx:
            if re.match(r"^[1-9]\.", txt):
                last_rec_elem = para._element
            if re.match(r"^8\.", txt):
                has_rec_8 = True
            if re.match(r"^9\.", txt):
                has_rec_9 = True
            if re.match(r"^References\s*$", txt, re.IGNORECASE):
                break

    added = 0
    if rec_section_idx is None:
        print("  WARNING: Recommendations section not found")
        return 0
    if last_rec_elem is None:
        print("  WARNING: No numbered recommendations found")
        return 0

    insert_after = last_rec_elem

    if not has_rec_9:
        new_p = doc.add_paragraph(REC_9, style="normal")
        new_elem = new_p._element
        doc.element.body.remove(new_elem)
        insert_after.addnext(new_elem)
        insert_after = new_elem
        added += 1
        print("  Added recommendation 9")

    if not has_rec_8:
        new_p = doc.add_paragraph(REC_8, style="normal")
        new_elem = new_p._element
        doc.element.body.remove(new_elem)
        insert_after.addprevious(new_elem)
        added += 1
        print("  Added recommendation 8")

    return added


# ══════════════════════════════════════════════════════════════════════════════
# Step 6 — Add Table 3 note
# ══════════════════════════════════════════════════════════════════════════════
def add_table3_note(doc):
    table3_idx = None
    for i, para in enumerate(doc.paragraphs):
        txt = para.text.strip()
        if re.search(r"Table\s+3[:\.]?\s+Distribution of Respondents", txt, re.IGNORECASE):
            table3_idx = i
            break

    if table3_idx is None:
        print("  WARNING: Table 3 (Distribution of Respondents) not found")
        return 0

    # Check if note already exists nearby
    for j in range(table3_idx, min(table3_idx + 20, len(doc.paragraphs))):
        if TABLE3_NOTE[:40].lower() in doc.paragraphs[j].text.lower():
            print("  Table 3 note already present")
            return 0

    # Find insertion point: after a Note line or before next major item
    insert_elem = doc.paragraphs[table3_idx]._element
    for j in range(table3_idx + 1, min(table3_idx + 25, len(doc.paragraphs))):
        p = doc.paragraphs[j]
        txt = p.text.strip()
        if txt.startswith("Note.") or txt.startswith("Note:"):
            insert_elem = p._element
            break
        if re.match(r"^(Table|Figure|CHAPTER|References)", txt, re.IGNORECASE) and j > table3_idx + 2:
            insert_elem = doc.paragraphs[j - 1]._element
            break

    new_p = doc.add_paragraph(TABLE3_NOTE, style="normal")
    new_elem = new_p._element
    doc.element.body.remove(new_elem)
    insert_elem.addnext(new_elem)
    print("  Added Table 3 note")
    return 1


# ══════════════════════════════════════════════════════════════════════════════
# Main
# ══════════════════════════════════════════════════════════════════════════════
def main():
    print("=" * 65)
    print("Manuscript Merge Script — SmartSpend Final")
    print("=" * 65)

    print(f"\nLoading Ellen's V4...")
    doc = Document(ELLEN_V4)
    print(f"  {len(doc.paragraphs)} paragraphs, {len(doc.tables)} tables")

    # Step 1: Replace abstract
    print("\n[1] Replacing abstract with accurate version...")
    n = replace_abstract(doc)
    COUNTS["abstract_replaced"] += n

    # Step 2 (Comment 2): Rewrite qualitative Research Design sentence
    print("\n[2] Rewriting qualitative Research Design sentence...")
    n = rewrite_research_design_sentence(doc)
    COUNTS["research_design_rewritten"] += n

    # Step 3 (Comment 3): Rewrite Technical Background entries
    print("\n[3] Rewriting Technical Background (SmartSpend-focused)...")
    n = rewrite_technical_background(doc)
    COUNTS["tech_bg_rewritten"] += n

    # Step 4 (Comment 1): Restructure Data Gathering Tools per objective
    print("\n[4] Restructuring Data Gathering Tools per objective...")
    n = restructure_data_gathering(doc)
    COUNTS["data_gathering_rewritten"] += n

    # Step 5: Apply all text replacements throughout
    print("\n[5] Applying accuracy corrections throughout document...")
    total_counts = process_all_paragraphs(doc)
    for k, v in total_counts.items():
        COUNTS[k] = COUNTS.get(k, 0) + v

    # Step 6: Add recommendations 8 & 9
    print("\n[6] Checking recommendations 8 and 9...")
    n = add_missing_recommendations(doc)
    COUNTS["rec_8_9_added"] += n

    # Step 7: Add Table 3 note
    print("\n[7] Checking Table 3 note...")
    n = add_table3_note(doc)
    COUNTS["table3_note_added"] += n

    # Save
    print(f"\n[8] Saving to:\n  {OUTPUT}")
    doc.save(OUTPUT)
    print("  Saved.")

    # Sanity check
    print("\n[9] Sanity check...")
    verify = Document(OUTPUT)
    full_text = " ".join(p.text for p in verify.paragraphs)

    checks = [
        ("quantitative descriptive developmental", "quantitative descriptive developmental"),
        ("nine recommendations",                   "nine recommendations"),
        ("eight-provider cloud failover",           "eight-provider cloud failover"),
        ("Avigail Candevario, PFMe",                "Avigail Candevario, PFMe"),
        ("SUS score 61.83",                         "61.83"),
        ("SD 17.58",                                "17.58"),
        ("30 respondents",                          "30"),
        ("random sampling",                         "random sampling"),
        ("Gemini 3.5 Flash-Lite",                   "Gemini 3.5 Flash-Lite"),
        ("was developed",                           "was developed"),
        ("Data Gathering per-objective intro",      "this section describes the data gathering tools"),
        ("Tech BG Flutter rewrite",                 "Flutter was used to build the SmartSpend Android"),
        ("nine recommendations count",              "nine recommendations"),
    ]

    all_passed = True
    for label, search in checks:
        found = search.lower() in full_text.lower()
        status = "PASS" if found else "FAIL"
        if not found:
            all_passed = False
        print(f"  [{status}] {label}")

    # Check mixed-methods is gone
    if re.search(r"mixed[- ]methods", full_text, re.IGNORECASE):
        print("  [WARN] 'mixed-methods' still present in document — review manually")
    else:
        print("  [PASS] 'mixed-methods' cleaned")

    # Summary
    print("\n" + "=" * 65)
    print("REPLACEMENT SUMMARY")
    print("=" * 65)
    print(f"  abstract replaced                                   : {COUNTS['abstract_replaced']}")
    print(f"  research design sentence rewritten (Comment 2)      : {COUNTS['research_design_rewritten']}")
    print(f"  tech background entries rewritten (Comment 3)       : {COUNTS['tech_bg_rewritten']}")
    print(f"  data gathering restructured per objective (Comment 1): {COUNTS['data_gathering_rewritten']}")
    print(f"  mixed-methods → quantitative descriptive dev        : {COUNTS['mixed_methods']}")
    print(f"  purposive sampling → random sampling (respondents)  : {COUNTS['purposive_sampling_respondents']}")
    print(f"  purposive sampling preserved (validator sentences)  : {COUNTS['purposive_sampling_preserved']}")
    print(f"  seven/7 recommendations → nine/9                    : {COUNTS['seven_recommendations']}")
    print(f"  six-provider → eight-provider                       : {COUNTS['six_provider']}")
    print(f"  five/5 fallbacks → seven fallbacks                  : {COUNTS['five_fallbacks']}")
    print(f"  proposed SmartSpend → developed SmartSpend          : {COUNTS['proposed_smartspend']}")
    print(f"  proposed system/the proposed → developed            : {COUNTS['proposed_system']}")
    print(f"  will be developed → was developed                   : {COUNTS['will_be_developed']}")
    print(f"  validator blank filled                               : {COUNTS['validator_blank_filled']}")
    print(f"  population blank fixed                               : {COUNTS['population_blank']}")
    print(f"  figures renumbered                                   : {COUNTS['figure_renumbered']}")
    print(f"  tables renumbered                                    : {COUNTS['table_renumbered']}")
    print(f"  recommendations 8/9 added                           : {COUNTS['rec_8_9_added']}")
    print(f"  Table 3 note added                                   : {COUNTS['table3_note_added']}")
    print()
    if all_passed:
        print("All sanity checks PASSED.")
    else:
        print("Some sanity checks FAILED — review marked items above.")
    print(f"\nOutput: {OUTPUT}")
    print("=" * 65)


if __name__ == "__main__":
    main()
