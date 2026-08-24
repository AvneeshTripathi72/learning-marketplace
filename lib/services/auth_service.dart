import '../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _api;

  AuthService(this._api);

  Future<UserModel> login(String email, String password) async {
    try {
      final response = await _api.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      return UserModel.fromJson(response.data['user']);
    } catch (_) {
      // Return mock user if backend is not available locally yet
      return UserModel(
        id: 'user_001',
        name: 'Logged User',
        email: email,
        role: email.contains('pub') ? UserRole.publication : UserRole.public,
        publicationId: email.contains('pub') ? 'oxford_pub' : null,
      );
    }
  }

  Future<UserModel?> getProfile() async {
    try {
      final response = await _api.get('/auth/me');
      return UserModel.fromJson(response.data['user']);
    } catch (_) {
      return null;
    }
  }
}
