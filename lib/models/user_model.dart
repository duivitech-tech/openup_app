// lib/models/user_model.dart

class UserModel {
  final String alias;
  final String? generatedUsername;
  final bool isPremium;
  final String? planType;
  final String? expiryDate;
  final int? messagesLeft;

  const UserModel({
    required this.alias,
    this.generatedUsername,
    this.isPremium = false,
    this.planType,
    this.expiryDate,
    this.messagesLeft,
  });

  factory UserModel.fromStorage({
    required String alias,
    String? generatedUsername,
    String? isPremiumStr,
    String? planType,
    String? expiryDate,
  }) {
    return UserModel(
      alias: alias,
      generatedUsername: generatedUsername,
      isPremium: isPremiumStr == 'true',
      planType: planType,
      expiryDate: expiryDate,
    );
  }

  /// Parse from GET /api/user/profile response.
  /// Shape: { id, name, deviceId, isPremium, subscriptionExpiry, messagesLeft, createdAt }
  factory UserModel.fromProfileJson(Map<String, dynamic> json) {
    // Support both flat and nested { user: {...} } structures
    final data = json.containsKey('user')
        ? json['user'] as Map<String, dynamic>
        : json;
    return UserModel(
      alias: data['alias'] as String? ?? data['name'] as String? ?? '',
      generatedUsername: data['generatedUsername'] as String?,
      isPremium: data['isPremium'] as bool? ?? false,
      planType: data['planType'] as String?,
      expiryDate: data['expiryDate'] as String? ?? data['subscriptionExpiry'] as String?,
      messagesLeft: data['messagesLeft'] as int?,
    );
  }

  UserModel copyWith({
    String? alias,
    String? generatedUsername,
    bool? isPremium,
    String? planType,
    String? expiryDate,
    int? messagesLeft,
  }) {
    return UserModel(
      alias: alias ?? this.alias,
      generatedUsername: generatedUsername ?? this.generatedUsername,
      isPremium: isPremium ?? this.isPremium,
      planType: planType ?? this.planType,
      expiryDate: expiryDate ?? this.expiryDate,
      messagesLeft: messagesLeft ?? this.messagesLeft,
    );
  }

  @override
  String toString() =>
      'UserModel(alias: $alias, isPremium: $isPremium, plan: $planType, messagesLeft: $messagesLeft)';
}

// ─── Auth response (signup + login) ──────────────────────────────────────────

class AuthResponse {
  final bool success;
  final String? accessToken;
  final String? refreshToken;
  final String? userId;
  final UserModel? user;
  final String? error;

  const AuthResponse({
    required this.success,
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.user,
    this.error,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    UserModel? user;
    if (json.containsKey('user') && json['user'] != null) {
      user = UserModel.fromProfileJson(json);
    } else if (json.containsKey('name') || json.containsKey('alias')) {
      user = UserModel.fromProfileJson(json);
    }
    return AuthResponse(
      success: json['success'] as bool? ?? false,
      accessToken: json['accessToken'] as String?,
      refreshToken: json['refreshToken'] as String?,
      userId: json['userId'] as String?,
      user: user,
      error: json['error'] as String?,
    );
  }
}

// ─── Register premium response ────────────────────────────────────────────────

class RegisterPremiumResponse {
  final bool success;
  final String? generatedUsername;
  final String? expiryDate;
  final String? error;

  const RegisterPremiumResponse({
    required this.success,
    this.generatedUsername,
    this.expiryDate,
    this.error,
  });

  factory RegisterPremiumResponse.fromJson(Map<String, dynamic> json) {
    return RegisterPremiumResponse(
      success: json['success'] as bool? ?? false,
      generatedUsername: json['generatedUsername'] as String?,
      expiryDate: json['expiryDate'] as String?,
      error: json['error'] as String?,
    );
  }
}
