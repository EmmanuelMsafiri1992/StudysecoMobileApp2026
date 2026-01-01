import 'package:flutter/foundation.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../models/subject_model.dart';

class SubjectsProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuthProvider? _authProvider;

  bool _isLoading = false;
  String? _error;
  List<Subject> _subjects = [];
  List<Subject> _enrolledSubjects = [];
  Subject? _selectedSubject;
  List<Department> _departments = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Subject> get subjects => _subjects;
  List<Subject> get enrolledSubjects => _enrolledSubjects;
  Subject? get selectedSubject => _selectedSubject;
  List<Department> get departments => _departments;

  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
    if (_authProvider?.isAuthenticated == true && _subjects.isEmpty) {
      fetchSubjects();
    }
  }

  Future<void> fetchSubjects() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.get('/subjects');

      if (response.statusCode == 200) {
        _subjects = (response.data['data'] as List)
            .map((s) => Subject.fromJson(s))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchEnrolledSubjects() async {
    try {
      final response = await _apiService.get('/student/subjects');

      if (response.statusCode == 200) {
        _enrolledSubjects = (response.data['data'] as List)
            .map((s) => Subject.fromJson(s))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> fetchSubjectDetail(String id) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.get('/subjects/$id');

      if (response.statusCode == 200) {
        _selectedSubject = Subject.fromJson(response.data['data']);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDepartments() async {
    try {
      final response = await _apiService.get('/departments');

      if (response.statusCode == 200) {
        _departments = (response.data['data'] as List)
            .map((d) => Department.fromJson(d))
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Failed to fetch departments: $e');
    }
  }

  List<Subject> getSubjectsByDepartment(int departmentId) {
    return _subjects.where((s) => s.departmentId == departmentId).toList();
  }

  List<Subject> searchSubjects(String query) {
    final lowerQuery = query.toLowerCase();
    return _subjects.where((s) {
      return s.name.toLowerCase().contains(lowerQuery) ||
          (s.description?.toLowerCase().contains(lowerQuery) ?? false);
    }).toList();
  }

  void clearSelectedSubject() {
    _selectedSubject = null;
    notifyListeners();
  }
}
