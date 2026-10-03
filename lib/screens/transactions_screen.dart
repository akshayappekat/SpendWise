import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/transaction_provider.dart';
import '../widgets/transaction_tile.dart';
import 'add_transaction_screen.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final filtered = provider.filteredTransactions;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
      ),
      body: Column(
        children: [
          // Search & Filter controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                TextField(
                  onChanged: (query) => provider.setSearchQuery(query),
                  decoration: InputDecoration(
                    hintText: 'Search transactions...',
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.grey.withValues(alpha: 0.08),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: provider.filterType,
                            isExpanded: true,
                            items: ['All', 'Income', 'Expense'].map((t) {
                              return DropdownMenuItem(value: t, child: Text('Type: $t'));
                            }).toList(),
                            onChanged: (val) => provider.setFilters(type: val),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: provider.filterCategory,
                            isExpanded: true,
                            items: ['All', 'Food', 'Transport', 'Shopping', 'Education', 'Entertainment', 'Bills', 'Health', 'Salary', 'Investment']
                                .map((c) {
                              return DropdownMenuItem(value: c, child: Text(c == 'All' ? 'Category: All' : c));
                            }).toList(),
                            onChanged: (val) => provider.setFilters(category: val),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: filtered.isEmpty
                ? const Center(
                    child: Text(
                      'No matching transactions found.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final tx = filtered[index];
                      return TransactionTile(
                        transaction: tx,
                        currencySymbol: provider.selectedCurrency,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddTransactionScreen(transactionToEdit: tx),
                            ),
                          );
                        },
                        onDelete: () {
                          _showDeleteConfirm(context, provider, tx.id!);
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, TransactionProvider provider, int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteTransaction(id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
