import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../core/storage/secure_storage_service.dart';

final secureStorageProvider = Provider((ref) => SecureStorageService());

class AuthNotifier extends StateNotifier<UserModel?> {
  final SecureStorageService _storage;

  AuthNotifier(this._storage)
      : super(
          UserModel(
            id: 'pub_admin_1',
            email: 'admin@publication.com',
            name: 'Oxford Publication Admin',
            role: UserRole.publication,
            publicationId: 'pub_oxford_1',
            avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
            mobile: '+91 9876543210',
          ),
        );

  void login(UserModel user, String token) {
    _storage.saveToken(token);
    state = user;
  }

  Future<void> loginAsPublicationAdmin() async {
    final user = UserModel(
      id: 'pub_admin_1',
      email: 'admin@publication.com',
      name: 'Oxford Publication Admin',
      role: UserRole.publication,
      publicationId: 'pub_oxford_1',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150',
      mobile: '+91 9876543210',
    );
    login(user, 'dummy_pub_admin_token');
  }

  Future<void> loginAsPublicStudent() async {
    final user = UserModel(
      id: 'student_1',
      email: 'student@gmail.com',
      name: 'Rahul Sharma (Student)',
      role: UserRole.public,
      avatarUrl: 'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?w=150',
      mobile: '+91 9123456789',
    );
    login(user, 'dummy_student_token');
  }

  void updateProfile({String? name, String? email, String? mobile, String? avatarUrl}) {
    if (state != null) {
      state = state!.copyWith(
        name: name,
        email: email,
        mobile: mobile,
        avatarUrl: avatarUrl,
      );
    }
  }

  void logout() {
    _storage.deleteToken();
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthNotifier(storage);
});
