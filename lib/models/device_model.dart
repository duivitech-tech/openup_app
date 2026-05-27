// lib/models/device_model.dart

class DeviceModel {
  final int messagesLeft;
  final bool isPremium;

  const DeviceModel({
    required this.messagesLeft,
    required this.isPremium,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      messagesLeft: (json['messagesLeft'] as num?)?.toInt() ?? 0,
      isPremium: json['isPremium'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'messagesLeft': messagesLeft,
        'isPremium': isPremium,
      };

  DeviceModel copyWith({int? messagesLeft, bool? isPremium}) {
    return DeviceModel(
      messagesLeft: messagesLeft ?? this.messagesLeft,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  @override
  String toString() =>
      'DeviceModel(messagesLeft: $messagesLeft, isPremium: $isPremium)';
}

/// Response from /api/device/deduct
class DeductResponse {
  final bool allowed;
  final int? messagesLeft;
  final String? reason;

  const DeductResponse({
    required this.allowed,
    this.messagesLeft,
    this.reason,
  });

  factory DeductResponse.fromJson(Map<String, dynamic> json) {
    return DeductResponse(
      allowed: json['allowed'] as bool? ?? false,
      messagesLeft: (json['messagesLeft'] as num?)?.toInt(),
      reason: json['reason'] as String?,
    );
  }
}
