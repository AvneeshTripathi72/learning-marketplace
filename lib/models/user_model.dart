enum UserRole { publication, public, admin }

class UserModel {
  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String? publicationId;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.publicationId,
  });

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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role.name,
      'publicationId': publicationId,
    };
  }
}
