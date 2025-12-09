import 'package:bproject/Service/storage-service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../Constants/api_constants.dart';


class ApiService {
  // دالة مساعدة لعمل POST request
  static Future<Map<String, dynamic>> post({
    required String endpoint,
    required Map<String, dynamic> body,
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      // تجهيز الـ Headers
      final headers = Map<String, String>.from(ApiConstants.headers);

      // إضافة التوكن إذا كان مطلوب
      if (requiresAuth) {
        final token = await StorageService.getToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      // إرسال الطلب
      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      // معالجة الرد
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // دالة مساعدة لعمل GET request
  static Future<Map<String, dynamic>> get({
    required String endpoint,
    bool requiresAuth = false,
  }) async {
    try {
      final url = Uri.parse('${ApiConstants.baseUrl}$endpoint');

      final headers = Map<String, String>.from(ApiConstants.headers);

      if (requiresAuth) {
        final token = await StorageService.getToken();
        if (token != null) {
          headers['Authorization'] = 'Bearer $token';
        }
      }

      final response = await http.get(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // معالجة الردود
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Something went wrong');
    }
  }
}