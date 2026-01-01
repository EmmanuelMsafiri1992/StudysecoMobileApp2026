import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import '../../../core/providers/auth_provider.dart';
import '../../../core/services/api_service.dart';
import '../models/chat_model.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  AuthProvider? _authProvider;
  WebSocketChannel? _channel;

  bool _isLoading = false;
  String? _error;
  List<ChatGroup> _groups = [];
  ChatGroup? _currentGroup;
  List<ChatMessage> _messages = [];
  bool _isConnected = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<ChatGroup> get groups => _groups;
  ChatGroup? get currentGroup => _currentGroup;
  List<ChatMessage> get messages => _messages;
  bool get isConnected => _isConnected;

  void updateAuth(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  Future<void> fetchGroups() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await _apiService.get('/chat/groups');

      if (response.statusCode == 200) {
        _groups = (response.data['data'] as List)
            .map((g) => ChatGroup.fromJson(g))
            .toList();
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchGroupMessages(String groupId, {int page = 1}) async {
    try {
      if (page == 1) {
        _isLoading = true;
        notifyListeners();
      }

      final response = await _apiService.get(
        '/chat/groups/$groupId/messages',
        queryParameters: {'page': page},
      );

      if (response.statusCode == 200) {
        final newMessages = (response.data['data'] as List)
            .map((m) => ChatMessage.fromJson(m))
            .toList();

        if (page == 1) {
          _messages = newMessages;
        } else {
          _messages.addAll(newMessages);
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> joinGroup(String groupId) async {
    try {
      _currentGroup = _groups.firstWhere((g) => g.id.toString() == groupId);
      await fetchGroupMessages(groupId);
      _connectWebSocket(groupId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void _connectWebSocket(String groupId) {
    try {
      final token = _authProvider?.token;
      if (token == null) return;

      final wsUrl = 'wss://studyseco.com/ws/chat/$groupId?token=$token';
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _channel!.stream.listen(
        (data) {
          final message = ChatMessage.fromJson(jsonDecode(data));
          _messages.insert(0, message);
          notifyListeners();
        },
        onError: (error) {
          _isConnected = false;
          notifyListeners();
        },
        onDone: () {
          _isConnected = false;
          notifyListeners();
        },
      );

      _isConnected = true;
      notifyListeners();
    } catch (e) {
      debugPrint('WebSocket connection error: $e');
    }
  }

  Future<bool> sendMessage(String content, {String? type, String? attachment}) async {
    try {
      final response = await _apiService.post(
        '/chat/groups/${_currentGroup!.id}/messages',
        data: {
          'content': content,
          'type': type ?? 'text',
          if (attachment != null) 'attachment': attachment,
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  Future<bool> deleteMessage(int messageId) async {
    try {
      final response = await _apiService.delete('/chat/messages/$messageId');

      if (response.statusCode == 200) {
        _messages.removeWhere((m) => m.id == messageId);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    }
  }

  void leaveGroup() {
    _channel?.sink.close();
    _channel = null;
    _currentGroup = null;
    _messages = [];
    _isConnected = false;
    notifyListeners();
  }

  void markAsRead() {
    if (_currentGroup != null) {
      _apiService.post('/chat/groups/${_currentGroup!.id}/read');
    }
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }
}
