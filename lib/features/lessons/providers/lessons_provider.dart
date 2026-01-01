import 'package:flutter/foundation.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../../subjects/models/subject_model.dart';

class LessonsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuthProvider? _authProvider;

  bool _isLoading = false;
  String? _error;
  List<Lesson> _lessons = [];
  Lesson? _currentLesson;
  double _videoProgress = 0;
  bool _isVideoPlaying = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Lesson> get lessons => _lessons;
  Lesson? get currentLesson => _currentLesson;
  double get videoProgress => _videoProgress;
  bool get isVideoPlaying => _isVideoPlaying;

  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  Future<void> fetchLessons({int? topicId, int? subjectId}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final queryParams = <String, dynamic>{};
      if (topicId != null) queryParams['topic_id'] = topicId;
      if (subjectId != null) queryParams['subject_id'] = subjectId;

      final response = await _apiService.get('/lessons', queryParameters: queryParams);

      if (response.statusCode == 200) {
        _lessons = (response.data['data'] as List)
            .map((l) => Lesson.fromJson(l))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchLessonDetail(String lessonId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.get('/lessons/$lessonId');

      if (response.statusCode == 200) {
        _currentLesson = Lesson.fromJson(response.data['data']);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> markLessonComplete(int lessonId) async {
    try {
      final response = await _apiService.post('/lessons/$lessonId/complete');

      if (response.statusCode == 200) {
        // Update local lesson state
        final index = _lessons.indexWhere((l) => l.id == lessonId);
        if (index != -1) {
          _lessons[index] = Lesson(
            id: _lessons[index].id,
            topicId: _lessons[index].topicId,
            title: _lessons[index].title,
            description: _lessons[index].description,
            videoUrl: _lessons[index].videoUrl,
            thumbnail: _lessons[index].thumbnail,
            duration: _lessons[index].duration,
            order: _lessons[index].order,
            isCompleted: true,
            isPublished: _lessons[index].isPublished,
            notes: _lessons[index].notes,
          );
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<void> updateProgress(int lessonId, double progress) async {
    try {
      await _apiService.post('/lessons/$lessonId/progress', data: {
        'progress': progress,
      });
      _videoProgress = progress;
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to update progress: $e');
    }
  }

  void setVideoPlaying(bool playing) {
    _isVideoPlaying = playing;
    notifyListeners();
  }

  void setVideoProgress(double progress) {
    _videoProgress = progress;
    notifyListeners();
  }

  Lesson? getNextLesson() {
    if (_currentLesson == null) return null;

    final currentIndex = _lessons.indexWhere((l) => l.id == _currentLesson!.id);
    if (currentIndex >= 0 && currentIndex < _lessons.length - 1) {
      return _lessons[currentIndex + 1];
    }
    return null;
  }

  Lesson? getPreviousLesson() {
    if (_currentLesson == null) return null;

    final currentIndex = _lessons.indexWhere((l) => l.id == _currentLesson!.id);
    if (currentIndex > 0) {
      return _lessons[currentIndex - 1];
    }
    return null;
  }

  void clearCurrentLesson() {
    _currentLesson = null;
    _videoProgress = 0;
    notifyListeners();
  }
}
