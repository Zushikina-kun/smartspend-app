# Implementation Plan — Peso Phase 2 (Achievements + Voice Service)

## Context from exploration

- **achievements_screen.dart** — `_allBadges` is a `static const` list of 25 `_Badge` items. The last entry is `'advice_5'`. `_computeEarned()` is an `async Future<void>` method with a big sequential block. It already imports `shared_preferences`, `db_service.dart`, and `peso_mascot.dart`.
- **ai_screen.dart** — already imports `shared_preferences`. Messages map uses key `"text"` for all displayed messages, but the Peso `onTap` greeting uses key `'content'` (line ~3495) — this is a *different* key used only in that one isolated initial add. The `_send()` method saves user messages via `await DBService.saveChatMessage(role: 'user', message: text)` (line ~744). `AIChatService.clearHistory()` is called in three places: New Chat (line ~3073), Clear Chat (line ~3113), and Full AI Reset (`val == 'reset_ai'`, line ~3152).
- **peso_mascot.dart** — `PesoMood` enum is already defined with all moods referenced in the plan (`celebrating`, `excited`, `proud`, `winking`). `PesoMascot` class is importable.
- **db_service.dart** — `getChatHistory(limit:)`, `getDebts()`, `getExpenses()` all confirmed as static public methods.
- **Build command**: `flutter build apk` (or `flutter run` for debug). Analyze: `flutter analyze`.

---

- [ ] 1. **Create `lib/services/peso_voice_service.dart`** (Task 2)

  Create the file from scratch with the exact content specified in the task. This is a pure Dart file with no Flutter dependencies — just `dart:math`. No other files need to change yet; this step just makes the service available to import.

  **Files:** `lib/services/peso_voice_service.dart`

  **Risk:** The string interpolation in `vars.forEach` uses `'{\$k}'` literal (the `$` is not escaped in a context with no interpolation — that string is correct because the outer string uses single quotes and the replacement key is literally `{key}`. Double-check: in the map, every placeholder is written `{category}`, `{amount}`, etc., without a `$`. The `vars.forEach` replaces `'{$k}'` which evaluates at runtime to `'{category}'` etc. This is correct).

  **Verify:** `flutter analyze lib/services/peso_voice_service.dart` — zero errors.

---

- [ ] 2. **Add 10 new badges to `_allBadges` in `achievements_screen.dart`** (Task 1a)

  Append 10 `_Badge` entries after the last existing entry `_Badge('🎓', 'Financial Literate', ...)` (the `'advice_5'` badge). The insertion point is after the closing `)` of that entry, still inside the `_allBadges` list, before the closing `];`.

  **Exact anchor** (find this text):
  ```dart
      _Badge('🎓', 'Financial Literate', 'Ask AI 5 financial advice questions',
          'advice_5'),
  ];
  ```
  Replace with:
  ```dart
      _Badge('🎓', 'Financial Literate', 'Ask AI 5 financial advice questions',
          'advice_5'),
      // Peso Companion badges
      _Badge('🤜', 'Peso Pal', 'Tap Peso 10 times in the app', 'peso_tap_10'),
      _Badge('💬', 'Chatterbox', 'Send 50 AI messages total', 'ai_50'),
      _Badge('🌅', 'Morning Logger', 'Log before 9 AM on 7 different days', 'morning_7'),
      _Badge('📆', 'Perfect Week', 'Log expenses every day for 7 consecutive days', 'log_7'),
      _Badge('💚', 'Generous Soul', 'Record lending money 3 times', 'lent_3'),
      _Badge('⭐', 'App Veteran', 'Use SmartSpend for 30 days since first expense', 'veteran_30'),
      _Badge('🏅', 'Collector', 'Earn 15 badges total', 'badges_15'),
      _Badge('☀️', 'Early Bird Pro', 'Log before 8 AM on 5 different days', 'early_pro'),
      _Badge('🌙', 'Night Owl Pro', 'Log after 10 PM on 5 different days', 'night_pro'),
      _Badge('🎤', 'Peso Fan', 'Have a 10-message chat session with Peso', 'chat_session_10'),
  ];
  ```

  **Risk:** `_allBadges.length` changes from 25 → 35, which affects the `earnedCount / _allBadges.length` display in the AppBar. That is the intended behavior.

  **Files:** `lib/screens/achievements_screen.dart`

  **Verify:** `flutter analyze lib/screens/achievements_screen.dart` — zero errors.

---

- [ ] 3. **Add tracking logic for 10 new badges in `_computeEarned()`** (Task 1b)

  Depends on step 2 (badge IDs must exist first).

  **Insertion point:** Find the final try/catch block that checks `earned_badge_ids` via SharedPreferences. There is a comment `// Celebrate newly unlocked badges — diff against previously stored set` before that block. Insert the new logic BEFORE that comment (i.e., between the `earned.add('advice_5')` logic's last block and the celebration try/catch).

  **Exact anchor** to find:
  ```dart
    if (mounted)
      setState(() {
        _earned = earned;
        _loading = false;
      });

    // Celebrate newly unlocked badges — diff against previously stored set
  ```
  Insert the full block from the task specification (Task 1b) between the `setState` call and the `// Celebrate newly unlocked badges` comment.

  **Imports needed:** None new — `SharedPreferences` is already imported on line 2. `DBService` is already imported. `PesoMood` / `PesoMascot` are already imported (needed for step 4).

  **Key correctness notes:**
  - `DBService.getChatHistory(limit: 9999)` — confirmed method signature is `getChatHistory({int limit = 100})`. The call is valid.
  - `DBService.getDebts()` — confirmed static method, returns `List<Map<String, dynamic>>`. Each map has a `'type'` key.
  - `allExp` is fetched 4 times in the new block (morning, early bird, night owl, perfect week). This is safe but slightly redundant — the implementer MAY hoist it to a single `final allExp = await DBService.getExpenses();` call assigned before the block, then reuse `allExp` in all four checks. However, each is wrapped in `try/catch` so independent fetches are safer for isolation. Keep as-is per spec.
  - The `Collector` badge (`badges_15`) checks `earned.length >= 15` AFTER other badges are computed — order matters; keep it after the other 9 new badges.
  - `chat_session_10` reads `prefs.getInt('peso_session_msg_count')` — this key is written by step 6 (ai_screen wiring). Both steps are independent features but `chat_session_10` gracefully defaults to 0 if the key doesn't exist yet.

  **Files:** `lib/screens/achievements_screen.dart`

  **Verify:** `flutter analyze lib/screens/achievements_screen.dart` — zero errors.

---

- [ ] 4. **Replace SnackBar unlock loop with Peso bottom sheet** (Task 1c)

  Depends on step 3 (the containing method must already be updated).

  **Exact anchor** — find the `for (final id in newlyEarned)` loop inside the `// Celebrate newly unlocked badges` try/catch block:
  ```dart
      if (newlyEarned.isNotEmpty && mounted) {
        for (final id in newlyEarned) {
          final badge = _allBadges.where((b) => b.id == id).firstOrNull;
          if (badge == null) continue;
          ScaffoldMessenger.of(context).showSnackBar(
  ```
  Replace the entire `for` loop body (keep the surrounding `if (newlyEarned.isNotEmpty && mounted)` check and keep the prefs save line `await prefs.setStringList('earned_badge_ids', earned.toList());` which is BEFORE the loop) with the `showModalBottomSheet` version from the task spec.

  **Key correctness notes:**
  - `PesoMood` — already imported via `peso_mascot.dart`. No new import needed.
  - `PesoMascot` — already imported. The constructor call `PesoMascot(size: 80, mood: mood)` is valid per the widget's constructor signature.
  - `Colors.transparent` — available via `flutter/material.dart` (already imported).
  - `withValues(alpha:)` — this is the project's established pattern (seen throughout the file). Do NOT use deprecated `withOpacity`.
  - The `await Future.delayed(const Duration(milliseconds: 200))` at the end of the loop replaces the existing `await Future.delayed(const Duration(milliseconds: 300))` — both serve the same purpose (slight gap between multiple sheets).
  - The `'content'` key mismatch does NOT affect this step (it's in ai_screen, not here). The message map key in achievements_screen is irrelevant.

  **Files:** `lib/screens/achievements_screen.dart`

  **Verify:** `flutter analyze lib/screens/achievements_screen.dart` — zero errors.

---

- [ ] 5. **Add `peso_voice_service.dart` import to `ai_screen.dart`** (Task 3a)

  Depends on step 1 (file must exist first).

  **Exact insertion point:** After the last `../services/` import in ai_screen.dart. Currently the last services import is `'../services/debug_service.dart'` and `'../services/undo_service.dart'` and `'../services/behavioral_feedback_service.dart'` etc. Add after the existing services imports block, keeping alphabetical order relative to `p`:
  ```dart
  import '../services/peso_voice_service.dart';
  ```
  Place it after `'../services/ocr_service.dart'` and before `'../services/score_service.dart'` (alphabetical by file name: ocr → peso → score).

  **Files:** `lib/screens/ai_screen.dart`

  **Verify:** `flutter analyze lib/screens/ai_screen.dart` — zero errors (no undefined name).

---

- [ ] 6. **Replace static greeting string with `PesoVoiceService.get()` call** (Task 3b)

  Depends on step 5 (import must be in place).

  **Exact anchor** (line ~3484 in ai_screen.dart):
  ```dart
                              final hour = DateTime.now().hour;
                              final greeting = hour < 12
                                  ? "Magandang umaga! ☀️"
                                  : hour < 18
                                      ? "Kumain ka na ba? 😄"
                                      : "Good evening! 🌙";
  ```
  Replace with:
  ```dart
                              final hour = DateTime.now().hour;
                              PesoContext greetingCtx;
                              if (hour < 5) {
                                greetingCtx = PesoContext.midnightGreeting;
                              } else if (hour < 12) {
                                greetingCtx = PesoContext.morningGreeting;
                              } else if (hour < 18) {
                                greetingCtx = PesoContext.afternoonGreeting;
                              } else {
                                greetingCtx = PesoContext.eveningGreeting;
                              }
                              final greeting = PesoVoiceService.get(greetingCtx);
  ```

  **Risk:** The `greeting` variable is also used two lines below in `PesoMascot.withSpeech(text: "$greeting\nAko si Peso...")`. The variable name stays the same so that usage requires no change.

  **Files:** `lib/screens/ai_screen.dart`

  **Verify:** `flutter analyze lib/screens/ai_screen.dart` — zero errors.

---

- [ ] 7. **Replace hardcoded onTap greeting string with `PesoVoiceService.get()`** (Task 3c)

  Depends on step 5 (import) and step 6 (context).

  **Exact anchor** (line ~3493 in ai_screen.dart). Note: the message map here uses key `'content'` (not `'text'`) — this is an isolated inconsistency in the original code. Keep `'content'` as the key:
  ```dart
                                        'content': 'Kumusta! 👋 I\'m Peso, your AI money buddy! '
                                            'You can talk to me in English or Filipino — just tell me what you spent, '
                                            'ask how your budget\'s doing, or say "how am I doing this month?" to start! 😊',
  ```
  Replace with:
  ```dart
                                        'content': PesoVoiceService.get(PesoContext.firstLogin),
  ```

  **Risk:** The `'content'` key is only used in this one `setState` call within the `onTap` handler. It is not rendered by the main message list builder (which uses `msg["text"]`), so this greeting appears only to initialize the `_messages` list. The key inconsistency (`'content'` vs `'text'`) predates this task — do not fix it here to avoid scope creep; leave as-is.

  **Files:** `lib/screens/ai_screen.dart`

  **Verify:** `flutter analyze lib/screens/ai_screen.dart` — zero errors.

---

- [ ] 8. **Track session message count in `_send()` and reset on clear** (Tasks 3d + 3e)

  Depends on step 5 (import), step 6 (establishes context for `PesoContext` usage).

  ### 3d — Track on send

  **Exact anchor** (line ~744 in ai_screen.dart):
  ```dart
      // Save user message to DB immediately — so it persists even if AI fails
      await DBService.saveChatMessage(role: 'user', message: text);
  ```
  Insert BEFORE that line:
  ```dart
      // Track session message count for chat_session_10 badge
      try {
        final prefs = await SharedPreferences.getInstance();
        final count = (prefs.getInt('peso_session_msg_count') ?? 0) + 1;
        await prefs.setInt('peso_session_msg_count', count);
      } catch (_) {}
  ```

  ### 3e — Reset on clear (THREE locations)

  **Location 1 — New Chat** (line ~3073): After `AIChatService.clearHistory();` inside the New Chat handler:
  ```dart
              AIChatService.clearHistory();
              setState(() {
  ```
  Insert after the `clearHistory()` call, before `setState`:
  ```dart
              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('peso_session_msg_count', 0);
              } catch (_) {}
  ```

  **Location 2 — Clear Chat** (line ~3113): Same pattern after the second `AIChatService.clearHistory();`:
  ```dart
              AIChatService.clearHistory();
              setState(() {
  ```
  Insert:
  ```dart
              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setInt('peso_session_msg_count', 0);
              } catch (_) {}
  ```

  **Location 3 — Full AI Reset** (`val == 'reset_ai'`, line ~3152): After `AIChatService.clearHistory(); // clear in-memory history`:
  ```dart
                AIChatService.clearHistory(); // clear in-memory history
                if (mounted) {
  ```
  Insert:
  ```dart
                try {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setInt('peso_session_msg_count', 0);
                } catch (_) {}
  ```

  **Risk:** Locations 1 and 2 are inside `async` button callbacks (`onPressed: () async { ... }`), so `await` is valid. Location 3 is inside `onSelected: (val) async { ... }`, also valid. `SharedPreferences` is already imported in this file (confirmed on line 5).

  **Disambiguation for locations 1 and 2:** Both have the exact same anchor text `AIChatService.clearHistory();` followed by `setState(() {`. Use surrounding context lines to disambiguate:
  - Location 1 has `await DBService.createNewChatSession();` immediately before it.
  - Location 2 also has `await DBService.createNewChatSession();` immediately before it but is preceded by `await DBService.deleteChatSession(sessionId);`.
  When using str_replace, include 2–3 lines of surrounding context to ensure each replacement is unique.

  **Files:** `lib/screens/ai_screen.dart`

  **Verify:** `flutter analyze lib/screens/ai_screen.dart` — zero errors.

---

- [ ] 9. **Full build verification**

  Run `flutter analyze` from the project root (no arguments = analyzes entire `lib/`). Then run `flutter build apk --debug` (or `flutter run --no-hot` on device if available) to confirm the app compiles with no errors.

  **Expected outcome:** Zero analysis errors or warnings introduced by these changes. The debug APK builds successfully.

  **Files:** no changes — verification only.

  **Verify:** `flutter analyze` exits with `No issues found!` (or only pre-existing warnings). `flutter build apk --debug` exits 0.

---

## Risk summary

| Risk | Mitigation |
|------|-----------|
| `'content'` key in ai_screen onTap message map is inconsistent with `'text'` used everywhere else | Keep `'content'` as-is; fixing it is out-of-scope and risks breaking the display logic that reads `'text'` |
| `Collector` badge (`badges_15`) checks `earned.length` AFTER all other badges — if ordering changes, threshold may not be met | Keep badge logic in exactly the order specified; `badges_15` check must come last among the new block |
| Three `clearHistory` reset locations in ai_screen — two share identical anchor text | Use 3+ surrounding context lines in str_replace to make each anchor unique |
| `PesoVoiceService.get()` returns a random line — greeting is non-deterministic | Intended by design; no risk to compilation or logic |
| `withValues(alpha:)` vs `withOpacity()` | Always use `withValues(alpha:)` — `withOpacity` is deprecated in this project (pattern confirmed throughout achievements_screen.dart) |
