abstract final class AppConfig {
  // Firestore collection names
  static const String usersCollection = 'users';
  static const String transactionsCollection = 'transactions';
  static const String recurringRulesCollection = 'recurring_rules';
  static const String budgetsCollection = 'budgets';
  static const String debtsCollection = 'debts';
  static const String alertsCollection = 'alerts';
  static const String exchangeRatesCollection = 'exchange_rates';

  // Firebase Storage paths
  static const String avatarsPath = 'avatars';

  // SharedPreferences keys
  static const String themeKey = 'theme_mode';
  static const String notificationsEnabledKey = 'notifications_enabled';
  static const String dateFormatKey = 'date_format';
  static const String defaultCurrencyKey = 'default_currency';

  // App defaults
  static const String defaultCurrency = 'MMK';
  static const String defaultDateFormat = 'MMM dd, yyyy';

  // Budget alert thresholds
  static const double warningThreshold = 0.8;
  static const double overdueThreshold = 1.0;
}
