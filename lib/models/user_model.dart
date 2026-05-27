// lib/models/user_model.dart

class UserModel {
  final String alias;
  final String? generatedUsername;
  final bool isPremium;
  final String? planType;
  final String? expiryDate;

  const UserModel({
    required this.alias,
    this.generatedUsername,
    this.isPremium = false,
    this.planType,
    this.expiryDate,
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

  UserModel copyWith({
    String? alias,
    String? generatedUsername,
    bool? isPremium,
    String? planType,
    String? expiryDate,
  }) {
    return UserModel(
      alias: alias ?? this.alias,
      generatedUsername: generatedUsername ?? this.generatedUsername,
      isPremium: isPremium ?? this.isPremium,
      planType: planType ?? this.planType,
      expiryDate: expiryDate ?? this.expiryDate,
    );
  }

  @override
  String toString() =>
      'UserModel(alias: $alias, isPremium: $isPremium, plan: $planType)';
}

/// Response from /api/user/register-premium
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
