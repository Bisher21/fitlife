import 'package:flutter/foundation.dart';

// 1. UserResponseModel (What you RECEIVE from the API on login/register)
class UserResponseModel {
  final int id;
  final String name;
  final String email;

  final String createdAt;
  final String updatedAt;

  UserResponseModel({
    required this.id,
    required this.name,
    required this.email,

    required this.createdAt,
    required this.updatedAt,
  });


  factory UserResponseModel.fromJson(Map<String, dynamic> json) {
    return UserResponseModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      // Note: The backend response does not include the password, so we don't map it.
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }

  // Method to convert the model back to a map (for saving to SharedPreferences)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,

      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}




