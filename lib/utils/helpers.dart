import 'package:intl/intl.dart';

class AppHelpers {
  static String formatCurrency(double amount, {String symbol = '₹'}) {
    final formatter = NumberFormat.currency(
      symbol: '$symbol ',
      decimalDigits: amount.truncateToDouble() == amount ? 0 : 2,
    );
    return formatter.format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatMonth(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  static String formatMonthKey(DateTime date) {
    return DateFormat('yyyy-MM').format(date);
  }
}
