import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../core/services/api_service.dart';
import '../core/services/storage_service.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();

  UserModel? _user;
  bool _isLoading = false;
  bool _isAuthenticated = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _isAuthenticated;

  // Initialize auth state
  Future<void> initializeAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _storageService.getToken();
      if (token != null) {
        final response = await _apiService.getMe();
        if (response.statusCode == 200 && response.data['success']) {
          _user = UserModel.fromJson(response.data['data']);
          _isAuthenticated = true;
        } else {
          await _storageService.clearAll();
        }
      }
    } catch (e) {
      await _storageService.clearAll();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String role,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.register({
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
      });

      if (response.statusCode == 201 && response.data['success']) {
        final userData = response.data['data'];
        _user = UserModel.fromJson(userData);
        await _storageService.saveToken(userData['token']);
        await _storageService.saveUserData(userData);
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        Fluttertoast.showToast(msg: 'Registration successful');
        return true;
      } else {
        final errorMsg = response.data['message'] ?? 'Registration failed';
        Fluttertoast.showToast(msg: errorMsg, toastLength: Toast.LENGTH_LONG);
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      String errorMessage = 'Registration failed';
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        errorMessage = 'Cannot connect to server. Please check your internet connection.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Connection timeout. Please try again.';
      } else if (e.toString().contains('400') || e.toString().contains('already exists')) {
        errorMessage = 'Email already registered. Please login instead.';
      } else {
        errorMessage = 'Registration failed: ${e.toString()}';
      }
      Fluttertoast.showToast(msg: errorMessage, toastLength: Toast.LENGTH_LONG);
      return false;
    }
  }

  // Login
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.login({
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200 && response.data['success']) {
        final userData = response.data['data'];
        _user = UserModel.fromJson(userData);
        await _storageService.saveToken(userData['token']);
        await _storageService.saveUserData(userData);
        _isAuthenticated = true;
        _isLoading = false;
        notifyListeners();
        Fluttertoast.showToast(msg: 'Login successful');
        return true;
      } else {
        final errorMsg = response.data['message'] ?? 'Login failed';
        Fluttertoast.showToast(msg: errorMsg, toastLength: Toast.LENGTH_LONG);
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      String errorMessage = 'Login failed';
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        errorMessage = 'Cannot connect to server. Please check your internet connection.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Connection timeout. Please try again.';
      } else if (e.toString().contains('401') || e.toString().contains('Invalid credentials')) {
        errorMessage = 'Invalid email or password';
      } else {
        errorMessage = 'Login failed: ${e.toString()}';
      }
      Fluttertoast.showToast(msg: errorMessage, toastLength: Toast.LENGTH_LONG);
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    await _storageService.clearAll();
    _user = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  // Update user
  void updateUser(UserModel updatedUser) {
    _user = updatedUser;
    notifyListeners();
  }

  String? _resetToken;

  String? get resetToken => _resetToken;

  // Forgot password
  Future<Map<String, dynamic>> forgotPassword({required String email}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.forgotPassword({'email': email});

      if (response.statusCode == 200 && response.data['success']) {
        _isLoading = false;
        notifyListeners();
        // Get reset token from response (for testing - in production, this would be sent via email)
        final resetToken = response.data['data']?['resetToken'];
        _resetToken = resetToken;
        
        if (resetToken != null) {
          Fluttertoast.showToast(
            msg: 'Reset token: $resetToken (valid for 10 minutes)',
            toastLength: Toast.LENGTH_LONG,
          );
          return {
            'success': true,
            'resetToken': resetToken,
            'message': response.data['message'] ?? 'Reset token generated successfully',
          };
        } else {
          Fluttertoast.showToast(
            msg: response.data['message'] ?? 'Reset token sent successfully',
            toastLength: Toast.LENGTH_LONG,
          );
          return {
            'success': true,
            'message': response.data['message'] ?? 'Reset token sent successfully',
          };
        }
      } else {
        Fluttertoast.showToast(msg: response.data['message'] ?? 'Failed to generate reset token');
        _isLoading = false;
        notifyListeners();
        return {
          'success': false,
          'message': response.data['message'] ?? 'Failed to generate reset token',
        };
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      String errorMessage = 'Failed to generate reset token';
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        errorMessage = 'Cannot connect to server. Please check your internet connection.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Connection timeout. Please try again.';
      }
      Fluttertoast.showToast(msg: errorMessage, toastLength: Toast.LENGTH_LONG);
      return {
        'success': false,
        'message': errorMessage,
      };
    }
  }

  // Reset password
  Future<bool> resetPassword({
    required String email,
    required String resetToken,
    required String newPassword,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.resetPassword({
        'email': email,
        'resetToken': resetToken,
        'newPassword': newPassword,
      });

      if (response.statusCode == 200 && response.data['success']) {
        _isLoading = false;
        notifyListeners();
        Fluttertoast.showToast(msg: 'Password reset successfully');
        return true;
      } else {
        Fluttertoast.showToast(msg: response.data['message'] ?? 'Failed to reset password');
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      String errorMessage = 'Failed to reset password';
      if (e.toString().contains('SocketException') || e.toString().contains('Failed host lookup')) {
        errorMessage = 'Cannot connect to server. Please check your internet connection.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Connection timeout. Please try again.';
      } else if (e.toString().contains('Invalid') || e.toString().contains('expired')) {
        errorMessage = 'Invalid or expired reset token';
      }
      Fluttertoast.showToast(msg: errorMessage, toastLength: Toast.LENGTH_LONG);
      return false;
    }
  }
}
