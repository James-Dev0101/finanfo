import 'package:intl/intl.dart';

class CurrencyUtils {
  CurrencyUtils._();

  static String format(double amount, String currencyCode, {bool compact = false}) {
    final symbol = symbolFor(currencyCode);
    if (compact) {
      return '$symbol${NumberFormat.compact().format(amount)}';
    }
    return NumberFormat.currency(
      locale: 'en_US',
      symbol: symbol,
      decimalDigits: _decimalDigits(currencyCode),
    ).format(amount);
  }

  static String symbolFor(String code) {
    const symbols = {
      'USD': '\$', 'EUR': '€', 'GBP': '£', 'JPY': '¥', 'CNY': '¥',
      'INR': '₹', 'KRW': '₩', 'THB': '฿', 'MMK': 'K', 'SGD': 'S\$',
      'AUD': 'A\$', 'CAD': 'C\$', 'HKD': 'HK\$', 'NZD': 'NZ\$',
      'CHF': 'Fr', 'MXN': 'MX\$', 'BRL': 'R\$', 'ZAR': 'R',
      'PHP': '₱', 'VND': '₫', 'IDR': 'Rp', 'MYR': 'RM',
    };
    return symbols[code] ?? code;
  }

  static int _decimalDigits(String code) {
    const noDecimals = {'JPY', 'KRW', 'MMK', 'VND'};
    return noDecimals.contains(code) ? 0 : 2;
  }

  static double convert(double amount, double fromRate, double toRate) {
    if (fromRate == 0) return 0;
    return (amount / fromRate) * toRate;
  }
}
