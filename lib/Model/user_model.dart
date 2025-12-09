class UserModel {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String? provider;
  final String? providerId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.provider,
    this.providerId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      emailVerifiedAt: json['email_verified_at'],
      provider: json['provider'],
      providerId: json['provider_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'email_verified_at': emailVerifiedAt,
      'provider': provider,
      'provider_id': providerId,
    };
  }

  bool get isEmailVerified => emailVerifiedAt != null;
}