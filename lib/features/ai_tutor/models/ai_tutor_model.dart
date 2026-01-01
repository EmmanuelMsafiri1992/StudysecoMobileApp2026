class TutorMessage {
  final int id;
  final String content;
  final bool isUser;
  final bool isError;
  final List<String>? suggestions;
  final List<RelatedResource>? relatedResources;
  final DateTime createdAt;

  TutorMessage({
    required this.id,
    required this.content,
    required this.isUser,
    this.isError = false,
    this.suggestions,
    this.relatedResources,
    required this.createdAt,
  });

  factory TutorMessage.fromJson(Map<String, dynamic> json) {
    return TutorMessage(
      id: json['id'],
      content: json['content'],
      isUser: json['is_user'] ?? false,
      isError: json['is_error'] ?? false,
      suggestions: (json['suggestions'] as List?)?.cast<String>(),
      relatedResources: json['related_resources'] != null
          ? (json['related_resources'] as List)
              .map((r) => RelatedResource.fromJson(r))
              .toList()
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class RelatedResource {
  final int id;
  final String title;
  final String type; // lesson, quiz, resource
  final String? url;

  RelatedResource({
    required this.id,
    required this.title,
    required this.type,
    this.url,
  });

  factory RelatedResource.fromJson(Map<String, dynamic> json) {
    return RelatedResource(
      id: json['id'],
      title: json['title'],
      type: json['type'],
      url: json['url'],
    );
  }
}

class TutorInfo {
  final int id;
  final String name;
  final String? avatar;
  final String? email;
  final String? phone;
  final String? bio;
  final String? specialization;
  final List<String>? subjects;
  final double? rating;
  final bool isAvailable;

  TutorInfo({
    required this.id,
    required this.name,
    this.avatar,
    this.email,
    this.phone,
    this.bio,
    this.specialization,
    this.subjects,
    this.rating,
    this.isAvailable = true,
  });

  factory TutorInfo.fromJson(Map<String, dynamic> json) {
    return TutorInfo(
      id: json['id'],
      name: json['name'],
      avatar: json['avatar'],
      email: json['email'],
      phone: json['phone'],
      bio: json['bio'],
      specialization: json['specialization'],
      subjects: (json['subjects'] as List?)?.cast<String>(),
      rating: json['rating']?.toDouble(),
      isAvailable: json['is_available'] ?? true,
    );
  }
}

class LiveSession {
  final int id;
  final int studentId;
  final int tutorId;
  final String tutorName;
  final int subjectId;
  final String subjectName;
  final String topic;
  final String status; // pending, confirmed, completed, cancelled
  final DateTime scheduledAt;
  final String? meetingLink;
  final String? notes;
  final DateTime createdAt;

  LiveSession({
    required this.id,
    required this.studentId,
    required this.tutorId,
    required this.tutorName,
    required this.subjectId,
    required this.subjectName,
    required this.topic,
    required this.status,
    required this.scheduledAt,
    this.meetingLink,
    this.notes,
    required this.createdAt,
  });

  factory LiveSession.fromJson(Map<String, dynamic> json) {
    return LiveSession(
      id: json['id'],
      studentId: json['student_id'],
      tutorId: json['tutor_id'],
      tutorName: json['tutor_name'] ?? json['tutor']?['name'] ?? 'Unknown',
      subjectId: json['subject_id'],
      subjectName: json['subject_name'] ?? json['subject']?['name'] ?? 'Unknown',
      topic: json['topic'],
      status: json['status'] ?? 'pending',
      scheduledAt: DateTime.parse(json['scheduled_at']),
      meetingLink: json['meeting_link'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
