# Month 1 Implementation Plan - SmartSpend v3.4.0
**Created:** November 21, 2026  
**Base Version:** v3.3.9+126  
**Target Version:** v3.4.0  
**Total Features:** 15  
**Estimated Effort:** 120 hours

---

## Overview

This plan implements all 15 Month 1 high-priority features from the post-defense roadmap. Features are ordered by dependency and complexity, with independent features grouped for parallel implementation when possible.

**Feature Execution:** Strictly sequential - one FEAT at a time. Each FEAT builds, tests, and commits locally before proceeding to the next. The convergence loop at the end handles cross-FEAT integration testing and fixes.

**Verification:** Every feature must pass `flutter analyze` (zero errors/warnings) and `flutter build apk --debug` (successful compilation). Manual testing scenarios are documented in each FEAT file.

---

## Feature Implementation Order

### FEAT-001: Cash Flow Forecasting (24-40 hours)
**Files:**
- Create: `lib/services/forecast_service.dart` (forecast logic, confidence calculation)
- Create: `lib/screens/forecast_screen.dart` (30-day chart UI)
- Modify: `lib/services/db_service.dart` (add getUpcomingObligations method)
- Modify: `lib/screens/home_screen.dart` (add drawer navigation link)

**What:** 30-day balance projection based on recurring transactions and historical spending patterns. Shows line chart with confidence level (High/Medium/Low) and warnings when balance goes negative.

**Why First:** Foundation for OFW and tax features. Requires only existing database tables (expenses, recurring). No dependencies on other Month 1 features.

**Verify:**
```powershell
flutter analyze
flutter build apk --debug
# Manual test: Add 60 days of expenses + 3 recurring bills → forecast shows 30-day projection with dips on bill dates
```

---

### FEAT-002: Price Intelligence Phase 1 (20 hours)
**Files:**
- Create: `lib/models/price_data.dart` (price record model)
- Create: `lib/services/price_intelligence_service.dart` (price comparison, alerts)
- Modify: `lib/services/db_service.dart` (add prices table in _createTables and _ensureColumns)
- Modify: `lib/services/ocr_service.dart` (extract line items from receipts)
- Modify: `lib/screens/edit_expense_screen.dart` or detail view (add price comparison button)
- Modify: `lib/screens/home_screen.dart` (add price alert card)

**What:** Extract prices from receipts via OCR, store in database, compare prices across stores, and alert users when they buy products at higher prices than known alternatives.

**Why Second:** Independent of other features. Leverages existing OCR infrastructure. Foundation for future price hike detection phases.

**Verify:**
```powershell
flutter analyze
flutter build apk --debug
# Manual test: Scan 2 receipts with same product at different prices → price comparison shows both, alert appears on home screen
```

---

### FEAT-003: eGov Phase 1 - SSS Integration (12 hours)
**Files:**
- Create: `lib/services/egov/sss_service.dart` (contribution & loan calculators)
- Create: `lib/screens/egov/sss_screen.dart` (3-tab UI: calculator, loans, history)
- Modify: `lib/screens/home_screen.dart` (add Government section in drawer)

**What:** SSS contribution calculator (2026 rates), 3 loan calculators (salary, calamity, emergency), and mock 12-month contribution history.

**Why Third:** Independent feature, no dependencies. Part of eGov trio (SSS/PhilHealth/Pag-IBIG) that can be implemented in any order.

**Verify:**
```powershell
flutter analyze
flutter build apk --debug
# Manual test: ₱20k salary → ₱1,900 employee + ₱4,033 employer = ₱5,933 total (verify against SSS 2026 table)
```

---

### FEAT-004: eGov Phase 1 - PhilHealth Integration (10 hours)
**Files:**
- Create: `lib/services/egov/philhealth_service.dart` (premium calculator, coverage mock)
- Modify: `lib/screens/gov_contributions_screen.dart` (add PhilHealth tab)

**What:** PhilHealth premium calculator (5% of salary, max ₱5k), mock coverage verification showing active status and benefits.

**Why Fourth:** Independent, no dependencies on FEAT-003. Integrates with existing gov_contributions_screen from v3.2.0.

**Verify:**
```powershell
flutter analyze
flutter build apk --debug
# Manual test: ₱30k employed → ₱1,500 total (₱750 employee + ₱750 employer), ₱150k → capped at ₱5k
```

---

### FEAT-005: eGov Phase 1 - Pag-IBIG Integration (10 hours)
**Files:**
- Create: `lib/services/egov/pagibig_service.dart` (contribution, housing loan, MP2 calculators)
- Create: `lib/screens/egov/pagibig_screen.dart` (3-tab UI)
- Modify: `lib/screens/home_screen.dart` (add Pag-IBIG to Government section)

**What:** Pag-IBIG contribution calculator (2% employee + 2% employer), housing loan calculator (6.5% interest, 5-30 years), MP2 savings projections with year-by-year breakdown and chart.

**Why Fifth:** Completes eGov trio. Independent of FEAT-003/004. Slightly more complex due to MP2 chart visualization.

**Verify:**
```powershell
flutter analyze
flutter build apk --debug
# Manual test: ₱25k salary → ₱1k total, ₱2M loan 20yr → ₱14,990/month, ₱5k MP2 10yr 7% → ₱865k final
```

---

### FEAT-006: Bill Payment Reminders (8 hours)
**Files:**
- Modify: `lib/services/notification_service.dart` (add scheduleBillReminder, checkAndScheduleBillReminders)
- Modify: `lib/screens/settings_screen.dart` (add Bill Reminders toggle)
- Modify: `lib/screens/home_screen.dart` (call checkAndScheduleBillReminders in initState)
- Modify: `lib/screens/recurring_screen.dart` (call check after bill add/update)

**What:** Push notifications for bills due in 3 days, 1 day, and on due date, with 'Mark as Paid' quick action that creates expense and advances next due date.

**Why Sixth:** Enhances existing recurring bills feature. No new tables needed. Uses existing notification infrastructure.

**Verify:**
```powershell
flutter analyze
flutter build apk --debug
# Manual test: Add bill due in 2 days → notifications scheduled at correct times, Mark as Paid creates expense and advances date
```

---

### FEAT-007: OFW Features - Remittance Tracking (8 hours)
**Files:**
- Create: `lib/models/remittance.dart` (remittance model)
- Create: `lib/screens/ofw/remittance_screen.dart` (remittance list, form, YTD summary)
- Modify: `lib/services/db_service.dart` (add remittances table, CRUD methods)
- Modify: `lib/services/currency_service.dart` (add getExchangeRate method with API + fallback)
- Modify: `lib/screens/home_screen.dart` (add OFW Features section in drawer)

**What:** Track sent/received remittances with multi-currency (USD, SAR, AED, SGD, HKD), exchange rate fetching, YTD summaries, and CSV export for tax filing.

**Why Seventh:** Independent feature targeting OFW market (10M+ users). No dependencies on other features.

**Verify:**
```powershell
flutter analyze
flutter build apk --debug
# Manual test: Add $500 remittance → fetch rate at 57 PHP/USD = ₱28,500, YTD summary updates, CSV export works
```

---

### FEAT-008: OFW Features - Balikbayan Box Tracker (8 hours)
**Files:**
- Create: `lib/models/balikbayan_box.dart` (box model)
- Create: `lib/screens/ofw/balikbayan_tracker_screen.dart` (box list, detail, contents management)
- Modify: `lib/services/db_service.dart` (add balikbayan_boxes and box_contents tables, CRUD methods)
- Modify: `lib/screens/home_screen.dart` (add to OFW Features section)

**What:** Track balikbayan boxes with tracking number, recipient, contents list (items with quantities/values), shipping company, status timeline, and delivery tracking.

**Why Eighth:** Complements FEAT-007. Independent feature, no dependencies. Culturally relevant for OFW market.

**Verify:**
```powershell
flutter analyze
flutter build apk --debug
# Manual test: Add box with 5 items → total value calculates, mark as delivered updates status, delete box cascades to contents
```

---

### FEAT-009: Budget Categories - Auto-categorization (6 hours)
**Files:**
- Modify: `lib/services/app_config.dart` or create `lib/services/ai_categorization_service.dart` (suggestCategory method)
- Modify: `lib/screens/add_expense_screen.dart` (auto-suggest on description blur)
- Modify: `lib/screens/batch_image_import_screen.dart` (auto-categorize batch imports)
- Modify: `lib/screens/ai_screen.dart` (auto-categorize AI imports)
- Modify: `lib/services/db_service.dart` (add category_corrections table for learning)
- Modify: `lib/screens/settings_screen.dart` (add Auto-Categorize toggle)

**What:** AI suggests categories based on description keywords and LLM when ambiguous. Auto-applies to manual entry and batch imports. Logs corrections for future learning.

**Why Ninth:** Enhances existing add expense flow. Depends on LLM infrastructure (already exists). Reduces manual work across all input methods.

**Verify:**
```powershell
flutter analyze
flutter build apk --debug
# Manual test: Type 'lunch at mcdo' → Food auto-suggested, 'grab ride' → Transportation, override Food to Entertainment → correction logged
```

---

### FEAT-010: Receipt Gallery - Search & Filter (4 hours)
**Files:**
- Create: `lib/screens/receipt_gallery_screen.dart` (grid view, search bar, filters)
- Modify: `lib/services/db_service.dart` (add getExpensesWithReceipts with filter params)
- Modify: `lib/screens/home_screen.dart` (add Receipt Gallery to Tools section)

**What:** GridView of all expenses with receipt photos, search by text/store/category, filters by date range/amount range, sort options, full-screen detail view.

**Why Tenth:** Independent feature leveraging existing photo_path field. Simple UI enhancement, no complex logic.

**Verify:**
```powershell
flutter analyze
flutter build apk --debug
# Manual test: Gallery shows 15 receipts, search 'grocery' filters correctly, date range Jan 1-31 works, sort by amount reorders
```

---

### FEAT-011: Debt Payoff Calculator (4 hours)
**Files:**
- Create: `lib/services/debt_calculator.dart` (Avalanche & Snowball methods)
- Create: `lib/screens/debt_payoff_screen.dart` (comparison UI, month-by-month projection)
- Modify: `lib/services/db_service.dart` (ALTER TABLE debts ADD COLUMN interest_rate)
- Modify: `lib/screens/debt_screen.dart` (add interest_rate to form, link to payoff screen)
- Modify: `lib/screens/home_screen.dart` (add to Tools section)

**What:** Calculate debt payoff using Avalanche (high interest first) vs Snowball (small balance first) with month-by-month projections, total interest comparison, and chart visualization.

**Why Eleventh:** Enhances existing debts feature. Requires adding interest_rate column (simple migration).

**Verify:**
```powershell
flutter analyze
flutter build apk --debug
# Manual test: 3 debts (₱10k 18%, ₱5k 12%, ₱8k 15%), ₱3k/month → Avalanche 9mo ₱2,100 interest vs Snowball 10mo ₱2,300 interest
```

---

### FEAT-012: Goal Progress Visualization (4 hours)
**Files:**
- Modify: `lib/screens/savings_goals_screen.dart` (enhance progress bars to circular with milestones)
- Modify: `lib/services/db_service.dart` (add goal_history table)

**What:** Enhanced goal cards with circular progress indicators, color-coding, milestone markers (25%/50%/75%), insights (daily savings needed, projected completion), contribution history timeline, and Peso celebration on completion.

**Why Twelfth:** Enhances existing savings goals feature. Simple UI improvements, adds history tracking.

**Verify:**
```powershell
flutter analyze
flutter build apk --debug
# Manual test: Goal 60% → yellow circle, add ₱5k → history entry created, reach 100% → Peso celebration plays
```

---

### FEAT-013: Insights Dashboard - Spending Trends (6 hours)
**Files:**
- Create: `lib/screens/insights_screen.dart` (month-over-month trends, AI insights)
- Modify: `lib/services/insight_service.dart` (add getCurrentMonthVsPreviousMonth)
- Modify: `lib/screens/home_screen.dart` (add Insights navigation link)

**What:** Month-over-month spending comparison by category showing percentage changes, AI-generated explanations for trends, week-over-week bar chart, and top 3 insights summary.

**Why Thirteenth:** Builds on existing insight_service. Leverages LLM for explanations. Adds analytics depth.

**Verify:**
```powershell
flutter analyze
flutter build apk --debug
# Manual test: Food ₱8.5k vs ₱6.5k prev month → shows +30.8% with AI insight explaining increase, week chart shows 4 bars
```

---

### FEAT-014: Export to Excel/CSV (4 hours)
**Files:**
- Modify: `lib/services/export_service.dart` (add exportAllTransactionsCSV, exportCategorizedReportCSV, exportMonthlyBreakdownCSV)
- Modify: `lib/screens/settings_screen.dart` or create export screen (export UI)
- Modify: `lib/services/db_service.dart` (add exports_log table)

**What:** Export all transactions, categorized reports, and monthly breakdowns to CSV. Export history tracking, share functionality, and formatting options for Excel compatibility.

**Why Fourteenth:** Enhances existing export_service. Independent feature providing data portability.

**Verify:**
```powershell
flutter analyze
flutter build apk --debug
# Manual test: Export 127 expenses Q1 → CSV opens in Excel correctly, categorized report sums to ₱45,632, share via email works
```

---

### FEAT-015: Backup & Restore (6 hours)
**Files:**
- Modify: `lib/services/backup_service.dart` (add createFullBackup, restoreFromBackup with verification)
- Create: `lib/screens/backup_screen.dart` or enhance existing (backup UI, history, auto-backup settings)
- Modify: `lib/screens/settings_screen.dart` (add Backup & Restore link)

**What:** Export complete database to JSON with SHA256 verification, restore from backup with validation, auto-backup scheduling (daily/weekly), backup history management, and safety features (pre-restore backup, version compatibility checks).

**Why Last:** Enhances existing backup_service. Critical safety feature but independent of others. Should be tested thoroughly as it affects all data.

**Verify:**
```powershell
flutter analyze
flutter build apk --debug
# Manual test: Create backup → 500KB JSON, delete all data, restore → all 200 expenses restored, corrupted JSON rejected, auto-backup creates daily backups
```

---

## Digest: Files Modified/Created Summary

### New Services (9 files)
- `lib/services/forecast_service.dart` — Cash flow forecasting logic
- `lib/services/price_intelligence_service.dart` — Price comparison and alerts
- `lib/services/egov/sss_service.dart` — SSS calculators
- `lib/services/egov/philhealth_service.dart` — PhilHealth calculators
- `lib/services/egov/pagibig_service.dart` — Pag-IBIG calculators
- `lib/services/ai_categorization_service.dart` — Auto-categorization logic
- `lib/services/debt_calculator.dart` — Avalanche/Snowball methods

### New Screens (9 files)
- `lib/screens/forecast_screen.dart` — 30-day forecast chart
- `lib/screens/egov/sss_screen.dart` — SSS 3-tab interface
- `lib/screens/egov/pagibig_screen.dart` — Pag-IBIG 3-tab interface
- `lib/screens/ofw/remittance_screen.dart` — Remittance tracking
- `lib/screens/ofw/balikbayan_tracker_screen.dart` — Box tracking
- `lib/screens/receipt_gallery_screen.dart` — Receipt photo gallery
- `lib/screens/debt_payoff_screen.dart` — Debt payoff calculator
- `lib/screens/insights_screen.dart` — Spending trends analysis
- `lib/screens/backup_screen.dart` — Backup management UI

### New Models (3 files)
- `lib/models/price_data.dart`
- `lib/models/remittance.dart`
- `lib/models/balikbayan_box.dart`

### Modified Services (6 files)
- `lib/services/db_service.dart` — Add 8 new tables, enhance queries
- `lib/services/notification_service.dart` — Bill reminders
- `lib/services/currency_service.dart` — Exchange rate fetching
- `lib/services/ocr_service.dart` — Line item extraction
- `lib/services/insight_service.dart` — Month-over-month comparison
- `lib/services/export_service.dart` — CSV export methods
- `lib/services/backup_service.dart` — Full backup/restore

### Modified Screens (8 files)
- `lib/screens/home_screen.dart` — Navigation links for all features
- `lib/screens/settings_screen.dart` — Preference toggles
- `lib/screens/add_expense_screen.dart` — Auto-categorization
- `lib/screens/edit_expense_screen.dart` — Price comparison button
- `lib/screens/gov_contributions_screen.dart` — PhilHealth integration
- `lib/screens/debt_screen.dart` — Interest rate field, payoff link
- `lib/screens/savings_goals_screen.dart` — Enhanced progress visualization
- `lib/screens/recurring_screen.dart` — Bill reminder trigger

### Database Changes (8 new tables)
1. `prices` — Product prices from receipts
2. `remittances` — OFW remittance tracking
3. `balikbayan_boxes` — Box tracking
4. `box_contents` — Box item details
5. `category_corrections` — Auto-categorization learning
6. `goal_history` — Goal contribution timeline
7. `exports_log` — Export history
8. Column additions: `debts.interest_rate`

### Build & Test Commands
**Verification for every FEAT:**
```powershell
flutter analyze                      # Must return 0 errors/warnings
flutter build apk --debug            # Must compile successfully
# Manual testing per FEAT acceptance criteria
```

**Final Integration Test (after all FEATs):**
```powershell
flutter clean
flutter pub get
flutter analyze
flutter build apk --release --split-per-abi --shrink
# Full regression testing: Week 1 features still work, all Month 1 features integrated correctly
```

---

## Notes

- **Commit Strategy:** Each FEAT commits locally after successful verification. No pushes until convergence loop approval.
- **Database Migrations:** All table additions use `_ensureColumns()` pattern with ALTER TABLE IF NOT EXISTS for backward compatibility.
- **API Keys:** Exchange rate API uses free tier (1500 requests/month). Cache rates for 24 hours to stay under limit.
- **Offline-First:** All features work offline except exchange rate fetching (has fallback hardcoded rates).
- **Firebase:** No new Firebase dependencies. Uses existing Remote Config for AI keys.
- **Testing:** No automated tests exist currently. All verification is manual with documented test scenarios.

---

## Success Criteria

- ✅ All 15 FEATs implemented and committed locally
- ✅ Zero errors/warnings from `flutter analyze`
- ✅ Successful `flutter build apk --release` compilation
- ✅ All manual test scenarios pass
- ✅ Week 1 features (Safe-to-Spend, UI fixes) still work after Month 1 integration
- ✅ No crashes on Android emulator or physical device
- ✅ App size remains under 55MB (arm64 split APK)

---

**End of Implementation Plan**
