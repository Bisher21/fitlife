

import 'package:flutter/material.dart';
import '../Model/user_model.dart';
import '../Service/auth-service.dart';


enum AuthStatus {
  initial,      // بداية التطبيق
  authenticated, // مسجل دخول
  unauthenticated, // غير مسجل
  loading,      // جاري التحميل
}

class AuthProvider extends ChangeNotifier {


  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _errorMessage;
  bool _isLoading = false;

  // Getters
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isEmailVerified => _user?.isEmailVerified ?? false;

  // ============================================
  // 1. التحقق من حالة المصادقة عند بدء التطبيق
  // ============================================

  Future<void> checkAuthStatus() async {
    try {
      _setLoading(true);

      final isLoggedIn = await AuthService.isLoggedIn();

      if (isLoggedIn) {
        // جلب بيانات المستخدم
        _user = await AuthService.getCachedUser();
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
    } finally {
      _setLoading(false);
    }
  }

  // ============================================
  // 2. تسجيل حساب جديد
  // ============================================

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await AuthService.register(
        name: name,
        email: email,
        password: password,
      );

      if (response.status && response.user != null) {
        _user = response.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = _extractErrorMessage(e.toString());
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================
  // 3. تسجيل الدخول
  // ============================================

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await AuthService.login(
        email: email,
        password: password,
      );

      if (response.status && response.user != null) {
        _user = response.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = _extractErrorMessage(e.toString());
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================
  // 4. تسجيل الدخول بجوجل
  // ============================================

  Future<bool> socialLogin({
    required String provider,
    required String accessToken,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      final response = await AuthService.socialLogin(
        provider: provider,
        accessToken: accessToken,
      );

      if (response.status && response.user != null) {
        _user = response.user;
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _errorMessage = response.message;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = _extractErrorMessage(e.toString());
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================
  // 5. تسجيل الخروج
  // ============================================

  Future<bool> logout() async {
    try {
      _setLoading(true);

      await AuthService.logout();

      _user = null;
      _status = AuthStatus.unauthenticated;
      _clearError();
      notifyListeners();

      return true;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e.toString());
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================
  // 6. تحديث بيانات المستخدم
  // ============================================

  Future<void> refreshUser() async {
    try {
      _user = await AuthService.getCurrentUser();
      notifyListeners();
    } catch (e) {
      _errorMessage = _extractErrorMessage(e.toString());
      notifyListeners();
    }
  }

  // ============================================
  // 7. إعادة إرسال رابط التحقق من البريد
  // ============================================

  Future<bool> resendVerificationEmail() async {
    try {
      _setLoading(true);
      _clearError();

      final success = await AuthService.resendVerificationEmail();

      if (!success) {
        _errorMessage = 'فشل إرسال رابط التحقق';
      }

      notifyListeners();
      return success;
    } catch (e) {
      _errorMessage = _extractErrorMessage(e.toString());
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ============================================
  // 8. التحقق من حالة تفعيل البريد الإلكتروني
  // ============================================

  Future<bool> checkEmailVerificationStatus() async {
    try {
      final isVerified = await AuthService.checkEmailVerification();

      if (isVerified && _user != null) {
        // تحديث بيانات المستخدم
        await refreshUser();
      }

      return isVerified;
    } catch (e) {
      return false;
    }
  }

  // ============================================
  // دوال مساعدة
  // ============================================

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  // استخراج رسالة الخطأ من Exception
  String _extractErrorMessage(String error) {
    if (error.contains('Invalid credentials')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    } else if (error.contains('Network error')) {
      return 'خطأ في الاتصال بالإنترنت';
    } else if (error.contains('Invalid or expired social token')) {
      return 'رمز تسجيل الدخول غير صالح أو منتهي الصلاحية';
    } else if (error.contains('email has already been taken')) {
      return 'البريد الإلكتروني مستخدم بالفعل';
    } else {
      // إزالة "Exception: " من بداية الرسالة
      return error.replaceFirst('Exception: ', '');
    }
  }
}



