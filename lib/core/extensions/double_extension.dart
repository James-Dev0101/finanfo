import 'package:intl/intl.dart';

extension DoubleX on double {
  String formatCurrency(String currencyCode, {bool compact = false}) {
    final format = compact
        ? NumberFormat.compactCurrency(
            locale: 'en_US',
            symbol: _currencySymbol(currencyCode),
            decimalDigits: 0,
          )
        : NumberFormat.currency(
            locale: 'en_US',
            symbol: _currencySymbol(currencyCode),
            decimalDigits: 2,
          );
    return format.format(this);
  }

  String toCompact() => NumberFormat.compact(locale: 'en_US').format(this);

  String _currencySymbol(String code) {
    final symbols = {
      'USD': '\$',
      'EUR': '€',
      'GBP': '£',
      'JPY': '¥',
      'CNY': '¥',
      'INR': '₹',
      'KRW': '₩',
      'THB': '฿',
      'MMK': 'K',
      'SGD': 'S\$',
      'AUD': 'A\$',
      'CAD': 'C\$',
      'HKD': 'HK\$',
    };
    return symbols[code] ?? code;
  }
}

extension NumX on num {
  double get toDouble => this is double ? this as double : (this as int).toDouble();
}
