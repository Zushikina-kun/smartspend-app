import 'dart:math';

/// Service for SSS (Social Security System) calculations and data
class SSSService {
  /// 2026 SSS Contribution Table (simplified)
  /// Based on 14% total contribution rate (9.5% employer + 4.5% employee)
  static final List<Map<String, dynamic>> _contributionTable = [
    {'minSalary': 1000, 'maxSalary': 4249, 'totalContribution': 560, 'employerShare': 380, 'employeeShare': 180},
    {'minSalary': 4250, 'maxSalary': 4749, 'totalContribution': 630, 'employerShare': 427.50, 'employeeShare': 202.50},
    {'minSalary': 4750, 'maxSalary': 5249, 'totalContribution': 700, 'employerShare': 475, 'employeeShare': 225},
    {'minSalary': 5250, 'maxSalary': 5749, 'totalContribution': 770, 'employerShare': 522.50, 'employeeShare': 247.50},
    {'minSalary': 5750, 'maxSalary': 6249, 'totalContribution': 840, 'employerShare': 570, 'employeeShare': 270},
    {'minSalary': 6250, 'maxSalary': 6749, 'totalContribution': 910, 'employerShare': 617.50, 'employeeShare': 292.50},
    {'minSalary': 6750, 'maxSalary': 7249, 'totalContribution': 980, 'employerShare': 665, 'employeeShare': 315},
    {'minSalary': 7250, 'maxSalary': 7749, 'totalContribution': 1050, 'employerShare': 712.50, 'employeeShare': 337.50},
    {'minSalary': 7750, 'maxSalary': 8249, 'totalContribution': 1120, 'employerShare': 760, 'employeeShare': 360},
    {'minSalary': 8250, 'maxSalary': 8749, 'totalContribution': 1190, 'employerShare': 807.50, 'employeeShare': 382.50},
    {'minSalary': 8750, 'maxSalary': 9249, 'totalContribution': 1260, 'employerShare': 855, 'employeeShare': 405},
    {'minSalary': 9250, 'maxSalary': 9749, 'totalContribution': 1330, 'employerShare': 902.50, 'employeeShare': 427.50},
    {'minSalary': 9750, 'maxSalary': 10249, 'totalContribution': 1400, 'employerShare': 950, 'employeeShare': 450},
    {'minSalary': 10250, 'maxSalary': 10749, 'totalContribution': 1470, 'employerShare': 997.50, 'employeeShare': 472.50},
    {'minSalary': 10750, 'maxSalary': 11249, 'totalContribution': 1540, 'employerShare': 1045, 'employeeShare': 495},
    {'minSalary': 11250, 'maxSalary': 11749, 'totalContribution': 1610, 'employerShare': 1092.50, 'employeeShare': 517.50},
    {'minSalary': 11750, 'maxSalary': 12249, 'totalContribution': 1680, 'employerShare': 1140, 'employeeShare': 540},
    {'minSalary': 12250, 'maxSalary': 12749, 'totalContribution': 1750, 'employerShare': 1187.50, 'employeeShare': 562.50},
    {'minSalary': 12750, 'maxSalary': 13249, 'totalContribution': 1820, 'employerShare': 1235, 'employeeShare': 585},
    {'minSalary': 13250, 'maxSalary': 13749, 'totalContribution': 1890, 'employerShare': 1282.50, 'employeeShare': 607.50},
    {'minSalary': 13750, 'maxSalary': 14249, 'totalContribution': 1960, 'employerShare': 1330, 'employeeShare': 630},
    {'minSalary': 14250, 'maxSalary': 14749, 'totalContribution': 2030, 'employerShare': 1377.50, 'employeeShare': 652.50},
    {'minSalary': 14750, 'maxSalary': 15249, 'totalContribution': 2100, 'employerShare': 1425, 'employeeShare': 675},
    {'minSalary': 15250, 'maxSalary': 15749, 'totalContribution': 2170, 'employerShare': 1472.50, 'employeeShare': 697.50},
    {'minSalary': 15750, 'maxSalary': 16249, 'totalContribution': 2240, 'employerShare': 1520, 'employeeShare': 720},
    {'minSalary': 16250, 'maxSalary': 16749, 'totalContribution': 2310, 'employerShare': 1567.50, 'employeeShare': 742.50},
    {'minSalary': 16750, 'maxSalary': 17249, 'totalContribution': 2380, 'employerShare': 1615, 'employeeShare': 765},
    {'minSalary': 17250, 'maxSalary': 17749, 'totalContribution': 2450, 'employerShare': 1662.50, 'employeeShare': 787.50},
    {'minSalary': 17750, 'maxSalary': 18249, 'totalContribution': 2520, 'employerShare': 1710, 'employeeShare': 810},
    {'minSalary': 18250, 'maxSalary': 18749, 'totalContribution': 2590, 'employerShare': 1757.50, 'employeeShare': 832.50},
    {'minSalary': 18750, 'maxSalary': 19249, 'totalContribution': 2660, 'employerShare': 1805, 'employeeShare': 855},
    {'minSalary': 19250, 'maxSalary': 19749, 'totalContribution': 2730, 'employerShare': 1852.50, 'employeeShare': 877.50},
    {'minSalary': 19750, 'maxSalary': 20249, 'totalContribution': 2800, 'employerShare': 1900, 'employeeShare': 900},
    {'minSalary': 20250, 'maxSalary': 20749, 'totalContribution': 2870, 'employerShare': 1947.50, 'employeeShare': 922.50},
    {'minSalary': 20750, 'maxSalary': 21249, 'totalContribution': 2940, 'employerShare': 1995, 'employeeShare': 945},
    {'minSalary': 21250, 'maxSalary': 21749, 'totalContribution': 3010, 'employerShare': 2042.50, 'employeeShare': 967.50},
    {'minSalary': 21750, 'maxSalary': 22249, 'totalContribution': 3080, 'employerShare': 2090, 'employeeShare': 990},
    {'minSalary': 22250, 'maxSalary': 22749, 'totalContribution': 3150, 'employerShare': 2137.50, 'employeeShare': 1012.50},
    {'minSalary': 22750, 'maxSalary': 23249, 'totalContribution': 3220, 'employerShare': 2185, 'employeeShare': 1035},
    {'minSalary': 23250, 'maxSalary': 23749, 'totalContribution': 3290, 'employerShare': 2232.50, 'employeeShare': 1057.50},
    {'minSalary': 23750, 'maxSalary': 24249, 'totalContribution': 3360, 'employerShare': 2280, 'employeeShare': 1080},
    {'minSalary': 24250, 'maxSalary': 24749, 'totalContribution': 3430, 'employerShare': 2327.50, 'employeeShare': 1102.50},
    {'minSalary': 24750, 'maxSalary': 29750, 'totalContribution': 4095, 'employerShare': 2778.75, 'employeeShare': 1316.25},
  ];

  /// Calculate monthly SSS contribution based on salary
  /// Returns a map with employerShare, employeeShare, and totalContribution
  static Map<String, double> calculateMonthlyContribution(double monthlySalary) {
    if (monthlySalary < 1000) {
      return {
        'employerShare': 0.0,
        'employeeShare': 0.0,
        'totalContribution': 0.0,
      };
    }

    // Find the matching bracket
    for (var bracket in _contributionTable) {
      if (monthlySalary >= bracket['minSalary'] && monthlySalary <= bracket['maxSalary']) {
        return {
          'employerShare': bracket['employerShare'].toDouble(),
          'employeeShare': bracket['employeeShare'].toDouble(),
          'totalContribution': bracket['totalContribution'].toDouble(),
        };
      }
    }

    // If salary exceeds maximum, use the highest bracket
    var maxBracket = _contributionTable.last;
    return {
      'employerShare': maxBracket['employerShare'].toDouble(),
      'employeeShare': maxBracket['employeeShare'].toDouble(),
      'totalContribution': maxBracket['totalContribution'].toDouble(),
    };
  }

  /// Calculate SSS Salary Loan monthly amortization
  /// loanAmount: principal amount (max 2x monthly salary)
  /// monthlyPay: monthly salary for eligibility check
  /// Returns map with monthlyPayment, totalPayment, totalInterest
  static Map<String, double> calculateSalaryLoan(double monthlyPay, double loanAmount) {
    const int termMonths = 24;
    const double annualInterestRate = 0.10;
    const double monthlyInterestRate = annualInterestRate / 12;

    // Calculate monthly payment using amortization formula
    double monthlyPayment = loanAmount * 
        (monthlyInterestRate * pow(1 + monthlyInterestRate, termMonths)) /
        (pow(1 + monthlyInterestRate, termMonths) - 1);

    double totalPayment = monthlyPayment * termMonths;
    double totalInterest = totalPayment - loanAmount;

    return {
      'monthlyPayment': monthlyPayment,
      'totalPayment': totalPayment,
      'totalInterest': totalInterest,
      'principal': loanAmount,
      'termMonths': termMonths.toDouble(),
    };
  }

  /// Calculate SSS Calamity Loan
  /// Maximum ₱20,000, 10% annual interest, 24-month term
  static Map<String, double> calculateCalamityLoan(double monthlyPay) {
    const double maxLoanAmount = 20000;
    return calculateSalaryLoan(monthlyPay, maxLoanAmount);
  }

  /// Calculate SSS Emergency Loan
  /// Range: ₱5,000-₱20,000, 10% annual interest, 12-month term
  static Map<String, double> calculateEmergencyLoan(double monthlyPay, double loanAmount) {
    const int termMonths = 12;
    const double annualInterestRate = 0.10;
    const double monthlyInterestRate = annualInterestRate / 12;

    // Clamp loan amount to valid range
    double validAmount = loanAmount.clamp(5000, 20000);

    // Calculate monthly payment using amortization formula
    double monthlyPayment = validAmount * 
        (monthlyInterestRate * pow(1 + monthlyInterestRate, termMonths)) /
        (pow(1 + monthlyInterestRate, termMonths) - 1);

    double totalPayment = monthlyPayment * termMonths;
    double totalInterest = totalPayment - validAmount;

    return {
      'monthlyPayment': monthlyPayment,
      'totalPayment': totalPayment,
      'totalInterest': totalInterest,
      'principal': validAmount,
      'termMonths': termMonths.toDouble(),
    };
  }

  /// Generate mock SSS contribution history for the past 12 months
  /// Uses provided salary or defaults to ₱15,000
  static List<Map<String, dynamic>> generateMockContributionHistory({double? salary}) {
    final double monthlySalary = salary ?? 15000;
    final List<Map<String, dynamic>> history = [];
    final Random random = Random();
    final DateTime now = DateTime.now();

    for (int i = 11; i >= 0; i--) {
      // Generate date for i months ago
      DateTime contributionDate = DateTime(now.year, now.month - i, 1);
      
      // Add some variation to salary (±5%)
      double variationFactor = 0.95 + (random.nextDouble() * 0.1);
      double adjustedSalary = monthlySalary * variationFactor;
      
      // Calculate contribution for this salary
      Map<String, double> contribution = calculateMonthlyContribution(adjustedSalary);
      
      history.add({
        'date': contributionDate,
        'salary': adjustedSalary,
        'employerShare': contribution['employerShare'],
        'employeeShare': contribution['employeeShare'],
        'totalContribution': contribution['totalContribution'],
      });
    }

    return history;
  }

  /// Get SSS contribution rate information
  static Map<String, String> getContributionInfo() {
    return {
      'totalRate': '14%',
      'employerRate': '9.5%',
      'employeeRate': '4.5%',
      'salaryRange': '₱1,000 - ₱29,750+',
      'description': 'SSS contributions are mandatory for all employees in the Philippines. The total contribution is split between employer (9.5%) and employee (4.5%).',
    };
  }

  /// Get SSS loan eligibility information
  static Map<String, String> getLoanEligibilityInfo() {
    return {
      'salaryLoan': 'Must have at least 36 posted monthly contributions, 6 of which must be within the last 12 months. Maximum loanable amount is twice your monthly salary credit.',
      'calamityLoan': 'Available during declared calamities. Must have at least 36 posted monthly contributions. Maximum amount is ₱20,000.',
      'emergencyLoan': 'Available as short-term assistance. Must have at least 6 posted monthly contributions. Amount ranges from ₱5,000 to ₱20,000.',
      'officialSource': 'For real contribution history and loan applications, visit https://www.sss.gov.ph',
    };
  }
}
