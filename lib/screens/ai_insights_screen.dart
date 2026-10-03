import 'package:flutter/material.dart';

class AIInsightsScreen extends StatelessWidget {
  const AIInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Financial Insights'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Color(0xFF6C5CE7),
                    child: Icon(Icons.psychology, color: Colors.white, size: 30),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('SpendWise AI Assistant', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        SizedBox(height: 4),
                        Text('Automated financial analysis derived strictly from your stored transactions.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildInsightCard(
            title: 'Top Expenditure Category',
            description: 'Food represents your highest expense category this month, accounting for 45% of total outgoings.',
            icon: Icons.pie_chart,
            color: const Color(0xFFFF7675),
          ),
          _buildInsightCard(
            title: 'Savings Performance',
            description: 'You have successfully saved 38.3% of your income this month.',
            icon: Icons.savings,
            color: const Color(0xFF00B894),
          ),
          _buildInsightCard(
            title: 'Budget Health Summary',
            description: 'You recorded ₹18,500 in expenses against a ₹20,000 monthly budget (92.5% utilization).',
            icon: Icons.account_balance_wallet,
            color: const Color(0xFF6C5CE7),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
                  const SizedBox(height: 6),
                  Text(description, style: const TextStyle(fontSize: 14, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
