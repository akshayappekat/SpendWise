// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:spendwise/main.dart';

import 'package:flutter/services.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/sqflite'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'getDatabasesPath') {
          return '/tmp';
        }
        if (methodCall.method == 'openDatabase') {
          return 1;
        }
        if (methodCall.method == 'query' || methodCall.method == 'insert') {
          return [];
        }
        return null;
      },
    );
  });

  testWidgets('SpendWiseApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SpendWiseApp());
    await tester.pump();
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Transactions'), findsWidgets);
    expect(find.text('Analytics'), findsWidgets);
    expect(find.text('Budget'), findsWidgets);
    expect(find.text('More'), findsWidgets);
  });
}
