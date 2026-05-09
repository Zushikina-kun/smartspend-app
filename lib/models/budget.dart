class Budget {
  final int? id;
  final String category;
  final double amount;
  final bool isPercentage;
  final double percentageValue;

  Budget({
    this.id,
    required this.category,
    required this.amount,
    this.isPercentage = false,
    this.percentageValue = 0,
  });

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'category': category,
        'amount': amount,
        'is_percentage': isPercentage ? 1 : 0,
        'percentage_value': percentageValue,
      };

  factory Budget.fromMap(Map<String, dynamic> map) => Budget(
        id: map['id'] as int?,
        category: map['category'] as String,
        amount: (map['amount'] as num).toDouble(),
        isPercentage: (map['is_percentage'] as int? ?? 0) == 1,
        percentageValue: (map['percentage_value'] as num?)?.toDouble() ?? 0,
      );
}
