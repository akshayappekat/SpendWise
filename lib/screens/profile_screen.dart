import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/transaction_provider.dart';
import '../services/firebase_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out of SpendWise?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7675),
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      txProvider.clearUserData();
      await authProvider.logout();
      if (context.mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final firebaseService = FirebaseService();
    final user = authProvider.currentUser;

    final userName = user?.name ?? 'User';
    final userEmail = user?.email ?? 'No email set';
    final avatarLetter = userName.isNotEmpty ? userName[0].toUpperCase() : 'U';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // User Info Header
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: const Color(0xFF6C5CE7),
                    child: Text(
                      avatarLetter,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          userEmail,
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Preferences Section
          const Text('Preferences', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.currency_exchange, color: Color(0xFF6C5CE7)),
                  title: const Text('Currency Symbol'),
                  trailing: DropdownButton<String>(
                    value: provider.selectedCurrency,
                    items: ['₹', '\$', '€', '£', '¥'].map((symbol) {
                      return DropdownMenuItem(value: symbol, child: Text(symbol));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) provider.setCurrency(val);
                    },
                  ),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.dark_mode, color: Color(0xFF6C5CE7)),
                  title: const Text('Dark Mode Theme'),
                  value: provider.isDarkMode,
                  onChanged: (val) => provider.toggleTheme(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Synchronization Section
          const Text('Cloud & Sync', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.cloud_done, color: Color(0xFF00B894)),
                  title: const Text('Firebase Sync'),
                  subtitle: Text(
                    firebaseService.isLoggedIn ? 'Synced with cloud' : 'Offline local database mode',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: ElevatedButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      if (!firebaseService.isLoggedIn) {
                        await firebaseService.signInWithEmail(userEmail, 'password');
                        if (context.mounted) {
                          messenger.showSnackBar(
                            const SnackBar(content: Text('Signed in with Firebase successfully!')),
                          );
                        }
                      } else {
                        await firebaseService.signOut();
                      }
                      provider.refreshState();
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C5CE7)),
                    child: Text(firebaseService.isLoggedIn ? 'Sign Out' : 'Connect', style: const TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Account Action / Logout Section
          const Text('Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFFF7675)),
              title: const Text(
                'Log Out',
                style: TextStyle(color: Color(0xFFFF7675), fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('End session & return to login screen', style: TextStyle(fontSize: 12)),
              onTap: () => _handleLogout(context),
            ),
          ),
          const SizedBox(height: 24),

          // App Info
          const Center(
            child: Text(
              'SpendWise v1.0.0 • Built with Flutter & Dart',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
