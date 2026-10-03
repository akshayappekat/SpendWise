class TransactionModel {
  final int? id;
  final int? userId;
  final String type; // 'income' or 'expense'
  final double amount;
  final String category;
  final String paymentMethod; // 'Cash', 'UPI', 'Credit Card', 'Debit Card', 'Bank Transfer', 'Other'
  final DateTime date;
  final String description;

  TransactionModel({
    this.id,
    this.userId,
    required this.type,
    required this.amount,
    required this.category,
    this.paymentMethod = 'Cash',
    required this.date,
    required this.description,
  });

  bool get isIncome => type.toLowerCase() == 'income';
  bool get isExpense => type.toLowerCase() == 'expense';

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'amount': amount,
      'category': category,
      'paymentMethod': paymentMethod,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'] as int?,
      userId: map['userId'] as int?,
      type: map['type'] as String,
      amount: (map['amount'] as num).toDouble(),
      category: map['category'] as String,
      paymentMethod: map['paymentMethod'] as String? ?? 'Cash',
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String? ?? '',
    );
  }

  TransactionModel copyWith({
    int? id,
    int? userId,
    String? type,
    double? amount,
    String? category,
    String? paymentMethod,
    DateTime? date,
    String? description,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }
}
