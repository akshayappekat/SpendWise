import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction_model.dart';
import '../providers/transaction_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

class AddTransactionScreen extends StatefulWidget {
  final TransactionModel? transactionToEdit;

  const AddTransactionScreen({super.key, this.transactionToEdit});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();

  late String _type; // 'expense' or 'income'
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;
  late String _selectedCategory;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final tx = widget.transactionToEdit;
    _type = tx?.type ?? 'expense';
    _amountController = TextEditingController(
      text: tx != null ? tx.amount.toString() : '',
    );
    _descriptionController = TextEditingController(
      text: tx?.description ?? '',
    );
    _selectedCategory = tx?.category ?? AppConstants.expenseCategories.first;
    _selectedDate = tx?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveForm() {
    if (!_formKey.currentState!.validate()) return;

    final amount = double.parse(_amountController.text);
    final provider = Provider.of<TransactionProvider>(context, listen: false);

    if (widget.transactionToEdit == null) {
      // Create new
      final newTx = TransactionModel(
        type: _type,
        amount: amount,
        category: _selectedCategory,
        date: _selectedDate,
        description: _descriptionController.text.trim(),
      );
      provider.addTransaction(newTx);
    } else {
      // Edit existing
      final updatedTx = widget.transactionToEdit!.copyWith(
        type: _type,
        amount: amount,
        category: _selectedCategory,
        date: _selectedDate,
        description: _descriptionController.text.trim(),
      );
      provider.updateTransaction(updatedTx);
    }

    Navigator.pop(context);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final categories = _type == 'expense'
        ? AppConstants.expenseCategories
        : AppConstants.incomeCategories;

    if (!categories.contains(_selectedCategory)) {
      _selectedCategory = categories.first;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transactionToEdit == null ? 'Add Transaction' : 'Edit Transaction'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Type Toggle
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _type = 'income'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _type == 'income' ? const Color(0xFF00B894) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '○ Income',
                            style: TextStyle(
                              color: _type == 'income' ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _type = 'expense'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _type == 'expense' ? const Color(0xFFFF7675) : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '● Expense',
                            style: TextStyle(
                              color: _type == 'expense' ? Colors.white : Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Amount
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount (${provider.selectedCurrency})',
                  hintText: '0.00',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.attach_money),
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Please enter an amount';
                  final parsed = double.tryParse(val);
                  if (parsed == null || parsed <= 0) return 'Please enter a valid positive number';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Category Dropdown
              DropdownButtonFormField<String>(
                initialValue: _selectedCategory,
                decoration: InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: categories.map((cat) {
                  final icon = AppConstants.categoryIcons[cat] ?? Icons.circle;
                  return DropdownMenuItem(
                    value: cat,
                    child: Row(
                      children: [
                        Icon(icon, size: 20),
                        const SizedBox(width: 10),
                        Text(cat),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedCategory = val);
                },
              ),
              const SizedBox(height: 20),

              // Date Selector
              InkWell(
                onTap: _pickDate,
                borderRadius: BorderRadius.circular(16),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    prefixIcon: const Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    AppHelpers.formatDate(_selectedDate),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  hintText: 'e.g. Lunch with team',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  prefixIcon: const Icon(Icons.description),
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C5CE7),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(
                    widget.transactionToEdit == null ? 'SAVE TRANSACTION' : 'UPDATE TRANSACTION',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
