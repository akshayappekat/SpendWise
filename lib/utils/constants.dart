import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'SpendWise';
  static const String appSubtitle = 'Personal Expense Tracker';

  // Category Names
  static const List<String> expenseCategories = [
    'Food',
    'Transport',
    'Shopping',
    'Education',
    'Entertainment',
    'Bills',
    'Health',
    'Other',
  ];

  static const List<String> incomeCategories = [
    'Salary',
    'Freelance',
    'Investment',
    'Gift',
    'Other Income',
  ];

  static Map<String, IconData> categoryIcons = {
    'Food': Icons.fastfood,
    'Transport': Icons.directions_car,
    'Shopping': Icons.shopping_bag,
    'Education': Icons.school,
    'Entertainment': Icons.movie,
    'Bills': Icons.receipt_long,
    'Health': Icons.medical_services,
    'Salary': Icons.account_balance_wallet,
    'Freelance': Icons.work,
    'Investment': Icons.trending_up,
    'Gift': Icons.card_giftcard,
    'Other': Icons.more_horiz,
    'Other Income': Icons.attach_money,
  };

  static Map<String, Color> categoryColors = {
    'Food': const Color(0xFFFF6B6B),
    'Transport': const Color(0xFF4ECDC4),
    'Shopping': const Color(0xFFFFD166),
    'Education': const Color(0xFF118AB2),
    'Entertainment': const Color(0xFF06D6A0),
    'Bills': const Color(0xFF9D4EDD),
    'Health': const Color(0xFFF72585),
    'Salary': const Color(0xFF2EC4B6),
    'Freelance': const Color(0xFF3F37C9),
    'Investment': const Color(0xFF4895EF),
    'Gift': const Color(0xFFF15BB5),
    'Other': const Color(0xFF8D99AE),
    'Other Income': const Color(0xFF70E000),
  };
}
