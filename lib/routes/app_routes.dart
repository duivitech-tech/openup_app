// lib/routes/app_routes.dart

import 'package:get/get.dart';
import '../modules/splash/binding.dart';
import '../modules/splash/view.dart';
import '../modules/onboarding/binding.dart';
import '../modules/onboarding/view.dart';
import '../modules/identity/binding.dart';
import '../modules/identity/view.dart';
import '../modules/login/binding.dart';
import '../modules/login/view.dart';
import '../modules/home/binding.dart';
import '../modules/home/view.dart';
import '../modules/chat/binding.dart';
import '../modules/chat/view.dart';
import '../modules/premium/binding.dart';
import '../modules/premium/view.dart';
import '../modules/premium/register_view.dart';
import '../modules/premium/register_binding.dart';
import '../modules/profile/binding.dart';
import '../modules/profile/view.dart';

/// All named route constants for the app.
class AppRoutes {
  AppRoutes._();

  static const String splash          = '/';
  static const String onboarding      = '/onboarding';
  static const String identity        = '/identity';
  static const String login           = '/login';
  static const String home            = '/home';
  static const String chat            = '/chat';
  static const String premium         = '/premium';
  static const String premiumRegister = '/premium/register';
  static const String profile         = '/profile';
}

/// All GetPage definitions with bindings and transitions.
class AppPages {
  AppPages._();

  static final List<GetPage> pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.identity,
      page: () => const IdentityView(),
      binding: IdentityBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatView(),
      binding: ChatBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.premium,
      page: () => const PremiumView(),
      binding: PremiumBinding(),
      transition: Transition.downToUp,
      transitionDuration: const Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.premiumRegister,
      page: () => const PremiumRegisterView(),
      binding: PremiumRegisterBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
      transition: Transition.fade,
      transitionDuration: const Duration(milliseconds: 200),
    ),
  ];
}
