class TaxService {
  /// Estimates monthly income tax based on PH BIR TRAIN Law tax table.
  /// Input: monthly income in PHP
  /// Output: estimated monthly tax in PHP
  /// NOTE: Estimation only — not official tax advice.
  static double estimateTax(double monthlyIncome) {
    // Annualize
    final annual = monthlyIncome * 12;

    double annualTax;

    if (annual <= 250000) {
      annualTax = 0;
    } else if (annual <= 400000) {
      annualTax = (annual - 250000) * 0.15;
    } else if (annual <= 800000) {
      annualTax = 22500 + (annual - 400000) * 0.20;
    } else if (annual <= 2000000) {
      annualTax = 102500 + (annual - 800000) * 0.25;
    } else if (annual <= 8000000) {
      annualTax = 402500 + (annual - 2000000) * 0.30;
    } else {
      annualTax = 2202500 + (annual - 8000000) * 0.35;
    }

    return annualTax / 12;
  }

  /// Suggested monthly savings based on 20% rule
  static double suggestedSavings(double monthlyIncome) {
    return monthlyIncome * 0.20;
  }
}
