import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'db_service.dart';
import 'score_service.dart';
import 'app_config.dart';

/// Current app version — keep in sync with pubspec.yaml.
const kAppVersion = '2.9.45';

/// Debug signing certificate SHA-1 fingerprint for this machine.
/// Add this to Firebase Console → Project Settings → Android → SHA certificate fingerprints
/// if Google Sign-In stops working on debug builds.
const _kDebugSha1 =
    '4D:1C:67:D4:78:7A:30:20:6D:5B:D5:97:6E:F6:EF:87:3D:91:12:E8';

/// Exports a full debug log — chat history, expenses, budgets, settings —
/// as a plain text file for easy debugging and QA reporting.
class DebugService {
  static Future<void> exportDebugLog() async {
    final now = DateTime.now();
    final fmt = DateFormat('yyyy-MM-dd HH:mm:ss');
    final fileFmt = DateFormat('yyyyMMdd_HHmmss');
    final buffer = StringBuffer();

    buffer.writeln('═══════════════════════════════════════════════');
    buffer.writeln('  SMART SPEND — DEBUG LOG');
    buffer.writeln('  Version: $kAppVersion');
    buffer.writeln('  Generated: ${fmt.format(now)}');
    buffer.writeln('═══════════════════════════════════════════════');
    buffer.writeln();

    // ── SETTINGS ──────────────────────────────────────────
    buffer.writeln('── SETTINGS ──────────────────────────────────');
    final db = await DBService.getDB();
    final settings = await db.query('settings');
    for (final s in settings) {
      final key = s['key'] as String;
      // Mask sensitive values
      final value = key.contains('key') || key.contains('token')
          ? '***'
          : s['value'] as String? ?? '';
      buffer.writeln('  $key = $value');
    }
    buffer.writeln();

    // ── AI MODEL STATE ─────────────────────────────────────
    buffer.writeln('── AI MODEL STATE ──────────────────────────────');
    buffer.writeln('  active_model_id = ${AppConfig.activeModelId}');
    buffer.writeln('  active_model_label = ${AppConfig.activeModelLabel}');
    buffer.writeln('  groq_limit_reached = ${AppConfig.groqLimitReached}');
    // Dump the rolling request trace with one entry per line for readability
    final traceRaw = await DBService.getSetting('ai_request_trace') ?? '';
    if (traceRaw.isNotEmpty) {
      buffer.writeln('  ai_request_trace:');
      for (final line in traceRaw.split('\n').where((l) => l.isNotEmpty)) {
        buffer.writeln('    $line');
      }
    }
    final lastFail = await DBService.getSetting('last_silent_action_fail');
    if (lastFail != null) {
      buffer.writeln('  last_silent_action_fail = $lastFail');
    }
    final lastUngrounded = await DBService.getSetting('last_ungrounded_advice');
    if (lastUngrounded != null) {
      buffer.writeln('  last_ungrounded_advice = $lastUngrounded');
    }
    buffer.writeln();

    // ── USER PROFILE ──────────────────────────────────────
    buffer.writeln('── USER PROFILE ────────────────────────────────');
    try {
      final profiles = await db.query('user_profile', limit: 1);
      if (profiles.isNotEmpty) {
        final p = profiles.first;
        buffer.writeln(
            '  uid = ${(p['uid'] as String?)?.substring(0, 8) ?? '?'}...');
        buffer.writeln(
            '  name = ${p['first_name'] ?? ''} ${p['last_name'] ?? ''}'.trim());
        buffer.writeln('  email = ${p['email'] ?? '(none)'}');
      } else {
        buffer.writeln('  (no profile — not signed in)');
      }
    } catch (_) {
      buffer.writeln('  (unavailable)');
    }
    buffer.writeln();

    // ── EXPENSES ──────────────────────────────────────────
    final expenses = await DBService.getExpenses();
    buffer.writeln('── EXPENSES (${expenses.length} total) ────────');
    for (final e in expenses) {
      buffer.writeln(
          '  [${e.date}] ${e.itemName} | ${e.category} | ₱${e.amount} | ${e.paymentMethod ?? 'Cash'}'
          ' | ${(e.isWant == true) ? 'Want' : 'Need'}'
          '${e.shopName != null ? ' @ ${e.shopName}' : ''}'
          '${e.aiGenerated ? ' [AI]' : ''}'
          '${e.notes != null ? ' — ${e.notes}' : ''}'
          '${e.tags != null && e.tags!.isNotEmpty ? ' [tags:${e.tags}]' : ''}');
    }
    buffer.writeln();

    // ── BUDGETS ───────────────────────────────────────────
    final budgets = await DBService.getBudgets();
    buffer.writeln('── BUDGETS (${budgets.length}) ─────────────────');
    for (final b in budgets) {
      buffer.writeln('  ${b.category}: ₱${b.amount}');
    }
    buffer.writeln();

    // ── INCOME ────────────────────────────────────────────
    final income = await DBService.getIncome();
    buffer.writeln('── INCOME ENTRIES (${income.length}) ───────────');
    for (final i in income) {
      buffer.writeln(
          '  [${i['date']}] ${i['title']} | ${i['category']} | ₱${i['amount']}');
    }
    buffer.writeln();

    // ── WALLETS ───────────────────────────────────────────
    final wallets = await DBService.getWallets();
    final walletTotal =
        wallets.fold<double>(0, (s, w) => s + (w['balance'] as num));
    buffer.writeln('── WALLETS (${wallets.length}) ──────────────────');
    for (final w in wallets) {
      buffer.writeln(
          '  ${w['icon'] ?? '💵'} ${w['name']} | ₱${(w['balance'] as num).toStringAsFixed(2)}');
    }
    if (wallets.isNotEmpty) {
      buffer.writeln('  TOTAL LIQUID: ₱${walletTotal.toStringAsFixed(2)}');
    }
    buffer.writeln();

    // ── SAVINGS GOALS ─────────────────────────────────────
    final goals = await DBService.getGoals();
    buffer.writeln('── SAVINGS GOALS (${goals.length}) ─────────────');
    for (final g in goals) {
      final pct = (g['target_amount'] as num) > 0
          ? ((g['current_amount'] as num) / (g['target_amount'] as num) * 100)
              .toStringAsFixed(1)
          : '0.0';
      buffer.writeln(
          '  ${g['name']}: ₱${g['current_amount']}/${g['target_amount']} ($pct%)'
          '${g['deadline'] != null ? ' (due ${g['deadline']})' : ''}');
    }
    buffer.writeln();

    // ── DEBTS ─────────────────────────────────────────────
    final debts = await DBService.getDebts();
    buffer.writeln('── DEBTS & LENDING (${debts.length}) ───────────');
    for (final d in debts) {
      final remaining = (d['amount'] as num) - (d['paid_amount'] as num);
      buffer.writeln(
          '  [${d['type']}] ${d['title']} — ${d['person']} | ₱$remaining remaining'
          '${d['due_date'] != null ? ' (due ${d['due_date']})' : ''}');
    }
    buffer.writeln();

    // ── RECURRING ─────────────────────────────────────────
    final recurring = await DBService.getRecurring();
    buffer.writeln('── RECURRING (${recurring.length}) ─────────────');
    for (final r in recurring) {
      buffer.writeln(
          '  ${r['title']} | ${r['category']} | ₱${r['amount']} | ${r['frequency']}'
          ' | next: ${r['next_date']}'
          ' | ${(r['is_expense'] as int) == 1 ? 'expense' : 'income'}');
    }
    buffer.writeln();

    // ── RECURRING CANDIDATES (auto-detected patterns) ─────
    try {
      final candidates =
          await db.query('recurring_candidates', orderBy: 'avg_amount DESC');
      buffer.writeln('── RECURRING CANDIDATES (${candidates.length}) ──');
      for (final c in candidates) {
        final dismissed = (c['dismissed'] as int? ?? 0) == 1;
        buffer.writeln(
            '  ${dismissed ? '[dismissed] ' : ''}${c['description']} | ${c['category']}'
            ' | ~₱${(c['avg_amount'] as num).toStringAsFixed(0)} ${c['frequency']}'
            ' | last: ${c['last_seen']}');
      }
    } catch (_) {
      buffer.writeln('── RECURRING CANDIDATES ── (unavailable)');
    }
    buffer.writeln();

    // ── INSURANCE & CONTRIBUTIONS ─────────────────────────
    final policies = await DBService.getInsurancePolicies();
    buffer.writeln('── INSURANCE & CONTRIBUTIONS (${policies.length}) ──');
    for (final p in policies) {
      buffer.writeln(
          '  ${p['name']} | ${p['type']} | ₱${p['premium_amount']}/${p['frequency']}'
          '${p['next_due_date'] != null ? ' | next: ${p['next_due_date']}' : ''}');
    }
    buffer.writeln();

    // ── PALUWAGAN ─────────────────────────────────────────
    try {
      final paluwagan = await db.query('paluwagan');
      if (paluwagan.isNotEmpty) {
        buffer.writeln('── PALUWAGAN (${paluwagan.length}) ──────────────');
        for (final pal in paluwagan) {
          buffer.writeln(
              '  ${pal['name']} | ₱${pal['contribution_amount']}/${pal['frequency']}'
              ' | members: ${pal['member_count']}'
              ' | status: ${pal['status'] ?? 'active'}');
        }
        buffer.writeln();
      }
    } catch (_) {}

    // ── CUSTOM CATEGORIES ─────────────────────────────────
    final customCats = await DBService.getCustomCategories();
    buffer.writeln('── CUSTOM CATEGORIES (${customCats.length}) ────────');
    for (final c in customCats) {
      buffer.writeln('  ${c['name']}');
    }
    buffer.writeln();

    // ── CATEGORY RULES ────────────────────────────────────
    final rules = await DBService.getCategoryRules();
    buffer.writeln('── AUTO-CATEGORIZATION RULES (${rules.length}) ──');
    for (final r in rules) {
      buffer.writeln('  "${r['keyword']}" → ${r['category']}');
    }
    buffer.writeln();

    // ── MOOD LOG ──────────────────────────────────────────
    final moodHistory = await DBService.getMoodHistory(days: 30);
    buffer.writeln(
        '── MOOD LOG (last 30 days, ${moodHistory.length} entries) ──');
    for (final m in moodHistory) {
      final emojis = ['😞', '😕', '😐', '🙂', '😄'];
      final score = m['mood_score'] as int;
      final emoji = score >= 1 && score <= 5 ? emojis[score - 1] : '?';
      final note = m['note'] as String?;
      buffer.writeln(
          '  ${m['date']}: $emoji ($score/5)${note != null && note.isNotEmpty ? ' — "$note"' : ''}');
    }
    buffer.writeln();

    // ── SCORE HISTORY ─────────────────────────────────────
    final scores = await DBService.getScoreHistory(days: 30);
    buffer.writeln('── HEALTH SCORE HISTORY (last 30 days) ────────');
    for (final s in scores) {
      buffer.writeln('  ${s['date']}: ${s['score']}/100');
    }
    buffer.writeln();

    // ── CHAT HISTORY ──────────────────────────────────────
    final chat = await DBService.getChatHistory(limit: 200);
    buffer.writeln('── AI CHAT HISTORY (${chat.length} messages) ───');
    int errorCount = 0;
    for (final msg in chat) {
      final role = (msg['role'] as String).toUpperCase().padRight(5);
      final ts = (msg['timestamp'] as String).substring(0, 19);
      final rawText = msg['message'] as String;
      // Decode persisted error metadata prefix for display
      String displayText = rawText;
      String metaSuffix = '';
      if (rawText.startsWith('||ERR:')) {
        try {
          final sepIdx = rawText.indexOf('||', 6);
          if (sepIdx != -1) {
            displayText = rawText.substring(sepIdx + 2);
            metaSuffix = ' [error metadata persisted]';
          }
        } catch (_) {}
      }
      final text = displayText.length > 500
          ? '${displayText.replaceAll('\n', ' ').substring(0, 500)}... [truncated]'
          : displayText.replaceAll('\n', ' ');
      final isError = displayText.contains('⏱️') ||
          displayText.contains("couldn't respond") ||
          displayText.contains('timed out') ||
          displayText.contains('Daily AI limit') ||
          displayText.contains('authentication failed');
      if (isError) errorCount++;
      final prefix = isError ? '[ERROR] ' : '';
      buffer.writeln('  [$ts] $role: $prefix$text$metaSuffix');
    }
    // Action count from ai_request_trace (authoritative — actions stripped before save)
    int actionCount = 0;
    try {
      final trace = await DBService.getSetting('ai_request_trace') ?? '';
      for (final line in trace.split('\n').where((l) => l.isNotEmpty)) {
        final m = RegExp(r'actions=(\d+)').firstMatch(line);
        if (m != null) actionCount += int.tryParse(m.group(1) ?? '0') ?? 0;
      }
    } catch (_) {}
    buffer.writeln(
        '  SUMMARY: $errorCount errors, $actionCount actions executed');
    buffer.writeln();

    // ── CONVERSATION SUMMARIES ────────────────────────────
    try {
      final summaries = await db.query('conversation_summaries',
          orderBy: 'id DESC', limit: 3);
      if (summaries.isNotEmpty) {
        buffer.writeln(
            '── AI CONVERSATION SUMMARIES (${summaries.length} stored) ──');
        for (final s in summaries) {
          final ts = (s['created_at'] as String? ?? '').substring(0, 16);
          final msgCount = s['message_count_at_summary'] ?? '?';
          final text = (s['summary'] as String)
              .replaceAll('\n', ' ')
              .substring(0, ((s['summary'] as String).length).clamp(0, 300));
          buffer.writeln('  [$ts | at msg #$msgCount] $text');
        }
        buffer.writeln();
      }
    } catch (_) {}

    // ── PAYMENT PLANS ─────────────────────────────────────
    List<Map<String, dynamic>> plans = [];
    try {
      plans = await db.query('installment_plans', orderBy: 'created_at DESC');
    } catch (_) {}
    buffer.writeln('── PAYMENT PLANS (${plans.length}) ─────────────');
    for (final p in plans) {
      final paid = p['months_paid'] as int? ?? 0;
      final total = p['months_total'] as int? ?? 0;
      final monthly = (p['monthly_payment'] as num?)?.toDouble() ?? 0;
      final remaining = (total - paid) * monthly;
      buffer.writeln(
          '  ${p['title']}${p['provider'] != null ? ' (${p['provider']})' : ''}'
          ' | ₱${monthly.toStringAsFixed(0)}/mo | $paid/$total months'
          ' | ₱${remaining.toStringAsFixed(0)} remaining'
          ' | due day: ${p['due_day']}');
    }
    buffer.writeln();

    // ── INSTALLMENTS (legacy) ─────────────────────────────
    List<Map<String, dynamic>> installments = [];
    try {
      installments = await db.query('installments');
    } catch (_) {}
    if (installments.isNotEmpty) {
      buffer.writeln('── INSTALLMENTS LEGACY (${installments.length}) ──');
      for (final i in installments) {
        buffer.writeln('  ${i['name']} | ₱${i['monthly_payment']}/mo'
            ' | ${i['months_paid']}/${i['months_total']} months');
      }
      buffer.writeln();
    }

    // ── NOTIFICATION & SYSTEM STATE ───────────────────────
    // Shows all diagnostic/operational settings not already in the main SETTINGS
    // block above, organized for easier reading.
    buffer.writeln('── NOTIFICATION & SYSTEM STATE ─────────────────');
    final systemKeys = [
      // Notification gates
      'last_weekly_notif',
      'last_anomaly_check',
      'last_velocity_check',
      'last_want_alert',
      'last_daily_briefing',
      // FHS / decay
      'warning_decay_days',
      'last_decay_check',
      'prev_fhs_score',
      // Level-up badges
      'level_up_60', 'level_up_70', 'level_up_80', 'level_up_90',
      // Gap awareness
      'gap_penalty_days',
      'gap_clean_days',
      'last_gap_check_date',
      // Startup alerts
      'last_startup_alert_date',
      'income_sanity_check',
      'balance_discrepancy_check',
      // Spending limits
      'limit_daily', 'limit_weekly', 'limit_monthly', 'limit_yearly',
      // App features
      'wallet_auto_deduct',
      'round_up_savings',
      'impulse_pause_enabled',
      'compact_mode',
      'balance_mode',
      'mood_checkin_enabled',
      'income_wallet_mode',
      'app_lock_enabled',
      // AI insight cache
      'cached_ai_insight_date',
      // Rollover
      'rollover_applied_month',
      // Recurring detection
      'last_recurring_check',
      // Migration flags
      'is_want_migrated',
      'item_name_sanitized',
      'education_need_fixed',
      'installments_migrated',
      'dup_cleanup_v2938',
    ];
    for (final key in systemKeys) {
      final val = await DBService.getSetting(key);
      if (val != null) buffer.writeln('  $key = $val');
    }
    buffer.writeln();

    // ── FHS SCORE BREAKDOWN (current month) ───────────────
    try {
      final currentMonth = DateFormat('yyyy-MM').format(now);
      final thisMonthExp = expenses
          .where((e) => e.date.startsWith(currentMonth))
          .map((e) =>
              {'amount': e.amount, 'category': e.category, 'date': e.date})
          .toList();
      final monthlyIncome0 = await DBService.getMonthlyIncome();
      final iwMode = await DBService.getIncomeWalletMode();
      final tightest = await DBService.getTightestLimit();
      final spendLimit = tightest['limit'] as double;
      final spendPeriod = tightest['period'] as String;
      final breakdown = ScoreService.getBreakdown(
        thisMonthExp,
        budgets: budgets,
        monthlyIncome: iwMode ? monthlyIncome0 : 0,
        lightweightMode: !iwMode,
        spendingLimit: spendLimit,
        spendingLimitPeriod: spendPeriod,
      );
      buffer.writeln('── FHS SCORE BREAKDOWN (this month) ───────────');
      for (final item in breakdown) {
        buffer.writeln(
            '  ${item['component']}: ${item['points']} pts — ${item['reason']}');
      }
      final total = breakdown.fold<int>(0, (s, i) => s + (i['points'] as int));
      buffer.writeln('  TOTAL: $total/100');
    } catch (_) {}
    buffer.writeln();

    // ── AI CONTEXT SUMMARY ────────────────────────────────
    buffer.writeln('── AI CONTEXT SUMMARY ──────────────────────────');
    final monthlyIncome = await DBService.getMonthlyIncome();
    final accountType = await DBService.getSetting('account_type') ?? 'unknown';
    final quizChallenge =
        await DBService.getSetting('quiz_challenge') ?? 'none';
    final currentMonth2 = DateFormat('yyyy-MM').format(now);
    final thisMonthTotal = expenses
        .where((e) => e.date.startsWith(currentMonth2))
        .fold<double>(0, (s, e) => s + e.amount);
    final wantTotal = expenses
        .where((e) => e.date.startsWith(currentMonth2) && e.isWant == true)
        .fold<double>(0, (s, e) => s + e.amount);
    final needTotal = thisMonthTotal - wantTotal;
    buffer.writeln('  Account type: $accountType');
    buffer.writeln('  Monthly income: ₱${monthlyIncome.toStringAsFixed(0)}');
    buffer.writeln('  This month spent: ₱${thisMonthTotal.toStringAsFixed(0)}');
    buffer.writeln(
        '  Wants: ₱${wantTotal.toStringAsFixed(0)} | Needs: ₱${needTotal.toStringAsFixed(0)}');
    buffer.writeln('  Quiz challenge: $quizChallenge');
    buffer.writeln(
        '  Goals: ${goals.length} | Debts: ${debts.length} | Recurring: ${recurring.length}');
    buffer.writeln();

    // ── ANALYTICS DATA SNAPSHOT ───────────────────────────
    buffer.writeln('── ANALYTICS DATA SNAPSHOT ─────────────────────');
    final currentMonth3 = DateFormat('yyyy-MM').format(now);
    final thisMonthExpenses =
        expenses.where((e) => e.date.startsWith(currentMonth3)).toList();
    final lastMonthKey = now.month == 1
        ? '${now.year - 1}-12'
        : '${now.year}-${(now.month - 1).toString().padLeft(2, '0')}';
    final lastMonthExpenses =
        expenses.where((e) => e.date.startsWith(lastMonthKey)).toList();
    final thisMonthByCategory = <String, double>{};
    for (final e in thisMonthExpenses) {
      thisMonthByCategory[e.category] =
          (thisMonthByCategory[e.category] ?? 0) + e.amount;
    }
    final allTimeTotal = expenses.fold<double>(0, (s, e) => s + e.amount);
    final allMonthlyTotals = <String, double>{};
    for (final e in expenses) {
      try {
        final d = DateTime.parse(e.date);
        final key = '${d.year}-${d.month.toString().padLeft(2, '0')}';
        allMonthlyTotals[key] = (allMonthlyTotals[key] ?? 0) + e.amount;
      } catch (_) {}
    }
    buffer.writeln(
        '  All-time total (${expenses.length} expenses): ₱${allTimeTotal.toStringAsFixed(2)}');
    buffer.writeln('  Per-month breakdown (authoritative — what AI uses):');
    for (final entry in (allMonthlyTotals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key)))) {
      buffer.writeln('    ${entry.key}: ₱${entry.value.toStringAsFixed(2)}');
    }
    buffer.writeln(
        '  This month ($currentMonth3): ${thisMonthExpenses.length} expenses, ₱${thisMonthTotal.toStringAsFixed(0)} total');
    buffer.writeln(
        '  Last month ($lastMonthKey): ${lastMonthExpenses.length} expenses, ₱${lastMonthExpenses.fold<double>(0, (s, e) => s + e.amount).toStringAsFixed(0)} total');
    buffer.writeln('  This month by category:');
    for (final entry in (thisMonthByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)))) {
      buffer.writeln('    ${entry.key}: ₱${entry.value.toStringAsFixed(0)}');
    }
    const needsCategories = {
      'Food',
      'Transportation',
      'Bills',
      'Health',
      'Education'
    };
    double needs5020 = 0, wants5020 = 0;
    for (final e in thisMonthExpenses) {
      if (needsCategories.contains(e.category)) {
        needs5020 += e.amount;
      } else if (e.category != 'Others') {
        wants5020 += e.amount;
      }
    }
    final savings5020 =
        (monthlyIncome - thisMonthTotal).clamp(0.0, double.infinity);
    buffer.writeln(
        '  50/30/20 (this month): Needs ₱${needs5020.toStringAsFixed(0)} | Wants ₱${wants5020.toStringAsFixed(0)} | Savings ₱${savings5020.toStringAsFixed(0)}');
    buffer.writeln(
        '  Income: ₱${monthlyIncome.toStringAsFixed(0)} | Remaining: ₱${(monthlyIncome - thisMonthTotal).toStringAsFixed(0)}');
    buffer.writeln();

    // ── SCAN HISTORY ──────────────────────────────────────
    final scans = await DBService.getScanHistory(limit: 20);
    buffer.writeln('── SCAN HISTORY (last 20) ──────────────────────');
    for (final s in scans) {
      buffer.writeln(
          '  [${(s['scanned_at'] as String).substring(0, 19)}] ${s['barcode']}');
    }
    buffer.writeln();

    buffer.writeln('═══════════════════════════════════════════════');
    buffer.writeln('  BUILD INFO');
    buffer.writeln('═══════════════════════════════════════════════');
    buffer.writeln('  Debug SHA-1: $_kDebugSha1');
    buffer.writeln(
        '  If Google Sign-In fails: add this SHA-1 to Firebase Console');
    buffer.writeln(
        '  Firebase: Project Settings → Your Apps → Android → Add fingerprint');
    buffer.writeln();
    buffer.writeln('═══════════════════════════════════════════════');
    buffer.writeln('  END OF DEBUG LOG');
    buffer.writeln('═══════════════════════════════════════════════');

    // Write to temp file and share
    final dir = await getTemporaryDirectory();
    final fileName = 'smartspend_debug_${fileFmt.format(now)}.txt';
    final file = File('${dir.path}/$fileName');
    await file.writeAsString(buffer.toString());

    await Share.shareXFiles(
      [XFile(file.path, mimeType: 'text/plain')],
      subject: 'Smart Spend Debug Log — ${DateFormat('MMM d, y').format(now)}',
    );
  }
}
