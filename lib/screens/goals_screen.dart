import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/goal_model.dart';
import '../utils/helpers.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final symbol = provider.selectedCurrency;

    // Sample goals if list is empty
    final goals = provider.goals.isNotEmpty
        ? provider.goals
        : [
            GoalModel(
              id: 1,
              name: 'Emergency Fund',
              targetAmount: 50000,
              currentAmount: 25000,
              targetDate: DateTime(2026, 12, 31),
            ),
            GoalModel(
              id: 2,
              name: 'New Laptop',
              targetAmount: 80000,
              currentAmount: 35000,
              targetDate: DateTime(2026, 11, 15),
            ),
          ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financial Goals'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: goals.length,
        itemBuilder: (context, index) {
          final goal = goals[index];
          final progress = goal.progressPercentage;

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        goal.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C5CE7).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${progress.toStringAsFixed(1)}%',
                          style: const TextStyle(
                            color: Color(0xFF6C5CE7),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress / 100,
                      minHeight: 10,
                      backgroundColor: Colors.grey.withValues(alpha: 0.15),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6C5CE7)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Saved: ${AppHelpers.formatCurrency(goal.currentAmount, symbol: symbol)}',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'Target: ${AppHelpers.formatCurrency(goal.targetAmount, symbol: symbol)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Target Date: ${AppHelpers.formatDate(goal.targetDate)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Funds added to goal!')),
                          );
                        },
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Funds'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C5CE7),
                          foregroundColor: Colors.white,
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF6C5CE7),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
