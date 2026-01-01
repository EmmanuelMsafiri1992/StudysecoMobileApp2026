import 'package:flutter/foundation.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../models/assignment_model.dart';

class AssignmentProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuthProvider? _authProvider;

  bool _isLoading = false;
  String? _error;
  List<Assignment> _assignments = [];
  Assignment? _currentAssignment;
  List<AssignmentSubmission> _submissions = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Assignment> get assignments => _assignments;
  Assignment? get currentAssignment => _currentAssignment;
  List<AssignmentSubmission> get submissions => _submissions;

  List<Assignment> get pendingAssignments =>
      _assignments.where((a) => !a.isSubmitted && !a.isOverdue).toList();

  List<Assignment> get overdueAssignments =>
      _assignments.where((a) => !a.isSubmitted && a.isOverdue).toList();

  List<Assignment> get submittedAssignments =>
      _assignments.where((a) => a.isSubmitted).toList();

  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  Future<void> fetchAssignments({int? subjectId, String? status}) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final queryParams = <String, dynamic>{};
      if (subjectId != null) queryParams['subject_id'] = subjectId;
      if (status != null) queryParams['status'] = status;

      final response = await _apiService.get('/student/assignments', queryParameters: queryParams);

      if (response.statusCode == 200) {
        _assignments = (response.data['data'] as List)
            .map((a) => Assignment.fromJson(a))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchAssignmentDetail(String assignmentId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.get('/student/assignments/$assignmentId');

      if (response.statusCode == 200) {
        _currentAssignment = Assignment.fromJson(response.data['data']);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitAssignment({
    required int assignmentId,
    required String content,
    List<String>? attachments,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final data = <String, dynamic>{
        'content': content,
      };

      if (attachments != null && attachments.isNotEmpty) {
        // Handle file uploads
        final response = await _apiService.uploadMultipleFiles(
          '/student/assignments/$assignmentId/submit',
          filePaths: attachments,
          fieldName: 'attachments',
          additionalData: data,
        );

        if (response.statusCode == 200) {
          await fetchAssignments();
          return true;
        }
      } else {
        final response = await _apiService.post(
          '/student/assignments/$assignmentId/submit',
          data: data,
        );

        if (response.statusCode == 200) {
          await fetchAssignments();
          return true;
        }
      }

      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchSubmissions(int assignmentId) async {
    try {
      final response = await _apiService.get('/student/assignments/$assignmentId/submissions');

      if (response.statusCode == 200) {
        _submissions = (response.data['data'] as List)
            .map((s) => AssignmentSubmission.fromJson(s))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to fetch submissions: $e');
    }
  }

  void clearCurrentAssignment() {
    _currentAssignment = null;
    _submissions = [];
    notifyListeners();
  }
}
