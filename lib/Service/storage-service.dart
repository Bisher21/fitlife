
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../Model/user_model.dart';

class StorageService {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';
  static const _userKey = 'user_data';

  // حفظ التوكن
  static Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // جلب التوكن
  static Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // حفظ بيانات المستخدم
  static Future<void> saveUser(UserModel user) async {
    final userJson = jsonEncode(user.toJson());
    await _storage.write(key: _userKey, value: userJson);
  }

  // جلب بيانات المستخدم
  static Future<UserModel?> getUser() async {
    final userJson = await _storage.read(key: _userKey);
    if (userJson == null) return null;
    return UserModel.fromJson(jsonDecode(userJson));
  }

  // حذف كل البيانات (عند Logout)
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  // التحقق من وجود توكن
  static Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}