import '../models/transaction_model.dart';

/// Optional Firebase integration service for cloud sync & authentication
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  bool _isLoggedIn = false;
  String? _userEmail;

  bool get isLoggedIn => _isLoggedIn;
  String? get userEmail => _userEmail;

  Future<bool> signInWithEmail(String email, String password) async {
    // Scaffold for Firebase Auth signInWithEmailAndPassword
    await Future.delayed(const Duration(milliseconds: 800));
    _isLoggedIn = true;
    _userEmail = email;
    return true;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _isLoggedIn = false;
    _userEmail = null;
  }

  Future<void> syncTransactionToCloud(TransactionModel transaction) async {
    if (!_isLoggedIn) return;
    // Scaffold for Firestore collection('transactions').doc().set(...)
    await Future.delayed(const Duration(milliseconds: 500));
  }
}
