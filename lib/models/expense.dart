class Expense {
  final int? id;
  final String itemName;
  final String category;
  final double amount;
  final String date;
  final String? time;
  final String? paymentMethod;
  final String? shopName;
  final String? location;
  final String? notes;
  final bool aiGenerated;
  final double confidenceScore;
  final String? updatedAt; // ISO timestamp for last-write-wins cloud sync
  final String? photoPath; // Local file path for attached receipt photo
  final bool? isWant; // true = Want, false/null = Need
  final String? tags; // comma-separated tags e.g. "#capstone,#school"

  Expense({
    this.id,
    required this.itemName,
    required this.category,
    required this.amount,
    required this.date,
    this.time,
    this.paymentMethod = 'Cash',
    this.shopName,
    this.location,
    this.notes,
    this.aiGenerated = true,
    this.confidenceScore = 1.0,
    this.updatedAt,
    this.photoPath,
    this.isWant,
    this.tags,
  });

  // Legacy compat: 'note' maps to itemName for old code
  String get note => notes ?? itemName;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'item_name': itemName,
      'category': category,
      'amount': amount,
      'date': date,
      'time': time,
      'payment_method': paymentMethod,
      'shop_name': shopName,
      'location': location,
      'notes': notes,
      'ai_generated': aiGenerated ? 1 : 0,
      'confidence_score': confidenceScore,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (photoPath != null) 'photo_path': photoPath,
      'is_want': (isWant ?? false) ? 1 : 0,
      if (tags != null && tags!.isNotEmpty) 'tags': tags,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'] as int?,
      itemName: (map['item_name'] ?? map['note'] ?? '') as String,
      category: (map['category'] ?? 'Others') as String,
      amount: (map['amount'] as num).toDouble(),
      date: (map['date'] ?? '') as String,
      time: map['time'] as String?,
      paymentMethod: (map['payment_method'] ?? 'Cash') as String,
      shopName: map['shop_name'] as String?,
      location: map['location'] as String?,
      notes: map['notes'] as String?,
      aiGenerated: (map['ai_generated'] ?? 1) == 1,
      confidenceScore: (map['confidence_score'] as num?)?.toDouble() ?? 1.0,
      updatedAt: map['updated_at'] as String?,
      photoPath: map['photo_path'] as String?,
      isWant: map['is_want'] != null ? (map['is_want'] as int) == 1 : null,
      tags: map['tags'] as String?,
    );
  }

  Expense copyWith({
    int? id,
    String? itemName,
    String? category,
    double? amount,
    String? date,
    String? time,
    String? paymentMethod,
    String? shopName,
    String? location,
    String? notes,
    bool? aiGenerated,
    double? confidenceScore,
    String? updatedAt,
    String? photoPath,
    bool? isWant,
    String? tags,
  }) {
    return Expense(
      id: id ?? this.id,
      itemName: itemName ?? this.itemName,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      time: time ?? this.time,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shopName: shopName ?? this.shopName,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      aiGenerated: aiGenerated ?? this.aiGenerated,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      updatedAt: updatedAt ?? this.updatedAt,
      photoPath: photoPath ?? this.photoPath,
      isWant: isWant ?? this.isWant,
      tags: tags ?? this.tags,
    );
  }
}
