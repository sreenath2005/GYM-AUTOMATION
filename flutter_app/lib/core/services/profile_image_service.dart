import 'dart:convert';
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileImageService {
  static const String _keyPrefix = 'profile_image_';

  /// Save image bytes for a given userId
  static Future<void> saveImage(String userId, Uint8List bytes) async {
    final prefs = await SharedPreferences.getInstance();
    final base64Str = base64Encode(bytes);
    await prefs.setString('$_keyPrefix$userId', base64Str);
  }

  /// Load image bytes for a given userId (null if not set)
  static Future<Uint8List?> loadImage(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final base64Str = prefs.getString('$_keyPrefix$userId');
    if (base64Str == null) return null;
    return base64Decode(base64Str);
  }

  /// Remove stored image for a given userId
  static Future<void> clearImage(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_keyPrefix$userId');
  }
}
