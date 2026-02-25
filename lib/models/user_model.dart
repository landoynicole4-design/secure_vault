class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final bool isBiometricEnabled;
  final String provider; // 'email', 'google', 'facebook'
  final DateTime? createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.isBiometricEnabled = false,
    this.provider = 'email',
    this.createdAt,
  });

  // ── fromMap (used by Firestore) ────────────────────────────
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      photoUrl: map['photoUrl'],
      isBiometricEnabled: map['isBiometricEnabled'] ?? false,
      provider: map['provider'] ?? 'email',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : null,
    );
  }

  // ── toMap (used when saving to Firestore) ──────────────────
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isBiometricEnabled': isBiometricEnabled,
      'provider': provider,
      'createdAt': createdAt ?? DateTime.now(),
    };
  }

  // ── copyWith ───────────────────────────────────────────────
  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? isBiometricEnabled,
    String? provider,
    DateTime? createdAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      provider: provider ?? this.provider,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // ── Helper getters ─────────────────────────────────────────
  bool get hasPhoto => photoUrl != null && photoUrl!.isNotEmpty;
  bool get isGoogleUser => provider == 'google';
  bool get isFacebookUser => provider == 'facebook';
  bool get isEmailUser => provider == 'email';

  @override
  String toString() {
    return 'UserModel(uid: $uid, email: $email, displayName: $displayName, provider: $provider)';
  }
}
