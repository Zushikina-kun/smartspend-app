// FEAT-011 — Debt Payoff Calculator service
// Provides avalanche (highest rate first) and snowball (lowest balance first)
// payoff simulations independent of the database.

class DebtEntry {
  final String name;
  final double balance;
  final double annualInterestRate; // e.g. 0.18 for 18%
  final double minPayment;

  DebtEntry({
    required this.name,
    required this.balance,
    required this.annualInterestRate,
    required this.minPayment,
  });
}

class DebtMilestone {
  final String debtName;
  final int monthPaidOff;

  DebtMilestone({required this.debtName, required this.monthPaidOff});
}

class PayoffResult {
  final String method; // 'avalanche' or 'snowball'
  final List<String> payoffOrder;
  final int monthsToDebtFree;
  final double totalInterestPaid;
  final List<DebtMilestone> milestones;

  PayoffResult({
    required this.method,
    required this.payoffOrder,
    required this.monthsToDebtFree,
    required this.totalInterestPaid,
    required this.milestones,
  });
}

class DebtCalculator {
  static const int _maxMonths = 600;

  /// Avalanche: apply extra payment to the highest-rate debt each month.
  static PayoffResult avalanche(
      List<DebtEntry> debts, double extraMonthlyPayment) {
    return _simulate(debts, extraMonthlyPayment, 'avalanche');
  }

  /// Snowball: apply extra payment to the lowest-balance debt each month.
  static PayoffResult snowball(
      List<DebtEntry> debts, double extraMonthlyPayment) {
    return _simulate(debts, extraMonthlyPayment, 'snowball');
  }

  static PayoffResult _simulate(
      List<DebtEntry> debts, double extraMonthlyPayment, String method) {
    if (debts.isEmpty) {
      return PayoffResult(
        method: method,
        payoffOrder: [],
        monthsToDebtFree: 0,
        totalInterestPaid: 0,
        milestones: [],
      );
    }

    // Working copies of balances indexed by position
    final balances = List<double>.from(debts.map((d) => d.balance));
    double totalInterest = 0;
    final milestones = <DebtMilestone>[];
    final payoffOrder = <String>[];

    for (int month = 1; month <= _maxMonths; month++) {
      // Check if all debts cleared
      if (balances.every((b) => b <= 0.001)) break;

      // --- Apply monthly interest to each active debt ---
      for (int i = 0; i < debts.length; i++) {
        if (balances[i] <= 0.001) continue;
        final monthlyRate = debts[i].annualInterestRate / 12;
        final interest = balances[i] * monthlyRate;
        balances[i] += interest;
        totalInterest += interest;
      }

      // --- Determine focus debt ---
      final activeIndices = [
        for (int i = 0; i < debts.length; i++)
          if (balances[i] > 0.001) i
      ];
      if (activeIndices.isEmpty) break;

      int focusIdx;
      if (method == 'avalanche') {
        focusIdx = activeIndices.reduce((a, b) =>
            debts[a].annualInterestRate >= debts[b].annualInterestRate ? a : b);
      } else {
        focusIdx =
            activeIndices.reduce((a, b) => balances[a] <= balances[b] ? a : b);
      }

      // --- Pay minimums on all non-focus debts ---
      double remaining =
          debts.fold(0.0, (sum, d) => sum + d.minPayment) + extraMonthlyPayment;

      for (final i in activeIndices) {
        if (i == focusIdx) continue;
        final pay = debts[i].minPayment.clamp(0.0, balances[i]);
        balances[i] = (balances[i] - pay).clamp(0.0, double.infinity);
        remaining -= pay;
        if (balances[i] <= 0.001) {
          balances[i] = 0;
          milestones
              .add(DebtMilestone(debtName: debts[i].name, monthPaidOff: month));
          payoffOrder.add(debts[i].name);
        }
      }

      // --- Apply remainder to focus debt ---
      remaining = remaining.clamp(0.0, double.infinity);
      final focusPay = remaining.clamp(0.0, balances[focusIdx]);
      balances[focusIdx] =
          (balances[focusIdx] - focusPay).clamp(0.0, double.infinity);
      if (balances[focusIdx] <= 0.001) {
        balances[focusIdx] = 0;
        milestones.add(
            DebtMilestone(debtName: debts[focusIdx].name, monthPaidOff: month));
        payoffOrder.add(debts[focusIdx].name);
      }
    }

    final months = milestones.isEmpty
        ? _maxMonths
        : milestones.map((m) => m.monthPaidOff).reduce((a, b) => a > b ? a : b);

    return PayoffResult(
      method: method,
      payoffOrder: payoffOrder,
      monthsToDebtFree: months,
      totalInterestPaid: totalInterest,
      milestones: milestones,
    );
  }
}
