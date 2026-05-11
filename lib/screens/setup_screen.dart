import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/db_service.dart';
import '../services/currency_service.dart';
import 'home_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _step = 0;

  // Step 1 — Account type
  String _accountType = 'employed';

  // Step 2 — Income type
  String _incomeFrequency = 'monthly';
  final _incomeCtrl = TextEditingController();

  // Step 3 — Currency
  String _currency = 'PHP';

  // Step 4 — Financial Quiz
  String _biggestChallenge = ''; // 'overspending', 'saving', 'debt', 'tracking'
  bool _hasRegularBills = false;
  bool _wantsEmergencyFund = false;

  bool _saving = false;

  final _accountTypes = [
    ('employed', Icons.work_outline, 'Employed', 'Monthly salary or wages'),
    ('business', Icons.store_outlined, 'Business Owner', 'Business income'),
    ('freelancer', Icons.laptop_outlined, 'Freelancer', 'Project-based income'),
    ('student', Icons.school_outlined, 'Student', 'Allowance-based'),
    (
      'working_student',
      Icons.work_history_outlined,
      'Working Student',
      'Both income & allowance'
    ),
    (
      'pensioner',
      Icons.elderly_outlined,
      'Pensioner / Retiree',
      'Pension or retirement income'
    ),
    ('unemployed', Icons.person_outline, 'Unemployed', 'No regular income'),
    (
      'general',
      Icons.person_pin_outlined,
      'General / Other',
      'Any income type — full flexibility'
    ),
  ];

  bool get _isAllowanceBased => _accountType == 'student';
  bool get _hasIncome => _accountType != 'unemployed';

  List<(String, String)> get _frequencyOptions {
    if (_isAllowanceBased) {
      return [
        ('daily', 'Daily allowance'),
        ('weekly', 'Weekly allowance'),
        ('monthly', 'Monthly allowance'),
        ('manual', 'Manual — just enter my total'),
      ];
    }
    if (_accountType == 'pensioner') {
      return [
        ('monthly', 'Monthly pension'),
        ('bimonthly', 'Bi-monthly pension'),
        ('manual', 'Manual — just enter my total'),
      ];
    }
    if (_accountType == 'freelancer') {
      return [
        ('weekly', 'Weekly project pay'),
        ('bimonthly', 'Bi-monthly'),
        ('monthly', 'Monthly retainer'),
        ('manual', 'Manual — just enter my total'),
      ];
    }
    if (_accountType == 'unemployed' || _accountType == 'general') {
      return [
        ('manual', 'Manual — just enter my total'),
        ('monthly', 'Monthly'),
        ('weekly', 'Weekly'),
      ];
    }
    return [
      ('daily', 'Daily wage'),
      ('weekly', 'Weekly pay'),
      ('bimonthly', 'Bi-monthly (15th & 30th)'),
      ('monthly', 'Monthly salary'),
      ('manual', 'Manual — just enter my total'),
    ];
  }

  String get _incomeLabel {
    if (_incomeFrequency == 'manual') return 'Current Balance';
    switch (_accountType) {
      case 'student':
        return 'Allowance';
      case 'unemployed':
        return 'Budget';
      case 'pensioner':
        return 'Pension';
      case 'freelancer':
        return 'Income';
      case 'general':
        return 'Income / Budget';
      default:
        return 'Income';
    }
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      await DBService.setSetting('account_type', _accountType);
      await DBService.setSetting('income_frequency', _incomeFrequency);

      if (_hasIncome && _incomeCtrl.text.isNotEmpty) {
        final amount = double.tryParse(_incomeCtrl.text) ?? 0;
        // Convert to monthly equivalent for storage
        // 'manual' = user entered their total balance directly — store as-is
        double monthly = amount;
        if (_incomeFrequency == 'daily') monthly = amount * 22;
        if (_incomeFrequency == 'weekly') monthly = amount * 4.33;
        if (_incomeFrequency == 'bimonthly') monthly = amount * 2;
        // manual: monthly = amount (no conversion)
        await DBService.setMonthlyIncome(monthly);
      }

      await CurrencyService.setCurrency(_currency);
      await DBService.setSetting('setup_done', 'true');

      // Apply quiz answers — auto-create budgets and goals based on responses
      await _applyQuizAnswers();

      // Push all setup data to Firestore so it's available on other devices
      // immediately after setup, without waiting for the next explicit sync.
      try {
        await DBService.pushAllToCloud();
      } catch (_) {}

      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _applyQuizAnswers() async {
    final income = await DBService.getMonthlyIncome();
    final now = DateTime.now();
    final fmt = DateFormat('yyyy-MM-dd');

    // Auto-create budgets based on challenge + account type
    if (income > 0) {
      // Base budget splits by challenge
      final splits = <String, double>{};
      if (_biggestChallenge == 'overspending') {
        // Tighter budgets to control spending
        splits['Food'] = 0.25;
        splits['Transportation'] = 0.10;
        splits['Bills'] = 0.20;
        splits['Shopping'] = 0.08;
        splits['Entertainment'] = 0.05;
      } else if (_biggestChallenge == 'saving') {
        // Leave more room for savings
        splits['Food'] = 0.25;
        splits['Transportation'] = 0.10;
        splits['Bills'] = 0.20;
        splits['Shopping'] = 0.05;
        splits['Entertainment'] = 0.05;
      } else {
        // Default balanced split
        splits['Food'] = 0.30;
        splits['Transportation'] = 0.15;
        splits['Bills'] = 0.20;
        splits['Shopping'] = 0.10;
        splits['Entertainment'] = 0.08;
      }
      for (final entry in splits.entries) {
        await DBService.setBudget(entry.key, income * entry.value);
      }
    }

    // Auto-create emergency fund goal if requested
    if (_wantsEmergencyFund && income > 0) {
      final target = income * 3; // 3-month emergency fund
      await DBService.insertGoal({
        'name': 'Emergency Fund',
        'purpose': '3-month safety net',
        'target_amount': target,
        'current_amount': 0.0,
        'start_date': fmt.format(now),
        'deadline': fmt.format(now.add(const Duration(days: 365))),
        'created_at': now.toIso8601String(),
      });
    }

    // Save quiz challenge for personalization
    if (_biggestChallenge.isNotEmpty) {
      await DBService.setSetting('quiz_challenge', _biggestChallenge);
    }
  }

  @override
  void dispose() {
    _incomeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress
              Row(
                children: List.generate(
                    4,
                    (i) => Expanded(
                          child: Container(
                            height: 4,
                            margin: EdgeInsets.only(right: i < 3 ? 6 : 0),
                            decoration: BoxDecoration(
                              color: i <= _step
                                  ? cs.primary
                                  : cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        )),
              ),
              const SizedBox(height: 32),

              if (_step == 0) ..._buildStep0(cs),
              if (_step == 1) ..._buildStep1(cs),
              if (_step == 2) ..._buildStep2(cs),
              if (_step == 3) ..._buildStep3(cs),

              const Spacer(),

              Row(
                children: [
                  if (_step > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() => _step--),
                        child: const Text("Back"),
                      ),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _saving
                          ? null
                          : () {
                              if (_step < 3) {
                                setState(() => _step++);
                              } else {
                                _finish();
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: cs.primary,
                        foregroundColor: cs.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _saving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : Text(_step < 3
                              ? (_step == 1 &&
                                      _hasIncome &&
                                      _incomeCtrl.text.isEmpty
                                  ? "Skip for now"
                                  : "Continue")
                              : "Get Started"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStep0(ColorScheme cs) => [
        const Text("What best describes you?",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text("This helps us personalize your experience.",
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),
        ..._accountTypes.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => setState(() => _accountType = t.$1),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _accountType == t.$1
                        ? cs.primary.withValues(alpha: 0.1)
                        : cs.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _accountType == t.$1
                          ? cs.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(t.$2,
                          color: _accountType == t.$1
                              ? cs.primary
                              : cs.onSurface.withValues(alpha: 0.6)),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(t.$3,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text(t.$4,
                                style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        cs.onSurface.withValues(alpha: 0.6))),
                          ],
                        ),
                      ),
                      if (_accountType == t.$1)
                        Icon(Icons.check_circle, color: cs.primary),
                    ],
                  ),
                ),
              ),
            )),
      ];

  List<Widget> _buildStep1(ColorScheme cs) => [
        Text("What's your $_incomeLabel?",
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(
            "We'll use this to calculate your savings rate and financial health score.",
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 4),
        // Trust-first: make income optional — don't block users who aren't ready
        Text(
          "Optional — you can set this later from your Profile.",
          style: TextStyle(
              fontSize: 12,
              color: cs.onSurface.withValues(alpha: 0.45),
              fontStyle: FontStyle.italic),
        ),
        const SizedBox(height: 20),
        if (_hasIncome) ...[
          const Text("How often do you receive it?",
              style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 12),
          ..._frequencyOptions.map((f) => InkWell(
                onTap: () => setState(() => _incomeFrequency = f.$1),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(
                        _incomeFrequency == f.$1
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: _incomeFrequency == f.$1
                            ? cs.primary
                            : cs.onSurface.withValues(alpha: 0.4),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(f.$2),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 16),
          TextField(
            controller: _incomeCtrl,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: _incomeFrequency == 'manual'
                  ? "How much money do you have right now?"
                  : "$_incomeLabel amount (${CurrencyService.symbol})",
              prefixText: "${CurrencyService.symbol} ",
              hintText:
                  _incomeFrequency == 'manual' ? "e.g. 5000" : "e.g. 15000",
              helperText: _incomeFrequency == 'manual'
                  ? "Enter your current total — no conversion, stored as-is"
                  : null,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("📌 PH Minimum Wage Reference",
                    style:
                        TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                const SizedBox(height: 4),
                const Text("• NCR: ₱610/day (~₱13,420/mo)",
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
                const Text("• Region III: ₱500/day (~₱11,000/mo)",
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
                const Text("• Region IV-A: ₱533/day (~₱11,726/mo)",
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
                const Text("• Other regions: ₱350–₱480/day",
                    style: TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              "No problem! You can still track expenses and set budgets. "
              "You can add income later when your situation changes.",
              style: TextStyle(height: 1.5),
            ),
          ),
        ],
      ];

  List<Widget> _buildStep2(ColorScheme cs) => [
        const Text("Choose your currency",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text("You can change this anytime in settings.",
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            children: CurrencyService.supportedCurrencies.entries.map((entry) {
              final isSelected = _currency == entry.key;
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      isSelected ? cs.primary : cs.surfaceContainerHighest,
                  child: Text(
                    CurrencyService.currencySymbols[entry.key] ?? entry.key,
                    style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? cs.onPrimary : cs.onSurface),
                  ),
                ),
                title: Text(entry.key,
                    style: TextStyle(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal)),
                subtitle: Text(entry.value.split(' ').skip(1).join(' '),
                    style: const TextStyle(fontSize: 12)),
                trailing: isSelected
                    ? Icon(Icons.check_circle, color: cs.primary)
                    : null,
                onTap: () => setState(() => _currency = entry.key),
              );
            }).toList(),
          ),
        ),
      ];

  List<Widget> _buildStep3(ColorScheme cs) => [
        const Text("One last thing — tell us about yourself",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(
            "We'll personalize your budgets and set up helpful defaults.",
            style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 24),

        // Question 1 — Biggest financial challenge
        const Text("What's your biggest financial challenge?",
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
        const SizedBox(height: 12),
        ...[
          ('overspending', '💸 Overspending', 'I spend more than I should'),
          ('saving', '🎯 Saving money', 'I struggle to save consistently'),
          ('debt', '💳 Managing debt', 'I have loans or debts to pay off'),
          (
            'tracking',
            '📋 Tracking expenses',
            'I lose track of where money goes'
          ),
        ].map((opt) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: InkWell(
                onTap: () => setState(() => _biggestChallenge = opt.$1),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _biggestChallenge == opt.$1
                        ? cs.primary.withValues(alpha: 0.1)
                        : cs.surfaceContainerHighest.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _biggestChallenge == opt.$1
                          ? cs.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(opt.$1 == _biggestChallenge ? '✓ ' : '   ',
                          style: TextStyle(color: cs.primary)),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(opt.$2,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500)),
                            Text(opt.$3,
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),

        const SizedBox(height: 16),

        // Question 2 — Regular bills
        InkWell(
          onTap: () => setState(() => _hasRegularBills = !_hasRegularBills),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _hasRegularBills
                  ? cs.primary.withValues(alpha: 0.1)
                  : cs.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _hasRegularBills ? cs.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _hasRegularBills
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: _hasRegularBills ? cs.primary : Colors.grey,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("I have regular bills",
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      Text("Internet, rent, subscriptions, etc.",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Question 3 — Emergency fund
        InkWell(
          onTap: () =>
              setState(() => _wantsEmergencyFund = !_wantsEmergencyFund),
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _wantsEmergencyFund
                  ? cs.primary.withValues(alpha: 0.1)
                  : cs.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _wantsEmergencyFund ? cs.primary : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _wantsEmergencyFund
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: _wantsEmergencyFund ? cs.primary : Colors.grey,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("I want to build an emergency fund",
                          style: TextStyle(fontWeight: FontWeight.w500)),
                      Text("3–6 months of expenses as a safety net",
                          style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ];
}
