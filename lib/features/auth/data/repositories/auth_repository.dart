import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/storage/secure_storage.dart';
import '../models/auth_models.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.read(dioClientProvider),
    ref.read(secureStorageProvider),
  );
});

class AuthRepository {
  final DioClient _dio;
  final SecureStorageService _storage;

  AuthRepository(this._dio, this._storage);

  Future<AuthResponse> login(String identifier, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {'username': identifier, 'password': password},
      );
      final auth = AuthResponse.fromJson(response.data['data']);
      await _storage.saveTokens(
        accessToken: auth.accessToken,
        refreshToken: auth.refreshToken,
      );
      await _storage.saveUserInfo(
        userId: auth.user.id,
        role: auth.user.role,
        email: auth.user.email,
        fullName: auth.user.fullName,
      );
      return auth;
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Login failed. Please try again.');
    }
  }

  Future<void> register(RegisterRequest request) async {
    try {
      await _dio.post(ApiConstants.register, data: request.toJson());
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Registration failed. Please try again.');
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _dio.post(ApiConstants.forgotPassword, data: {'email': email});
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to send reset email. Please try again.');
    }
  }

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      await _dio.post(ApiConstants.resetPassword, data: {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      });
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to reset password. Please try again.');
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _dio.post('/api/users/change-password', data: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to change password.');
    }
  }

  Future<UserProfile> getProfile() async {
    try {
      final response = await _dio.get(ApiConstants.profile);
      return UserProfile.fromJson(response.data['data']);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to load profile.');
    }
  }

  Future<UserProfile> updateProfile({
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await _dio.put(ApiConstants.profile, data: {
        'fullName': fullName,
        if (phone != null) 'phone': phone,
      });
      return UserProfile.fromJson(response.data['data']);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Failed to update profile.');
    }
  }

  Future<void> setupAccount({
    String? email,
    String? phone,
    required String newPassword,
  }) async {
    try {
      await _dio.put(ApiConstants.setupAccount, data: {
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        'newPassword': newPassword,
      });
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Account setup failed. Please try again.');
    }
  }

  Future<void> logout() async {
    try {
      final token = await _storage.getRefreshToken();
      if (token != null) {
        await _dio.post(ApiConstants.logout, data: {'refreshToken': token});
      }
    } catch (_) {
      // Best-effort logout — always clear local storage
    } finally {
      await _storage.clearAll();
    }
  }
}
