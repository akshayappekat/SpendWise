import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final String currencySymbol;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.currencySymbol,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final icon = AppConstants.categoryIcons[transaction.category] ?? Icons.category;
    final color = AppConstants.categoryColors[transaction.category] ?? Colors.blueAccent;
    final isIncome = transaction.isIncome;
    final formattedAmount = '${isIncome ? '+' : '-'}${AppHelpers.formatCurrency(transaction.amount, symbol: currencySymbol)}';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          transaction.description.isNotEmpty
              ? transaction.description
              : transaction.category,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          '${transaction.category} • ${AppHelpers.formatDate(transaction.date)}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              formattedAmount,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isIncome ? const Color(0xFF00B894) : const Color(0xFFFF7675),
              ),
            ),
            if (onDelete != null) ...[
              const SizedBox(width: 4),
              IconButton(
                icon: const Icon(Icons.delete_outline, size: 20, color: Colors.grey),
                onPressed: onDelete,
              ),
            ]
          ],
        ),
      ),
    );
  }
}
