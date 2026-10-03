class RecurringModel {
  final int? id;
  final String title;
  final double amount;
  final String frequency; // 'Daily', 'Weekly', 'Monthly', 'Yearly'
  final String category;
  final DateTime nextDate;
  final bool active;

  RecurringModel({
    this.id,
    required this.title,
    required this.amount,
    required this.frequency,
    required this.category,
    required this.nextDate,
    this.active = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'frequency': frequency,
      'category': category,
      'nextDate': nextDate.toIso8601String(),
      'active': active ? 1 : 0,
    };
  }

  factory RecurringModel.fromMap(Map<String, dynamic> map) {
    return RecurringModel(
      id: map['id'] as int?,
      title: map['title'] as String,
      amount: (map['amount'] as num).toDouble(),
      frequency: map['frequency'] as String,
      category: map['category'] as String,
      nextDate: DateTime.parse(map['nextDate'] as String),
      active: (map['active'] as int? ?? 1) == 1,
    );
  }
}
