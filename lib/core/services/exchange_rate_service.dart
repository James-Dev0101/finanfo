import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class ExchangeRateService {
  ExchangeRateService(this._firestore);

  final FirebaseFirestore _firestore;

  static const _cacheKey = 'exchange_rates_cache';
  static const _baseCurrency = 'USD';

  Map<String, double>? _cachedRates;

  Future<Map<String, double>> getRates() async {
    if (_cachedRates != null) return _cachedRates!;

    // Try Firestore first
    try {
      final today = _todayKey();
      final doc = await _firestore
          .collection(AppConfig.exchangeRatesCollection)
          .doc(today)
          .get();

      if (doc.exists) {
        final rates = Map<String, double>.from(
          (doc.data()?['rates'] as Map<String, dynamic>? ?? {})
              .map((k, v) => MapEntry(k, (v as num).toDouble())),
        );
        rates[_baseCurrency] = 1.0;
        _cachedRates = rates;
        _persistLocally(rates);
        return rates;
      }
    } catch (_) {
      // Fall through to local cache
    }

    // Fall back to local cache
    return _loadLocal();
  }

  double convert({
    required double amount,
    required String from,
    required String to,
    required Map<String, double> rates,
  }) {
    if (from == to) return amount;
    final fromRate = rates[from] ?? 1.0;
    final toRate = rates[to] ?? 1.0;
    return (amount / fromRate) * toRate;
  }

  Future<void> _persistLocally(Map<String, double> rates) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_cacheKey, jsonEncode(rates));
  }

  Future<Map<String, double>> _loadLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw != null) {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        return decoded.map((k, v) => MapEntry(k, (v as num).toDouble()));
      }
    } catch (_) {}
    // Absolute fallback — USD only
    return {_baseCurrency: 1.0};
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
