// lib/bindings/initial_binding.dart

import 'package:get/get.dart';
import '../network/dio_client.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../repositories/device_repository.dart';
import '../repositories/payment_repository.dart';
import '../repositories/user_repository.dart';

/// Injected at app startup via GetMaterialApp.initialBinding.
/// All services registered here are permanent singletons.
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Storage must be first — all others depend on it
    Get.put<StorageService>(StorageService(), permanent: true);

    // Network layer
    Get.put<DioClient>(DioClient(), permanent: true);

    // API service depends on DioClient
    Get.put<ApiService>(ApiService(), permanent: true);

    // Repositories depend on ApiService + StorageService
    Get.put<DeviceRepository>(DeviceRepository(), permanent: true);
    Get.put<PaymentRepository>(PaymentRepository(), permanent: true);
    Get.put<UserRepository>(UserRepository(), permanent: true);
  }
}
