import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Constants/api_constants.dart';
import 'package:bproject/services/storage-service.dart';

class ApiService {


  static Future<void> clearLocalAuthData() async {
    await SharedPreferencesHelper.clearAll();
  }

  // 1️⃣ Register
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
      ).timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        await SharedPreferencesHelper.saveToken(data['token']);
        await SharedPreferencesHelper.saveUser(data['user']);
        return {
          'success': true,
          'message': 'Welcome aboard! Your account has been created.',
          'user': data['user'],
        };
      } else {

        return {
          'success': false,
          'message': data['message'] ?? 'We couldn’t create your account. Please check your details and try again.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error. Please check your internet connection.'};
    }
  }


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
      ).timeout(const Duration(seconds: 10));

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        await SharedPreferencesHelper.saveToken(data['token']);
        await SharedPreferencesHelper.saveUser(data['user']);
        return {
          'success': true,
          'message': 'Welcome back!',
          'user': data['user'],
        };
      } else if (response.statusCode == 401) {
        return {'success': false, 'message': 'Incorrect email or password.'};
      } else {
        return {'success': false, 'message': 'Something went wrong. Please try logging in again later.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Can’t connect to the server. Please check your Wi-Fi or data.'};
    }
  }


  static Future<Map<String, dynamic>> getAuthenticatedUser() async {
    try {
      String? token = await SharedPreferencesHelper.getToken();

      if (token == null) {
        return {'success': false, 'message': 'Your session expired. Please log in again.'};
      }

      final response = await http.get(
        Uri.parse(ApiConstants.getUser),
        headers: ApiConstants.headersWithToken(token),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        await SharedPreferencesHelper.saveUser(data);
        return {'success': true, 'user': data};
      }

      else if (response.statusCode == 403) {
        return {
          'success': false,
          'isNotVerified': true,
          'message': 'Your email is not verified yet.'
        };
      }
      else {
        return {
          'success': false,
          'message': data['message'] ?? 'Unable to refresh your profile info.'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error.'};
    }
  }


  static Future<Map<String, dynamic>> logout() async {
    try {
      String? token = await SharedPreferencesHelper.getToken();
      if (token != null) {
        http.post(
          Uri.parse(ApiConstants.logout),
          headers: ApiConstants.headersWithToken(token),
        );
      }
      await clearLocalAuthData();
      return {'success': true, 'message': 'You have been logged out successfully.'};
    } catch (e) {
      await clearLocalAuthData();
      return {'success': true, 'message': 'Logged out successfully.'};
    }
  }


  static Future<Map<String, dynamic>> resendVerification() async {
    try {
      final token = await SharedPreferencesHelper.getToken();
      if (token == null) return {'success': false, 'message': 'Please log in to verify your email.'};

      final response = await http.post(
        Uri.parse(ApiConstants.resendVerification),
        headers: ApiConstants.headersWithToken(token),
      );

      if (response.statusCode == 200 || response.statusCode == 202) {
        return {'success': true, 'message': 'A new verification link has been sent to your inbox!'};
      } else {
        return {'success': false, 'message': 'We couldn’t send the link right now. Please try again in a few minutes.'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Check your internet connection.'};
    }
  }


  static Future<Map<String, dynamic>> socialLogin({
    required String idToken,
    required String deviceName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.socialLogin),
        headers: ApiConstants.headers,
        body: json.encode({
          'provider': 'google',
          'id_token': idToken,
          'device_name': deviceName,
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['status'] == true) {
        await SharedPreferencesHelper.saveToken(data['token']);
        await SharedPreferencesHelper.saveUser(data['user']);
        return {
          'success': true,
          'message': 'Successfully signed in with Google!',
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': 'Google sign-in failed. Please try a different account or use your email.',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection interrupted. Please try again.'};
    }
  }
}