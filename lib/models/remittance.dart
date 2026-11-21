class Remittance {
  final int? id;
  final String date;        // ISO 8601
  final double amount;      // amount in foreign currency
  final String currency;    // USD, SAR, AED, SGD, HKD
  final String recipientName;
  final String platform;    // e.g. Western Union, GCash Padala, Remitly
  final double fee;
  final String notes;

  const Remittance({this.id, required this.date, required this.amount,
    required this.currency, required this.recipientName,
    required this.platform, this.fee = 0.0, this.notes = ''});

  factory Remittance.fromMap(Map<String, dynamic> m) => Remittance(
    id: m['id'] as int?,
    date: m['date'] as String,
    amount: (m['amount'] as num).toDouble(),
    currency: m['currency'] as String,
    recipientName: m['recipient_name'] as String,
    platform: m['platform'] as String,
    fee: (m['fee'] as num? ?? 0).toDouble(),
    notes: m['notes'] as String? ?? '',
  );

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'date': date,
    'amount': amount,
    'currency': currency,
    'recipient_name': recipientName,
    'platform': platform,
    'fee': fee,
    'notes': notes,
  };

  /// Convert to PHP using hardcoded exchange rates
  double get amountPHP {
    const rates = {'USD': 56.0, 'SAR': 15.0, 'AED': 15.0, 'SGD': 42.0, 'HKD': 7.0};
    return amount * (rates[currency] ?? 1.0);
  }
}
