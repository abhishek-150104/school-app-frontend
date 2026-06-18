import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/api_constants.dart';
import '../storage/secure_storage.dart';

final dioClientProvider = Provider<DioClient>((ref) {
  return DioClient(ref.read(secureStorageProvider));
});

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => message;
}

class DioClient {
  late final Dio _dio;
  final SecureStorageService _storage;

  DioClient(this._storage) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(_AuthInterceptor(_storage, _dio));
  }

  Future<Response> get(String path, {Map<String, dynamic>? params}) =>
      _dio.get(path, queryParameters: params);

  Future<Response> post(String path, {dynamic data}) =>
      _dio.post(path, data: data);

  Future<Response> put(String path, {dynamic data}) =>
      _dio.put(path, data: data);

  Future<Response> patch(String path, {dynamic data}) =>
      _dio.patch(path, data: data);

  Future<Response> delete(String path) => _dio.delete(path);
}

class _AuthInterceptor extends Interceptor {
  final SecureStorageService _storage;
  final Dio _dio;

  _AuthInterceptor(this._storage, this._dio);

  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await _storage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // Secure storage may fail on web (WebCrypto OperationError) — proceed without token
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        // Retry the original request with the new token
        try {
          final token = await _storage.getAccessToken();
          err.requestOptions.headers['Authorization'] = 'Bearer $token';
        } catch (_) {}
        try {
          final response = await _dio.fetch(err.requestOptions);
          return handler.resolve(response);
        } catch (_) {}
      }
      // Refresh failed — clear storage so router redirects to login
      try {
        await _storage.clearAll();
      } catch (_) {}
    }

    String message;
    try {
      final data = err.response?.data;
      message = (data is Map
              ? (data['message'] ?? data['error'])?.toString()
              : null) ??
          err.message ??
          'Something went wrong';
    } catch (_) {
      message = err.message ?? 'Something went wrong';
    }
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: ApiException(message, err.response?.statusCode),
      response: err.response,
      type: err.type,
    ));
  }

  Future<bool> _tryRefresh() async {
    try {
      final refreshToken = await _storage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await Dio().post(
        '${ApiConstants.baseUrl}${ApiConstants.refreshToken}',
        data: {'refreshToken': refreshToken},
      );
      final data = response.data['data'];
      await _storage.saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
