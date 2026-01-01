import 'package:flutter/foundation.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../models/exam_model.dart';

class ExamProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuthProvider? _authProvider;

  bool _isLoading = false;
  String? _error;
  List<MockExam> _exams = [];
  MockExam? _currentExam;
  ExamAttempt? _currentAttempt;
  List<ExamAttempt> _attempts = [];
  int _currentQuestionIndex = 0;
  Map<int, int> _selectedAnswers = {};
  int _remainingTime = 0;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<MockExam> get exams => _exams;
  MockExam? get currentExam => _currentExam;
  ExamAttempt? get currentAttempt => _currentAttempt;
  List<ExamAttempt> get attempts => _attempts;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<int, int> get selectedAnswers => _selectedAnswers;
  int get remainingTime => _remainingTime;

  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  Future<void> fetchExams({int? subjectId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final queryParams = <String, dynamic>{};
      if (subjectId != null) queryParams['subject_id'] = subjectId;

      final response = await _apiService.get('/mock-exams', queryParameters: queryParams);

      if (response.statusCode == 200) {
        _exams = (response.data['data'] as List)
            .map((e) => MockExam.fromJson(e))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchExamDetail(String examId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.get('/mock-exams/$examId');

      if (response.statusCode == 200) {
        _currentExam = MockExam.fromJson(response.data['data']);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> startExam(String examId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.post('/mock-exams/$examId/start');

      if (response.statusCode == 200) {
        _currentAttempt = ExamAttempt.fromJson(response.data['data']['attempt']);
        _currentExam = MockExam.fromJson(response.data['data']['exam']);
        _currentQuestionIndex = 0;
        _selectedAnswers = {};
        _remainingTime = _currentExam!.duration * 60;
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
    if (_currentQuestionIndex < (_currentExam?.questions?.length ?? 1) - 1) {
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
    if (index >= 0 && index < (_currentExam?.questions?.length ?? 0)) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  void updateRemainingTime(int seconds) {
    _remainingTime = seconds;
    notifyListeners();
  }

  Future<ExamAttempt?> submitExam() async {
    if (_currentAttempt == null) return null;

    try {
      _isLoading = true;
      notifyListeners();

      final answers = _selectedAnswers.entries.map((e) => {
        'question_id': e.key,
        'answer_id': e.value,
      }).toList();

      final response = await _apiService.post(
        '/mock-exams/${_currentExam!.id}/submit',
        data: {
          'attempt_id': _currentAttempt!.id,
          'answers': answers,
          'time_spent': (_currentExam!.duration * 60) - _remainingTime,
        },
      );

      if (response.statusCode == 200) {
        _currentAttempt = ExamAttempt.fromJson(response.data['data']);
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

  Future<void> fetchAttempts(String examId) async {
    try {
      final response = await _apiService.get('/mock-exams/$examId/attempts');

      if (response.statusCode == 200) {
        _attempts = (response.data['data'] as List)
            .map((a) => ExamAttempt.fromJson(a))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to fetch attempts: $e');
    }
  }

  void resetExam() {
    _currentExam = null;
    _currentAttempt = null;
    _currentQuestionIndex = 0;
    _selectedAnswers = {};
    _remainingTime = 0;
    notifyListeners();
  }
}
