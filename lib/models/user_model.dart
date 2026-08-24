enum UserRole { publication, public, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? publicationId;
  final String? avatarUrl;
  final String? mobile;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.publicationId,
    this.avatarUrl,
    this.mobile,
  });

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    UserRole? role,
    String? publicationId,
    String? avatarUrl,
    String? mobile,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      publicationId: publicationId ?? this.publicationId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      mobile: mobile ?? this.mobile,
    );
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.name == json['role'],
        orElse: () => UserRole.public,
      ),
      publicationId: json['publicationId'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      mobile: json['mobile'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'publicationId': publicationId,
      'avatarUrl': avatarUrl,
      'mobile': mobile,
    };
  }
}
