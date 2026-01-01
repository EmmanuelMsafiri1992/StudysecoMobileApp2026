import 'package:flutter/foundation.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../models/community_model.dart';

class CommunityProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuthProvider? _authProvider;

  bool _isLoading = false;
  String? _error;
  List<CommunityPost> _posts = [];
  CommunityPost? _currentPost;
  String _filter = 'all'; // all, questions, discussions, polls, shared

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<CommunityPost> get posts => _posts;
  CommunityPost? get currentPost => _currentPost;
  String get filter => _filter;

  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  Future<void> fetchPosts({String? type, int? subjectId, int page = 1}) async {
    try {
      _isLoading = page == 1;
      _error = null;
      if (page == 1) notifyListeners();

      final queryParams = <String, dynamic>{'page': page};
      if (type != null && type != 'all') queryParams['type'] = type;
      if (subjectId != null) queryParams['subject_id'] = subjectId;

      final response = await _apiService.get('/community/posts', queryParameters: queryParams);

      if (response.statusCode == 200) {
        final newPosts = (response.data['data'] as List)
            .map((p) => CommunityPost.fromJson(p))
            .toList();

        if (page == 1) {
          _posts = newPosts;
        } else {
          _posts.addAll(newPosts);
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchPostDetail(String postId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await _apiService.get('/community/posts/$postId');

      if (response.statusCode == 200) {
        _currentPost = CommunityPost.fromJson(response.data['data']);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createPost({
    required String title,
    required String content,
    required String type,
    int? subjectId,
    List<String>? tags,
    List<PollOption>? pollOptions,
  }) async {
    try {
      final response = await _apiService.post('/community/posts', data: {
        'title': title,
        'content': content,
        'type': type,
        if (subjectId != null) 'subject_id': subjectId,
        if (tags != null) 'tags': tags,
        if (pollOptions != null)
          'poll_options': pollOptions.map((o) => o.option).toList(),
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchPosts();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> likePost(int postId) async {
    try {
      final response = await _apiService.post('/community/posts/$postId/like');

      if (response.statusCode == 200) {
        final index = _posts.indexWhere((p) => p.id == postId);
        if (index != -1) {
          _posts[index] = _posts[index].copyWith(
            isLiked: !_posts[index].isLiked,
            likesCount: _posts[index].isLiked
                ? _posts[index].likesCount - 1
                : _posts[index].likesCount + 1,
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

  Future<bool> addComment(int postId, String content, {int? parentId}) async {
    try {
      final response = await _apiService.post(
        '/community/posts/$postId/comments',
        data: {
          'content': content,
          if (parentId != null) 'parent_id': parentId,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchPostDetail(postId.toString());
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> votePoll(int postId, int optionId) async {
    try {
      final response = await _apiService.post(
        '/community/posts/$postId/vote',
        data: {'option_id': optionId},
      );

      if (response.statusCode == 200) {
        await fetchPostDetail(postId.toString());
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> markAsSolution(int postId, int commentId) async {
    try {
      final response = await _apiService.post(
        '/community/posts/$postId/solution',
        data: {'comment_id': commentId},
      );

      if (response.statusCode == 200) {
        await fetchPostDetail(postId.toString());
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  void setFilter(String filter) {
    _filter = filter;
    fetchPosts(type: filter);
  }

  void clearCurrentPost() {
    _currentPost = null;
    notifyListeners();
  }
}
