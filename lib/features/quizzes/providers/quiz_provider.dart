import 'package:flutter/foundation.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../models/quiz_model.dart';

class QuizProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuthProvider? _authProvider;

  bool _isLoading = false;
  String? _error;
  List<Quiz> _quizzes = [];
  Quiz? _currentQuiz;
  QuizAttempt? _currentAttempt;
  List<QuizAttempt> _attempts = [];
  int _currentQuestionIndex = 0;
  Map<int, int> _selectedAnswers = {};
  int _remainingTime = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Quiz> get quizzes => _quizzes;
  Quiz? get currentQuiz => _currentQuiz;
  QuizAttempt? get currentAttempt => _currentAttempt;
  List<QuizAttempt> get attempts => _attempts;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<int, int> get selectedAnswers => _selectedAnswers;
  int get remainingTime => _remainingTime;

  QuizQuestion? get currentQuestion {
    if (_currentQuiz?.questions == null ||
        _currentQuestionIndex >= _currentQuiz!.questions!.length) {
      return null;
    }
    return _currentQuiz!.questions![_currentQuestionIndex];
  }

  bool get isLastQuestion {
    return _currentQuiz?.questions == null ||
        _currentQuestionIndex >= _currentQuiz!.questions!.length - 1;
  }

  double get progress {
    if (_currentQuiz?.questions == null || _currentQuiz!.questions!.isEmpty) {
      return 0;
    }
    return (_currentQuestionIndex + 1) / _currentQuiz!.questions!.length;
  }

  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  Future<void> fetchQuizzes({int? subjectId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final queryParams = <String, dynamic>{};
      if (subjectId != null) queryParams['subject_id'] = subjectId;

      final response = await _apiService.get('/quizzes', queryParameters: queryParams);

      if (response.statusCode == 200) {
        _quizzes = (response.data['data'] as List)
            .map((q) => Quiz.fromJson(q))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchQuizDetail(String quizId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.get('/quizzes/$quizId');

      if (response.statusCode == 200) {
        _currentQuiz = Quiz.fromJson(response.data['data']);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startQuiz(String quizId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.post('/quizzes/$quizId/start');

      if (response.statusCode == 200) {
        _currentAttempt = QuizAttempt.fromJson(response.data['data']['attempt']);
        _currentQuiz = Quiz.fromJson(response.data['data']['quiz']);
        _currentQuestionIndex = 0;
        _selectedAnswers = {};
        _remainingTime = _currentQuiz!.timeLimit * 60;
        _isLoading = false;
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void selectAnswer(int questionId, int answerId) {
    _selectedAnswers[questionId] = answerId;
    notifyListeners();
  }

  void nextQuestion() {
    if (!isLastQuestion) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < (_currentQuiz?.questions?.length ?? 0)) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  void updateRemainingTime(int seconds) {
    _remainingTime = seconds;
    notifyListeners();
  }

  Future<QuizAttempt?> submitQuiz() async {
    if (_currentAttempt == null) return null;

    try {
      _isLoading = true;
      notifyListeners();

      final answers = _selectedAnswers.entries.map((e) => {
        'question_id': e.key,
        'answer_id': e.value,
      }).toList();

      final response = await _apiService.post(
        '/quizzes/${_currentQuiz!.id}/submit',
        data: {
          'attempt_id': _currentAttempt!.id,
          'answers': answers,
          'time_spent': (_currentQuiz!.timeLimit * 60) - _remainingTime,
        },
      );

      if (response.statusCode == 200) {
        _currentAttempt = QuizAttempt.fromJson(response.data['data']);
        return _currentAttempt;
      }
      return null;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAttempts(String quizId) async {
    try {
      final response = await _apiService.get('/quizzes/$quizId/attempts');

      if (response.statusCode == 200) {
        _attempts = (response.data['data'] as List)
            .map((a) => QuizAttempt.fromJson(a))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to fetch attempts: $e');
    }
  }

  void resetQuiz() {
    _currentQuiz = null;
    _currentAttempt = null;
    _currentQuestionIndex = 0;
    _selectedAnswers = {};
    _remainingTime = 0;
    notifyListeners();
  }
}
