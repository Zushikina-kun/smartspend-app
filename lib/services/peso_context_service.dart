/// Tracks which screen Peso is currently on and provides
/// screen-aware contextual tips. Any screen can call setScreen()
/// in initState so Peso knows where he is.
///
/// Screen keys match screen names for easy identification.
class PesoContextService {
  static String _currentScreen = 'home';
  static Map<String, dynamic> _screenData = {};

  /// Call from any screen's initState to tell Peso where he is.
  /// [data] can include live values: {'budgetPct': 85, 'goalName': 'Laptop', ...}
  static void setScreen(String screen, {Map<String, dynamic>? data}) {
    _currentScreen = screen;
    _screenData = data ?? {};
  }

  static String get currentScreen => _currentScreen;
  static Map<String, dynamic> get screenData => _screenData;

  /// Returns contextual tips for a given screen key.
  static List<String> getTipsForScreen(String screen) {
    return _tips[screen] ?? _tips['home']!;
  }

  /// Returns a single tip interpolated with any live data.
  static String getTip({String? screen}) {
    final key = screen ?? _currentScreen;
    final tips = _tips[key] ?? _tips['home']!;
    var tip = tips[DateTime.now().millisecondsSinceEpoch % tips.length];
    // Interpolate live data
    _screenData.forEach((k, v) {
      tip = tip.replaceAll('{$k}', v.toString());
    });
    return tip;
  }

  static const Map<String, List<String>> _tips = {
    'home': [
      'Kamusta ang budget mo ngayon? Tap me to ask! 💬',
      'I can log expenses, check FHS, or answer anything! 😊',
      'Tip: Tell me what you spent in Taglish — I understand both! 🇵🇭',
      'Say "how am I doing this month?" for a full breakdown! 📊',
    ],
    'analytics': [
      'Want me to explain any chart? Just ask! 📊',
      'Ask "where am I overspending?" for a detailed breakdown! 💡',
      'Try "what if I cut Shopping by ₱500?" — I\'ll show the impact! 💹',
    ],
    'profile': [
      'Your Financial Health Certificate is shareable here! 🏆',
      'Export your data any time — Profile → Export CSV! 📋',
      'Send Feedback is here if you find bugs or have ideas! 🐛',
    ],
    'budget': [
      'Set limits per category — I\'ll warn you at 80% and 100%! 💡',
      'Tip: Budget for "Wants" separately to track impulse spending! 🛒',
      'Ask me "am I on track with my budgets?" for a summary! 📊',
    ],
    'goals': [
      'Set goals with deadlines — I\'ll track monthly contributions needed! 🎯',
      'Tip: Add contribution regularly, even small amounts count! 💰',
      'Ask me "how long until I reach my {goalName} goal?" anytime! 📅',
    ],
    'debts': [
      'Track what you owe AND what\'s owed to you — I\'ll remind before dues! 💳',
      'Installment plans (ShopeePayLater, HomeCredit) can be tracked here! 📋',
      'Ask me "how much do I owe in total?" for a summary! 💬',
    ],
    'insurance': [
      'SSS, PhilHealth, Pag-IBIG due dates — never miss a contribution! 🛡️',
      'Tip: Add all your insurance policies here to track total monthly cost! 📋',
    ],
    'bank_import': [
      'Paste your GCash, BPI, BDO, or Maya transaction text — I\'ll parse it! 📋',
      'Tip: You can also paste Shopee order confirmations and receipts! 🧾',
    ],
    'bank_comparison': [
      'Compare PH banks and digital banks — rates, minimums, features! 🏦',
      'GoTyme gives 5% p.a. with no minimum balance — worth checking! 💚',
    ],
    'recurring': [
      'Add Netflix, GCash load, Meralco — I\'ll remind you before they\'re due! 🔁',
      'Tip: Semester interval is available for school-related recurring costs! 🎓',
    ],
    'calendar': [
      'Bills, debts, goals, and expenses — all in one timeline view! 🗓️',
      'Tap any day to see what happened — expenses, due dates, everything! 📅',
    ],
    'achievements': [
      'Earn badges by hitting financial milestones — 36 total! 🏅',
      'Tip: Log consistently for 7 days for the Week Warrior badge! 🔥',
      'Tap me 10 times anywhere to unlock the Peso Pal badge! 🤜',
    ],
    'paluwagan': [
      'Track your rotating savings group here — who\'s next, how much! 🤝',
      'Tip: Record all contributions so everyone knows the status! 📋',
    ],
    'help': [
      'Can\'t find what you need? Ask me in the Peso AI tab! 💬',
      'Tip: You can ask me anything about how the app works! 🤖',
    ],
    'add_expense': [
      'Tell me what you spent in Filipino or English — I\'ll fill the rest! 💬',
      'Tip: Add a note to remember context — I\'ll remember it for you! 📝',
    ],
    'pca_calculator': [
      'Peso Cost Averaging — invest a fixed amount regularly! 📈',
      'MP2 gives 6-7% annually — great for peso cost averaging! 💹',
    ],
  };
}
