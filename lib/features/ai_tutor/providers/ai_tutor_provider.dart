import 'package:flutter/foundation.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../models/ai_tutor_model.dart';

class AiTutorProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuthProvider? _authProvider;

  bool _isLoading = false;
  String? _error;
  List<TutorMessage> _messages = [];
  int? _currentSubjectId;
  TutorInfo? _assignedTutor;
  bool _isTyping = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<TutorMessage> get messages => _messages;
  int? get currentSubjectId => _currentSubjectId;
  TutorInfo? get assignedTutor => _assignedTutor;
  bool get isTyping => _isTyping;

  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  Future<void> initializeChat(int subjectId) async {
    _currentSubjectId = subjectId;
    _messages = [];
    await fetchAssignedTutor(subjectId);
    await fetchChatHistory(subjectId);
    notifyListeners();
  }

  Future<void> fetchAssignedTutor(int subjectId) async {
    try {
      final response = await _apiService.get('/ai/tutor/$subjectId');

      if (response.statusCode == 200) {
        _assignedTutor = TutorInfo.fromJson(response.data['data']);
      }
    } catch (e) {
      debugPrint('Failed to fetch tutor: $e');
    }
  }

  Future<void> fetchChatHistory(int subjectId) async {
    try {
      final response = await _apiService.get('/ai/chat/$subjectId/history');

      if (response.statusCode == 200) {
        _messages = (response.data['data'] as List)
            .map((m) => TutorMessage.fromJson(m))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to fetch chat history: $e');
    }
  }

  Future<void> sendMessage(String content) async {
    if (_currentSubjectId == null) return;

    // Add user message
    final userMessage = TutorMessage(
      id: DateTime.now().millisecondsSinceEpoch,
      content: content,
      isUser: true,
      createdAt: DateTime.now(),
    );
    _messages.add(userMessage);
    _isTyping = true;
    notifyListeners();

    try {
      final response = await _apiService.post(
        '/ai/chat/${_currentSubjectId}/message',
        data: {'message': content},
      );

      if (response.statusCode == 200) {
        final aiMessage = TutorMessage.fromJson(response.data['data']);
        _messages.add(aiMessage);
      } else {
        _error = 'Failed to get response';
      }
    } catch (e) {
      _error = e.toString();
      // Add error message
      _messages.add(TutorMessage(
        id: DateTime.now().millisecondsSinceEpoch,
        content: 'Sorry, I encountered an error. Please try again.',
        isUser: false,
        isError: true,
        createdAt: DateTime.now(),
      ));
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  Future<bool> requestLiveSession({
    required String topic,
    required DateTime preferredTime,
    String? notes,
  }) async {
    try {
      final response = await _apiService.post('/ai/live-session', data: {
        'subject_id': _currentSubjectId,
        'topic': topic,
        'preferred_time': preferredTime.toIso8601String(),
        if (notes != null) 'notes': notes,
      });

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  void clearChat() {
    _messages = [];
    _currentSubjectId = null;
    _assignedTutor = null;
    notifyListeners();
  }
}
