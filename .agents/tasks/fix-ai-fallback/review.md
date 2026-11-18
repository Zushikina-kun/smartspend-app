# Review: fix-ai-fallback — AI Fallback Chain Fix

**Commit:** 1e9e512bd8debb3be254db3ff2365336feb151ec  
**Files reviewed:** `lib/services/app_config.dart`, `lib/services/ai_chat_service.dart`, `lib/services/llm_service.dart`  
**Verification evidence:** `flutter analyze` — 0 errors, 89 pre-existing info-level hints.

---

## Evidence Summary

### Requirement 1 — `autoFallback()` skips empty-key OpenRouter

`app_config.dart` line 427–430: within the `auto` branch, after incrementing `_consecutiveFailures`, the code calls `_autoActualModel('smart')` to get the concrete provider name. The condition `currentProvider == 'openrouter' || !hasOpenRouterKey` covers both "OpenRouter was chosen" and "key is empty regardless of what was chosen." When either is true, `_activeModelId` is set to `hasGemini ? 'gemini_flash_lite' : 'groq_llama4_scout'` — skipping OpenRouter entirely.

`hasOpenRouterKey` (line 283) is `(_remoteOpenRouterKey ?? _fallbackOpenRouterKey).isNotEmpty`, and `_fallbackOpenRouterKey` is `""` (line 44), so an absent Remote Config key correctly resolves to empty → false.

**Satisfied.**

### Requirement 2 — Firebase `minimumFetchInterval` reduced to 5 minutes on first/stale load

`app_config.dart` lines 594–615: before calling `setConfigSettings`, the code reads `rc_last_fetch_status` and `rc_last_fetch_ts` from DB. If `lastStatus == null` (first open) or `lastFetchTs` is absent (treated as stale) or the stored timestamp is more than 60 minutes ago, `fetchInterval` is set to 5 minutes; otherwise 1 hour. The result is used in `minimumFetchInterval`.

After a successful `fetchAndActivate()`, both `rc_last_fetch_status` and `rc_last_fetch_ts` are written (lines 631, 634). On `fetchAndActivate` failure, only `rc_last_fetch_status` is written (with the error string), and `rc_last_fetch_ts` is **not** updated. This is correct: an unchanged `rc_last_fetch_ts` means the stale check will still fire a short interval on the next launch, retrying the fetch. The error string `'FETCH_ERROR: ...'` is non-null, so `isFirstLoad` will be false on subsequent launches — the stale check covers this case because `rc_last_fetch_ts` will still be old (or absent).

**Satisfied.**

### Requirement 3 — Chat context preserved on fallback retry

`ai_chat_service.dart`: `_history` is a static list at class level, never cleared by `autoFallback()`. The recursive call `sendMessage(message, isFallbackRetry: true)` rebuilds the `messages` list from `_history` and unchanged prompt components inside the same `sendMessage` body. The lazy getters `_groqKey`, `_groqUrl`, and `AppConfig.groqModel` read from `AppConfig._activeModelId` on every call, so after `autoFallback()` updates `_activeModelId` from `auto`/`openrouter` to e.g. `gemini_flash_lite`, the retry's HTTP request correctly targets the new provider's endpoint, key, and model name.

**Satisfied.**

### Requirement 4 — OpenRouter headers in `ai_chat_service.dart`

`ai_chat_service.dart` lines 1290–1293: within the `http.post` headers map, a Dart collection-if adds `HTTP-Referer` and `X-Title` only when `AppConfig.activeModelId == 'openrouter'`. The condition uses the public getter `activeModelId` which returns `_activeModelId` directly — this correctly reflects the state *after* any `autoFallback()` switch.

**Satisfied.**

### Requirement 5 — Auto mode switches provider on first failure (not after 3 retries)

`app_config.dart` lines 413–435: when `_activeModelId == 'auto'`, the code increments `_consecutiveFailures` and then **immediately** determines the new provider (lines 427–435) on the first call (count = 1). It does not wait for `_consecutiveFailures >= 3` before switching — the `>= 3` branch handles a final escalation to `groq_llama4_scout` only when the auto-selected intermediate provider also fails three times. The first-failure-immediate-switch correctly prevents 3 × 35 s timeout cycles.

**Satisfied.**

### Requirement 6 — OpenRouter headers in `llm_service.dart`

`llm_service.dart` lines 35–38: same pattern as Fix 4 — `HTTP-Referer` and `X-Title` added inside the `_doRequest` closure's headers map, conditional on `AppConfig.activeModelId == 'openrouter'`. Because `_doRequest` is a closure that calls the lazy getters, it re-evaluates `AppConfig.activeModelId` on every invocation, including the fallback retry at line 68.

**Satisfied.**

---

## Potential Concerns Investigated and Dismissed

**`groqApiKey` returning Gemini key while auto mode is active then `_activeModelId` is switched:** After `autoFallback()` sets `_activeModelId` from `'auto'` to e.g. `'gemini_flash_lite'`, subsequent calls to `groqApiKey`/`groqBaseUrl`/`groqModel` switch to the `gemini_flash_lite` case, returning the Gemini key and endpoint. No residual `'auto'` routing occurs on the retry.

**`!hasOpenRouterKey` redundant with `currentProvider == 'openrouter'`:** When no key exists, `_autoActualModel()` already cannot return `'openrouter'` (the `hasOpenRouter` local var in that method is false). The `!hasOpenRouterKey` guard in the fallback branch is defensive and harmless — it covers a future case where `_autoActualModel` is modified. Not a bug.

**Missing `rc_last_fetch_ts` write on error:** Intentionally correct (see Req 2 analysis). The next launch will see a stale or absent timestamp and use the 5-minute interval again.

**No new behaviors introduced:** No other logic paths were changed. The `isFallbackRetry` guard prevents double-counting the daily limit on retries. The `!isFallbackRetry` guard on the timeout fallback path prevents infinite recursion.

---

## Verdict

**APPROVED** — All six requirements are satisfied. No correctness, security, or data failures introduced. Build verification (flutter analyze) passed with 0 errors.
