/// PhilHealth Premium Calculator and Coverage Service
/// Implements 2026 PhilHealth rates: 5% of monthly basic salary
/// Max contribution: ₱5,000 (salary cap at ₱100,000)
class PhilHealthService {
  // 2026 PhilHealth contribution rate
  static const double contributionRate = 0.05; // 5%
  static const double maxContribution = 5000.0; // ₱5,000
  static const double salaryCap = 100000.0; // ₱100,000

  /// Calculate monthly PhilHealth premium based on monthly salary
  /// Returns total premium (capped at ₱5,000)
  static double calculateMonthlyPremium(double monthlySalary) {
    if (monthlySalary <= 0) return 0.0;

    final double premium = monthlySalary * contributionRate;
    return premium > maxContribution ? maxContribution : premium;
  }

  /// Get detailed premium breakdown based on employment type
  /// employmentType: 'employed', 'self-employed', or 'voluntary'
  static Map<String, dynamic> getPremiumBreakdown(
    double monthlySalary,
    String employmentType,
  ) {
    final double totalPremium = calculateMonthlyPremium(monthlySalary);
    final bool isMaxCap = monthlySalary >= salaryCap;

    double employeeShare = 0.0;
    double employerShare = 0.0;

    if (employmentType == 'employed') {
      // 50-50 split for employed
      employeeShare = totalPremium / 2;
      employerShare = totalPremium / 2;
    } else {
      // self-employed or voluntary pay 100%
      employeeShare = totalPremium;
      employerShare = 0.0;
    }

    return {
      'totalPremium': totalPremium,
      'employeeShare': employeeShare,
      'employerShare': employerShare,
      'isMaxCap': isMaxCap,
    };
  }

  /// Generate mock coverage information for demonstration
  /// In a real implementation, this would connect to PhilHealth API
  static Map<String, dynamic> generateMockCoverageInfo() {
    return {
      'isActive': true,
      'membershipType': 'Employed',
      'lastContribution': 'Oct 2026',
      'availableBenefits': [
        'Inpatient Care',
        'Outpatient Care',
        'Z Benefits',
        'Maternity Care',
      ],
    };
  }

  /// Get benefit descriptions for info buttons
  static Map<String, String> getBenefitDescriptions() {
    return {
      'Inpatient Care':
          'Coverage for hospital confinement including room and board, physician fees, diagnostic procedures, and medications. Case rates apply based on diagnosis.',
      'Outpatient Care':
          'Coverage for outpatient consultations, preventive services, diagnostic tests, and prescribed medications at accredited facilities.',
      'Z Benefits':
          'Special coverage for catastrophic illnesses including cancers, end-stage renal disease, and other life-threatening conditions requiring expensive treatment.',
      'Maternity Care':
          'Coverage for prenatal care, normal and caesarean deliveries, and newborn care packages for qualifying members.',
    };
  }
}
