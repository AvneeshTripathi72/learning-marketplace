import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../core/storage/secure_storage_service.dart';
import '../core/constants/api_endpoints.dart';

final secureStorageProvider = Provider((ref) => SecureStorageService());

class AuthNotifier extends StateNotifier<UserModel?> {
  final SecureStorageService _storage;

  final Map<String, Map<String, dynamic>> _registeredUsers = {
    'admin@system.com': {
      'name': 'System Administrator',
      'password': 'Admin@12345',
      'role': UserRole.admin,
      'publicationId': null,
    },
    'vendor@oxford.com': {
      'name': 'Oxford Publication Vendor',
      'password': 'Vendor@12345',
      'role': UserRole.publication,
      'publicationId': 'oxford_pub',
    },
    'student@gmail.com': {
      'name': 'Rahul Sharma (Student)',
      'password': 'Student@12345',
      'role': UserRole.public,
      'publicationId': null,
    },
    'hariom.info07@gmail.com': {
      'name': 'Hariom (Student)',
      'password': 'Hariom2005.',
      'role': UserRole.public,
      'publicationId': null,
    },
  };

  AuthNotifier(this._storage) : super(null) {
    _initPersistentStorage();
  }

  Future<void> _initPersistentStorage() async {
    try {
      final storedUsers = await _storage.getRegisteredUsers();
      if (storedUsers != null && storedUsers.isNotEmpty) {
        storedUsers.forEach((key, val) {
          final roleStr = (val['role'] ?? 'public').toString().toLowerCase();
          UserRole role = UserRole.public;
          if (roleStr == 'admin') {
            role = UserRole.admin;
          } else if (roleStr == 'publication' || roleStr == 'vendor') {
            role = UserRole.publication;
          }

          _registeredUsers[key] = {
            'name': val['name'] ?? key.split('@').first,
            'password': val['password'] ?? '',
            'role': role,
            'publicationId': val['publicationId'],
          };
        });
      }
      final savedUser = await _storage.getCurrentUser();
      if (savedUser != null) {
        state = savedUser;
      }
    } catch (_) {}
  }

  void login(UserModel user, String token) {
    _storage.saveToken(token);
    _storage.saveCurrentUser(user);
    state = user;
  }

  Future<UserModel?> loginWithCredentials(String email, String password) async {
    final cleanEmail = email.trim().toLowerCase();

    // 1. Try production HTTP backend endpoint POST /auth/login
    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}${ApiEndpoints.login}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': cleanEmail, 'password': password}),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final userJson = data['user'];
        final token = data['token'] ?? 'jwt_token_${DateTime.now().millisecondsSinceEpoch}';

        UserRole role = UserRole.public;
        if (userJson['role'] == 'PUBLICATION' || userJson['role'] == 'VENDOR') {
          role = UserRole.publication;
        } else if (userJson['role'] == 'ADMIN') {
          role = UserRole.admin;
        }

        final user = UserModel(
          id: userJson['id'] ?? 'user_1',
          name: userJson['name'] ?? 'User',
          email: userJson['email'] ?? cleanEmail,
          role: role,
          publicationId: userJson['publicationId'],
        );

        login(user, token);
        return user;
      } else if (response.statusCode == 401 || response.statusCode == 400) {
        // Backend actively rejected authentication credentials!
        return null;
      }
    } catch (_) {}

    // 2. Check local persistent DB registered accounts map with strict password matching
    if (_registeredUsers.containsKey(cleanEmail)) {
      final acc = _registeredUsers[cleanEmail]!;
      final storedPass = acc['password'] as String?;
      final rawRole = acc['role'];

      UserRole userRole = UserRole.public;
      if (rawRole is UserRole) {
        userRole = rawRole;
      } else if (rawRole is String) {
        if (rawRole.toLowerCase() == 'admin') {
          userRole = UserRole.admin;
        } else if (rawRole.toLowerCase() == 'publication' || rawRole.toLowerCase() == 'vendor') {
          userRole = UserRole.publication;
        }
      }

      if (storedPass != null && storedPass.isNotEmpty && storedPass == password) {
        final user = UserModel(
          id: 'user_${cleanEmail.hashCode}',
          name: (acc['name'] as String?) ?? cleanEmail.split('@').first,
          email: cleanEmail,
          role: userRole,
          publicationId: acc['publicationId'] as String?,
        );
        login(user, 'jwt_token_${DateTime.now().millisecondsSinceEpoch}');
        return user;
      } else {
        // Wrong password entered - strict authentication failure!
        return null;
      }
    }

    // Account not found in registered DB
    return null;
  }

  Future<bool> registerAccountOnly({
    required String name,
    required String email,
    required String password,
    required String roleStr,
  }) async {
    final cleanEmail = email.trim().toLowerCase();
    UserRole role = UserRole.public;
    if (roleStr.toUpperCase() == 'PUBLICATION' || roleStr.toUpperCase() == 'VENDOR') {
      role = UserRole.publication;
    } else if (roleStr.toUpperCase() == 'ADMIN') {
      role = UserRole.admin;
    }

    // Save registered user credentials in memory map
    _registeredUsers[cleanEmail] = {
      'name': name,
      'password': password,
      'role': role,
      'publicationId': role == UserRole.publication ? 'pub_${cleanEmail.split('@').first}' : null,
    };

    // Serialize map to JSON format for disk storage
    final serializableUsers = <String, Map<String, dynamic>>{};
    _registeredUsers.forEach((key, value) {
      serializableUsers[key] = {
        'name': value['name'],
        'password': value['password'],
        'role': value['role'] is UserRole ? (value['role'] as UserRole).name : value['role'].toString(),
        'publicationId': value['publicationId'],
      };
    });

    await _storage.saveRegisteredUsers(serializableUsers);

    try {
      final response = await http.post(
        Uri.parse('${ApiEndpoints.baseUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'email': cleanEmail,
          'password': password,
          'role': roleStr,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
    } catch (_) {}
    return true;
  }

  void updateProfile({String? name, String? email, String? mobile, String? avatarUrl}) {
    if (state != null) {
      final updated = state!.copyWith(
        name: name,
        email: email,
        mobile: mobile,
        avatarUrl: avatarUrl,
      );
      state = updated;
      _storage.saveCurrentUser(updated);
    }
  }

  Future<void> logout() async {
    await _storage.deleteToken();
    state = null;
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, UserModel?>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return AuthNotifier(storage);
});
