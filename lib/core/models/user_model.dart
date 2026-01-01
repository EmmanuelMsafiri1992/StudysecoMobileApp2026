class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? avatar;
  final String? bio;
  final String? gradeLevel;
  final bool emailVerified;
  final DateTime? lastLogin;
  final Enrollment? enrollment;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.avatar,
    this.bio,
    this.gradeLevel,
    this.emailVerified = false,
    this.lastLogin,
    this.enrollment,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'] ?? 'student',
      avatar: json['avatar'],
      bio: json['bio'],
      gradeLevel: json['grade_level'],
      emailVerified: json['email_verified'] ?? json['email_verified_at'] != null,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
      enrollment: json['enrollment'] != null
          ? Enrollment.fromJson(json['enrollment'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'avatar': avatar,
      'bio': bio,
      'grade_level': gradeLevel,
      'email_verified': emailVerified,
      'last_login': lastLogin?.toIso8601String(),
      'enrollment': enrollment?.toJson(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? avatar,
    String? bio,
    String? gradeLevel,
    bool? emailVerified,
    DateTime? lastLogin,
    Enrollment? enrollment,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      avatar: avatar ?? this.avatar,
      bio: bio ?? this.bio,
      gradeLevel: gradeLevel ?? this.gradeLevel,
      emailVerified: emailVerified ?? this.emailVerified,
      lastLogin: lastLogin ?? this.lastLogin,
      enrollment: enrollment ?? this.enrollment,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Enrollment {
  final int id;
  final int userId;
  final String status;
  final bool isTrial;
  final DateTime? trialEndsAt;
  final DateTime? accessExpiresAt;
  final int? daysRemaining;
  final List<EnrolledSubject>? subjects;
  final DateTime createdAt;
  final DateTime updatedAt;

  Enrollment({
    required this.id,
    required this.userId,
    required this.status,
    this.isTrial = false,
    this.trialEndsAt,
    this.accessExpiresAt,
    this.daysRemaining,
    this.subjects,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isActive => status == 'approved' || status == 'active';
  bool get isPending => status == 'pending';
  bool get isExpired => status == 'access_expired' ||
      (accessExpiresAt != null && accessExpiresAt!.isBefore(DateTime.now()));

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['id'],
      userId: json['user_id'],
      status: json['status'],
      isTrial: json['is_trial'] ?? false,
      trialEndsAt: json['trial_ends_at'] != null
          ? DateTime.parse(json['trial_ends_at'])
          : null,
      accessExpiresAt: json['access_expires_at'] != null
          ? DateTime.parse(json['access_expires_at'])
          : null,
      daysRemaining: json['days_remaining'],
      subjects: json['subjects'] != null
          ? (json['subjects'] as List)
              .map((s) => EnrolledSubject.fromJson(s))
              .toList()
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'status': status,
      'is_trial': isTrial,
      'trial_ends_at': trialEndsAt?.toIso8601String(),
      'access_expires_at': accessExpiresAt?.toIso8601String(),
      'days_remaining': daysRemaining,
      'subjects': subjects?.map((s) => s.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class EnrolledSubject {
  final int id;
  final int subjectId;
  final String name;
  final String? icon;
  final int progress;
  final int lessonsCompleted;
  final int totalLessons;

  EnrolledSubject({
    required this.id,
    required this.subjectId,
    required this.name,
    this.icon,
    this.progress = 0,
    this.lessonsCompleted = 0,
    this.totalLessons = 0,
  });

  factory EnrolledSubject.fromJson(Map<String, dynamic> json) {
    return EnrolledSubject(
      id: json['id'],
      subjectId: json['subject_id'] ?? json['id'],
      name: json['name'],
      icon: json['icon'],
      progress: json['progress'] ?? 0,
      lessonsCompleted: json['lessons_completed'] ?? 0,
      totalLessons: json['total_lessons'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'subject_id': subjectId,
      'name': name,
      'icon': icon,
      'progress': progress,
      'lessons_completed': lessonsCompleted,
      'total_lessons': totalLessons,
    };
  }
}
