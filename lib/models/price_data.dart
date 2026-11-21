class PriceData {
  final int? id;
  final String productName;
  final String? storeName;
  final double price;
  final DateTime date;
  final String? category;
  final int? expenseId;
  final DateTime? createdAt;

  PriceData({
    this.id,
    required this.productName,
    this.storeName,
    required this.price,
    required this.date,
    this.category,
    this.expenseId,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'product_name': productName,
      'store_name': storeName,
      'price': price,
      'date': date.toIso8601String(),
      'category': category,
      'expense_id': expenseId,
      'created_at': (createdAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory PriceData.fromMap(Map<String, dynamic> map) {
    return PriceData(
      id: map['id'] as int?,
      productName: map['product_name'] as String,
      storeName: map['store_name'] as String?,
      price: (map['price'] as num).toDouble(),
      date: DateTime.parse(map['date'] as String),
      category: map['category'] as String?,
      expenseId: map['expense_id'] as int?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }
}
