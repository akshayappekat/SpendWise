import 'package:flutter/material.dart';
import 'goals_screen.dart';
import 'recurring_screen.dart';
import 'receipt_scanner_screen.dart';
import 'ai_insights_screen.dart';
import 'profile_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final items = [
      _MoreOptionItem(
        title: 'Financial Goals',
        subtitle: 'Track progress towards your savings targets',
        icon: Icons.savings_outlined,
        iconColor: const Color(0xFF6C5CE7),
        badgeColor: const Color(0xFF6C5CE7).withValues(alpha: 0.12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GoalsScreen()),
        ),
      ),
      _MoreOptionItem(
        title: 'Recurring Transactions',
        subtitle: 'Manage subscriptions & regular bill payments',
        icon: Icons.autorenew_outlined,
        iconColor: const Color(0xFF00CEC9),
        badgeColor: const Color(0xFF00CEC9).withValues(alpha: 0.12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RecurringScreen()),
        ),
      ),
      _MoreOptionItem(
        title: 'Receipt Scanner',
        subtitle: 'Scan receipts to automatically record expenses',
        icon: Icons.camera_alt_outlined,
        iconColor: const Color(0xFF6C5CE7),
        badgeColor: const Color(0xFF6C5CE7).withValues(alpha: 0.12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ReceiptScannerScreen()),
        ),
      ),
      _MoreOptionItem(
        title: 'AI Insights',
        subtitle: 'Smart automated spending analysis & tips',
        icon: Icons.psychology_outlined,
        iconColor: const Color(0xFFA29BFE),
        badgeColor: const Color(0xFFA29BFE).withValues(alpha: 0.2),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AIInsightsScreen()),
        ),
      ),
      _MoreOptionItem(
        title: 'Settings & Profile',
        subtitle: 'Currency settings, theme & cloud sync',
        icon: Icons.person_outline,
        iconColor: const Color(0xFF00B894),
        badgeColor: const Color(0xFF00B894).withValues(alpha: 0.12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('More Options'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFFA29BFE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6C5CE7).withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.widgets_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SpendWise Features',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Access goals, subscriptions, scanner, AI tools & settings',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Tools & Preferences',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: isDark ? 2 : 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: item.onTap,
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: item.badgeColor,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              item.icon,
                              color: item.iconColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.subtitle,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            color: isDark ? Colors.grey[600] : Colors.grey[400],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }
}

class _MoreOptionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color badgeColor;
  final VoidCallback onTap;

  const _MoreOptionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.badgeColor,
    required this.onTap,
  });
}
