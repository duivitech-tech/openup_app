// lib/models/device_model.dart

class DeviceModel {
  final bool registered;

  const DeviceModel({required this.registered});

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      registered: json['registered'] as bool? ?? false,
    );
  }
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
