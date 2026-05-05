class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    required this.defaultCurrency,
    required this.onboardingComplete,
  });

  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final String defaultCurrency;
  final bool onboardingComplete;

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool clearPhotoUrl = false,
    String? defaultCurrency,
    bool? onboardingComplete,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: clearPhotoUrl ? null : (photoUrl ?? this.photoUrl),
      defaultCurrency: defaultCurrency ?? this.defaultCurrency,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUser &&
          runtimeType == other.runtimeType &&
          uid == other.uid &&
          email == other.email &&
          displayName == other.displayName &&
          photoUrl == other.photoUrl &&
          defaultCurrency == other.defaultCurrency &&
          onboardingComplete == other.onboardingComplete;

  @override
  int get hashCode =>
      uid.hashCode ^
      email.hashCode ^
      displayName.hashCode ^
      photoUrl.hashCode ^
      defaultCurrency.hashCode ^
      onboardingComplete.hashCode;

  @override
  String toString() =>
      'AppUser(uid: $uid, email: $email, displayName: $displayName, '
      'photoUrl: $photoUrl, defaultCurrency: $defaultCurrency, '
      'onboardingComplete: $onboardingComplete)';
}
