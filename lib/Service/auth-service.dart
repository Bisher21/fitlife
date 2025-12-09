import 'package:bproject/Service/storage-service.dart';
import 'package:flutter/foundation.dart';
import '../Constants/api_constants.dart';
import '../Model/auth_response.dart';
import '../Model/user_model.dart';
import 'api-service.dart';

class AuthService {

  // 1. تسجيل حساب جديد (Register)

  static Future<AuthResponse> register({
    required String name,
    required String email,
    required String password,
    String? deviceName,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: ApiConstants.register,
        body: {
          'name': name,
          'email': email,
          'password': password,
          'device_name': deviceName ?? _getDeviceName(),
        },
      );

      final authResponse = AuthResponse.fromJson(response);

      // حفظ التوكن والمستخدم
      if (authResponse.status && authResponse.token != null) {
        await StorageService.saveToken(authResponse.token!);
        if (authResponse.user != null) {
          await StorageService.saveUser(authResponse.user!);
        }
      }

      return authResponse;
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }


  // 2. تسجيل الدخول (Login)

  static Future<AuthResponse> login({
    required String email,
    required String password,
    String? deviceName,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: ApiConstants.login,
        body: {
          'email': email,
          'password': password,
          'device_name': deviceName ?? _getDeviceName(),
        },
      );

      final authResponse = AuthResponse.fromJson(response);

      // حفظ التوكن والمستخدم
      if (authResponse.status && authResponse.token != null) {
        await StorageService.saveToken(authResponse.token!);
        if (authResponse.user != null) {
          await StorageService.saveUser(authResponse.user!);
        }
      }

      return authResponse;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // ============================================
  // 3. تسجيل الدخول بجوجل (Social Login)
  // ============================================
  static Future<AuthResponse> socialLogin({
    required String provider, // "google"
    required String accessToken, // ID Token من Google Sign-In
    String? deviceName,
  }) async {
    try {
      final response = await ApiService.post(
        endpoint: ApiConstants.socialLogin,
        body: {
          'provider': provider,
          'access_token': accessToken,
          'device_name': deviceName ?? _getDeviceName(),
        },
      );

      final authResponse = AuthResponse.fromJson(response);

      // حفظ التوكن والمستخدم
      if (authResponse.status && authResponse.token != null) {
        await StorageService.saveToken(authResponse.token!);
        if (authResponse.user != null) {
          await StorageService.saveUser(authResponse.user!);
        }
      }

      return authResponse;
    } catch (e) {
      throw Exception('Social login failed: $e');
    }
  }

  // ============================================
  // 4. تسجيل الخروج (Logout)
  // ============================================
  static Future<bool> logout() async {
    try {
      final response = await ApiService.post(
        endpoint: ApiConstants.logout,
        body: {},
        requiresAuth: true,
      );

      // حذف البيانات المحلية
      await StorageService.clearAll();

      return response['status'] ?? false;
    } catch (e) {
      // حتى لو فشل الطلب، احذف البيانات المحلية
      await StorageService.clearAll();
      throw Exception('Logout failed: $e');
    }
  }

  // ============================================
  // 5. جلب بيانات المستخدم الحالي
  // ============================================
  static Future<UserModel> getCurrentUser() async {
    try {
      final response = await ApiService.get(
        endpoint: ApiConstants.user,
        requiresAuth: true,
      );

      final user = UserModel.fromJson(response);

      // تحديث البيانات المحفوظة
      await StorageService.saveUser(user);

      return user;
    } catch (e) {
      throw Exception('Failed to get user: $e');
    }
  }

  // ============================================
  // 6. إعادة إرسال رابط التحقق من البريد
  // ============================================
  static Future<bool> resendVerificationEmail() async {
    try {
      final response = await ApiService.post(
        endpoint: ApiConstants.resendVerification,
        body: {},
        requiresAuth: true,
      );

      return response['status'] ?? false;
    } catch (e) {
      throw Exception('Failed to resend verification: $e');
    }
  }

  // ============================================
  // 7. التحقق من حالة تسجيل الدخول
  // ============================================
  static Future<bool> isLoggedIn() async {
    try {
      final hasToken = await StorageService.hasToken();
      if (!hasToken) return false;

      // محاولة جلب بيانات المستخدم للتأكد من صلاحية التوكن
      await getCurrentUser();
      return true;
    } catch (e) {
      // إذا فشل، يعني التوكن منتهي
      await StorageService.clearAll();
      return false;
    }
  }

  // ============================================
  // 8. جلب المستخدم من الذاكرة المحلية
  // ============================================
  static Future<UserModel?> getCachedUser() async {
    return await StorageService.getUser();
  }

  // ============================================
  // 9. التحقق من حالة تفعيل البريد الإلكتروني
  // ============================================
  static Future<bool> checkEmailVerification() async {
    try {
      final user = await getCurrentUser();
      return user.isEmailVerified;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // Helpers - دوال مساعدة
  // ============================================

  // الحصول على اسم الجهاز
  static String _getDeviceName() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'Android Device';
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'iOS Device';
    } else {
      return 'Unknown Device';
    }
  }
}