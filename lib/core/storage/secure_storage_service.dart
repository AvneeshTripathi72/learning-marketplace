import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../../models/user_model.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _usersKey = 'app_registered_users_db_v1';
  static const String _currentUserKey = 'app_current_user_session_v1';

  Future<void> saveToken(String token) async {
    await _storage.write(key: AppConstants.tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: AppConstants.tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: AppConstants.tokenKey);
    await _storage.delete(key: _currentUserKey);
  }

  // Persistent User DB storage
  Future<void> saveRegisteredUsers(Map<String, Map<String, dynamic>> users) async {
    try {
      final jsonStr = jsonEncode(users);
      await _storage.write(key: _usersKey, value: jsonStr);
    } catch (_) {}
  }

  Future<Map<String, Map<String, dynamic>>?> getRegisteredUsers() async {
    try {
      final jsonStr = await _storage.read(key: _usersKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr) as Map<String, dynamic>;
        return decoded.map((key, value) => MapEntry(key, Map<String, dynamic>.from(value as Map)));
      }
    } catch (_) {}
    return null;
  }

  // Persistent Active User Session
  Future<void> saveCurrentUser(UserModel user) async {
    try {
      final jsonStr = jsonEncode(user.toJson());
      await _storage.write(key: _currentUserKey, value: jsonStr);
    } catch (_) {}
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final jsonStr = await _storage.read(key: _currentUserKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final jsonMap = jsonDecode(jsonStr) as Map<String, dynamic>;
        return UserModel.fromJson(jsonMap);
      }
    } catch (_) {}
    return null;
  }
}
