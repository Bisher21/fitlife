import 'dart:convert';
import 'package:bproject/Service/storage-service.dart';
import 'package:http/http.dart' as http;
import '../Constants/api_constants.dart';
import '../Model/user_model.dart';


class ApiService {
  // 1️⃣ تسجيل حساب جديد
  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String deviceName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.register),
        headers: ApiConstants.headers,
        body: json.encode({
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
          'device_name': deviceName,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        // حفظ Token والبيانات
        await SharedPreferencesHelper.saveToken(data['token']);
        await SharedPreferencesHelper.saveUser(data['user']);

        return {
          'success': true,
          'message': data['message'],
          'user': UserResponseModel.fromJson(data['user']).toJson(),
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'حدث خطأ أثناء التسجيل',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'خطأ في الاتصال: $e',
      };
    }
  }

  // 2️⃣ تسجيل الدخول
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
    required String deviceName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.login),
        headers: ApiConstants.headers,
        body: json.encode({
          'email': email,
          'password': password,
          'device_name': deviceName,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        // حفظ Token والبيانات
        await SharedPreferencesHelper.saveToken(data['token']);
        await SharedPreferencesHelper.saveUser(data['user']);

        return {
          'success': true,
          'message': data['message'],
          'user': UserResponseModel.fromJson(data['user']).toJson(),
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'خطأ في الاتصال: $e',
      };
    }
  }

  static Future<Map<String, dynamic>> getAuthenticatedUser() async {
    try {
      String? token = await SharedPreferencesHelper.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'لم يتم تسجيل الدخول',
        };
      }

      final response = await http.get(
        Uri.parse(ApiConstants.getUser),
        headers: ApiConstants.headersWithToken(token),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        await SharedPreferencesHelper.saveUser(data['user']);

        return {
          'success': true,
          'user': UserResponseModel.fromJson(data['user']).toJson(),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في جلب البيانات',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'خطأ في الاتصال: $e',
      };
    }
  }

  // 4️⃣ تسجيل الخروج
  static Future<Map<String, dynamic>> logout() async {
    try {
      String? token = await SharedPreferencesHelper.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'لم يتم تسجيل الدخول',
        };
      }

      final response = await http.post(
        Uri.parse(ApiConstants.logout),
        headers: ApiConstants.headersWithToken(token),
      );

      // حذف البيانات المحلية
      await SharedPreferencesHelper.clearAll();

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': 'تم تسجيل الخروج بنجاح',
        };
      } else {
        return {
          'success': false,
          'message': 'حدث خطأ أثناء تسجيل الخروج',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'خطأ في الاتصال: $e',
      };
    }
  }

  // 5️⃣ إعادة إرسال رابط التحقق من البريد
  static Future<Map<String, dynamic>> resendVerification() async {
    try {
      String? token = await SharedPreferencesHelper.getToken();

      if (token == null) {
        return {
          'success': false,
          'message': 'لم يتم تسجيل الدخول',
        };
      }

      final response = await http.post(
        Uri.parse(ApiConstants.resendVerification),
        headers: ApiConstants.headersWithToken(token),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'تم إرسال رابط التحقق',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل في إرسال رابط التحقق',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'خطأ في الاتصال: $e',
      };
    }
  }

  // 6️⃣ تسجيل الدخول عبر Google/Facebook
  static Future<Map<String, dynamic>> socialLogin({
    required String provider, // "google" or "facebook"
    required String accessToken,
    required String deviceName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.socialLogin),
        headers: ApiConstants.headers,
        body: json.encode({
          'provider': provider,
          'access_token': accessToken,
          'device_name': deviceName,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        await SharedPreferencesHelper.saveToken(data['token']);
        await SharedPreferencesHelper.saveUser(data['user']);

        return {
          'success': true,
          'message': 'تم تسجيل الدخول بنجاح',
          'user': UserResponseModel.fromJson(data['user']).toJson(),
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'فشل تسجيل الدخول',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'خطأ في الاتصال: $e',
      };
    }
  }
}