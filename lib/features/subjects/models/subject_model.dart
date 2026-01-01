class Subject {
  final int id;
  final String name;
  final String? code;
  final String? description;
  final String? icon;
  final String? image;
  final int? departmentId;
  final String? departmentName;
  final String? gradeLevel;
  final int topicsCount;
  final int lessonsCount;
  final int quizzesCount;
  final int progress;
  final bool isEnrolled;
  final List<Topic>? topics;
  final double? price;
  final DateTime createdAt;

  Subject({
    required this.id,
    required this.name,
    this.code,
    this.description,
    this.icon,
    this.image,
    this.departmentId,
    this.departmentName,
    this.gradeLevel,
    this.topicsCount = 0,
    this.lessonsCount = 0,
    this.quizzesCount = 0,
    this.progress = 0,
    this.isEnrolled = false,
    this.topics,
    this.price,
    required this.createdAt,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      description: json['description'],
      icon: json['icon'],
      image: json['image'],
      departmentId: json['department_id'],
      departmentName: json['department_name'] ?? json['department']?['name'],
      gradeLevel: json['grade_level'],
      topicsCount: json['topics_count'] ?? 0,
      lessonsCount: json['lessons_count'] ?? 0,
      quizzesCount: json['quizzes_count'] ?? 0,
      progress: json['progress'] ?? 0,
      isEnrolled: json['is_enrolled'] ?? false,
      topics: json['topics'] != null
          ? (json['topics'] as List).map((t) => Topic.fromJson(t)).toList()
          : null,
      price: json['price']?.toDouble(),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'icon': icon,
      'image': image,
      'department_id': departmentId,
      'grade_level': gradeLevel,
      'topics_count': topicsCount,
      'lessons_count': lessonsCount,
      'quizzes_count': quizzesCount,
      'progress': progress,
      'is_enrolled': isEnrolled,
      'price': price,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Topic {
  final int id;
  final int subjectId;
  final String name;
  final String? description;
  final int order;
  final int lessonsCount;
  final int completedLessons;
  final List<Lesson>? lessons;
  final bool isCompleted;

  Topic({
    required this.id,
    required this.subjectId,
    required this.name,
    this.description,
    this.order = 0,
    this.lessonsCount = 0,
    this.completedLessons = 0,
    this.lessons,
    this.isCompleted = false,
  });

  double get progress =>
      lessonsCount > 0 ? (completedLessons / lessonsCount) * 100 : 0;

  factory Topic.fromJson(Map<String, dynamic> json) {
    return Topic(
      id: json['id'],
      subjectId: json['subject_id'],
      name: json['name'],
      description: json['description'],
      order: json['order'] ?? 0,
      lessonsCount: json['lessons_count'] ?? 0,
      completedLessons: json['completed_lessons'] ?? 0,
      lessons: json['lessons'] != null
          ? (json['lessons'] as List).map((l) => Lesson.fromJson(l)).toList()
          : null,
      isCompleted: json['is_completed'] ?? false,
    );
  }
}

class Lesson {
  final int id;
  final int topicId;
  final String title;
  final String? description;
  final String? videoUrl;
  final String? thumbnail;
  final int duration; // in minutes
  final int order;
  final bool isCompleted;
  final bool isPublished;
  final String? notes;
  final List<LessonResource>? resources;

  Lesson({
    required this.id,
    required this.topicId,
    required this.title,
    this.description,
    this.videoUrl,
    this.thumbnail,
    this.duration = 0,
    this.order = 0,
    this.isCompleted = false,
    this.isPublished = true,
    this.notes,
    this.resources,
  });

  String get durationFormatted {
    if (duration < 60) {
      return '${duration}min';
    } else {
      final hours = duration ~/ 60;
      final mins = duration % 60;
      return mins > 0 ? '${hours}h ${mins}min' : '${hours}h';
    }
  }

  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      id: json['id'],
      topicId: json['topic_id'],
      title: json['title'],
      description: json['description'],
      videoUrl: json['video_url'],
      thumbnail: json['thumbnail'],
      duration: json['duration'] ?? 0,
      order: json['order'] ?? 0,
      isCompleted: json['is_completed'] ?? false,
      isPublished: json['is_published'] ?? true,
      notes: json['notes'],
      resources: json['resources'] != null
          ? (json['resources'] as List)
              .map((r) => LessonResource.fromJson(r))
              .toList()
          : null,
    );
  }
}

class LessonResource {
  final int id;
  final String name;
  final String type;
  final String url;
  final int? size;

  LessonResource({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    this.size,
  });

  factory LessonResource.fromJson(Map<String, dynamic> json) {
    return LessonResource(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      url: json['url'],
      size: json['size'],
    );
  }
}

class Department {
  final int id;
  final String name;
  final String? description;
  final String? icon;
  final int subjectsCount;

  Department({
    required this.id,
    required this.name,
    this.description,
    this.icon,
    this.subjectsCount = 0,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      icon: json['icon'],
      subjectsCount: json['subjects_count'] ?? 0,
    );
  }
}
