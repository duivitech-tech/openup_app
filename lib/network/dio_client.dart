// lib/network/dio_client.dart

import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../core/constants/api_constants.dart';
import 'api_interceptor.dart';

class DioClient extends GetxService {
  late final Dio _dio;

  Dio get dio => _dio;

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout:
            const Duration(milliseconds: ApiConstants.connectTimeout),
        receiveTimeout:
            const Duration(milliseconds: ApiConstants.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        responseType: ResponseType.json,
      ),
    );

    // Attach logging + error interceptor
    _dio.interceptors.add(ApiInterceptor());
  }
}
