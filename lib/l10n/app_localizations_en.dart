// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'SmartSpend';

  @override
  String get navHome => 'Home';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navAI => 'Peso';

  @override
  String get navTools => 'Tools';

  @override
  String get navProfile => 'Profile';

  @override
  String get settings => 'Settings';

  @override
  String get appSettings => 'App Settings';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get expenses => 'Expenses';

  @override
  String get safeToSpend => 'Safe to Spend';

  @override
  String get financialHealthScore => 'Financial Health Score';

  @override
  String get savingsGoals => 'Savings Goals';

  @override
  String get aiAssistant => 'AI Assistant';

  @override
  String get more => 'More';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get saveAgain => 'Save again';

  @override
  String get close => 'Close';

  @override
  String get confirm => 'Confirm';

  @override
  String get delete => 'Delete';

  @override
  String get edit => 'Edit';

  @override
  String get done => 'Done';

  @override
  String get gotIt => 'Got it';

  @override
  String get iUnderstand => 'I understand';

  @override
  String get loading => 'Loading…';

  @override
  String get language => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageFilipino => 'Filipino (Tagalog)';

  @override
  String get sectionBehavior => 'BEHAVIOR';

  @override
  String get sectionDisplay => 'DISPLAY';

  @override
  String get sectionAppearance => 'APPEARANCE';

  @override
  String get sectionSecurity => 'SECURITY';

  @override
  String get sectionTrackingMode => 'TRACKING MODE';

  @override
  String get sectionNotifications => 'NOTIFICATIONS';

  @override
  String get sectionAiModel => 'AI MODEL';

  @override
  String get sectionLocalAi => 'LOCAL AI (PRIVATE MODE)';

  @override
  String get sectionHomeScreenSections => 'HOME SCREEN — SHOW / HIDE SECTIONS';

  @override
  String get sectionAnalyticsSections => 'ANALYTICS — SHOW / HIDE SECTIONS';

  @override
  String get sectionExportData => 'EXPORT DATA';

  @override
  String get sectionBackupRestore => 'BACKUP & RESTORE';

  @override
  String get sectionFeedback => 'FEEDBACK';

  @override
  String get sectionAppInfo => 'APP INFO';

  @override
  String get sectionQuickPresets => 'QUICK PRESETS';

  @override
  String get sectionLanguage => 'LANGUAGE';

  @override
  String get autoDeductWallets => 'Auto-deduct wallets';

  @override
  String get autoDeductWalletsSubtitle =>
      'Deduct from Cash/GCash/Maya when logging expenses';

  @override
  String get confirmBeforeDeducting => 'Confirm before deducting';

  @override
  String get confirmBeforeDeductingSubtitle =>
      'Ask \"Deduct from wallet?\" before each expense — off by default for speed';

  @override
  String get impulsePause => 'Impulse pause';

  @override
  String get impulsePauseSubtitle =>
      'Confirm before logging large Want expenses';

  @override
  String get budgetAlerts => 'Budget alerts';

  @override
  String get budgetAlertsSubtitle => 'Notify when a category hits 80% or 100%';

  @override
  String get spendingLimits => 'Spending limits';

  @override
  String get spendingLimitsSubtitle =>
      'Set daily, weekly, monthly, or yearly caps';

  @override
  String get balanceMode => 'Balance mode';

  @override
  String get balanceModeSubtitle =>
      'Show total wallet balance instead of income-based remaining';

  @override
  String get roundUpSavings => 'Round-up savings';

  @override
  String get roundUpSavingsSubtitle =>
      'Auto-save spare change to your first goal (rounds to ₱10)';

  @override
  String get darkMode => 'Dark mode';

  @override
  String get darkModeSubtitle => 'Switch between light and dark theme';

  @override
  String get compactMode => 'Compact mode';

  @override
  String get compactModeSubtitle => 'Reduce spacing and list density';

  @override
  String get highContrast => 'High contrast';

  @override
  String get highContrastSubtitle =>
      'Pure black/white theme for maximum readability';

  @override
  String get appTheme => 'App theme';

  @override
  String get textSize => 'Text size';

  @override
  String get displayCurrency => 'Display currency';

  @override
  String get displayCurrencySubtitle =>
      'Tap to change — all amounts stored in PHP';

  @override
  String get trackIncomeWallets => 'Track income & wallets';

  @override
  String get anomalyAlerts => 'Spending anomaly alerts';

  @override
  String get anomalyAlertsSubtitle =>
      'Weekly alert when a category spikes 2.5× above usual';

  @override
  String get smartSuggestions => 'Smart suggestions';

  @override
  String get smartSuggestionsSubtitle =>
      'Daily nudges: upcoming bills, pace alerts, goal milestones, shortfall risk';

  @override
  String get billReminders => 'Bill reminders';

  @override
  String get billRemindersSubtitle =>
      'Get notified 3 days before, 1 day before, and on due date for upcoming bills';

  @override
  String get sendFeedback => 'Send Feedback';

  @override
  String get sendFeedbackSubtitle => 'Report a bug or suggest a feature';

  @override
  String get exportTransactionsCSV => 'Export Transactions (CSV)';

  @override
  String get exportSummaryCSV => 'Export Summary (CSV)';

  @override
  String get createBackup => 'Create Backup';

  @override
  String get restoreFromBackup => 'Restore from Backup';

  @override
  String get appVersion => 'App version';

  @override
  String get headsUp => 'Heads Up!';

  @override
  String get offlineBanner =>
      '📴 Offline — core features work. Peso AI needs internet.';

  @override
  String get tellPesoHint => 'Tell Peso what you spent today…';

  @override
  String get noInternetPeso => 'No internet — Peso unavailable';

  @override
  String get analyzeButton => 'Analyze';

  @override
  String get retryButton => 'Retry';

  @override
  String get saveExpense => 'Save Expense';

  @override
  String get amount => 'Amount';

  @override
  String get itemName => 'Item name';

  @override
  String get shopName => 'Shop / Merchant';

  @override
  String get notes => 'Notes';

  @override
  String get category => 'Category';

  @override
  String get paymentMethod => 'Payment method';

  @override
  String get date => 'Date';

  @override
  String get wantNeed => 'Want / Need';

  @override
  String get wantLabel => 'Want';

  @override
  String get needLabel => 'Need';

  @override
  String get describeExpense => 'Describe your expense…';

  @override
  String get aiAnalyzing => 'AI is analyzing…';

  @override
  String get retrying => 'Retrying…';

  @override
  String get pleaseDescribeFirst => 'Please describe your expense first.';

  @override
  String get pleaseEnterValidAmount => 'Please enter a valid amount.';

  @override
  String get pleaseEnterItemName => 'Please enter an item name.';

  @override
  String get alreadyLoggedToday => 'Already logged today?';

  @override
  String get wasThisPlanned => 'Was this planned? 🤔';

  @override
  String get waitLetMeReconsider => 'Wait, let me reconsider';

  @override
  String get yesSaveIt => 'Yes, save it';

  @override
  String get deductFromWallet => 'Deduct from wallet?';

  @override
  String get pastedReview =>
      'Pasted! Review the fields below and tap Analyze or Save.';

  @override
  String get clipboardEmpty => 'Clipboard is empty.';

  @override
  String get aiScreenTitle => 'Peso AI';

  @override
  String get typeAMessage => 'Type a message…';

  @override
  String get fullChat => 'Full Chat';

  @override
  String get financialAdviceNotice => 'Financial Advice Notice';

  @override
  String get languageCebuano => 'Cebuano (Bisaya)';

  @override
  String get analyticsScreenTitle => 'Analytics';

  @override
  String get budgetsScreenTitle => 'Budgets';

  @override
  String get savingsGoalsScreenTitle => 'Savings Goals';

  @override
  String get recurringScreenTitle => 'Recurring Transactions';

  @override
  String get debtScreenTitle => 'Debts';

  @override
  String get incomeScreenTitle => 'Income';

  @override
  String get profileScreenTitle => 'Profile';

  @override
  String get transactionsScreenTitle => 'Transactions';

  @override
  String get addBudget => 'Add Budget';

  @override
  String get newGoal => 'New Goal';

  @override
  String get addRecurring => 'Add Recurring';

  @override
  String get addDebt => 'Add Debt';

  @override
  String get addIncome => 'Add Income';

  @override
  String get noExpensesYet => 'No expenses yet';

  @override
  String get noBudgetsYet => 'No budgets set yet';

  @override
  String get noGoalsYet => 'No savings goals yet';

  @override
  String get noRecurringYet => 'No recurring transactions yet';

  @override
  String get noDebtsYet => 'No debts yet';

  @override
  String get noIncomeYet => 'No income records yet';

  @override
  String get deleteExpense => 'Delete Expense';

  @override
  String get deleteGoal => 'Delete Goal';

  @override
  String get deleteDebt => 'Delete Debt';

  @override
  String get deleteIncome => 'Delete Income';

  @override
  String get deleteRecurring => 'Delete Recurring';

  @override
  String get recordPayment => 'Record Payment';

  @override
  String get logAllDue => 'Log All Due';

  @override
  String get logNow => 'Log Now';

  @override
  String get createGoal => 'Create Goal';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get emergencyFund => 'Emergency Fund';

  @override
  String get overBudgetWarning => 'Over Budget Warning';

  @override
  String get confirmAndLog => 'Confirm & Log';

  @override
  String get refresh => 'Refresh';

  @override
  String get getAiAdvice => 'Get AI Financial Advice';

  @override
  String get thisMonth => 'This Month';

  @override
  String get allTime => 'All Time';

  @override
  String get entries => 'Entries';

  @override
  String get total => 'Total';

  @override
  String get income => 'Income';

  @override
  String get balance => 'Balance';

  @override
  String get spent => 'Spent';

  @override
  String get budgeted => 'Budgeted';

  @override
  String get add => 'Add';

  @override
  String get pay => 'Pay';

  @override
  String get resetAllData => 'Reset All Data';

  @override
  String get about => 'About';

  @override
  String get achievements => 'Achievements';

  @override
  String get help => 'Help';

  @override
  String get transactions => 'Transactions';

  @override
  String get chatHistoryScreenTitle => 'Chat History';

  @override
  String get feedbackScreenTitle => 'Send Feedback';

  @override
  String get forecastScreenTitle => 'Cash Flow Forecast';

  @override
  String get govContributionsScreenTitle => 'Gov Contributions';

  @override
  String get heatmapScreenTitle => 'Spending Heatmap';

  @override
  String get insightsScreenTitle => 'Spending Insights';

  @override
  String get investmentScreenTitle => 'Investment Portfolio';

  @override
  String get netWorthScreenTitle => 'Net Worth';

  @override
  String get taxScreenTitle => 'BIR Tax Calculator';

  @override
  String get challengesScreenTitle => 'Challenges & Streaks';

  @override
  String get debtCalculatorScreenTitle => 'Debt Payoff Calculator';

  @override
  String get priceIntelligenceScreenTitle => 'Price Intelligence';

  @override
  String get insuranceScreenTitle => 'Insurance & Contributions';

  @override
  String get palawaganScreenTitle => 'Paluwagan Tracker';

  @override
  String get pcaCalculatorScreenTitle => 'Peso Cost Averaging';

  @override
  String get merchantMergeScreenTitle => 'Merchant Cleanup';

  @override
  String get bankComparisonScreenTitle => 'PH Banks & Investments';

  @override
  String get currencyScreenTitle => 'Currency & Region';

  @override
  String get glossaryScreenTitle => 'Financial Glossary';

  @override
  String get logDueBillsScreenTitle => 'Log Due Bills';

  @override
  String get manageCategoriesScreenTitle => 'Manage Categories';

  @override
  String get manageRulesScreenTitle => 'Manage Rules';
}
