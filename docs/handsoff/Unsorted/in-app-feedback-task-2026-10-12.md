# In-App Feedback & Suggestions — Task Planning
**Date:** October 12, 2026
**Status:** To-Do — NO CODE YET
**Context:** Website now has a feedback form (prefills GitHub issues). The app needs its own in-app version so users can report bugs or suggest features without leaving the app.

---

## How the Website Version Works (reference)
The website feedback form:
1. User fills: type (Suggestion/Bug/Question/Other), title, details, optional email, consent checkbox
2. On submit: opens `https://github.com/Zushikina-kun/smartspend-app/issues/new?title=...&body=...&labels=...` in a new tab with all fields pre-filled
3. User sees the GitHub issue form pre-filled — just taps "Submit new issue"
4. No server, no token, no API key needed

The in-app version will use the same approach via `url_launcher` to open the pre-filled GitHub URL.

---

## In-App Implementation Plan

### File to CREATE: `lib/screens/feedback_screen.dart`

```dart
// feedback_screen.dart
// Allows users to submit bug reports, feature suggestions, or questions
// by opening a pre-filled GitHub issue in their browser.
// No server, no API key — uses GitHub's new-issue URL parameter system.
```

**UI Design:**
- Full screen with AppBar: "Send Feedback" + Peso mascot (winking, 32px) in title row
- Type selector chips (row): 💡 Suggestion · 🐛 Bug Report · ❓ Question · 💬 Other
- Text field: "Title / Topic" (required, max 120 chars)
- Text area: "Details" (required, max 2000 chars, char counter in bottom-right)
- Text field: "Your email" (optional, helper text: "Only if you want a reply — not shared publicly")
- Checkbox: "I understand this may be posted as a public GitHub issue"
- Submit button (FilledButton, full-width): "Send to Team →"
- Small text below button: "Or browse existing issues →" (launches issues list URL)

**Submit behavior:**
```dart
final title = '[${typeLabel}] ${_titleCtrl.text.trim()}';
final body = [
  if (email.isNotEmpty) 'Submitted by: $email\n',
  '**Type:** $_selectedType\n',
  '**App version:** ${AppConfig.version}\n',
  '**Android:** ${await _getAndroidVersion()}\n\n',
  '**Details:**\n${_detailsCtrl.text.trim()}\n\n',
  '---\n*Submitted via SmartSpend in-app feedback*',
].join();
final url = Uri.parse(
  'https://github.com/Zushikina-kun/smartspend-app/issues/new'
  '?title=${Uri.encodeComponent(title)}'
  '&body=${Uri.encodeComponent(body)}'
  '&labels=${Uri.encodeComponent(_selectedType)}'
);
await launchUrl(url, mode: LaunchMode.externalApplication);
```

**After submit:**
- Show `PesoMascot.withSpeech(mood: PesoMood.celebrating, text: "Salamat! 🙏\nWe'll review your feedback!")`
- "Done" button to pop back

**Dependency:** `url_launcher` — already in pubspec.yaml (check before adding)

---

### Where to Surface In-App Feedback

**1. Profile screen → "Send Feedback" tile** (highest priority)
Find the Profile screen's list of options. Add between "Export Data" and "About":
```dart
ListTile(
  leading: const Icon(Icons.feedback_outlined),
  title: const Text('Send Feedback'),
  subtitle: const Text('Bug reports · Feature ideas · Suggestions'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FeedbackScreen())),
)
```

**2. Settings screen → Help & Feedback section**
Add a "Send Feedback" tile under the existing Help/About section.

**3. AI screen overflow menu (⋮)**
The AI screen has a 3-dot overflow menu. Add "Send Feedback" as the last item.

**4. About screen**
The `about_screen.dart` — add a prominent "Send Feedback" button alongside the support links.

**5. Quick Access Hub**
Add to the `_QuickAccessHub` under "Help & Support" group (or create that group if missing).

---

### In-App Feedback Entry Points Map

```
Profile screen       → "Send Feedback" list tile
Settings screen      → Help section tile  
AI screen (⋮ menu)  → Last overflow item
About screen         → Button alongside support links
Quick Access Hub     → New "Help & Support" group
```

---

## Additional: In-App Bug Report Auto-Fill

For crash-adjacent situations (not full crash reports — just in-app error states), auto-fill some context:

When Peso shows `sad` due to an error in AI chat, show a "Report this issue?" SnackBar action:
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('Something went wrong'),
    action: SnackBarAction(
      label: 'Report',
      onPressed: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => FeedbackScreen(
          prefillType: 'bug',
          prefillTitle: 'AI chat error',
          prefillDetails: 'Error occurred in AI chat.\nProvider: ${AppConfig.currentModel}\nTimestamp: ${DateTime.now()}',
        ))),
    ),
  ),
);
```

This requires `FeedbackScreen` to accept optional `prefillType`, `prefillTitle`, `prefillDetails` parameters.

---

## Implementation Checklist

- [ ] Check if `url_launcher` is already in `pubspec.yaml` (it likely is — used by other screens)
- [ ] Create `lib/screens/feedback_screen.dart`
- [ ] Add to `profile_screen.dart`
- [ ] Add to `settings_screen.dart`  
- [ ] Add to `ai_screen.dart` overflow menu
- [ ] Add to `about_screen.dart`
- [ ] Add to `home_screen.dart` Quick Access Hub
- [ ] Test pre-filled GitHub URL opens correctly on Android
- [ ] Add `PesoMood.winking` to `peso_mascot.dart` (needed for FeedbackScreen header)

**Estimate:** ~3h total once `PesoMood.winking` is built

---

*Added by Kiro — October 12, 2026*
