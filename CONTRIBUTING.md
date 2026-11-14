# Contributing to SmartSpend

Thank you for your interest in contributing to SmartSpend! 🎉

SmartSpend is an AI-powered personal finance tracker built for Filipinos. We welcome contributions from developers, designers, researchers, and users who want to help improve financial literacy in the Philippines.

---

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Pull Request Process](#pull-request-process)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)
- [Community](#community)

---

## 🤝 Code of Conduct

SmartSpend is a research project from Lorma Colleges, and we maintain a welcoming, inclusive environment. By participating, you agree to:

- Be respectful and constructive in all interactions
- Focus on what's best for the Filipino user community
- Accept feedback gracefully and provide feedback kindly
- Prioritize user privacy and data security in all contributions

---

## 🚀 Getting Started

**Current Version:** 3.2.0  
**Tech Stack:** Flutter (Dart), Firebase, SQLite, Google ML Kit  
**Target:** Android 7.0+ (API level 24+)

Before contributing:
1. ⭐ Star the repository
2. 🍴 Fork the repository
3. 📖 Read this guide completely
4. 🐛 Check existing issues or create a new one
5. 💬 Discuss your proposed changes (for major features)

---

## 💻 Development Setup

### Prerequisites

- **Flutter SDK:** 3.0.0 or higher
- **Dart SDK:** 2.17.0 or higher
- **Android Studio** or **VS Code** with Flutter extensions
- **Git**
- **Android device or emulator** (Android 7.0+)

### Installation Steps

```bash
# 1. Clone your fork
git clone https://github.com/YOUR_USERNAME/smartspend-app.git
cd smartspend-app

# 2. Install dependencies
flutter pub get

# 3. Set up configuration files
# Copy app_config.dart.example to app_config.dart and add your API keys
cp lib/services/app_config.dart.example lib/services/app_config.dart

# 4. Copy Firebase config (optional for local dev — app works without it)
# Add android/app/google-services.json if you have Firebase access

# 5. Run the app
flutter run
```

### Verify Installation

```bash
# Check Flutter setup
flutter doctor

# Run code analysis
flutter analyze

# Run tests
flutter test
```

**Expected:** Zero errors, info-level lints only.

---

## 🎯 How to Contribute

### Types of Contributions We Welcome

#### 🐛 Bug Reports
- Use the in-app feedback feature (shake device → Report Bug)
- Or create a GitHub issue with:
  - Clear description of the problem
  - Steps to reproduce
  - Expected vs actual behavior
  - Device info (model, Android version)
  - Screenshots if applicable

#### ✨ Feature Requests
- Check existing issues first to avoid duplicates
- Explain the problem you're solving
- Describe the proposed solution
- Consider Filipino user context

#### 💡 Code Contributions
- Bug fixes
- New features (discuss first for large changes)
- Performance improvements
- UI/UX enhancements
- Test coverage expansion

#### 📝 Documentation
- Improve README, guides, or code comments
- Add Filipino language translations
- Create tutorials or video guides
- Fix typos or outdated information

#### 🎨 Design
- UI mockups for new features
- Icon or asset improvements
- Peso mascot mood variations
- Marketing materials

---

## 📐 Coding Standards

### General Principles

1. **Filipino-First Design**
   - Consider Filipino financial context (GCash, jeepney fare, paluwagan, etc.)
   - Support Taglish in user-facing text
   - Respect Philippine data privacy laws (RA 10173)

2. **Privacy & Security**
   - Never log sensitive user data
   - Always use parameterized queries for database operations
   - Keep API keys in `.gitignore` files
   - Minimize data collection

3. **Code Quality**
   - Write clean, readable, self-documenting code
   - Follow Flutter/Dart style guide
   - Keep functions small and focused
   - Add comments for complex logic only

### Dart Style Guide

```dart
// ✅ Good: Clear naming, proper structure
class GovContributionsScreen extends StatefulWidget {
  final String userId;
  
  const GovContributionsScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<GovContributionsScreen> createState() => _GovContributionsScreenState();
}

// ❌ Bad: Unclear naming, no const
class Screen2 extends StatefulWidget {
  String id;
  
  Screen2({this.id});
}
```

### File Organization

```
lib/
├── models/          # Data models
├── screens/         # UI screens
├── services/        # Business logic, API calls, database
├── widgets/         # Reusable UI components
├── utils/           # Helper functions
└── main.dart        # App entry point
```

### Naming Conventions

- **Files:** `snake_case.dart` (e.g., `gov_contributions_screen.dart`)
- **Classes:** `PascalCase` (e.g., `GovContributionsScreen`)
- **Variables/Functions:** `camelCase` (e.g., `calculateYtdTotal`)
- **Constants:** `camelCase` (e.g., `kDefaultCurrency`)
- **Private members:** `_camelCase` (e.g., `_fetchData`)

---

## 🔀 Pull Request Process

### Before You Submit

1. **Create a feature branch**
   ```bash
   git checkout -b feature/government-contributions-export
   # or
   git checkout -b fix/scrolling-overflow-budgets
   ```

2. **Follow commit message conventions**
   ```
   feat: add CSV export for government contributions
   fix: resolve scrolling overflow in budgets screen
   docs: update README with v3.2.0 features
   chore: update dependencies to latest versions
   refactor: simplify FHS calculation logic
   test: add unit tests for SSS pension estimator
   ```

3. **Test thoroughly**
   ```bash
   flutter analyze       # Must pass with zero errors
   flutter test          # All tests must pass
   flutter run --release # Manual smoke test
   ```

4. **Update documentation**
   - Update README if feature is user-facing
   - Add inline code comments for complex logic
   - Update CHANGELOG.md

### Submitting the PR

1. **Push your branch**
   ```bash
   git push origin feature/government-contributions-export
   ```

2. **Create Pull Request on GitHub**
   - Use clear, descriptive title
   - Reference related issue(s): "Closes #42"
   - Fill out PR template (if provided)
   - Add screenshots for UI changes
   - Describe testing performed

3. **PR Template Example**
   ```markdown
   ## Description
   Added CSV export functionality for government contributions (SSS/PhilHealth/Pag-IBIG).

   ## Type of Change
   - [ ] Bug fix
   - [x] New feature
   - [ ] Breaking change
   - [ ] Documentation update

   ## Checklist
   - [x] Code follows project style guidelines
   - [x] Self-review completed
   - [x] Commented complex code sections
   - [x] Updated documentation
   - [x] No new warnings introduced
   - [x] Added tests (if applicable)
   - [x] All tests pass
   - [x] UI tested on multiple screen sizes

   ## Testing
   - Tested on Android 11 (Pixel 4a)
   - Tested on Android 13 (Samsung Galaxy S22)
   - Verified CSV format with Excel and Google Sheets
   - Tested with zero contributions (edge case)

   ## Screenshots
   [Add screenshots here]
   ```

### Review Process

- Maintainers will review within 3-7 days
- Expect feedback and requested changes
- Discuss disagreements constructively
- Be patient — this is an academic project with volunteer maintainers

---

## 🧪 Testing Guidelines

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/fhs_calculator_test.dart

# Run with coverage
flutter test --coverage
```

### Writing Tests

**Unit Tests** (for services, utilities, models)
```dart
// test/services/sss_calculator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:smartspend_app/services/sss_calculator.dart';

void main() {
  group('SSS Pension Estimator', () {
    test('calculates correct monthly pension for 20 years contributions', () {
      final calculator = SSSCalculator();
      final pension = calculator.estimatePension(
        yearsOfContribution: 20,
        averageMonthlySalaryCredit: 20000,
      );
      
      expect(pension, greaterThan(0));
      expect(pension, lessThan(25000));
    });
  });
}
```

**Widget Tests** (for UI components)
```dart
// test/widgets/peso_mascot_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smartspend_app/widgets/peso_mascot.dart';

void main() {
  testWidgets('Peso mascot renders with correct mood', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PesoMascot(mood: PesoMood.happy),
        ),
      ),
    );

    expect(find.byType(PesoMascot), findsOneWidget);
  });
}
```

### Manual Testing Checklist

Before submitting PR:
- [ ] Feature works on Android 7.0 (minimum supported)
- [ ] Feature works on Android 13+ (latest)
- [ ] UI looks correct on small screens (5")
- [ ] UI looks correct on large screens (6.5"+)
- [ ] Works offline (if applicable)
- [ ] No crashes or ANR (Application Not Responding)
- [ ] Peso mascot interactions are smooth
- [ ] No new `flutter analyze` warnings

---

## 📚 Documentation

### Code Documentation

**Good:**
```dart
/// Calculates the estimated SSS monthly pension based on years of contribution
/// and average monthly salary credit.
///
/// Returns the estimated monthly pension in PHP. Returns 0 if user has less
/// than 10 years of contributions (SSS minimum requirement).
///
/// Formula: Based on SSS pension calculation as of 2024.
/// See: https://www.sss.gov.ph/retirement/
double estimateSSSPension({
  required int yearsOfContribution,
  required double averageMonthlySalaryCredit,
}) {
  // Implementation
}
```

**Avoid:**
```dart
// calculates pension
double calc(int y, double s) {
  // ...
}
```

### User-Facing Documentation

- Keep README updated with new features
- Use Filipino context in examples
- Add screenshots for visual features
- Maintain CHANGELOG.md

---

## 🌐 Community

### Get Help

- **GitHub Issues:** [github.com/Zushikina-kun/smartspend-app/issues](https://github.com/Zushikina-kun/smartspend-app/issues)
- **Email:** brix@lucidframe.dev
- **In-App Feedback:** Shake device → "Ask Question"

### Stay Updated

- ⭐ Star the repo for updates
- 👀 Watch releases for new versions
- 📱 Follow on social media (links in README)

---

## 🎓 Academic Context

SmartSpend is a capstone research project from Lorma Colleges (AY 2026-2027). Contributions support:
- Financial literacy in the Philippines
- Open-source education
- Filipino-first software development

**Core Team:**
- Brix A. Directo (Lead Developer)
- Cyrille John M. Rubis (UI/UX & Documentation)
- Djaunathan Albert S. Madayag (PM & QA)

**Adviser:** Dr. Janelli M. Raposas

---

## 📜 License

SmartSpend uses a **Source Available License (Non-Commercial)**. See [LICENSE](LICENSE) for details.

By contributing, you agree that your contributions will be licensed under the same terms.

---

## 🙏 Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md (if we create one)
- Credited in release notes for significant contributions
- Thanked in app About screen for major features

---

## ❓ Questions?

Open an issue with the label `question` or email brix@lucidframe.dev.

**Thank you for helping make SmartSpend better for all Filipinos! 🇵🇭💚**

---

*Last Updated: November 15, 2024 (v3.2.0)*
