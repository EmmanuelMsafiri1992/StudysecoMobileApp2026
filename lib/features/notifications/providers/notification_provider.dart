import 'package:flutter/foundation.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../models/notification_model.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuthProvider? _authProvider;

  bool _isLoading = false;
  String? _error;
  List<AppNotification> _notifications = [];
  int _unreadCount = 0;
  NotificationSettings? _settings;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<AppNotification> get notifications => _notifications;
  int get unreadCount => _unreadCount;
  NotificationSettings? get settings => _settings;

  List<AppNotification> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_authProvider?.isAuthenticated == true) {
      fetchNotifications();
    }
  }

  Future<void> fetchNotifications({int page = 1}) async {
    try {
      _isLoading = page == 1;
      if (page == 1) notifyListeners();

      final response = await _apiService.get(
        '/notifications',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        final newNotifications = (response.data['data'] as List)
            .map((n) => AppNotification.fromJson(n))
            .toList();

        if (page == 1) {
          _notifications = newNotifications;
        } else {
          _notifications.addAll(newNotifications);
        }

        _unreadCount = response.data['unread_count'] ?? 0;
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    try {
      final response = await _apiService.post('/notifications/$notificationId/read');

      if (response.statusCode == 200) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1 && !_notifications[index].isRead) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
          _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Failed to mark as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await _apiService.post('/notifications/read-all');

      if (response.statusCode == 200) {
        _notifications = _notifications
            .map((n) => n.copyWith(isRead: true))
            .toList();
        _unreadCount = 0;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to mark all as read: $e');
    }
  }

  Future<bool> deleteNotification(int notificationId) async {
    try {
      final response = await _apiService.delete('/notifications/$notificationId');

      if (response.statusCode == 200) {
        _notifications.removeWhere((n) => n.id == notificationId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<void> fetchSettings() async {
    try {
      final response = await _apiService.get('/notifications/settings');

      if (response.statusCode == 200) {
        _settings = NotificationSettings.fromJson(response.data['data']);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to fetch settings: $e');
    }
  }

  Future<bool> updateSettings(NotificationSettings newSettings) async {
    try {
      final response = await _apiService.put(
        '/notifications/settings',
        data: newSettings.toJson(),
      );

      if (response.statusCode == 200) {
        _settings = newSettings;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  void clearNotifications() {
    _notifications = [];
    _unreadCount = 0;
    notifyListeners();
  }
}
