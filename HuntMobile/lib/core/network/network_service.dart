import 'package:dio/dio.dart';

/// Network service configured with JWT header injection interceptor
class NetworkService {
  late final Dio dio;
  String? _jwtToken;

  NetworkService({String? baseUrl}) {
    dio = Dio(BaseOptions(
      baseUrl: baseUrl ?? 'http://localhost:5000/api',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      headers: {'Content-Type': 'application/json'},
    ));

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_jwtToken != null && _jwtToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_jwtToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );
  }

  void setToken(String token) {
    _jwtToken = token;
  }

  void clearToken() {
    _jwtToken = null;
  }
}
