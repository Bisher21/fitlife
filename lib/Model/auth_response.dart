import 'package:bproject/Model/user_model.dart';

class AuthResponse {
  final bool status;
  final String message;
  final UserModel? user;
  final String? token;

  AuthResponse({
    required this.status,
    required this.message,
    this.user,
    this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      token: json['token'],
    );
  }
}