import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ceb.dart';
import 'app_localizations_en.dart';
import 'app_localizations_tl.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ceb'),
    Locale('en'),
    Locale('tl')
  ];

  /// Application name
  ///
  /// In en, this message translates to:
  /// **'SmartSpend'**
  String get appTitle;

  /// Bottom nav: Home tab
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom nav: Analytics tab
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// Bottom nav: AI/Peso tab
  ///
  /// In en, this message translates to:
  /// **'Peso'**
  String get navAI;

  /// Bottom nav: Tools tab
  ///
  /// In en, this message translates to:
  /// **'Tools'**
  String get navTools;

  /// Bottom nav: Profile tab
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get navProfile;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// App settings appbar title
  ///
  /// In en, this message translates to:
  /// **'App Settings'**
  String get appSettings;

  /// Add expense button/title
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// Expenses label
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// Safe to Spend card title
  ///
  /// In en, this message translates to:
  /// **'Safe to Spend'**
  String get safeToSpend;

  /// Financial Health Score card title
  ///
  /// In en, this message translates to:
  /// **'Financial Health Score'**
  String get financialHealthScore;

  /// Savings Goals label
  ///
  /// In en, this message translates to:
  /// **'Savings Goals'**
  String get savingsGoals;

  /// AI assistant label
  ///
  /// In en, this message translates to:
  /// **'AI Assistant'**
  String get aiAssistant;

  /// More label
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get more;

  /// Cancel button
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save button
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Save again button in duplicate dialog
  ///
  /// In en, this message translates to:
  /// **'Save again'**
  String get saveAgain;

  /// Close button
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Confirm button
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Delete button
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Edit button
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// Done button
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// Got it button
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// I understand button
  ///
  /// In en, this message translates to:
  /// **'I understand'**
  String get iUnderstand;

  /// Loading indicator text
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// English language option
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Filipino/Tagalog language option
  ///
  /// In en, this message translates to:
  /// **'Filipino (Tagalog)'**
  String get languageFilipino;

  /// Settings section: Behavior
  ///
  /// In en, this message translates to:
  /// **'BEHAVIOR'**
  String get sectionBehavior;

  /// Settings section: Display
  ///
  /// In en, this message translates to:
  /// **'DISPLAY'**
  String get sectionDisplay;

  /// Settings section: Appearance
  ///
  /// In en, this message translates to:
  /// **'APPEARANCE'**
  String get sectionAppearance;

  /// Settings section: Security
  ///
  /// In en, this message translates to:
  /// **'SECURITY'**
  String get sectionSecurity;

  /// Settings section: Tracking Mode
  ///
  /// In en, this message translates to:
  /// **'TRACKING MODE'**
  String get sectionTrackingMode;

  /// Settings section: Notifications
  ///
  /// In en, this message translates to:
  /// **'NOTIFICATIONS'**
  String get sectionNotifications;

  /// Settings section: AI Model
  ///
  /// In en, this message translates to:
  /// **'AI MODEL'**
  String get sectionAiModel;

  /// Settings section: Local AI
  ///
  /// In en, this message translates to:
  /// **'LOCAL AI (PRIVATE MODE)'**
  String get sectionLocalAi;

  /// Settings section: Home screen toggles
  ///
  /// In en, this message translates to:
  /// **'HOME SCREEN — SHOW / HIDE SECTIONS'**
  String get sectionHomeScreenSections;

  /// Settings section: Analytics toggles
  ///
  /// In en, this message translates to:
  /// **'ANALYTICS — SHOW / HIDE SECTIONS'**
  String get sectionAnalyticsSections;

  /// Settings section: Export Data
  ///
  /// In en, this message translates to:
  /// **'EXPORT DATA'**
  String get sectionExportData;

  /// Settings section: Backup & Restore
  ///
  /// In en, this message translates to:
  /// **'BACKUP & RESTORE'**
  String get sectionBackupRestore;

  /// Settings section: Feedback
  ///
  /// In en, this message translates to:
  /// **'FEEDBACK'**
  String get sectionFeedback;

  /// Settings section: App Info
  ///
  /// In en, this message translates to:
  /// **'APP INFO'**
  String get sectionAppInfo;

  /// Settings section: Quick Presets
  ///
  /// In en, this message translates to:
  /// **'QUICK PRESETS'**
  String get sectionQuickPresets;

  /// Settings section: Language
  ///
  /// In en, this message translates to:
  /// **'LANGUAGE'**
  String get sectionLanguage;

  /// Settings toggle: Auto-deduct wallets
  ///
  /// In en, this message translates to:
  /// **'Auto-deduct wallets'**
  String get autoDeductWallets;

  /// Settings toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Deduct from Cash/GCash/Maya when logging expenses'**
  String get autoDeductWalletsSubtitle;

  /// Settings toggle: Confirm before deducting
  ///
  /// In en, this message translates to:
  /// **'Confirm before deducting'**
  String get confirmBeforeDeducting;

  /// Settings toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Ask \"Deduct from wallet?\" before each expense — off by default for speed'**
  String get confirmBeforeDeductingSubtitle;

  /// Settings toggle: Impulse pause
  ///
  /// In en, this message translates to:
  /// **'Impulse pause'**
  String get impulsePause;

  /// Settings toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Confirm before logging large Want expenses'**
  String get impulsePauseSubtitle;

  /// Settings toggle: Budget alerts
  ///
  /// In en, this message translates to:
  /// **'Budget alerts'**
  String get budgetAlerts;

  /// Settings toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Notify when a category hits 80% or 100%'**
  String get budgetAlertsSubtitle;

  /// Spending limits tile
  ///
  /// In en, this message translates to:
  /// **'Spending limits'**
  String get spendingLimits;

  /// Spending limits subtitle
  ///
  /// In en, this message translates to:
  /// **'Set daily, weekly, monthly, or yearly caps'**
  String get spendingLimitsSubtitle;

  /// Settings toggle: Balance mode
  ///
  /// In en, this message translates to:
  /// **'Balance mode'**
  String get balanceMode;

  /// Settings toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Show total wallet balance instead of income-based remaining'**
  String get balanceModeSubtitle;

  /// Settings toggle: Round-up savings
  ///
  /// In en, this message translates to:
  /// **'Round-up savings'**
  String get roundUpSavings;

  /// Settings toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Auto-save spare change to your first goal (rounds to ₱10)'**
  String get roundUpSavingsSubtitle;

  /// Settings toggle: Dark mode
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get darkMode;

  /// Settings toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Switch between light and dark theme'**
  String get darkModeSubtitle;

  /// Settings toggle: Compact mode
  ///
  /// In en, this message translates to:
  /// **'Compact mode'**
  String get compactMode;

  /// Settings toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Reduce spacing and list density'**
  String get compactModeSubtitle;

  /// Settings toggle: High contrast
  ///
  /// In en, this message translates to:
  /// **'High contrast'**
  String get highContrast;

  /// Settings toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Pure black/white theme for maximum readability'**
  String get highContrastSubtitle;

  /// App theme picker tile
  ///
  /// In en, this message translates to:
  /// **'App theme'**
  String get appTheme;

  /// Text size picker tile
  ///
  /// In en, this message translates to:
  /// **'Text size'**
  String get textSize;

  /// Display currency tile
  ///
  /// In en, this message translates to:
  /// **'Display currency'**
  String get displayCurrency;

  /// Display currency subtitle
  ///
  /// In en, this message translates to:
  /// **'Tap to change — all amounts stored in PHP'**
  String get displayCurrencySubtitle;

  /// Settings toggle: Track income & wallets
  ///
  /// In en, this message translates to:
  /// **'Track income & wallets'**
  String get trackIncomeWallets;

  /// Settings toggle: Anomaly alerts
  ///
  /// In en, this message translates to:
  /// **'Spending anomaly alerts'**
  String get anomalyAlerts;

  /// Settings toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Weekly alert when a category spikes 2.5× above usual'**
  String get anomalyAlertsSubtitle;

  /// Settings toggle: Smart suggestions
  ///
  /// In en, this message translates to:
  /// **'Smart suggestions'**
  String get smartSuggestions;

  /// Settings toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Daily nudges: upcoming bills, pace alerts, goal milestones, shortfall risk'**
  String get smartSuggestionsSubtitle;

  /// Settings toggle: Bill reminders
  ///
  /// In en, this message translates to:
  /// **'Bill reminders'**
  String get billReminders;

  /// Settings toggle subtitle
  ///
  /// In en, this message translates to:
  /// **'Get notified 3 days before, 1 day before, and on due date for upcoming bills'**
  String get billRemindersSubtitle;

  /// Feedback tile
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get sendFeedback;

  /// Feedback subtitle
  ///
  /// In en, this message translates to:
  /// **'Report a bug or suggest a feature'**
  String get sendFeedbackSubtitle;

  /// Export transactions tile
  ///
  /// In en, this message translates to:
  /// **'Export Transactions (CSV)'**
  String get exportTransactionsCSV;

  /// Export summary tile
  ///
  /// In en, this message translates to:
  /// **'Export Summary (CSV)'**
  String get exportSummaryCSV;

  /// Create backup tile
  ///
  /// In en, this message translates to:
  /// **'Create Backup'**
  String get createBackup;

  /// Restore from backup tile
  ///
  /// In en, this message translates to:
  /// **'Restore from Backup'**
  String get restoreFromBackup;

  /// App version tile
  ///
  /// In en, this message translates to:
  /// **'App version'**
  String get appVersion;

  /// Heads up alert title
  ///
  /// In en, this message translates to:
  /// **'Heads Up!'**
  String get headsUp;

  /// Offline banner message
  ///
  /// In en, this message translates to:
  /// **'📴 Offline — core features work. Peso AI needs internet.'**
  String get offlineBanner;

  /// Quick input hint text
  ///
  /// In en, this message translates to:
  /// **'Tell Peso what you spent today…'**
  String get tellPesoHint;

  /// Quick input offline hint
  ///
  /// In en, this message translates to:
  /// **'No internet — Peso unavailable'**
  String get noInternetPeso;

  /// Analyze button in add expense
  ///
  /// In en, this message translates to:
  /// **'Analyze'**
  String get analyzeButton;

  /// Retry button
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retryButton;

  /// Save expense button
  ///
  /// In en, this message translates to:
  /// **'Save Expense'**
  String get saveExpense;

  /// Amount field label
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get amount;

  /// Item name field label
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get itemName;

  /// Shop name field label
  ///
  /// In en, this message translates to:
  /// **'Shop / Merchant'**
  String get shopName;

  /// Notes field label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Category field label
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// Payment method field label
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get paymentMethod;

  /// Date field label
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// Want/Need toggle label
  ///
  /// In en, this message translates to:
  /// **'Want / Need'**
  String get wantNeed;

  /// Want label
  ///
  /// In en, this message translates to:
  /// **'Want'**
  String get wantLabel;

  /// Need label
  ///
  /// In en, this message translates to:
  /// **'Need'**
  String get needLabel;

  /// Add expense input hint
  ///
  /// In en, this message translates to:
  /// **'Describe your expense…'**
  String get describeExpense;

  /// AI analyzing status text
  ///
  /// In en, this message translates to:
  /// **'AI is analyzing…'**
  String get aiAnalyzing;

  /// Retrying status text
  ///
  /// In en, this message translates to:
  /// **'Retrying…'**
  String get retrying;

  /// Error: describe expense first
  ///
  /// In en, this message translates to:
  /// **'Please describe your expense first.'**
  String get pleaseDescribeFirst;

  /// Error: invalid amount
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid amount.'**
  String get pleaseEnterValidAmount;

  /// Error: missing item name
  ///
  /// In en, this message translates to:
  /// **'Please enter an item name.'**
  String get pleaseEnterItemName;

  /// Duplicate dialog title
  ///
  /// In en, this message translates to:
  /// **'Already logged today?'**
  String get alreadyLoggedToday;

  /// Impulse pause dialog title
  ///
  /// In en, this message translates to:
  /// **'Was this planned? 🤔'**
  String get wasThisPlanned;

  /// Impulse pause: reconsider button
  ///
  /// In en, this message translates to:
  /// **'Wait, let me reconsider'**
  String get waitLetMeReconsider;

  /// Impulse pause: save button
  ///
  /// In en, this message translates to:
  /// **'Yes, save it'**
  String get yesSaveIt;

  /// Wallet deduction dialog title
  ///
  /// In en, this message translates to:
  /// **'Deduct from wallet?'**
  String get deductFromWallet;

  /// Paste success message
  ///
  /// In en, this message translates to:
  /// **'Pasted! Review the fields below and tap Analyze or Save.'**
  String get pastedReview;

  /// Clipboard empty message
  ///
  /// In en, this message translates to:
  /// **'Clipboard is empty.'**
  String get clipboardEmpty;

  /// AI screen title
  ///
  /// In en, this message translates to:
  /// **'Peso AI'**
  String get aiScreenTitle;

  /// AI chat input hint
  ///
  /// In en, this message translates to:
  /// **'Type a message…'**
  String get typeAMessage;

  /// Full chat action in snackbar
  ///
  /// In en, this message translates to:
  /// **'Full Chat'**
  String get fullChat;

  /// Financial advice disclaimer title
  ///
  /// In en, this message translates to:
  /// **'Financial Advice Notice'**
  String get financialAdviceNotice;

  /// Cebuano language option
  ///
  /// In en, this message translates to:
  /// **'Cebuano (Bisaya)'**
  String get languageCebuano;

  /// Analytics screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get analyticsScreenTitle;

  /// Budgets screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgetsScreenTitle;

  /// Savings Goals screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Savings Goals'**
  String get savingsGoalsScreenTitle;

  /// Recurring Transactions screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Recurring Transactions'**
  String get recurringScreenTitle;

  /// Debts screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Debts'**
  String get debtScreenTitle;

  /// Income screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get incomeScreenTitle;

  /// Profile screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profileScreenTitle;

  /// Transactions screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactionsScreenTitle;

  /// Add Budget button label
  ///
  /// In en, this message translates to:
  /// **'Add Budget'**
  String get addBudget;

  /// New Goal FAB label
  ///
  /// In en, this message translates to:
  /// **'New Goal'**
  String get newGoal;

  /// Add Recurring FAB label
  ///
  /// In en, this message translates to:
  /// **'Add Recurring'**
  String get addRecurring;

  /// Add Debt FAB label
  ///
  /// In en, this message translates to:
  /// **'Add Debt'**
  String get addDebt;

  /// Add Income FAB label
  ///
  /// In en, this message translates to:
  /// **'Add Income'**
  String get addIncome;

  /// Empty state: no expenses
  ///
  /// In en, this message translates to:
  /// **'No expenses yet'**
  String get noExpensesYet;

  /// Empty state: no budgets
  ///
  /// In en, this message translates to:
  /// **'No budgets set yet'**
  String get noBudgetsYet;

  /// Empty state: no goals
  ///
  /// In en, this message translates to:
  /// **'No savings goals yet'**
  String get noGoalsYet;

  /// Empty state: no recurring
  ///
  /// In en, this message translates to:
  /// **'No recurring transactions yet'**
  String get noRecurringYet;

  /// Empty state: no debts
  ///
  /// In en, this message translates to:
  /// **'No debts yet'**
  String get noDebtsYet;

  /// Empty state: no income
  ///
  /// In en, this message translates to:
  /// **'No income records yet'**
  String get noIncomeYet;

  /// Delete expense dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Expense'**
  String get deleteExpense;

  /// Delete goal dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Goal'**
  String get deleteGoal;

  /// Delete debt dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Debt'**
  String get deleteDebt;

  /// Delete income dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Income'**
  String get deleteIncome;

  /// Delete recurring dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Recurring'**
  String get deleteRecurring;

  /// Record payment dialog title
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get recordPayment;

  /// Log all due button label
  ///
  /// In en, this message translates to:
  /// **'Log All Due'**
  String get logAllDue;

  /// Log now button label
  ///
  /// In en, this message translates to:
  /// **'Log Now'**
  String get logNow;

  /// Create goal button label
  ///
  /// In en, this message translates to:
  /// **'Create Goal'**
  String get createGoal;

  /// Save changes button label
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Emergency fund label
  ///
  /// In en, this message translates to:
  /// **'Emergency Fund'**
  String get emergencyFund;

  /// Over budget warning dialog title
  ///
  /// In en, this message translates to:
  /// **'Over Budget Warning'**
  String get overBudgetWarning;

  /// Confirm and log button
  ///
  /// In en, this message translates to:
  /// **'Confirm & Log'**
  String get confirmAndLog;

  /// Refresh button label
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get refresh;

  /// Get AI advice button label
  ///
  /// In en, this message translates to:
  /// **'Get AI Financial Advice'**
  String get getAiAdvice;

  /// This month label
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// All time label
  ///
  /// In en, this message translates to:
  /// **'All Time'**
  String get allTime;

  /// Entries count label
  ///
  /// In en, this message translates to:
  /// **'Entries'**
  String get entries;

  /// Total label
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// Income label
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// Balance label
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get balance;

  /// Spent label
  ///
  /// In en, this message translates to:
  /// **'Spent'**
  String get spent;

  /// Budgeted label
  ///
  /// In en, this message translates to:
  /// **'Budgeted'**
  String get budgeted;

  /// Generic add button label
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Pay button label
  ///
  /// In en, this message translates to:
  /// **'Pay'**
  String get pay;

  /// Reset all data dialog title
  ///
  /// In en, this message translates to:
  /// **'Reset All Data'**
  String get resetAllData;

  /// About screen title
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Achievements screen title
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// Help screen title
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// Transactions label
  ///
  /// In en, this message translates to:
  /// **'Transactions'**
  String get transactions;

  /// Chat history screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Chat History'**
  String get chatHistoryScreenTitle;

  /// Feedback screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get feedbackScreenTitle;

  /// Forecast screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Cash Flow Forecast'**
  String get forecastScreenTitle;

  /// Gov contributions screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Gov Contributions'**
  String get govContributionsScreenTitle;

  /// Heatmap screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Spending Heatmap'**
  String get heatmapScreenTitle;

  /// Insights screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Spending Insights'**
  String get insightsScreenTitle;

  /// Investment screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Investment Portfolio'**
  String get investmentScreenTitle;

  /// Net worth screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Net Worth'**
  String get netWorthScreenTitle;

  /// Tax screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'BIR Tax Calculator'**
  String get taxScreenTitle;

  /// Challenges screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Challenges & Streaks'**
  String get challengesScreenTitle;

  /// Debt calculator screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Debt Payoff Calculator'**
  String get debtCalculatorScreenTitle;

  /// Price intelligence screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Price Intelligence'**
  String get priceIntelligenceScreenTitle;

  /// Insurance screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Insurance & Contributions'**
  String get insuranceScreenTitle;

  /// Paluwagan screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Paluwagan Tracker'**
  String get palawaganScreenTitle;

  /// PCA calculator screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Peso Cost Averaging'**
  String get pcaCalculatorScreenTitle;

  /// Merchant merge screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Merchant Cleanup'**
  String get merchantMergeScreenTitle;

  /// Bank comparison screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'PH Banks & Investments'**
  String get bankComparisonScreenTitle;

  /// Currency screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Currency & Region'**
  String get currencyScreenTitle;

  /// Glossary screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Financial Glossary'**
  String get glossaryScreenTitle;

  /// Log due bills screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Log Due Bills'**
  String get logDueBillsScreenTitle;

  /// Manage categories screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get manageCategoriesScreenTitle;

  /// Manage rules screen AppBar title
  ///
  /// In en, this message translates to:
  /// **'Manage Rules'**
  String get manageRulesScreenTitle;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ceb', 'en', 'tl'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ceb':
      return AppLocalizationsCeb();
    case 'en':
      return AppLocalizationsEn();
    case 'tl':
      return AppLocalizationsTl();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
