import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'database_service.dart';

/// Local Authentication Service for SpendWise application.
/// 
/// NOTE ON SECURITY: This implementation provides local database authentication
/// for offline application use. Passwords are password-verified against local SQLite
/// storage and user sessions are stored using SharedPreferences.
/// For cloud production systems, integrate Firebase Auth or OAuth backend.
class AuthService {
  static const String _keyUserId = 'spendwise_logged_in_user_id';
  static const String _keyUserName = 'spendwise_logged_in_user_name';
  static const String _keyUserEmail = 'spendwise_logged_in_user_email';

  /// Authenticate an existing user by email and password
  Future<UserModel> loginUser({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanEmail.isEmpty || cleanPassword.isEmpty) {
      throw Exception('Email and password must not be empty.');
    }

    final user = await DatabaseService.instance.getUserByEmail(cleanEmail);
    if (user == null) {
      throw Exception('No account found with this email address.');
    }

    if (user.password != cleanPassword) {
      throw Exception('Invalid password. Please check your credentials.');
    }

    // Save active session locally
    await _saveSession(user);

    return user;
  }

  /// Register a new user with unique ID, name, email, and password
  Future<UserModel> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    final cleanName = name.trim();
    final cleanEmail = email.trim().toLowerCase();
    final cleanPassword = password.trim();

    if (cleanName.isEmpty) {
      throw Exception('Please enter your full name.');
    }
    if (cleanEmail.isEmpty || !cleanEmail.contains('@') || !cleanEmail.contains('.')) {
      throw Exception('Please enter a valid email address.');
    }
    if (cleanPassword.length < 6) {
      throw Exception('Password must be at least 6 characters long.');
    }

    // Check if email already exists
    final existingUser = await DatabaseService.instance.getUserByEmail(cleanEmail);
    if (existingUser != null) {
      throw Exception('An account with this email already exists.');
    }

    final newUser = UserModel(
      name: cleanName,
      email: cleanEmail,
      password: cleanPassword,
    );

    final savedUser = await DatabaseService.instance.createUser(newUser);

    // Save session locally
    await _saveSession(savedUser);

    return savedUser;
  }

  /// Load currently saved session from SharedPreferences on app startup
  Future<UserModel?> getSavedSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt(_keyUserId);

    if (userId == null) {
      return null;
    }

    // Attempt to verify with local database
    final userFromDb = await DatabaseService.instance.getUserById(userId);
    if (userFromDb != null) {
      return userFromDb;
    }

    // Fallback to cached preferences
    final name = prefs.getString(_keyUserName);
    final email = prefs.getString(_keyUserEmail);
    if (name != null && email != null) {
      return UserModel(id: userId, name: name, email: email);
    }

    return null;
  }

  /// Clear active session from SharedPreferences on Logout
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyUserEmail);
  }

  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    if (user.id != null) {
      await prefs.setInt(_keyUserId, user.id!);
    }
    await prefs.setString(_keyUserName, user.name);
    await prefs.setString(_keyUserEmail, user.email);
  }
}
