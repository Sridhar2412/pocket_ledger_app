import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/constants.dart';

Dio createDio(SharedPreferences prefs) {
  final dio = Dio(BaseOptions(
    baseUrl: Constants.baseUrl,
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = prefs.getString(Constants.authTokenKey);
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    },
    onError: (DioException e, handler) {
      // Basic mock error handling
      if (e.response?.statusCode == 401) {
        // Handle unauthenticated case (e.g., clear token)
        prefs.remove(Constants.authTokenKey);
      }
      handler.next(e);
    },
  ));

  return dio;
}
