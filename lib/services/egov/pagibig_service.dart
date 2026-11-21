import 'dart:math';

/// Pag-IBIG Fund calculation service for contributions, housing loans, and MP2 savings
class PagIBIGService {
  /// Calculate monthly Pag-IBIG contribution
  /// Based on 2026 rates: 2% employee + 2% employer = 4% total
  /// Salary cap: minimum ₱1,500, maximum ₱5,000 for computation
  static Map<String, double> calculateMonthlyContribution(double monthlySalary) {
    // Apply salary cap for computation
    double cappedSalary = monthlySalary;
    if (cappedSalary < 1500) {
      cappedSalary = 1500;
    }
    if (cappedSalary > 5000) {
      cappedSalary = 5000;
    }

    double employeeContribution = cappedSalary * 0.02;
    double employerContribution = cappedSalary * 0.02;
    double totalContribution = employeeContribution + employerContribution;

    return {
      'employee': employeeContribution,
      'employer': employerContribution,
      'total': totalContribution,
      'cappedSalary': cappedSalary,
    };
  }

  /// Calculate housing loan monthly amortization
  /// Uses standard amortization formula: M = P[r(1+r)^n]/[(1+r)^n-1]
  /// where M = monthly payment, P = principal, r = monthly rate, n = number of payments
  static Map<String, double> calculateHousingLoan({
    required double loanAmount,
    required int years,
    double annualInterestRate = 6.5,
  }) {
    if (loanAmount <= 0 || years <= 0) {
      return {
        'monthlyPayment': 0,
        'totalPayment': 0,
        'totalInterest': 0,
      };
    }

    double monthlyRate = annualInterestRate / 100 / 12;
    int numberOfPayments = years * 12;

    // Amortization formula
    double monthlyPayment;
    if (monthlyRate == 0) {
      monthlyPayment = loanAmount / numberOfPayments;
    } else {
      monthlyPayment = loanAmount *
          (monthlyRate * pow(1 + monthlyRate, numberOfPayments)) /
          (pow(1 + monthlyRate, numberOfPayments) - 1);
    }

    double totalPayment = monthlyPayment * numberOfPayments;
    double totalInterest = totalPayment - loanAmount;

    return {
      'monthlyPayment': monthlyPayment,
      'totalPayment': totalPayment,
      'totalInterest': totalInterest,
    };
  }

  /// Calculate MP2 savings projection year-by-year
  /// Returns array of yearly projections with contributions and dividends
  /// Default dividend rate: 6-8% average (varies yearly based on fund performance)
  static List<Map<String, dynamic>> calculateMP2Projection({
    required double monthlyContribution,
    required int years,
    double annualDividendRate = 7.0,
  }) {
    List<Map<String, dynamic>> projections = [];
    
    double totalContributions = 0;
    double totalDividends = 0;
    double currentBalance = 0;

    for (int year = 1; year <= years; year++) {
      // Add contributions for the year
      double yearContributions = monthlyContribution * 12;
      totalContributions += yearContributions;
      
      // Calculate dividends on balance at start of year plus half of current year contributions
      // (assuming contributions are spread throughout the year)
      double averageBalance = currentBalance + (yearContributions / 2);
      double yearDividends = averageBalance * (annualDividendRate / 100);
      totalDividends += yearDividends;
      
      // Update balance
      currentBalance = totalContributions + totalDividends;

      projections.add({
        'year': year,
        'contributions': totalContributions,
        'dividends': totalDividends,
        'totalValue': currentBalance,
      });
    }

    return projections;
  }

  /// Get housing loan details and notes
  static Map<String, dynamic> getHousingLoanInfo() {
    return {
      'maxLoanAmount': 6000000.0,
      'minTerm': 5,
      'maxTerm': 30,
      'defaultRate': 6.5,
      'notes': [
        'Maximum loan amount: ₱6,000,000 (depending on affordability)',
        'Loan term: 5 to 30 years',
        'Interest rates vary based on loan term and market conditions',
        'Actual loan amount depends on income, existing obligations, and property value',
      ],
    };
  }

  /// Get MP2 program details and notes
  static Map<String, dynamic> getMP2Info() {
    return {
      'minMonthlyContribution': 500.0,
      'lockInPeriod': 5,
      'averageDividendRate': 7.0,
      'notes': [
        'Modified Pag-IBIG II (MP2) is a voluntary savings program',
        '5-year lock-in period per savings cycle',
        'Tax-free dividends based on Pag-IBIG Fund performance',
        'Historical dividend rates: 6-8% average annually',
        'Contributions are separate from regular Pag-IBIG savings',
        'Flexible contribution amounts (minimum ₱500/month recommended)',
      ],
    };
  }

  /// Get contribution rate details and notes
  static Map<String, dynamic> getContributionInfo() {
    return {
      'employeeRate': 2.0,
      'employerRate': 2.0,
      'totalRate': 4.0,
      'minSalary': 1500.0,
      'maxSalary': 5000.0,
      'notes': [
        'Employee contribution: 2% of monthly salary',
        'Employer contribution: 2% of monthly salary',
        'Total contribution: 4% of monthly salary',
        'Salary cap: ₱1,500 minimum, ₱5,000 maximum for computation',
        'Contributions are mandatory for all employees',
      ],
    };
  }
}
