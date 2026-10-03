import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/budget_progress.dart';

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({super.key});

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late TextEditingController _budgetController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<TransactionProvider>(context, listen: false);
    _budgetController = TextEditingController(
      text: provider.monthlyBudgetAmount.toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _updateBudget() {
    final amount = double.tryParse(_budgetController.text);
    if (amount != null && amount > 0) {
      Provider.of<TransactionProvider>(context, listen: false).setMonthlyBudget(amount);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monthly budget updated successfully!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final symbol = provider.selectedCurrency;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budget Management'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const BudgetProgressCard(),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Set Monthly Spending Limit',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _budgetController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Budget Amount ($symbol)',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                        prefixIcon: const Icon(Icons.account_balance),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _updateBudget,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C5CE7),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('UPDATE BUDGET', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInsightRow(
                      icon: Icons.check_circle_outline,
                      color: Colors.green,
                      title: 'Budget Health',
                      subtitle: provider.budgetUtilizationPercentage <= 100
                          ? 'You are within your safe spending limit!'
                          : 'Warning: You have exceeded your budget limits!',
                    ),
                    const Divider(),
                    _buildInsightRow(
                      icon: Icons.lightbulb_outline,
                      color: Colors.amber,
                      title: 'Spending Tip',
                      subtitle: 'Try allocating no more than 50% of your income towards essential bill expenses.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightRow({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}
