import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

import '../config/app_config.dart';
import '../services/api_service.dart';
import '../models/user_model.dart';

enum AuthStatus { initial, authenticated, unauthenticated, loading }

class AuthProvider extends ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final ApiService _apiService = ApiService();

  AuthStatus _status = AuthStatus.initial;
  User? _user;
  String? _token;
  String? _error;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get token => _token;
  String? get error => _error;
  bool get isAuthenticated => _status == AuthStatus.authenticated && _token != null;
  bool get isStudent => _user?.role == 'student';
  bool get isTeacher => _user?.role == 'teacher';
  bool get isAdmin => _user?.role == 'admin';

  AuthProvider() {
    _loadStoredAuth();
  }

  Future<void> _loadStoredAuth() async {
    try {
      final token = await _storage.read(key: AppConfig.tokenKey);
      final userData = await _storage.read(key: AppConfig.userKey);

      if (token != null && userData != null) {
        _token = token;
        _user = User.fromJson(jsonDecode(userData));
        _apiService.setToken(token);
        _status = AuthStatus.authenticated;
      } else {
        _status = AuthStatus.unauthenticated;
      }
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      _status = AuthStatus.loading;
      _error = null;
      notifyListeners();

      final response = await _apiService.post('/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        _token = data['token'];
        _user = User.fromJson(data['user']);

        await _storage.write(key: AppConfig.tokenKey, value: _token);
        await _storage.write(
          key: AppConfig.userKey,
          value: jsonEncode(_user!.toJson()),
        );

        _apiService.setToken(_token!);
        _status = AuthStatus.authenticated;
        notifyListeners();
        return true;
      } else {
        _error = response.data['message'] ?? 'Login failed';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? gradeLevel,
  }) async {
    try {
      _status = AuthStatus.loading;
      _error = null;
      notifyListeners();

      final response = await _apiService.post('/register', data: {
        'name': name,
        'email': email,
        'phone': phone,
        'password': password,
        'password_confirmation': passwordConfirmation,
        'grade_level': gradeLevel,
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return true;
      } else {
        _error = response.data['message'] ?? 'Registration failed';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> verifyEmail(String email, String otp) async {
    try {
      _status = AuthStatus.loading;
      _error = null;
      notifyListeners();

      final response = await _apiService.post('/verify-email', data: {
        'email': email,
        'otp': otp,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        if (data['token'] != null) {
          _token = data['token'];
          _user = User.fromJson(data['user']);

          await _storage.write(key: AppConfig.tokenKey, value: _token);
          await _storage.write(
            key: AppConfig.userKey,
            value: jsonEncode(_user!.toJson()),
          );

          _apiService.setToken(_token!);
          _status = AuthStatus.authenticated;
        } else {
          _status = AuthStatus.unauthenticated;
        }
        notifyListeners();
        return true;
      } else {
        _error = response.data['message'] ?? 'Verification failed';
        _status = AuthStatus.unauthenticated;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resendOtp(String email) async {
    try {
      final response = await _apiService.post('/resend-otp', data: {
        'email': email,
      });

      return response.statusCode == 200;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    try {
      _status = AuthStatus.loading;
      _error = null;
      notifyListeners();

      final response = await _apiService.post('/forgot-password', data: {
        'email': email,
      });

      _status = AuthStatus.unauthenticated;
      notifyListeners();

      return response.statusCode == 200;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      _status = AuthStatus.loading;
      _error = null;
      notifyListeners();

      final response = await _apiService.post('/reset-password', data: {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });

      _status = AuthStatus.unauthenticated;
      notifyListeners();

      return response.statusCode == 200;
    } catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshUser() async {
    try {
      final response = await _apiService.get('/user');

      if (response.statusCode == 200) {
        _user = User.fromJson(response.data['user']);
        await _storage.write(
          key: AppConfig.userKey,
          value: jsonEncode(_user!.toJson()),
        );
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to refresh user: $e');
    }
  }

  Future<bool> updateProfile({
    String? name,
    String? phone,
    String? bio,
    String? avatar,
  }) async {
    try {
      final response = await _apiService.put('/user/profile', data: {
        if (name != null) 'name': name,
        if (phone != null) 'phone': phone,
        if (bio != null) 'bio': bio,
        if (avatar != null) 'avatar': avatar,
      });

      if (response.statusCode == 200) {
        _user = User.fromJson(response.data['user']);
        await _storage.write(
          key: AppConfig.userKey,
          value: jsonEncode(_user!.toJson()),
        );
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await _apiService.post('/user/change-password', data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': confirmPassword,
      });

      return response.statusCode == 200;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _apiService.post('/logout');
    } catch (e) {
      debugPrint('Logout API error: $e');
    }

    await _storage.delete(key: AppConfig.tokenKey);
    await _storage.delete(key: AppConfig.userKey);

    _token = null;
    _user = null;
    _status = AuthStatus.unauthenticated;
    _apiService.clearToken();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
