import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../services/app_config.dart';
import '../services/app_lock_service.dart';
import '../services/event_bus.dart';
import '../services/theme_service.dart';
import '../main.dart';
import '../widgets/local_ai_setup_sheet.dart';
import 'home_screen.dart' show SpendingLimitsSheet;
import 'pin_setup_screen.dart';
import 'currency_screen.dart';

/// Full-screen App Settings — replaces the old bottom sheet.
/// All toggles are always interactive (no grayed-out states).
/// Lite Mode one-tap toggle turns off all 10 optional sections at once.
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _loading = true;

  // ── Behavior ────────────────────────────────────────────────────────────────
  bool autoDeduct = true;
  bool walletConfirmDeduct = false; // opt-in: ask before deducting each expense
  bool impulseEnabled = true;
  bool budgetAlerts = true;

  // ── Display ─────────────────────────────────────────────────────────────────
  bool balanceMode = false;
  bool roundUpSavings = true;
  bool compactMode = false;

  // ── Tracking mode ───────────────────────────────────────────────────────────
  bool incomeWalletMode = true;

  // ── Notifications ───────────────────────────────────────────────────────────
  bool anomalyEnabled = true;
  bool proactiveNudgesEnabled = true;

  // ── Local AI ────────────────────────────────────────────────────────────────
  final _localUrlCtrl = TextEditingController();
  final _localModelCtrl = TextEditingController();
  final _localKeyCtrl = TextEditingController();
  String? _localTestResult; // null=untested, 'ok'=success, else=error message
  bool _localTesting = false;

  // ── Home screen sections ────────────────────────────────────────────────────
  bool showSubscriptions = true;
  bool showQuickLog = true;
  bool showBadges = true;
  bool showMoodHome = true;
  bool showForecast = true;
  bool showPrediction = true;
  bool showPaydayCountdown = true;
  bool showMonthlyRecap = true;
  bool showChallenges = true;
  bool showSafeToSpend = true;

  // ── Analytics sections ──────────────────────────────────────────────────────
  bool showDTI = true;
  bool showEmergencyFund = true;
  bool showMilestones = true;
  bool showMarketInsights = true;

  // ── Derived ─────────────────────────────────────────────────────────────────
  bool get liteMode =>
      !showSubscriptions &&
      !showQuickLog &&
      !showBadges &&
      !showMoodHome &&
      !showForecast &&
      !showPrediction &&
      !showPaydayCountdown &&
      !showMonthlyRecap &&
      !showChallenges &&
      !showSafeToSpend &&
      !showDTI &&
      !showEmergencyFund &&
      !showMilestones &&
      !showMarketInsights;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _localUrlCtrl.dispose();
    _localModelCtrl.dispose();
    _localKeyCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    autoDeduct = (await DBService.getSetting('wallet_auto_deduct')) != 'false';
    walletConfirmDeduct =
        (await DBService.getSetting('wallet_confirm_deduct')) == 'true';
    // mood_checkin_enabled is now unified with show_mood_home — one toggle controls both.
    // Migrate any existing mood_checkin_enabled=false → show_mood_home=false on first load.
    final oldMoodKey = await DBService.getSetting('mood_checkin_enabled');
    if (oldMoodKey == 'false') {
      await DBService.setSetting('show_mood_home', 'false');
      await DBService.setSetting(
          'mood_checkin_enabled', 'true'); // clear old key
    }
    impulseEnabled =
        (await DBService.getSetting('impulse_pause_enabled')) != 'false';
    budgetAlerts =
        (await DBService.getSetting('budget_alerts_enabled')) != 'false';
    balanceMode = (await DBService.getSetting('balance_mode')) == 'true';
    roundUpSavings =
        (await DBService.getSetting('round_up_savings')) != 'false';
    compactMode = themeService.compactMode;
    incomeWalletMode = await DBService.getIncomeWalletMode();
    anomalyEnabled =
        (await DBService.getSetting('anomaly_detection_enabled')) != 'false';
    proactiveNudgesEnabled =
        (await DBService.getSetting('show_proactive_nudges')) != 'false';
    showSubscriptions =
        (await DBService.getSetting('show_subscriptions')) != 'false';
    showQuickLog = (await DBService.getSetting('show_quick_log')) != 'false';
    showBadges = (await DBService.getSetting('show_badges')) != 'false';
    showMoodHome = (await DBService.getSetting('show_mood_home')) != 'false';
    showForecast = (await DBService.getSetting('show_forecast')) != 'false';
    showPrediction = (await DBService.getSetting('show_prediction')) != 'false';
    showPaydayCountdown =
        (await DBService.getSetting('show_payday_countdown')) != 'false';
    showMonthlyRecap =
        (await DBService.getSetting('show_monthly_recap')) != 'false';
    showChallenges = (await DBService.getSetting('show_challenges')) != 'false';
    showSafeToSpend =
        (await DBService.getSetting('show_safe_to_spend')) != 'false';
    showDTI = (await DBService.getSetting('show_dti')) != 'false';
    showEmergencyFund =
        (await DBService.getSetting('show_emergency_fund')) != 'false';
    showMilestones = (await DBService.getSetting('show_milestones')) != 'false';
    showMarketInsights =
        (await DBService.getSetting('show_market_insights')) != 'false';
    // Load local AI settings
    _localUrlCtrl.text = AppConfig.customLocalUrl;
    _localModelCtrl.text = AppConfig.customLocalModel;
    _localKeyCtrl.text = AppConfig.customLocalKey;
    if (mounted) setState(() => _loading = false);
  }

  void _applyLiteMode(bool on) => _applyPreset(on ? 'lite' : 'normal');

  /// Apply an experience preset — sets all 14 show_* keys atomically.
  /// Presets are starting points; individual toggles below still work.
  void _applyPreset(String preset) {
    // Visibility matrix per preset level
    // Lite 🪶 — essentials only
    // Casual 😊 — regular tracker
    // Normal ⚖️ — balanced (default)
    // Pro 🚀 — everything
    final s = preset == 'lite'
        ? _PresetValues.lite()
        : preset == 'casual'
            ? _PresetValues.casual()
            : preset == 'pro'
                ? _PresetValues.pro()
                : _PresetValues.normal();

    setState(() {
      showSubscriptions = s.subscriptions;
      showQuickLog = s.quickLog;
      showBadges = s.badges;
      showMoodHome = s.moodHome;
      showForecast = s.forecast;
      showPrediction = s.prediction;
      showPaydayCountdown = s.paydayCountdown;
      showMonthlyRecap = s.monthlyRecap;
      showChallenges = s.challenges;
      showSafeToSpend = s.safeToSpend;
      showDTI = s.dti;
      showEmergencyFund = s.emergencyFund;
      showMilestones = s.milestones;
      showMarketInsights = s.marketInsights;
    });
    void w(String k, bool v) => DBService.setSetting(k, v ? 'true' : 'false');
    w('show_subscriptions', s.subscriptions);
    w('show_quick_log', s.quickLog);
    w('show_badges', s.badges);
    w('show_mood_home', s.moodHome);
    w('show_forecast', s.forecast);
    w('show_prediction', s.prediction);
    w('show_payday_countdown', s.paydayCountdown);
    w('show_monthly_recap', s.monthlyRecap);
    w('show_challenges', s.challenges);
    w('show_safe_to_spend', s.safeToSpend);
    w('show_dti', s.dti);
    w('show_emergency_fund', s.emergencyFund);
    w('show_milestones', s.milestones);
    w('show_market_insights', s.marketInsights);
    DBService.setSetting('experience_preset', preset);
    fireEvent(AppEvent.incomeChanged);
  }

  /// Detect current active preset from show_* state, falling back to 'custom'.
  String get _activePreset {
    if (_matchesPreset('lite')) return 'lite';
    if (_matchesPreset('casual')) return 'casual';
    if (_matchesPreset('normal')) return 'normal';
    if (_matchesPreset('pro')) return 'pro';
    return 'custom';
  }

  bool _matchesPreset(String preset) {
    final s = preset == 'lite'
        ? _PresetValues.lite()
        : preset == 'casual'
            ? _PresetValues.casual()
            : preset == 'pro'
                ? _PresetValues.pro()
                : _PresetValues.normal();
    return showSubscriptions == s.subscriptions &&
        showQuickLog == s.quickLog &&
        showBadges == s.badges &&
        showMoodHome == s.moodHome &&
        showForecast == s.forecast &&
        showPrediction == s.prediction &&
        showPaydayCountdown == s.paydayCountdown &&
        showMonthlyRecap == s.monthlyRecap &&
        showChallenges == s.challenges &&
        showSafeToSpend == s.safeToSpend &&
        showDTI == s.dti &&
        showEmergencyFund == s.emergencyFund &&
        showMilestones == s.milestones &&
        showMarketInsights == s.marketInsights;
  }

  void _save(String key, bool value) {
    DBService.setSetting(key, value ? 'true' : 'false');
  }

  void _saveAndRefresh(String key, bool value) {
    _save(key, value);
    fireEvent(AppEvent.incomeChanged);
  }

  void _showThemePicker() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('App Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppTheme.values.map((t) {
            final isSelected = themeService.appTheme == t;
            return ListTile(
              dense: true,
              leading:
                  CircleAvatar(radius: 12, backgroundColor: t.primaryColor),
              title: Text(t.label),
              trailing: isSelected
                  ? Icon(Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary)
                  : null,
              onTap: () async {
                await themeService.setTheme(t);
                if (mounted) {
                  Navigator.pop(context);
                  setState(() {});
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
        ],
      ),
    );
  }

  void _showTextSizePicker() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Text Size'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            (1.0, 'Normal', 'Default text size'),
            (1.15, 'Large', 'Easier to read'),
            (1.3, 'Extra Large', 'Best for accessibility'),
          ].map((option) {
            final isSelected = themeService.textScale == option.$1;
            return ListTile(
              dense: true,
              leading: Icon(
                isSelected
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color:
                    isSelected ? Theme.of(context).colorScheme.primary : null,
              ),
              title: Text(option.$2),
              subtitle: Text(option.$3, style: const TextStyle(fontSize: 11)),
              onTap: () async {
                await themeService.setTextScale(option.$1);
                if (mounted) {
                  Navigator.pop(context);
                  setState(() {});
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 10),
        child: Text(text,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.grey[500],
                letterSpacing: 0.8)),
      );

  Widget _sectionHint(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child:
            Text(text, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      );

  /// Wraps a list of setting rows in a soft-shadow rounded card.
  Widget _sectionCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i < children.length - 1)
                Divider(
                    height: 1,
                    indent: 16,
                    endIndent: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .outline
                        .withValues(alpha: 0.12)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('App Settings'),
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 40),
              children: [
                // ── EXPERIENCE PRESETS ──────────────────────────────────
                _sectionLabel('QUICK PRESETS'),
                _ExperiencePresetSelector(
                  activePreset: _activePreset,
                  onSelect: _applyPreset,
                ),

                // ── BEHAVIOR ────────────────────────────────────────────────
                _sectionLabel('BEHAVIOR'),
                _sectionCard([
                  _tile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Auto-deduct wallets',
                    subtitle:
                        'Deduct from Cash/GCash/Maya when logging expenses',
                    value: autoDeduct,
                    onChanged: (v) {
                      setState(() => autoDeduct = v);
                      _save('wallet_auto_deduct', v);
                    },
                  ),
                  _tile(
                    icon: Icons.help_outline_rounded,
                    title: 'Confirm before deducting',
                    subtitle:
                        'Ask "Deduct from wallet?" before each expense — off by default for speed',
                    value: walletConfirmDeduct,
                    onChanged: (v) {
                      setState(() => walletConfirmDeduct = v);
                      _save('wallet_confirm_deduct', v);
                    },
                  ),
                  _tile(
                    icon: Icons.pause_circle_outline,
                    title: 'Impulse pause',
                    subtitle: 'Confirm before logging large Want expenses',
                    value: impulseEnabled,
                    onChanged: (v) {
                      setState(() => impulseEnabled = v);
                      _save('impulse_pause_enabled', v);
                    },
                  ),
                  _tile(
                    icon: Icons.notifications_outlined,
                    title: 'Budget alerts',
                    subtitle: 'Notify when a category hits 80% or 100%',
                    value: budgetAlerts,
                    onChanged: (v) {
                      setState(() => budgetAlerts = v);
                      _save('budget_alerts_enabled', v);
                    },
                  ),
                  // Spending limits nav row
                  InkWell(
                    onTap: () => SpendingLimitsSheet.show(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(children: [
                        Icon(Icons.speed_outlined,
                            size: 20, color: Colors.grey[600]),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Spending limits',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                                Text(
                                    'Set daily, weekly, monthly, or yearly caps',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey[500])),
                              ]),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey[400]),
                      ]),
                    ),
                  ),
                ]),

                // ── DISPLAY ─────────────────────────────────────────────────
                _sectionLabel('DISPLAY'),
                _sectionCard([
                  _tile(
                    icon: Icons.account_balance_wallet,
                    title: 'Balance mode',
                    subtitle:
                        'Show total wallet balance instead of income-based remaining',
                    value: balanceMode,
                    onChanged: (v) {
                      setState(() => balanceMode = v);
                      _saveAndRefresh('balance_mode', v);
                    },
                  ),
                  _tile(
                    icon: Icons.savings_outlined,
                    title: 'Round-up savings',
                    subtitle:
                        'Auto-save spare change to your first goal (rounds to ₱10)',
                    value: roundUpSavings,
                    onChanged: (v) {
                      setState(() => roundUpSavings = v);
                      _save('round_up_savings', v);
                    },
                  ),
                ]),

                // ── APPEARANCE ───────────────────────────────────────────────
                _sectionLabel('APPEARANCE'),
                _sectionCard([
                  _tile(
                    icon: Icons.dark_mode_outlined,
                    title: 'Dark mode',
                    subtitle: 'Switch between light and dark theme',
                    value: themeService.isDark,
                    onChanged: (_) {
                      themeService.toggle();
                      setState(() {});
                    },
                  ),
                  _tile(
                    icon: Icons.density_medium_outlined,
                    title: 'Compact mode',
                    subtitle: 'Reduce spacing and list density',
                    value: compactMode,
                    onChanged: (v) {
                      setState(() => compactMode = v);
                      themeService.setCompactMode(v);
                      _save('compact_mode', v);
                    },
                  ),
                  _tile(
                    icon: Icons.contrast_outlined,
                    title: 'High contrast',
                    subtitle: 'Pure black/white theme for maximum readability',
                    value: themeService.highContrast,
                    onChanged: (v) {
                      themeService.setHighContrast(v);
                      setState(() {});
                    },
                  ),
                  // App Theme picker
                  InkWell(
                    onTap: _showThemePicker,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(children: [
                        Icon(Icons.palette_outlined,
                            size: 20, color: Colors.grey[600]),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('App theme',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                                Text('Current: ${themeService.appTheme.label}',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey[500])),
                              ]),
                        ),
                        Row(children: [
                          Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: themeService.appTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(Icons.chevron_right, color: Colors.grey[400]),
                        ]),
                      ]),
                    ),
                  ),
                  // Text size picker
                  InkWell(
                    onTap: _showTextSizePicker,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(children: [
                        Icon(Icons.text_fields_outlined,
                            size: 20, color: Colors.grey[600]),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Text size',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                                Text('Current: ${themeService.textScaleLabel}',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey[500])),
                              ]),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey[400]),
                      ]),
                    ),
                  ),
                  // Display currency
                  InkWell(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const CurrencyScreen())),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(children: [
                        Icon(Icons.language_outlined,
                            size: 20, color: Colors.grey[600]),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Display currency',
                                    style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500)),
                                Text(
                                    'Tap to change — all amounts stored in PHP',
                                    style: TextStyle(
                                        fontSize: 11, color: Colors.grey[500])),
                              ]),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey[400]),
                      ]),
                    ),
                  ),
                ]),

                // ── SECURITY ─────────────────────────────────────────────────
                _sectionLabel('SECURITY'),
                _sectionCard([
                  FutureBuilder<bool>(
                    future: AppLockService.isEnabled(),
                    builder: (ctx, snap) {
                      final enabled = snap.data ?? false;
                      return InkWell(
                        onTap: () async {
                          final hasPin = await AppLockService.hasPin();
                          if (!hasPin || !enabled) {
                            final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const PinSetupScreen()));
                            if (result == true && mounted) setState(() {});
                          } else {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: const Text('Disable App Lock'),
                                content: const Text(
                                    'Remove PIN and biometric lock?'),
                                actions: [
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Cancel')),
                                  TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Disable',
                                          style: TextStyle(color: Colors.red))),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              await AppLockService.removePin();
                              if (mounted) setState(() {});
                            }
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Row(children: [
                            Icon(
                              enabled
                                  ? Icons.lock_outlined
                                  : Icons.lock_open_outlined,
                              size: 20,
                              color: enabled
                                  ? Colors.green[700]
                                  : Colors.grey[600],
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                        enabled
                                            ? 'App Lock — ON'
                                            : 'App Lock — OFF',
                                        style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: enabled
                                                ? Colors.green[700]
                                                : null)),
                                    Text(
                                        enabled
                                            ? 'PIN + biometric active. Tap to disable.'
                                            : 'Set a PIN to protect your data',
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[500])),
                                  ]),
                            ),
                            Icon(Icons.chevron_right, color: Colors.grey[400]),
                          ]),
                        ),
                      );
                    },
                  ),
                ]),

                // ── TRACKING MODE ────────────────────────────────────────────
                _sectionLabel('TRACKING MODE'),
                _sectionHint(
                    'Controls how your Financial Health Score is calculated.'),
                _sectionCard([
                  _tile(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Track income & wallets',
                    subtitle: incomeWalletMode
                        ? 'ON — full FHS with savings rate & wallet tracking'
                        : 'OFF — FHS uses spending habits only (no income needed)',
                    value: incomeWalletMode,
                    onChanged: (v) {
                      setState(() => incomeWalletMode = v);
                      DBService.setIncomeWalletMode(v);
                      fireEvent(AppEvent.incomeChanged);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            v
                                ? '✅ Full Mode ON — FHS now includes Savings Rate vs income. Score may drop if spending > income.'
                                : '💡 Lightweight Mode ON — FHS now uses spending habits only. Score reflects your tracking consistency.',
                            style: const TextStyle(fontSize: 13),
                          ),
                          duration: const Duration(seconds: 4),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ]),

                // ── NOTIFICATIONS ────────────────────────────────────────────
                _sectionLabel('NOTIFICATIONS'),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.amber.withValues(alpha: 0.3)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.info_outline,
                          size: 16, color: Colors.amber),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Notifications require system permission. '
                          'If alerts aren\'t arriving, check Settings → Apps → SmartSpend → Notifications.',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[700]),
                        ),
                      ),
                    ]),
                  ),
                ),
                _sectionCard([
                  _tile(
                    icon: Icons.search_outlined,
                    title: 'Spending anomaly alerts',
                    subtitle:
                        'Weekly alert when a category spikes 2.5× above usual',
                    value: anomalyEnabled,
                    onChanged: (v) {
                      setState(() => anomalyEnabled = v);
                      _save('anomaly_detection_enabled', v);
                    },
                  ),
                  _tile(
                    icon: Icons.tips_and_updates_outlined,
                    title: 'Smart suggestions',
                    subtitle:
                        'Daily nudges: upcoming bills, pace alerts, goal milestones, shortfall risk',
                    value: proactiveNudgesEnabled,
                    onChanged: (v) {
                      setState(() => proactiveNudgesEnabled = v);
                      _save('show_proactive_nudges', v);
                    },
                  ),
                ]),

                // ── AI MODEL ─────────────────────────────────────────────────
                _sectionLabel('AI MODEL'),
                _sectionHint(
                    'Switch the AI model. Auto-fallback still applies when limits are reached.'),
                ...AppConfig.availableModels.map((m) {
                  final isActive = AppConfig.activeModelId == m.$1;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        setState(() {});
                        AppConfig.setModel(m.$1);
                        // Note: AppConfig.setModel() calls _saveActiveModel()
                        // which writes 'active_model_id' — no extra DB write needed
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: isActive
                              ? theme.colorScheme.primary
                                  .withValues(alpha: 0.08)
                              : theme.colorScheme.surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isActive
                                ? theme.colorScheme.primary
                                    .withValues(alpha: 0.4)
                                : theme.colorScheme.outline
                                    .withValues(alpha: 0.15),
                            width: isActive ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(children: [
                          Icon(
                              isActive
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              size: 18,
                              color: isActive
                                  ? theme.colorScheme.primary
                                  : Colors.grey),
                          const SizedBox(width: 12),
                          Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                Text(m.$2,
                                    style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isActive
                                            ? theme.colorScheme.primary
                                            : null)),
                                Text(m.$3,
                                    style: TextStyle(
                                        fontSize: 10, color: Colors.grey[500])),
                              ])),
                          if (isActive)
                            Icon(Icons.check_circle,
                                size: 16, color: theme.colorScheme.primary),
                        ]),
                      ),
                    ),
                  );
                }),

                // ── LOCAL AI ─────────────────────────────────────────────────
                _sectionLabel('LOCAL AI (PRIVATE MODE)'),
                _sectionHint(
                    'Run your own LLM on your PC/Mac and connect SmartSpend to it over WiFi. Your financial data never leaves your home network.'),
                _sectionCard([
                  // Active indicator
                  if (AppConfig.hasCustomLocal) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.green.withValues(alpha: 0.25)),
                      ),
                      child: Row(children: [
                        const Icon(Icons.home, size: 16, color: Colors.green),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '🏠 Local AI active — ${AppConfig.customLocalModel.isNotEmpty ? AppConfig.customLocalModel : 'model not set'} @ ${AppConfig.customLocalUrl}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: Colors.green,
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ]),
                    ),
                    const SizedBox(height: 12),
                  ],
                  // URL field
                  TextField(
                    controller: _localUrlCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Base URL',
                      hintText: 'http://192.168.1.5:11434/v1',
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: Icon(Icons.link, size: 18),
                    ),
                    keyboardType: TextInputType.url,
                    onChanged: (_) => setState(() => _localTestResult = null),
                  ),
                  const SizedBox(height: 10),
                  // Model field
                  TextField(
                    controller: _localModelCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Model name',
                      hintText: 'qwen3:7b',
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: Icon(Icons.memory, size: 18),
                    ),
                    onChanged: (_) => setState(() => _localTestResult = null),
                  ),
                  const SizedBox(height: 10),
                  // API key field (usually blank)
                  TextField(
                    controller: _localKeyCtrl,
                    decoration: const InputDecoration(
                      labelText: 'API Key (optional — leave blank for Ollama)',
                      hintText: 'blank for most local setups',
                      border: OutlineInputBorder(),
                      isDense: true,
                      prefixIcon: Icon(Icons.key, size: 18),
                    ),
                    obscureText: true,
                    onChanged: (_) => setState(() => _localTestResult = null),
                  ),
                  const SizedBox(height: 12),
                  // Test result
                  if (_localTestResult != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: _localTestResult == 'ok'
                            ? Colors.green.withValues(alpha: 0.08)
                            : Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _localTestResult == 'ok'
                              ? Colors.green.withValues(alpha: 0.3)
                              : Colors.red.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        _localTestResult == 'ok'
                            ? '✅ Connected! Your local AI is responding.'
                            : '❌ $_localTestResult',
                        style: TextStyle(
                            fontSize: 12,
                            color: _localTestResult == 'ok'
                                ? Colors.green[700]
                                : Colors.red[700]),
                      ),
                    ),
                  // Buttons row
                  Row(children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: _localTesting
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2))
                            : const Icon(Icons.wifi_find, size: 16),
                        label: Text(
                            _localTesting ? 'Testing…' : 'Test Connection'),
                        onPressed: _localTesting
                            ? null
                            : () async {
                                setState(() {
                                  _localTesting = true;
                                  _localTestResult = null;
                                });
                                final url = _localUrlCtrl.text.trim();
                                final model = _localModelCtrl.text.trim();
                                final err =
                                    await AppConfig.testCustomLocal(url, model);
                                if (mounted) {
                                  // Save on successful test
                                  if (err == null) {
                                    await AppConfig.setCustomLocal(
                                      url: url,
                                      model: model,
                                      key: _localKeyCtrl.text.trim(),
                                    );
                                  }
                                  setState(() {
                                    _localTesting = false;
                                    _localTestResult = err ?? 'ok';
                                  });
                                }
                              },
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.menu_book_outlined, size: 16),
                      label: const Text('Setup Guide'),
                      onPressed: () => LocalAiSetupSheet.show(context),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  // Save / Clear row
                  Row(children: [
                    Expanded(
                      child: FilledButton.icon(
                        icon: const Icon(Icons.save_outlined, size: 16),
                        label: const Text('Save Settings'),
                        onPressed: () async {
                          await AppConfig.setCustomLocal(
                            url: _localUrlCtrl.text.trim(),
                            model: _localModelCtrl.text.trim(),
                            key: _localKeyCtrl.text.trim(),
                          );
                          if (mounted) {
                            setState(() {});
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Text(
                                  '✅ Local AI settings saved. Select "Local AI" in AI Model above to use it.'),
                              behavior: SnackBarBehavior.floating,
                            ));
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Clear'),
                      onPressed: () async {
                        await AppConfig.setCustomLocal(
                            url: '', model: '', key: '');
                        _localUrlCtrl.clear();
                        _localModelCtrl.clear();
                        _localKeyCtrl.clear();
                        if (mounted) setState(() => _localTestResult = null);
                      },
                    ),
                  ]),
                  const SizedBox(height: 4),
                  Text(
                    'After saving, go to AI Model above and select "Local AI (Your Computer)" to activate it. Cloud AI remains as automatic fallback.',
                    style: TextStyle(
                        fontSize: 11,
                        color:
                            theme.colorScheme.onSurface.withValues(alpha: 0.45),
                        height: 1.4),
                  ),
                ]),

                // ── HOME SCREEN SECTIONS ──────────────────────────────────────
                _sectionLabel('HOME SCREEN — SHOW / HIDE SECTIONS'),
                _sectionHint(
                    'Toggle optional cards. Core cards (spending summary, FHS score, wallets, budgets) are always visible.'),
                _sectionCard([
                  _tile(
                    icon: Icons.autorenew_outlined,
                    title: 'Subscription summary',
                    subtitle: 'Card showing detected recurring subscriptions',
                    value: showSubscriptions,
                    onChanged: (v) {
                      setState(() => showSubscriptions = v);
                      _saveAndRefresh('show_subscriptions', v);
                    },
                  ),
                  _tile(
                    icon: Icons.flash_on_outlined,
                    title: 'Quick-log chips',
                    subtitle: 'One-tap chips for your most frequent expenses',
                    value: showQuickLog,
                    onChanged: (v) {
                      setState(() => showQuickLog = v);
                      _saveAndRefresh('show_quick_log', v);
                    },
                  ),
                  _tile(
                    icon: Icons.emoji_events_outlined,
                    title: 'Achievement badges row',
                    subtitle: 'Your earned badges on the home screen',
                    value: showBadges,
                    onChanged: (v) {
                      setState(() => showBadges = v);
                      _saveAndRefresh('show_badges', v);
                    },
                  ),
                  _tile(
                    icon: Icons.emoji_emotions_outlined,
                    title: 'Daily mood check-in',
                    subtitle: 'Show daily mood prompt on the home screen',
                    value: showMoodHome,
                    onChanged: (v) {
                      setState(() => showMoodHome = v);
                      _saveAndRefresh('show_mood_home', v);
                    },
                  ),
                  _tile(
                    icon: Icons.waterfall_chart_outlined,
                    title: 'Cash flow forecast',
                    subtitle: 'Projected income vs spending card',
                    value: showForecast,
                    onChanged: (v) {
                      setState(() => showForecast = v);
                      _saveAndRefresh('show_forecast', v);
                    },
                  ),
                  _tile(
                    icon: Icons.psychology_outlined,
                    title: 'Behavioral prediction card',
                    subtitle: 'AI prediction of end-of-month spending',
                    value: showPrediction,
                    onChanged: (v) {
                      setState(() => showPrediction = v);
                      _saveAndRefresh('show_prediction', v);
                    },
                  ),
                  _tile(
                    icon: Icons.calendar_month_outlined,
                    title: 'Payday / income countdown',
                    subtitle:
                        'Card predicting your next income date and amount',
                    value: showPaydayCountdown,
                    onChanged: (v) {
                      setState(() => showPaydayCountdown = v);
                      _saveAndRefresh('show_payday_countdown', v);
                    },
                  ),
                  _tile(
                    icon: Icons.savings_outlined,
                    title: 'Safe to Spend',
                    subtitle:
                        'Wallet balance minus upcoming bills, goal contributions, and overdue debts',
                    value: showSafeToSpend,
                    onChanged: (v) {
                      setState(() => showSafeToSpend = v);
                      _saveAndRefresh('show_safe_to_spend', v);
                    },
                  ),
                  _tile(
                    icon: Icons.bar_chart_rounded,
                    title: 'Monthly recap alert',
                    subtitle:
                        'Alert on days 1–3 of each month comparing last month vs the month before',
                    value: showMonthlyRecap,
                    onChanged: (v) {
                      setState(() => showMonthlyRecap = v);
                      _saveAndRefresh('show_monthly_recap', v);
                    },
                  ),
                  _tile(
                    icon: Icons.emoji_events_outlined,
                    title: 'Daily & weekly challenges',
                    subtitle:
                        'Gamification quests and weekly spending challenges',
                    value: showChallenges,
                    onChanged: (v) {
                      setState(() => showChallenges = v);
                      _saveAndRefresh('show_challenges', v);
                    },
                  ),
                ]),

                // ── ANALYTICS SECTIONS ────────────────────────────────────────
                _sectionLabel('ANALYTICS — SHOW / HIDE SECTIONS'),
                _sectionHint(
                    'Pie chart, 50/30/20 tracker, and Want/Need breakdown are always shown.'),
                _sectionCard([
                  _tile(
                    icon: Icons.account_balance_outlined,
                    title: 'Debt-to-Income (DTI) ratio',
                    subtitle: 'DTI card in Analytics',
                    value: showDTI,
                    onChanged: (v) {
                      setState(() => showDTI = v);
                      _saveAndRefresh('show_dti', v);
                    },
                  ),
                  _tile(
                    icon: Icons.health_and_safety_outlined,
                    title: 'Emergency fund calculator',
                    subtitle: 'How many months of expenses you have saved',
                    value: showEmergencyFund,
                    onChanged: (v) {
                      setState(() => showEmergencyFund = v);
                      _saveAndRefresh('show_emergency_fund', v);
                    },
                  ),
                  _tile(
                    icon: Icons.flag_outlined,
                    title: 'Financial milestones',
                    subtitle: 'Timeline of your financial achievements',
                    value: showMilestones,
                    onChanged: (v) {
                      setState(() => showMilestones = v);
                      _saveAndRefresh('show_milestones', v);
                    },
                  ),
                  _tile(
                    icon: Icons.currency_exchange_outlined,
                    title: 'Market insights (exchange rates)',
                    subtitle: 'Live PHP exchange rates card in Analytics',
                    value: showMarketInsights,
                    onChanged: (v) {
                      setState(() => showMarketInsights = v);
                      _saveAndRefresh('show_market_insights', v);
                    },
                  ),
                ]),

                const SizedBox(height: 20),
              ],
            ),
    );
  }
}

// ── _PresetValues — visibility matrix for each experience level ─────────────

class _PresetValues {
  final bool subscriptions, quickLog, badges, moodHome, forecast, prediction;
  final bool paydayCountdown, monthlyRecap, challenges, safeToSpend;
  final bool dti, emergencyFund, milestones, marketInsights;

  const _PresetValues({
    required this.subscriptions,
    required this.quickLog,
    required this.badges,
    required this.moodHome,
    required this.forecast,
    required this.prediction,
    required this.paydayCountdown,
    required this.monthlyRecap,
    required this.challenges,
    required this.safeToSpend,
    required this.dti,
    required this.emergencyFund,
    required this.milestones,
    required this.marketInsights,
  });

  // 🪶 Lite — essentials only: balance card + FHS + recent expenses
  factory _PresetValues.lite() => const _PresetValues(
        subscriptions: false,
        quickLog: false,
        badges: false,
        moodHome: false,
        forecast: false,
        prediction: false,
        paydayCountdown: false,
        monthlyRecap: false,
        challenges: false,
        safeToSpend: false,
        dti: false,
        emergencyFund: false,
        milestones: false,
        marketInsights: false,
      );

  // 😊 Casual — for regular trackers: adds quick log, badges, challenges
  factory _PresetValues.casual() => const _PresetValues(
        subscriptions: false,
        quickLog: true,
        badges: true,
        moodHome: false,
        forecast: false,
        prediction: false,
        paydayCountdown: false,
        monthlyRecap: true,
        challenges: true,
        safeToSpend: false,
        dti: false,
        emergencyFund: false,
        milestones: false,
        marketInsights: false,
      );

  // ⚖️ Normal — balanced, recommended: adds wallet, payday, safe-to-spend, subscriptions
  factory _PresetValues.normal() => const _PresetValues(
        subscriptions: true,
        quickLog: true,
        badges: true,
        moodHome: true,
        forecast: true,
        prediction: false,
        paydayCountdown: true,
        monthlyRecap: true,
        challenges: true,
        safeToSpend: true,
        dti: true,
        emergencyFund: true,
        milestones: false,
        marketInsights: false,
      );

  // 🚀 Pro — everything visible
  factory _PresetValues.pro() => const _PresetValues(
        subscriptions: true,
        quickLog: true,
        badges: true,
        moodHome: true,
        forecast: true,
        prediction: true,
        paydayCountdown: true,
        monthlyRecap: true,
        challenges: true,
        safeToSpend: true,
        dti: true,
        emergencyFund: true,
        milestones: true,
        marketInsights: true,
      );
}

// ── _ExperiencePresetSelector widget ────────────────────────────────────────

class _ExperiencePresetSelector extends StatelessWidget {
  final String activePreset;
  final void Function(String) onSelect;

  const _ExperiencePresetSelector({
    required this.activePreset,
    required this.onSelect,
  });

  static const _presets = [
    ('lite', '🪶', 'Lite', 'Just the essentials'),
    ('casual', '😊', 'Casual', 'Regular tracker'),
    ('normal', '⚖️', 'Normal', 'Balanced — recommended'),
    ('pro', '🚀', 'Pro', 'Everything on'),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 4-button grid
        Row(
          children: _presets.map((p) {
            final isActive = activePreset == p.$1;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: GestureDetector(
                  onTap: () => onSelect(p.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding:
                        const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? cs.primary.withValues(alpha: 0.10)
                          : cs.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive
                            ? cs.primary.withValues(alpha: 0.45)
                            : cs.outline.withValues(alpha: 0.15),
                        width: isActive ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(p.$2, style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 4),
                        Text(
                          p.$3,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isActive ? cs.primary : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 8),
        // Subtitle for active preset
        Text(
          () {
            final match =
                _presets.where((p) => p.$1 == activePreset).firstOrNull;
            if (match != null) return match.$4;
            return 'Custom — some toggles changed individually';
          }(),
          style: TextStyle(
              fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5)),
        ),
        const SizedBox(height: 4),
        Text(
          'Presets adjust which cards are shown. You can still customize individually below.',
          style: TextStyle(
              fontSize: 10, color: cs.onSurface.withValues(alpha: 0.4)),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
