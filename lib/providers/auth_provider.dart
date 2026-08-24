import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../core/storage/secure_storage_service.dart';

final secureStorageProvider = Provider((ref) => SecureStorageService());

class AuthNotifier extends StateNotifier<UserModel?> {
  final SecureStorageService _storage;

  AuthNotifier(this._storage) : super(null);

  void login(UserModel user, String token) {
    _storage.saveToken(token);
    state = user;
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
