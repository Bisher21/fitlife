import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SharedPreferencesHelper {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // حفظ Token
  static Future<bool> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.setString(_tokenKey, token);
  }

  // استرجاع Token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // حفظ بيانات المستخدم
  static Future<bool> saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    String userJson = json.encode(userData);
    return await prefs.setString(_userKey, userJson);
  }

  // استرجاع بيانات المستخدم
  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString(_userKey);
    if (userJson != null) {
      return json.decode(userJson);
    }
    return null;
  }

  // حذف كل البيانات (عند تسجيل الخروج)
  static Future<bool> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    return await prefs.clear();
  }

  // التحقق من وجود Token
  static Future<bool> isLoggedIn() async {
    String? token = await getToken();
    return token != null && token.isNotEmpty;
  }
}