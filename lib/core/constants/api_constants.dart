// lib/core/constants/api_constants.dart

class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://openup-backend.vercel.app';

  // Device endpoints
  static const String deviceInit   = '/api/device/init';
  static const String deviceDeduct = '/api/device/deduct';

  // Payment endpoints
  static const String paymentInitiate = '/api/payment/initiate';

  // User endpoints
  static const String registerPremium = '/api/user/register-premium';
  static const String checkName       = '/api/user/check-name';
  static const String userProfile     = '/api/user/profile';   // GET  ?userId=
  static const String userLogout      = '/api/user/logout';    // POST { userId }

  // Auth endpoints
  static const String authSignup  = '/api/auth/signup';   // POST {deviceId, alias, pin}
  static const String authLogin   = '/api/auth/login';    // POST {deviceId, alias, pin}
  // Deprecated — kept for reference
  static const String authProfile = '/api/auth/profile';
  static const String authLogout  = '/api/auth/logout';

  // Timeouts
  static const int connectTimeout = 10000; // 10 seconds
  static const int receiveTimeout = 15000; // 15 seconds
}
