import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/expense_chart.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final symbol = provider.selectedCurrency;
    final categoryTotals = provider.categoryExpenseTotals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Monthly Expenses Breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: const Padding(
                padding: EdgeInsets.all(16),
                child: CategoryExpenseChart(),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Category Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  ...categoryTotals.entries.map((entry) {
                    final category = entry.key;
                    final amount = entry.value;
                    final icon = AppConstants.categoryIcons[category] ?? Icons.category;
                    final color = AppConstants.categoryColors[category] ?? Colors.purple;

                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(icon, color: color, size: 20),
                      ),
                      title: Text(category, style: const TextStyle(fontWeight: FontWeight.w600)),
                      trailing: Text(
                        AppHelpers.formatCurrency(amount, symbol: symbol),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    );
                  }),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Total Expenses', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    trailing: Text(
                      AppHelpers.formatCurrency(provider.totalExpenses, symbol: symbol),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFFFF7675),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
