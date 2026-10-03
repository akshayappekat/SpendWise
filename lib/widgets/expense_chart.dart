import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class CategoryExpenseChart extends StatelessWidget {
  const CategoryExpenseChart({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final categoryTotals = provider.categoryExpenseTotals;

    if (categoryTotals.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('No expense data available for analytics.'),
        ),
      );
    }

    final totalExp = provider.totalExpenses;

    final sections = categoryTotals.entries.map((entry) {
      final category = entry.key;
      final amount = entry.value;
      final percentage = (amount / totalExp) * 100;
      final color = AppConstants.categoryColors[category] ?? Colors.purple;

      return PieChartSectionData(
        color: color,
        value: amount,
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: 40,
              sections: sections,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: categoryTotals.entries.map((entry) {
            final category = entry.key;
            final amount = entry.value;
            final color = AppConstants.categoryColors[category] ?? Colors.purple;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(
                  '$category (${AppHelpers.formatCurrency(amount, symbol: provider.selectedCurrency)})',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
