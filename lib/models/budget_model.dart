class BudgetModel {
  final int? id;
  final int? userId;
  final String month; // Format: 'YYYY-MM' (e.g. '2026-09')
  final double amount;

  BudgetModel({
    this.id,
    this.userId,
    required this.month,
    required this.amount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'month': month,
      'amount': amount,
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as int?,
      userId: map['userId'] as int?,
      month: map['month'] as String,
      amount: (map['amount'] as num).toDouble(),
    );
  }

  BudgetModel copyWith({
    int? id,
    int? userId,
    String? month,
    double? amount,
  }) {
    return BudgetModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      month: month ?? this.month,
      amount: amount ?? this.amount,
    );
  }
}
