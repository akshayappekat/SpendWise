import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart' as path;
import '../models/user_model.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static sqflite.Database? _database;

  DatabaseService._init();

  Future<sqflite.Database?> get database async {
    if (kIsWeb) return null;
    if (_database != null) return _database!;
    _database = await _initDB('spendwise.db');
    return _database!;
  }

  Future<sqflite.Database> _initDB(String filePath) async {
    final dbPath = await sqflite.getDatabasesPath();
    final dbFile = path.join(dbPath, filePath);

    return await sqflite.openDatabase(
      dbFile,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _onUpgradeDB,
    );
  }

  Future<void> _createDB(sqflite.Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const intNullableType = 'INTEGER';

    await db.execute('''
      CREATE TABLE users (
        id $idType,
        name $textType,
        email TEXT UNIQUE NOT NULL,
        password $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id $idType,
        userId $intNullableType,
        type $textType,
        amount $realType,
        category $textType,
        paymentMethod TEXT,
        date $textType,
        description $textType
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id $idType,
        userId $intNullableType,
        month $textType,
        amount $realType
      )
    ''');

    final userId = await db.insert('users', {
      'name': 'Akshay',
      'email': 'akshay@example.com',
      'password': 'password123',
    });

    final initialDate = DateTime(2026, 9, 28);
    await db.insert('transactions', {
      'userId': userId,
      'type': 'income',
      'amount': 30000.0,
      'category': 'Salary',
      'paymentMethod': 'Bank Transfer',
      'date': initialDate.subtract(const Duration(days: 2)).toIso8601String(),
      'description': 'Monthly Salary',
    });
    await db.insert('transactions', {
      'userId': userId,
      'type': 'expense',
      'amount': 500.0,
      'category': 'Transport',
      'paymentMethod': 'UPI',
      'date': initialDate.subtract(const Duration(days: 1)).toIso8601String(),
      'description': 'Fuel refill',
    });
    await db.insert('transactions', {
      'userId': userId,
      'type': 'expense',
      'amount': 250.0,
      'category': 'Food',
      'paymentMethod': 'Cash',
      'date': initialDate.toIso8601String(),
      'description': 'Lunch',
    });

    await db.insert('budgets', {
      'userId': userId,
      'month': '2026-09',
      'amount': 20000.0,
    });
  }

  Future<void> _onUpgradeDB(sqflite.Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          email TEXT UNIQUE NOT NULL,
          password TEXT NOT NULL
        )
      ''');

      try {
        await db.execute('ALTER TABLE transactions ADD COLUMN userId INTEGER');
      } catch (_) {}

      try {
        await db.execute('ALTER TABLE budgets ADD COLUMN userId INTEGER');
      } catch (_) {}
    }
  }

  // --- WEB PERSISTENCE HELPERS ---
  static const String _webUsersKey = 'spendwise_web_users_db';
  static const String _webTxKey = 'spendwise_web_tx_db';
  static const String _webBudgetsKey = 'spendwise_web_budgets_db';

  Future<void> _initWebDataIfNeeded() async {
    if (!kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_webUsersKey)) {
      final demoUser = {'id': 1, 'name': 'Akshay', 'email': 'akshay@example.com', 'password': 'password123'};
      await prefs.setString(_webUsersKey, jsonEncode([demoUser]));

      final initialDate = DateTime(2026, 9, 28);
      final demoTxs = [
        {
          'id': 1,
          'userId': 1,
          'type': 'income',
          'amount': 30000.0,
          'category': 'Salary',
          'paymentMethod': 'Bank Transfer',
          'date': initialDate.subtract(const Duration(days: 2)).toIso8601String(),
          'description': 'Monthly Salary',
        },
        {
          'id': 2,
          'userId': 1,
          'type': 'expense',
          'amount': 500.0,
          'category': 'Transport',
          'paymentMethod': 'UPI',
          'date': initialDate.subtract(const Duration(days: 1)).toIso8601String(),
          'description': 'Fuel refill',
        },
        {
          'id': 3,
          'userId': 1,
          'type': 'expense',
          'amount': 250.0,
          'category': 'Food',
          'paymentMethod': 'Cash',
          'date': initialDate.toIso8601String(),
          'description': 'Lunch',
        }
      ];
      await prefs.setString(_webTxKey, jsonEncode(demoTxs));

      final demoBudget = [{'id': 1, 'userId': 1, 'month': '2026-09', 'amount': 20000.0}];
      await prefs.setString(_webBudgetsKey, jsonEncode(demoBudget));
    }
  }

  // --- USER OPERATIONS ---

  Future<UserModel> createUser(UserModel user) async {
    if (kIsWeb) {
      await _initWebDataIfNeeded();
      final prefs = await SharedPreferences.getInstance();
      final list = jsonDecode(prefs.getString(_webUsersKey) ?? '[]') as List;
      final newId = list.isEmpty ? 1 : ((list.last['id'] as int) + 1);
      final newUserMap = user.toMap();
      newUserMap['id'] = newId;
      list.add(newUserMap);
      await prefs.setString(_webUsersKey, jsonEncode(list));
      return user.copyWith(id: newId);
    } else {
      final db = (await database)!;
      final id = await db.insert('users', user.toMap());
      return user.copyWith(id: id);
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final cleanEmail = email.toLowerCase().trim();
    if (kIsWeb) {
      await _initWebDataIfNeeded();
      final prefs = await SharedPreferences.getInstance();
      final list = jsonDecode(prefs.getString(_webUsersKey) ?? '[]') as List;
      for (var item in list) {
        if ((item['email'] as String).toLowerCase().trim() == cleanEmail) {
          return UserModel.fromMap(Map<String, dynamic>.from(item as Map));
        }
      }
      return null;
    } else {
      try {
        final db = (await database)!;
        final maps = await db.query(
          'users',
          where: 'LOWER(email) = ?',
          whereArgs: [cleanEmail],
        );
        if (maps.isNotEmpty) {
          return UserModel.fromMap(maps.first);
        }
        return null;
      } catch (_) {
        return null;
      }
    }
  }

  Future<UserModel?> getUserById(int id) async {
    if (kIsWeb) {
      await _initWebDataIfNeeded();
      final prefs = await SharedPreferences.getInstance();
      final list = jsonDecode(prefs.getString(_webUsersKey) ?? '[]') as List;
      for (var item in list) {
        if (item['id'] == id) {
          return UserModel.fromMap(Map<String, dynamic>.from(item as Map));
        }
      }
      return null;
    } else {
      try {
        final db = (await database)!;
        final maps = await db.query(
          'users',
          where: 'id = ?',
          whereArgs: [id],
        );
        if (maps.isNotEmpty) {
          return UserModel.fromMap(maps.first);
        }
        return null;
      } catch (_) {
        return null;
      }
    }
  }

  // --- TRANSACTION OPERATIONS ---

  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    if (kIsWeb) {
      await _initWebDataIfNeeded();
      final prefs = await SharedPreferences.getInstance();
      final list = jsonDecode(prefs.getString(_webTxKey) ?? '[]') as List;
      final newId = DateTime.now().millisecondsSinceEpoch;
      final txMap = transaction.toMap();
      txMap['id'] = newId;
      list.insert(0, txMap);
      await prefs.setString(_webTxKey, jsonEncode(list));
      return transaction.copyWith(id: newId);
    } else {
      try {
        final db = (await database)!;
        final id = await db.insert('transactions', transaction.toMap());
        return transaction.copyWith(id: id);
      } catch (_) {
        return transaction;
      }
    }
  }

  Future<List<TransactionModel>> getTransactionsByUser(int userId) async {
    if (kIsWeb) {
      await _initWebDataIfNeeded();
      final prefs = await SharedPreferences.getInstance();
      final list = jsonDecode(prefs.getString(_webTxKey) ?? '[]') as List;
      final result = <TransactionModel>[];
      for (var item in list) {
        final map = Map<String, dynamic>.from(item as Map);
        if (map['userId'] == userId) {
          result.add(TransactionModel.fromMap(map));
        }
      }
      result.sort((a, b) => b.date.compareTo(a.date));
      return result;
    } else {
      try {
        final db = (await database)!;
        final result = await db.query(
          'transactions',
          where: 'userId = ?',
          whereArgs: [userId],
          orderBy: 'date DESC',
        );
        return result.map((json) => TransactionModel.fromMap(json)).toList();
      } catch (_) {
        return [];
      }
    }
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    if (kIsWeb) {
      await _initWebDataIfNeeded();
      final prefs = await SharedPreferences.getInstance();
      final list = jsonDecode(prefs.getString(_webTxKey) ?? '[]') as List;
      final result = list.map((item) => TransactionModel.fromMap(Map<String, dynamic>.from(item as Map))).toList();
      result.sort((a, b) => b.date.compareTo(a.date));
      return result;
    } else {
      try {
        final db = (await database)!;
        final result = await db.query('transactions', orderBy: 'date DESC');
        return result.map((json) => TransactionModel.fromMap(json)).toList();
      } catch (_) {
        return [];
      }
    }
  }

  Future<int> updateTransaction(TransactionModel transaction) async {
    if (kIsWeb) {
      await _initWebDataIfNeeded();
      final prefs = await SharedPreferences.getInstance();
      final list = jsonDecode(prefs.getString(_webTxKey) ?? '[]') as List;
      for (int i = 0; i < list.length; i++) {
        if (list[i]['id'] == transaction.id) {
          list[i] = transaction.toMap();
          await prefs.setString(_webTxKey, jsonEncode(list));
          return 1;
        }
      }
      return 0;
    } else {
      try {
        final db = (await database)!;
        return await db.update(
          'transactions',
          transaction.toMap(),
          where: 'id = ?',
          whereArgs: [transaction.id],
        );
      } catch (_) {
        return 0;
      }
    }
  }

  Future<int> deleteTransaction(int id) async {
    if (kIsWeb) {
      await _initWebDataIfNeeded();
      final prefs = await SharedPreferences.getInstance();
      final list = jsonDecode(prefs.getString(_webTxKey) ?? '[]') as List;
      final initialLength = list.length;
      list.removeWhere((item) => item['id'] == id);
      if (list.length < initialLength) {
        await prefs.setString(_webTxKey, jsonEncode(list));
        return 1;
      }
      return 0;
    } else {
      try {
        final db = (await database)!;
        return await db.delete(
          'transactions',
          where: 'id = ?',
          whereArgs: [id],
        );
      } catch (_) {
        return 0;
      }
    }
  }

  // --- BUDGET OPERATIONS ---

  Future<BudgetModel?> getBudget(String month, int userId) async {
    if (kIsWeb) {
      await _initWebDataIfNeeded();
      final prefs = await SharedPreferences.getInstance();
      final list = jsonDecode(prefs.getString(_webBudgetsKey) ?? '[]') as List;
      for (var item in list) {
        final map = Map<String, dynamic>.from(item as Map);
        if (map['month'] == month && map['userId'] == userId) {
          return BudgetModel.fromMap(map);
        }
      }
      return null;
    } else {
      try {
        final db = (await database)!;
        final maps = await db.query(
          'budgets',
          where: 'month = ? AND userId = ?',
          whereArgs: [month, userId],
        );
        if (maps.isNotEmpty) {
          return BudgetModel.fromMap(maps.first);
        }
        return null;
      } catch (_) {
        return null;
      }
    }
  }

  Future<void> setBudget(BudgetModel budget) async {
    if (kIsWeb) {
      await _initWebDataIfNeeded();
      final prefs = await SharedPreferences.getInstance();
      final list = jsonDecode(prefs.getString(_webBudgetsKey) ?? '[]') as List;
      bool updated = false;
      for (int i = 0; i < list.length; i++) {
        if (list[i]['month'] == budget.month && list[i]['userId'] == budget.userId) {
          list[i] = budget.toMap();
          updated = true;
          break;
        }
      }
      if (!updated) {
        final bMap = budget.toMap();
        bMap['id'] = DateTime.now().millisecondsSinceEpoch;
        list.add(bMap);
      }
      await prefs.setString(_webBudgetsKey, jsonEncode(list));
    } else {
      try {
        final db = (await database)!;
        final existing = await db.query(
          'budgets',
          where: 'month = ? AND userId = ?',
          whereArgs: [budget.month, budget.userId],
        );

        if (existing.isNotEmpty) {
          await db.update(
            'budgets',
            budget.toMap(),
            where: 'id = ?',
            whereArgs: [existing.first['id']],
          );
        } else {
          await db.insert('budgets', budget.toMap());
        }
      } catch (_) {}
    }
  }
}
