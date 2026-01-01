class ChatGroup {
  final int id;
  final String name;
  final String? description;
  final String? image;
  final int? subjectId;
  final String? subjectName;
  final String type; // subject, general, private
  final int membersCount;
  final int unreadCount;
  final ChatMessage? lastMessage;
  final bool isMember;
  final String? role; // admin, moderator, member
  final DateTime createdAt;

  ChatGroup({
    required this.id,
    required this.name,
    this.description,
    this.image,
    this.subjectId,
    this.subjectName,
    this.type = 'subject',
    this.membersCount = 0,
    this.unreadCount = 0,
    this.lastMessage,
    this.isMember = true,
    this.role,
    required this.createdAt,
  });

  factory ChatGroup.fromJson(Map<String, dynamic> json) {
    return ChatGroup(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      image: json['image'],
      subjectId: json['subject_id'],
      subjectName: json['subject_name'] ?? json['subject']?['name'],
      type: json['type'] ?? 'subject',
      membersCount: json['members_count'] ?? 0,
      unreadCount: json['unread_count'] ?? 0,
      lastMessage: json['last_message'] != null
          ? ChatMessage.fromJson(json['last_message'])
          : null,
      isMember: json['is_member'] ?? true,
      role: json['role'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class ChatMessage {
  final int id;
  final int groupId;
  final int userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final String type; // text, image, file, system
  final String? attachment;
  final String? attachmentName;
  final bool isPinned;
  final bool isDeleted;
  final int? replyToId;
  final ChatMessage? replyTo;
  final DateTime createdAt;

  ChatMessage({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    this.type = 'text',
    this.attachment,
    this.attachmentName,
    this.isPinned = false,
    this.isDeleted = false,
    this.replyToId,
    this.replyTo,
    required this.createdAt,
  });

  bool get isSystem => type == 'system';
  bool get hasAttachment => attachment != null;

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      groupId: json['group_id'],
      userId: json['user_id'],
      userName: json['user_name'] ?? json['user']?['name'] ?? 'Unknown',
      userAvatar: json['user_avatar'] ?? json['user']?['avatar'],
      content: json['content'] ?? '',
      type: json['type'] ?? 'text',
      attachment: json['attachment'],
      attachmentName: json['attachment_name'],
      isPinned: json['is_pinned'] ?? false,
      isDeleted: json['is_deleted'] ?? false,
      replyToId: json['reply_to_id'],
      replyTo: json['reply_to'] != null
          ? ChatMessage.fromJson(json['reply_to'])
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class ChatMember {
  final int id;
  final int userId;
  final String userName;
  final String? userAvatar;
  final String role;
  final bool isOnline;
  final DateTime? lastSeen;
  final DateTime joinedAt;

  ChatMember({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.role,
    this.isOnline = false,
    this.lastSeen,
    required this.joinedAt,
  });

  factory ChatMember.fromJson(Map<String, dynamic> json) {
    return ChatMember(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'] ?? json['user']?['name'] ?? 'Unknown',
      userAvatar: json['user_avatar'] ?? json['user']?['avatar'],
      role: json['role'] ?? 'member',
      isOnline: json['is_online'] ?? false,
      lastSeen: json['last_seen'] != null
          ? DateTime.parse(json['last_seen'])
          : null,
      joinedAt: DateTime.parse(json['joined_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
