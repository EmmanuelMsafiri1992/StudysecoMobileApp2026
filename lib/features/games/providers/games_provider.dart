import 'package:flutter/foundation.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../models/game_model.dart';

class GamesProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuthProvider? _authProvider;

  bool _isLoading = false;
  String? _error;
  List<Game> _games = [];
  Game? _currentGame;
  GameSession? _currentSession;
  List<GameScore> _leaderboard = [];
  List<GameScore> _userScores = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Game> get games => _games;
  Game? get currentGame => _currentGame;
  GameSession? get currentSession => _currentSession;
  List<GameScore> get leaderboard => _leaderboard;
  List<GameScore> get userScores => _userScores;

  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  Future<void> fetchGames({int? subjectId, String? type}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final queryParams = <String, dynamic>{};
      if (subjectId != null) queryParams['subject_id'] = subjectId;
      if (type != null) queryParams['type'] = type;

      final response = await _apiService.get('/games', queryParameters: queryParams);

      if (response.statusCode == 200) {
        _games = (response.data['data'] as List)
            .map((g) => Game.fromJson(g))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchGameDetail(String gameId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.get('/games/$gameId');

      if (response.statusCode == 200) {
        _currentGame = Game.fromJson(response.data['data']);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startGame(String gameId) async {
    try {
      final response = await _apiService.post('/games/$gameId/start');

      if (response.statusCode == 200) {
        _currentSession = GameSession.fromJson(response.data['data']);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<GameScore?> endGame({required int score, int? correctAnswers, int? totalQuestions}) async {
    if (_currentSession == null) return null;

    try {
      final response = await _apiService.post(
        '/games/${_currentGame!.id}/end',
        data: {
          'session_id': _currentSession!.id,
          'score': score,
          'correct_answers': correctAnswers,
          'total_questions': totalQuestions,
        },
      );

      if (response.statusCode == 200) {
        final gameScore = GameScore.fromJson(response.data['data']);
        _currentSession = null;
        notifyListeners();
        return gameScore;
      }
      return null;
    } catch (e) {
      _error = e.toString();
      return null;
    }
  }

  Future<void> fetchLeaderboard(String gameId, {String period = 'all'}) async {
    try {
      final response = await _apiService.get(
        '/games/$gameId/leaderboard',
        queryParameters: {'period': period},
      );

      if (response.statusCode == 200) {
        _leaderboard = (response.data['data'] as List)
            .map((s) => GameScore.fromJson(s))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to fetch leaderboard: $e');
    }
  }

  Future<void> fetchUserScores(String gameId) async {
    try {
      final response = await _apiService.get('/games/$gameId/my-scores');

      if (response.statusCode == 200) {
        _userScores = (response.data['data'] as List)
            .map((s) => GameScore.fromJson(s))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to fetch user scores: $e');
    }
  }

  void clearCurrentGame() {
    _currentGame = null;
    _currentSession = null;
    notifyListeners();
  }
}
