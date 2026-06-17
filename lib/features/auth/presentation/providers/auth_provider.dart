import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/auth_models.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/storage/secure_storage.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class AuthState {
  final bool isLoading;
  final bool isInitialized;
  final bool firstLogin;
  final String? error;
  final UserProfile? user;

  const AuthState({
    this.isLoading = false,
    this.isInitialized = false,
    this.firstLogin = false,
    this.error,
    this.user,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isLoading,
    bool? isInitialized,
    bool? firstLogin,
    String? error,
    UserProfile? user,
    bool clearError = false,
    bool clearUser = false,
  }) =>
      AuthState(
        isLoading: isLoading ?? this.isLoading,
        isInitialized: isInitialized ?? this.isInitialized,
        firstLogin: firstLogin ?? this.firstLogin,
        error: clearError ? null : (error ?? this.error),
        user: clearUser ? null : (user ?? this.user),
      );
}

// ── Notifier ──────────────────────────────────────────────────────────────────

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final SecureStorageService _storage;

  AuthNotifier(this._repository, this._storage) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    try {
      final loggedIn = await _storage.isLoggedIn()
          .timeout(const Duration(seconds: 3), onTimeout: () => false);
      if (loggedIn) {
        try {
          final user = await _repository.getProfile();
          state = state.copyWith(user: user, isInitialized: true);
        } catch (_) {
          await _storage.clearAll();
          state = state.copyWith(isInitialized: true, clearUser: true);
        }
      } else {
        state = state.copyWith(isInitialized: true);
      }
    } catch (_) {
      state = state.copyWith(isInitialized: true, clearUser: true);
    }
  }

  Future<bool> login(String identifier, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final auth = await _repository.login(identifier, password);
      state = state.copyWith(isLoading: false, user: auth.user, firstLogin: auth.firstLogin);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> register(RegisterRequest request) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.register(request);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.forgotPassword(email);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.resetPassword(
          email: email, otp: otp, newPassword: newPassword);
      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<bool> setupAccount({String? email, String? phone, required String newPassword}) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.setupAccount(email: email, phone: phone, newPassword: newPassword);
      state = state.copyWith(isLoading: false, firstLogin: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> refreshProfile() async {
    try {
      final user = await _repository.getProfile();
      state = state.copyWith(user: user);
    } catch (_) {}
  }

  Future<void> logout() async {
    await _repository.logout();
    state = const AuthState(isInitialized: true);
  }

  void clearError() => state = state.copyWith(clearError: true);
}

// ── Provider ──────────────────────────────────────────────────────────────────

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.read(authRepositoryProvider),
    ref.read(secureStorageProvider),
  );
});
