import 'package:flutter/foundation.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../models/dashboard_model.dart';

class StudentProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuthProvider? _authProvider;

  bool _isLoading = false;
  String? _error;
  DashboardData? _dashboardData;
  List<RecentActivity>? _recentActivities;

  bool get isLoading => _isLoading;
  String? get error => _error;
  DashboardData? get dashboardData => _dashboardData;
  List<RecentActivity>? get recentActivities => _recentActivities;

  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_authProvider?.isAuthenticated == true && _dashboardData == null) {
      fetchDashboard();
    }
  }

  Future<void> fetchDashboard() async {
    if (_authProvider?.isAuthenticated != true) return;

    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.get('/student/dashboard');

      if (response.statusCode == 200) {
        _dashboardData = DashboardData.fromJson(response.data['data']);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRecentActivities() async {
    try {
      final response = await _apiService.get('/student/activities');

      if (response.statusCode == 200) {
        _recentActivities = (response.data['data'] as List)
            .map((a) => RecentActivity.fromJson(a))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to fetch activities: $e');
    }
  }

  void clearData() {
    _dashboardData = null;
    _recentActivities = null;
    notifyListeners();
  }
}
