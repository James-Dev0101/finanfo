import 'package:intl/intl.dart';

class CurrencyUtils {
  CurrencyUtils._();

  // Currencies whose symbol follows the number: "100,000 Ks" not "Ks100,000"
  static const _suffixCurrencies = {'MMK', 'VND', 'KRW', 'IDR'};

  static String format(double amount, String currencyCode, {bool compact = false}) {
    final symbol = symbolFor(currencyCode);
    final isSuffix = _suffixCurrencies.contains(currencyCode);

    if (compact) {
      final compactStr = NumberFormat.compact().format(amount);
      return isSuffix ? '$compactStr $symbol' : '$symbol$compactStr';
    }

    if (isSuffix) {
      final formatted = NumberFormat('#,##0', 'en_US').format(amount);
      return '$formatted $symbol';
    }

    return NumberFormat.currency(
      locale: 'en_US',
      symbol: symbol,
      decimalDigits: _decimalDigits(currencyCode),
    ).format(amount);
  }

  static String symbolFor(String code) {
    const symbols = {
      'USD': '\$',  'EUR': '€',   'GBP': '£',   'JPY': '¥',   'CNY': '¥',
      'INR': '₹',  'KRW': '₩',   'THB': '฿',   'MMK': 'Ks',  'SGD': 'S\$',
      'AUD': 'A\$', 'CAD': 'C\$', 'HKD': 'HK\$','NZD': 'NZ\$',
      'CHF': 'Fr',  'MXN': 'MX\$','BRL': 'R\$', 'ZAR': 'R',
      'PHP': '₱',  'VND': '₫',   'IDR': 'Rp',  'MYR': 'RM',
    };
    return symbols[code] ?? code;
  }

  static int _decimalDigits(String code) {
    const noDecimals = {'JPY', 'KRW', 'MMK', 'VND', 'IDR'};
    return noDecimals.contains(code) ? 0 : 2;
  }

  static double convert(double amount, double fromRate, double toRate) {
    if (fromRate == 0) return 0;
    return (amount / fromRate) * toRate;
  }
}
