// lib/core/constants/api_constants.dart

class ApiConstants {
  ApiConstants._();

  static const String baseUrl = 'https://openup-backend.vercel.app';

  // Device endpoints
  static const String deviceInit = '/api/device/init';
  static const String deviceDeduct = '/api/device/deduct';

  // Payment endpoints
  static const String paymentInitiate = '/api/payment/initiate';

  // User endpoints
  static const String registerPremium = '/api/user/register-premium';
  static const String checkName = '/api/user/check-name';

  // Auth endpoints (for login flow)
  static const String authLogin = '/api/auth/login';
  static const String authSignup = '/api/auth/signup';

  // Timeouts
  static const int connectTimeout = 10000; // 10 seconds
  static const int receiveTimeout = 15000; // 15 seconds
}
