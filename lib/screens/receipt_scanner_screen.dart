import 'package:flutter/material.dart';

class ReceiptScannerScreen extends StatefulWidget {
  const ReceiptScannerScreen({super.key});

  @override
  State<ReceiptScannerScreen> createState() => _ReceiptScannerScreenState();
}

class _ReceiptScannerScreenState extends State<ReceiptScannerScreen> {
  bool _isScanning = false;
  bool _scanned = false;

  final _merchantController = TextEditingController(text: 'Starbucks Coffee');
  final _amountController = TextEditingController(text: '380.00');
  String _category = 'Food';

  @override
  void dispose() {
    _merchantController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _scanReceipt() async {
    setState(() => _isScanning = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isScanning = false;
      _scanned = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receipt Scanner'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _scanReceipt,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFF6C5CE7), width: 2),
                ),
                child: _isScanning
                    ? const Center(child: CircularProgressIndicator())
                    : const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 48, color: Color(0xFF6C5CE7)),
                          SizedBox(height: 12),
                          Text('Tap to Take/Upload Receipt Photo', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Supports JPG, PNG, WEBP', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 24),
            if (_scanned) ...[
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Extracted Receipt Data', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _merchantController,
                        decoration: const InputDecoration(labelText: 'Merchant / Description', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _amountController,
                        decoration: const InputDecoration(labelText: 'Amount (₹)', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _category,
                        decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
                        items: ['Food', 'Shopping', 'Transport', 'Bills', 'Health', 'Other']
                            .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (val) => setState(() => _category = val!),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Transaction saved from receipt!')),
                            );
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
                          child: const Text('CONFIRM & SAVE TRANSACTION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ]
          ],
        ),
      ),
    );
  }
}
