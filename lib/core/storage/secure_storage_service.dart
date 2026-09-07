import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';
import '../../models/user_model.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const String _usersKey = 'app_registered_users_db_v1';
  static const String _currentUserKey = 'app_current_user_session_v1';
  static const String _biometricKey = 'app_biometric_security_enabled_v1';
  static const String _launchCountKey = 'app_launch_count_v1';

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

  // Biometric Security Persistence
  Future<void> saveBiometricEnabled(bool enabled) async {
    try {
      await _storage.write(key: _biometricKey, value: enabled ? 'true' : 'false');
    } catch (_) {}
  }

  Future<bool> getBiometricEnabled() async {
    try {
      final val = await _storage.read(key: _biometricKey);
      return val == 'true';
    } catch (_) {}
    return false;
  }

  // Launch Count Tracking for 2nd-Time Fingerprint Lock Requirement
  Future<int> getAppLaunchCount() async {
    try {
      final val = await _storage.read(key: _launchCountKey);
      if (val != null) {
        return int.tryParse(val) ?? 1;
      }
    } catch (_) {}
    return 1;
  }

  Future<int> incrementAppLaunchCount() async {
    try {
      final current = await getAppLaunchCount();
      final nextCount = current + 1;
      await _storage.write(key: _launchCountKey, value: nextCount.toString());
      return nextCount;
    } catch (_) {}
    return 2;
  }

  Future<bool> isSecondLaunchOrLater() async {
    final count = await getAppLaunchCount();
    return count >= 2;
  }
}
