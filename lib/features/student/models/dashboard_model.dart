class DashboardData {
  final EnrollmentSummary enrollment;
  final ProgressSummary progress;
  final List<SubjectProgress> subjectProgress;
  final UpcomingItems upcoming;
  final List<RecentActivity> recentActivities;
  final WeeklyStats weeklyStats;

  DashboardData({
    required this.enrollment,
    required this.progress,
    required this.subjectProgress,
    required this.upcoming,
    required this.recentActivities,
    required this.weeklyStats,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    return DashboardData(
      enrollment: EnrollmentSummary.fromJson(json['enrollment'] ?? {}),
      progress: ProgressSummary.fromJson(json['progress'] ?? {}),
      subjectProgress: (json['subject_progress'] as List?)
              ?.map((s) => SubjectProgress.fromJson(s))
              .toList() ??
          [],
      upcoming: UpcomingItems.fromJson(json['upcoming'] ?? {}),
      recentActivities: (json['recent_activities'] as List?)
              ?.map((a) => RecentActivity.fromJson(a))
              .toList() ??
          [],
      weeklyStats: WeeklyStats.fromJson(json['weekly_stats'] ?? {}),
    );
  }
}

class EnrollmentSummary {
  final String status;
  final bool isTrial;
  final int daysRemaining;
  final DateTime? expiresAt;
  final int subjectsCount;

  EnrollmentSummary({
    required this.status,
    this.isTrial = false,
    required this.daysRemaining,
    this.expiresAt,
    required this.subjectsCount,
  });

  factory EnrollmentSummary.fromJson(Map<String, dynamic> json) {
    return EnrollmentSummary(
      status: json['status'] ?? 'pending',
      isTrial: json['is_trial'] ?? false,
      daysRemaining: json['days_remaining'] ?? 0,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
      subjectsCount: json['subjects_count'] ?? 0,
    );
  }
}

class ProgressSummary {
  final int totalLessons;
  final int completedLessons;
  final int totalQuizzes;
  final int completedQuizzes;
  final double averageScore;
  final int studyStreak;
  final int totalStudyHours;

  ProgressSummary({
    required this.totalLessons,
    required this.completedLessons,
    required this.totalQuizzes,
    required this.completedQuizzes,
    required this.averageScore,
    required this.studyStreak,
    required this.totalStudyHours,
  });

  double get lessonsProgress =>
      totalLessons > 0 ? (completedLessons / totalLessons) * 100 : 0;

  double get quizzesProgress =>
      totalQuizzes > 0 ? (completedQuizzes / totalQuizzes) * 100 : 0;

  factory ProgressSummary.fromJson(Map<String, dynamic> json) {
    return ProgressSummary(
      totalLessons: json['total_lessons'] ?? 0,
      completedLessons: json['completed_lessons'] ?? 0,
      totalQuizzes: json['total_quizzes'] ?? 0,
      completedQuizzes: json['completed_quizzes'] ?? 0,
      averageScore: (json['average_score'] ?? 0).toDouble(),
      studyStreak: json['study_streak'] ?? 0,
      totalStudyHours: json['total_study_hours'] ?? 0,
    );
  }
}

class SubjectProgress {
  final int id;
  final String name;
  final String? icon;
  final int progress;
  final int lessonsCompleted;
  final int totalLessons;
  final double averageScore;
  final String? lastAccessed;

  SubjectProgress({
    required this.id,
    required this.name,
    this.icon,
    required this.progress,
    required this.lessonsCompleted,
    required this.totalLessons,
    required this.averageScore,
    this.lastAccessed,
  });

  factory SubjectProgress.fromJson(Map<String, dynamic> json) {
    return SubjectProgress(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      progress: json['progress'] ?? 0,
      lessonsCompleted: json['lessons_completed'] ?? 0,
      totalLessons: json['total_lessons'] ?? 0,
      averageScore: (json['average_score'] ?? 0).toDouble(),
      lastAccessed: json['last_accessed'],
    );
  }
}

class UpcomingItems {
  final List<UpcomingAssignment> assignments;
  final List<UpcomingQuiz> quizzes;
  final List<UpcomingExam> exams;

  UpcomingItems({
    required this.assignments,
    required this.quizzes,
    required this.exams,
  });

  factory UpcomingItems.fromJson(Map<String, dynamic> json) {
    return UpcomingItems(
      assignments: (json['assignments'] as List?)
              ?.map((a) => UpcomingAssignment.fromJson(a))
              .toList() ??
          [],
      quizzes: (json['quizzes'] as List?)
              ?.map((q) => UpcomingQuiz.fromJson(q))
              .toList() ??
          [],
      exams: (json['exams'] as List?)
              ?.map((e) => UpcomingExam.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class UpcomingAssignment {
  final int id;
  final String title;
  final String subject;
  final DateTime dueDate;
  final bool isLate;

  UpcomingAssignment({
    required this.id,
    required this.title,
    required this.subject,
    required this.dueDate,
    required this.isLate,
  });

  factory UpcomingAssignment.fromJson(Map<String, dynamic> json) {
    return UpcomingAssignment(
      id: json['id'],
      title: json['title'],
      subject: json['subject'],
      dueDate: DateTime.parse(json['due_date']),
      isLate: json['is_late'] ?? false,
    );
  }
}

class UpcomingQuiz {
  final int id;
  final String title;
  final String subject;
  final DateTime? availableUntil;

  UpcomingQuiz({
    required this.id,
    required this.title,
    required this.subject,
    this.availableUntil,
  });

  factory UpcomingQuiz.fromJson(Map<String, dynamic> json) {
    return UpcomingQuiz(
      id: json['id'],
      title: json['title'],
      subject: json['subject'],
      availableUntil: json['available_until'] != null
          ? DateTime.parse(json['available_until'])
          : null,
    );
  }
}

class UpcomingExam {
  final int id;
  final String title;
  final String subject;
  final DateTime? scheduledAt;
  final int duration;

  UpcomingExam({
    required this.id,
    required this.title,
    required this.subject,
    this.scheduledAt,
    required this.duration,
  });

  factory UpcomingExam.fromJson(Map<String, dynamic> json) {
    return UpcomingExam(
      id: json['id'],
      title: json['title'],
      subject: json['subject'],
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'])
          : null,
      duration: json['duration'] ?? 180,
    );
  }
}

class RecentActivity {
  final int id;
  final String type;
  final String title;
  final String description;
  final String? subject;
  final int? score;
  final DateTime createdAt;

  RecentActivity({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    this.subject,
    this.score,
    required this.createdAt,
  });

  factory RecentActivity.fromJson(Map<String, dynamic> json) {
    return RecentActivity(
      id: json['id'],
      type: json['type'],
      title: json['title'],
      description: json['description'],
      subject: json['subject'],
      score: json['score'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class WeeklyStats {
  final List<DailyStudy> dailyStudy;
  final int totalMinutes;
  final int lessonsCompleted;
  final int quizzesCompleted;

  WeeklyStats({
    required this.dailyStudy,
    required this.totalMinutes,
    required this.lessonsCompleted,
    required this.quizzesCompleted,
  });

  factory WeeklyStats.fromJson(Map<String, dynamic> json) {
    return WeeklyStats(
      dailyStudy: (json['daily_study'] as List?)
              ?.map((d) => DailyStudy.fromJson(d))
              .toList() ??
          [],
      totalMinutes: json['total_minutes'] ?? 0,
      lessonsCompleted: json['lessons_completed'] ?? 0,
      quizzesCompleted: json['quizzes_completed'] ?? 0,
    );
  }
}

class DailyStudy {
  final String day;
  final int minutes;

  DailyStudy({
    required this.day,
    required this.minutes,
  });

  factory DailyStudy.fromJson(Map<String, dynamic> json) {
    return DailyStudy(
      day: json['day'],
      minutes: json['minutes'] ?? 0,
    );
  }
}
