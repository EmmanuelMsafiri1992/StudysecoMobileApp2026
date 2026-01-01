class Achievement {
  final int id;
  final String name;
  final String description;
  final String type; // academic, conduct, leadership, sports, extracurricular
  final String level; // bronze, silver, gold, platinum
  final String? icon;
  final String? badge;
  final int points;
  final bool isEarned;
  final bool isPublic;
  final DateTime? earnedAt;
  final String? criteria;
  final int? progress;
  final int? target;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.level,
    this.icon,
    this.badge,
    this.points = 0,
    this.isEarned = false,
    this.isPublic = true,
    this.earnedAt,
    this.criteria,
    this.progress,
    this.target,
  });

  double get progressPercentage {
    if (target == null || target == 0) return isEarned ? 100 : 0;
    return ((progress ?? 0) / target!) * 100;
  }

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      type: json['type'] ?? 'academic',
      level: json['level'] ?? 'bronze',
      icon: json['icon'],
      badge: json['badge'],
      points: json['points'] ?? 0,
      isEarned: json['is_earned'] ?? false,
      isPublic: json['is_public'] ?? true,
      earnedAt: json['earned_at'] != null
          ? DateTime.parse(json['earned_at'])
          : null,
      criteria: json['criteria'],
      progress: json['progress'],
      target: json['target'],
    );
  }
}

class AchievementStats {
  final int totalAchievements;
  final int earnedAchievements;
  final int totalPoints;
  final Map<String, int> byType;
  final Map<String, int> byLevel;
  final int rank;
  final int percentile;

  AchievementStats({
    required this.totalAchievements,
    required this.earnedAchievements,
    required this.totalPoints,
    required this.byType,
    required this.byLevel,
    required this.rank,
    required this.percentile,
  });

  double get completionRate =>
      totalAchievements > 0 ? (earnedAchievements / totalAchievements) * 100 : 0;

  factory AchievementStats.fromJson(Map<String, dynamic> json) {
    return AchievementStats(
      totalAchievements: json['total_achievements'] ?? 0,
      earnedAchievements: json['earned_achievements'] ?? 0,
      totalPoints: json['total_points'] ?? 0,
      byType: (json['by_type'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value as int),
          ) ??
          {},
      byLevel: (json['by_level'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), value as int),
          ) ??
          {},
      rank: json['rank'] ?? 0,
      percentile: json['percentile'] ?? 0,
    );
  }
}

class Certificate {
  final int id;
  final int userId;
  final String title;
  final String type; // completion, achievement, excellence
  final int? subjectId;
  final String? subjectName;
  final String? description;
  final String? pdfUrl;
  final String certificateNumber;
  final DateTime issuedAt;
  final DateTime? expiresAt;

  Certificate({
    required this.id,
    required this.userId,
    required this.title,
    required this.type,
    this.subjectId,
    this.subjectName,
    this.description,
    this.pdfUrl,
    required this.certificateNumber,
    required this.issuedAt,
    this.expiresAt,
  });

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  factory Certificate.fromJson(Map<String, dynamic> json) {
    return Certificate(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      type: json['type'] ?? 'completion',
      subjectId: json['subject_id'],
      subjectName: json['subject_name'] ?? json['subject']?['name'],
      description: json['description'],
      pdfUrl: json['pdf_url'],
      certificateNumber: json['certificate_number'] ?? '',
      issuedAt: DateTime.parse(json['issued_at'] ?? DateTime.now().toIso8601String()),
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'])
          : null,
    );
  }
}
