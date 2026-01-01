class AppNotification {
  final int id;
  final String type;
  final String title;
  final String message;
  final String? icon;
  final String? actionUrl;
  final Map<String, dynamic>? data;
  final bool isRead;
  final DateTime createdAt;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.icon,
    this.actionUrl,
    this.data,
    this.isRead = false,
    required this.createdAt,
  });

  AppNotification copyWith({
    bool? isRead,
  }) {
    return AppNotification(
      id: id,
      type: type,
      title: title,
      message: message,
      icon: icon,
      actionUrl: actionUrl,
      data: data,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt,
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      type: json['type'] ?? 'general',
      title: json['title'],
      message: json['message'],
      icon: json['icon'],
      actionUrl: json['action_url'],
      data: json['data'],
      isRead: json['is_read'] ?? json['read_at'] != null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class NotificationSettings {
  final bool pushEnabled;
  final bool emailEnabled;
  final bool soundEnabled;
  final Map<String, bool> typeSettings;

  NotificationSettings({
    this.pushEnabled = true,
    this.emailEnabled = true,
    this.soundEnabled = true,
    this.typeSettings = const {},
  });

  NotificationSettings copyWith({
    bool? pushEnabled,
    bool? emailEnabled,
    bool? soundEnabled,
    Map<String, bool>? typeSettings,
  }) {
    return NotificationSettings(
      pushEnabled: pushEnabled ?? this.pushEnabled,
      emailEnabled: emailEnabled ?? this.emailEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      typeSettings: typeSettings ?? this.typeSettings,
    );
  }

  factory NotificationSettings.fromJson(Map<String, dynamic> json) {
    return NotificationSettings(
      pushEnabled: json['push_enabled'] ?? true,
      emailEnabled: json['email_enabled'] ?? true,
      soundEnabled: json['sound_enabled'] ?? true,
      typeSettings: (json['type_settings'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value as bool),
          ) ??
          {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'push_enabled': pushEnabled,
      'email_enabled': emailEnabled,
      'sound_enabled': soundEnabled,
      'type_settings': typeSettings,
    };
  }
}
