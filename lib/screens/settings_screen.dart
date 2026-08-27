import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../services/app_config.dart';
import '../services/event_bus.dart';
import '../main.dart';

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
  bool moodEnabled = true;
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

  // ── Home screen sections ────────────────────────────────────────────────────
  bool showSubscriptions = true;
  bool showQuickLog = true;
  bool showBadges = true;
  bool showMoodHome = true;
  bool showForecast = true;
  bool showPrediction = true;

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
      !showDTI &&
      !showEmergencyFund &&
      !showMilestones &&
      !showMarketInsights;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    autoDeduct = (await DBService.getSetting('wallet_auto_deduct')) != 'false';
    moodEnabled =
        (await DBService.getSetting('mood_checkin_enabled')) != 'false';
    impulseEnabled =
        (await DBService.getSetting('impulse_pause_enabled')) != 'false';
    budgetAlerts =
        (await DBService.getSetting('budget_alerts_enabled')) != 'false';
    balanceMode = (await DBService.getSetting('balance_mode')) == 'true';
    roundUpSavings =
        (await DBService.getSetting('round_up_savings')) != 'false';
    compactMode = (await DBService.getSetting('compact_mode')) == 'true';
    incomeWalletMode = await DBService.getIncomeWalletMode();
    anomalyEnabled =
        (await DBService.getSetting('anomaly_detection_enabled')) != 'false';
    showSubscriptions =
        (await DBService.getSetting('show_subscriptions')) != 'false';
    showQuickLog = (await DBService.getSetting('show_quick_log')) != 'false';
    showBadges = (await DBService.getSetting('show_badges')) != 'false';
    showMoodHome = (await DBService.getSetting('show_mood_home')) != 'false';
    showForecast = (await DBService.getSetting('show_forecast')) != 'false';
    showPrediction = (await DBService.getSetting('show_prediction')) != 'false';
    showDTI = (await DBService.getSetting('show_dti')) != 'false';
    showEmergencyFund =
        (await DBService.getSetting('show_emergency_fund')) != 'false';
    showMilestones = (await DBService.getSetting('show_milestones')) != 'false';
    showMarketInsights =
        (await DBService.getSetting('show_market_insights')) != 'false';
    if (mounted) setState(() => _loading = false);
  }

  void _applyLiteMode(bool on) {
    setState(() {
      showSubscriptions = !on;
      showQuickLog = !on;
      showBadges = !on;
      showMoodHome = !on;
      showForecast = !on;
      showPrediction = !on;
      showDTI = !on;
      showEmergencyFund = !on;
      showMilestones = !on;
      showMarketInsights = !on;
    });
    DBService.setSetting('show_subscriptions', on ? 'false' : 'true');
    DBService.setSetting('show_quick_log', on ? 'false' : 'true');
    DBService.setSetting('show_badges', on ? 'false' : 'true');
    DBService.setSetting('show_mood_home', on ? 'false' : 'true');
    DBService.setSetting('show_forecast', on ? 'false' : 'true');
    DBService.setSetting('show_prediction', on ? 'false' : 'true');
    DBService.setSetting('show_dti', on ? 'false' : 'true');
    DBService.setSetting('show_emergency_fund', on ? 'false' : 'true');
    DBService.setSetting('show_milestones', on ? 'false' : 'true');
    DBService.setSetting('show_market_insights', on ? 'false' : 'true');
    fireEvent(AppEvent.incomeChanged);
  }

  void _save(String key, bool value) {
    DBService.setSetting(key, value ? 'true' : 'false');
  }

  void _saveAndRefresh(String key, bool value) {
    _save(key, value);
    fireEvent(AppEvent.incomeChanged);
  }

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(top: 20, bottom: 8),
        child: Text(text,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.grey[500],
                letterSpacing: 0.6)),
      );

  Widget _sectionHint(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child:
            Text(text, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
      );

  Widget _tile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w500)),
                Text(subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
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
                // ── LITE MODE ───────────────────────────────────────────────
                _sectionLabel('QUICK PRESETS'),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: liteMode
                        ? theme.colorScheme.primary.withValues(alpha: 0.08)
                        : Colors.grey.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: liteMode
                          ? theme.colorScheme.primary.withValues(alpha: 0.3)
                          : Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(children: [
                    Icon(Icons.view_compact_outlined,
                        size: 22,
                        color: liteMode
                            ? theme.colorScheme.primary
                            : Colors.grey[600]),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Lite Mode',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color:
                                  liteMode ? theme.colorScheme.primary : null),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          liteMode
                              ? 'ON — only core cards visible. Tap to restore all.'
                              : 'Hides all optional cards in one tap — clean, simple view.',
                          style:
                              TextStyle(fontSize: 11, color: Colors.grey[500]),
                        ),
                      ],
                    )),
                    Switch(
                      value: liteMode,
                      onChanged: _applyLiteMode,
                      activeThumbColor: theme.colorScheme.primary,
                    ),
                  ]),
                ),

                // ── BEHAVIOR ────────────────────────────────────────────────
                _sectionLabel('BEHAVIOR'),
                _tile(
                  icon: Icons.account_balance_wallet_outlined,
                  title: 'Auto-deduct wallets',
                  subtitle: 'Deduct from Cash/GCash/Maya when logging expenses',
                  value: autoDeduct,
                  onChanged: (v) {
                    setState(() => autoDeduct = v);
                    _save('wallet_auto_deduct', v);
                  },
                ),
                _tile(
                  icon: Icons.emoji_emotions_outlined,
                  title: 'Daily mood check-in',
                  subtitle: 'Show mood prompt each day',
                  value: moodEnabled,
                  onChanged: (v) {
                    setState(() => moodEnabled = v);
                    _save('mood_checkin_enabled', v);
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

                // ── DISPLAY ─────────────────────────────────────────────────
                _sectionLabel('DISPLAY'),
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
                _tile(
                  icon: Icons.density_medium_outlined,
                  title: 'Compact mode',
                  subtitle: 'Reduce spacing and list density',
                  value: compactMode,
                  onChanged: (v) {
                    setState(() => compactMode = v);
                    themeService.setCompactMode(v);
                    _saveAndRefresh('compact_mode', v);
                  },
                ),

                // ── TRACKING MODE ────────────────────────────────────────────
                _sectionLabel('TRACKING MODE'),
                _sectionHint(
                    'Controls how your Financial Health Score is calculated.'),
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
                  },
                ),

                // ── NOTIFICATIONS ────────────────────────────────────────────
                _sectionLabel('NOTIFICATIONS'),
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

                // ── AI MODEL ─────────────────────────────────────────────────
                _sectionLabel('AI MODEL'),
                _sectionHint(
                    'Switch the AI model. Auto-fallback still applies when limits are reached.'),
                ...AppConfig.availableModels.map((m) {
                  final isActive = AppConfig.activeModelId == m.$1;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: InkWell(
                      onTap: () {
                        setState(() {});
                        AppConfig.setModel(m.$1);
                        DBService.setSetting('preferred_model', m.$1);
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: isActive
                              ? theme.colorScheme.primary.withValues(alpha: 0.1)
                              : Colors.grey.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isActive
                                ? theme.colorScheme.primary
                                    .withValues(alpha: 0.4)
                                : Colors.grey.withValues(alpha: 0.2),
                            width: isActive ? 1.5 : 1,
                          ),
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
                          const SizedBox(width: 10),
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

                // ── HOME SCREEN SECTIONS ──────────────────────────────────────
                _sectionLabel('HOME SCREEN — SHOW / HIDE SECTIONS'),
                _sectionHint(
                    'Toggle optional cards. Core cards (spending summary, FHS score, wallets, budgets) are always visible.'),
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
                  title: 'Mood check-in (home)',
                  subtitle: 'Daily mood prompt on the home screen',
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

                // ── ANALYTICS SECTIONS ────────────────────────────────────────
                _sectionLabel('ANALYTICS — SHOW / HIDE SECTIONS'),
                _sectionHint(
                    'Pie chart, 50/30/20 tracker, and Want/Need breakdown are always shown.'),
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

                const SizedBox(height: 20),
              ],
            ),
    );
  }
}
