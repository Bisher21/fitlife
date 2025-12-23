import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Model/user_model.dart';
import '../services/storage-service.dart';
import '../services/api-service.dart';

// State class for authentication
class AuthState {
  final String? token;
  final UserResponseModel? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.token,
    this.user,
    this.isLoading = false,
    this.error,
  });

  bool get isAuthenticated => token != null && token!.isNotEmpty;
  bool get isVerified => user?.isVerified ?? false;

  AuthState copyWith({
    String? token,
    UserResponseModel? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      token: token ?? this.token,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState());

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true);

    final token = await SharedPreferencesHelper.getToken();
    final userMap = await SharedPreferencesHelper.getUser();

    UserResponseModel? user;
    if (userMap != null) {
      user = UserResponseModel.fromJson(userMap);
    }

    state = AuthState(
      token: token,
      user: user,
      isLoading: false,
    );
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    state = state.copyWith(isLoading: true);

    final result = await ApiService.login(
      email: email,
      password: password,
      deviceName: deviceName,
    );

    if (result['success']) {
      final user = UserResponseModel.fromJson(result['user']);
      final token = await SharedPreferencesHelper.getToken();
      state = AuthState(token: token, user: user, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }

    return result;
  }

  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String deviceName,
  }) async {
    state = state.copyWith(isLoading: true);

    final result = await ApiService.register(
      name: name,
      email: email,
      password: password,
      passwordConfirmation: passwordConfirmation,
      deviceName: deviceName,
    );

    if (result['success']) {
      final user = UserResponseModel.fromJson(result['user']);
      final token = await SharedPreferencesHelper.getToken();
      state = AuthState(token: token, user: user, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }

    return result;
  }

  Future<Map<String, dynamic>> socialLogin({
    required String idToken,
    required String deviceName,
  }) async {
    state = state.copyWith(isLoading: true);

    final result = await ApiService.socialLogin(
      idToken: idToken,
      deviceName: deviceName,
    );

    if (result['success']) {
      final user = UserResponseModel.fromJson(result['user']);
      final token = await SharedPreferencesHelper.getToken();
      state = AuthState(token: token, user: user, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false);
    }

    return result;
  }

  Future<Map<String, dynamic>> refreshUser() async {
    final result = await ApiService.getAuthenticatedUser();

    if (result['success']) {
      final user = UserResponseModel.fromJson(result['user']);
      state = state.copyWith(user: user);
    }

    return result;
  }

  Future<void> logout() async {
    await ApiService.logout();
    state = AuthState();
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});