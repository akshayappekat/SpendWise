import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../models/recurring_model.dart';
import '../utils/helpers.dart';

class RecurringScreen extends StatelessWidget {
  const RecurringScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final symbol = provider.selectedCurrency;

    final recurring = provider.recurring.isNotEmpty
        ? provider.recurring
        : [
            RecurringModel(
              id: 1,
              title: 'Netflix Subscription',
              amount: 649,
              frequency: 'Monthly',
              category: 'Entertainment',
              nextDate: DateTime(2026, 10, 5),
            ),
            RecurringModel(
              id: 2,
              title: 'House Rent',
              amount: 15000,
              frequency: 'Monthly',
              category: 'Bills',
              nextDate: DateTime(2026, 10, 1),
            ),
          ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Transactions'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: recurring.length,
        itemBuilder: (context, index) {
          final item = recurring[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF6C5CE7).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.autorenew, color: Color(0xFF6C5CE7)),
              ),
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                '${item.frequency} • Next: ${AppHelpers.formatDate(item.nextDate)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '-${AppHelpers.formatCurrency(item.amount, symbol: symbol)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Color(0xFFFF7675),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text('Active', style: TextStyle(fontSize: 11, color: Colors.green)),
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
