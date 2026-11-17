/// Computes the start date of the current budget period based on the user's
/// income frequency.
///
/// For `bimonthly` income (salary paid on the 15th & 30th), budgets reset
/// twice a month — on the 1st and on the 15th:
///   - If today is before the 15th, the period started on the 1st.
///   - If today is the 15th or later, the period started on the 15th.
///
/// For every other frequency (daily, weekly, monthly, manual), budgets reset
/// on the 1st of the month.
///
/// This implements Recommendation 1 (payday-cycle-aware budgeting) from the
/// SmartSpend study, aligning budget periods with the Filipino 15th/30th
/// salary cycle so "spent so far this period" reflects spending since the
/// user's last payday rather than always the calendar month start.
DateTime budgetPeriodStart(DateTime now, String incomeFreq) {
  if (incomeFreq == 'bimonthly' && now.day >= 15) {
    return DateTime(now.year, now.month, 15);
  }
  return DateTime(now.year, now.month, 1);
}
