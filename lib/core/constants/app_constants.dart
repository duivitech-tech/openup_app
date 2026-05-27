// lib/core/constants/app_constants.dart

class AppConstants {
  AppConstants._();

  // ─── Storage Keys ───────────────────────────────────────────────────────────
  static const String keyDeviceId = 'device_id';
  static const String keyMessagesLeft = 'messages_left';
  static const String keyIsPremium = 'is_premium';
  static const String keyNickname = 'nickname';
  static const String keyGeneratedUsername = 'generated_username';
  static const String keyPlanType = 'plan_type';
  static const String keyExpiryDate = 'expiry_date';
  static const String keyPin = 'pin';
  static const String keyAuthToken = 'auth_token';
  static const String keyUserId = 'user_id';

  // ─── Spacing ─────────────────────────────────────────────────────────────────
  static const double spaceXS = 8.0;
  static const double spaceSM = 12.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 20.0;
  static const double spaceXL = 24.0;
  static const double spaceXXL = 32.0;

  // ─── Border Radii ────────────────────────────────────────────────────────────
  static const double radiusCard = 12.0;
  static const double radiusButton = 10.0;
  static const double radiusInput = 8.0;
  static const double radiusBadge = 20.0;

  // ─── Component Sizes ─────────────────────────────────────────────────────────
  static const double buttonHeight = 52.0;
  static const double inputHeight = 48.0;
  static const double settingsRowHeight = 52.0;

  // ─── Animation Durations ─────────────────────────────────────────────────────
  static const int splashDurationMs = 1800;
  static const int fadeAnimationMs = 500;
  static const int pageTransitionMs = 200;
  static const int messageAnimationMs = 200;
  static const int buttonScaleMs = 100;

  // ─── Message Config ──────────────────────────────────────────────────────────
  static const double userBubbleMaxWidth = 0.75;
  static const double aiBubbleMaxWidth = 0.80;

  // ─── AI Mock Response Config ─────────────────────────────────────────────────
  static const int aiTypingDelayMs = 1200;
  static const int aiStreamCharDelayMs = 18;

  // ─── Plan Types ──────────────────────────────────────────────────────────────
  static const String planDaily = 'daily';
  static const String planWeekly = 'weekly';
  static const String planMonthly = 'monthly';

  // ─── Default Free Message Count ──────────────────────────────────────────────
  static const int defaultFreeMessages = 15;
}
