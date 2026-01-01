import 'package:flutter/foundation.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../models/achievement_model.dart';

class AchievementProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuthProvider? _authProvider;

  bool _isLoading = false;
  String? _error;
  List<Achievement> _achievements = [];
  List<Achievement> _earnedAchievements = [];
  AchievementStats? _stats;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Achievement> get achievements => _achievements;
  List<Achievement> get earnedAchievements => _earnedAchievements;
  AchievementStats? get stats => _stats;

  List<Achievement> get pendingAchievements =>
      _achievements.where((a) => !a.isEarned).toList();

  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  Future<void> fetchAchievements() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.get('/achievements');

      if (response.statusCode == 200) {
        _achievements = (response.data['data'] as List)
            .map((a) => Achievement.fromJson(a))
            .toList();
        _earnedAchievements = _achievements.where((a) => a.isEarned).toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchStats() async {
    try {
      final response = await _apiService.get('/achievements/stats');

      if (response.statusCode == 200) {
        _stats = AchievementStats.fromJson(response.data['data']);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to fetch stats: $e');
    }
  }

  List<Achievement> getByType(String type) {
    return _achievements.where((a) => a.type == type).toList();
  }

  List<Achievement> getByLevel(String level) {
    return _achievements.where((a) => a.level == level).toList();
  }
}
