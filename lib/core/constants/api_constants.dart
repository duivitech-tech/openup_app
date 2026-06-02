// lib/core/constants/api_constants.dart

class ApiConstants {
  ApiConstants._();

  static const String baseUrl     = 'https://openup-backend.vercel.app';
  static const String chatBaseUrl = 'https://openup-chatbot.onrender.com';

  // Device endpoints
  static const String deviceInit   = '/api/device/init';
  static const String deviceDeduct = '/api/device/deduct';

  // Payment endpoints
  static const String paymentInitiate = '/api/payment/initiate';

  // Auth endpoints
  static const String authSignup   = '/api/auth/signup';   // POST {deviceId, name, password}
  static const String authLogin    = '/api/auth/login';    // POST {name, password}
  static const String authRefresh  = '/api/auth/refresh';  // POST {refreshToken}
  static const String authLogout   = '/api/auth/logout';   // POST Bearer accessToken

  // User endpoints
  static const String registerPremium = '/api/user/register-premium';
  static const String checkName       = '/api/user/check-name';
  static const String userProfile     = '/api/user/profile';  // GET Bearer accessToken

  // App endpoints
  static const String checkAppUpdate  = '/api/app/update/check'; // GET ?platform=android&version=1.0.0&versionCode=1

  // Timeouts
  static const int connectTimeout = 10000; // 10 seconds
  static const int receiveTimeout = 15000; // 15 seconds
}
