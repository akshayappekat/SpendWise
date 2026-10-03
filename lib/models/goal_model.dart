class GoalModel {
  final int? id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;

  GoalModel({
    this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
  });

  double get progressPercentage {
    if (targetAmount <= 0) return 0.0;
    return ((currentAmount / targetAmount) * 100).clamp(0.0, 100.0);
  }

  double get remainingAmount => (targetAmount - currentAmount).clamp(0.0, targetAmount);

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'targetAmount': targetAmount,
      'currentAmount': currentAmount,
      'targetDate': targetDate.toIso8601String(),
    };
  }

  factory GoalModel.fromMap(Map<String, dynamic> map) {
    return GoalModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      targetAmount: (map['targetAmount'] as num).toDouble(),
      currentAmount: (map['currentAmount'] as num).toDouble(),
      targetDate: DateTime.parse(map['targetDate'] as String),
    );
  }
}
