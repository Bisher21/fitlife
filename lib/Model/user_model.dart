

class UserResponseModel {
final int id;
final String name;
final String email;
final String? emailVerifiedAt;
final String createdAt;
final String updatedAt;

UserResponseModel({
required this.id,
required this.name,
required this.email,
this.emailVerifiedAt,
required this.createdAt,
required this.updatedAt,
});

factory UserResponseModel.fromJson(Map<String, dynamic> json) {
return UserResponseModel(
id: json['id'] as int? ?? 0,
name: json['name'] as String? ?? '',
email: json['email'] as String? ?? '',

emailVerifiedAt: json['email_verified_at'] as String?,
createdAt: json['created_at'] as String? ?? '',
updatedAt: json['updated_at'] as String? ?? '',
);
}


Map<String, dynamic> toJson() {
return {
'id': id,
'name': name,
'email': email,
'email_verified_at': emailVerifiedAt,
'created_at': createdAt,
'updated_at': updatedAt,
};
}


  bool get isVerified => emailVerifiedAt != null;
}