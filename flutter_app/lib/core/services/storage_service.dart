import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Token Storage (Secure)
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: 'auth_token', value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: 'auth_token');
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: 'auth_token');
  }

  // User Data Storage
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    if (_prefs != null) {
      await _prefs!.setString('user_data', jsonEncode(userData));
    }
  }

  Future<Map<String, dynamic>?> getUserData() async {
    if (_prefs != null) {
      final userDataString = _prefs!.getString('user_data');
      if (userDataString != null) {
        return jsonDecode(userDataString) as Map<String, dynamic>;
      }
    }
    return null;
  }

  Future<void> deleteUserData() async {
    if (_prefs != null) {
      await _prefs!.remove('user_data');
    }
  }

  // Clear all data
  Future<void> clearAll() async {
    await deleteToken();
    await deleteUserData();
  }
}
