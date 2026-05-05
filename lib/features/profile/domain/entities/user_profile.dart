class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.defaultCurrency,
    required this.createdAt,
    this.totalTransactions = 0,
  });

  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String defaultCurrency;
  final DateTime createdAt;
  final int totalTransactions;

  UserProfile copyWith({
    String? displayName,
    String? photoUrl,
    String? defaultCurrency,
    int? totalTransactions,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      createdAt: createdAt,
      totalTransactions: totalTransactions ?? this.totalTransactions,
    );
  }
}
