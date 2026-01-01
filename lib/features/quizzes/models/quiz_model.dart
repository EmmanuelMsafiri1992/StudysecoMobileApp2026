class Quiz {
  final int id;
  final String title;
  final String? description;
  final int subjectId;
  final String? subjectName;
  final int timeLimit; // in minutes
  final int questionsCount;
  final int passingScore;
  final int maxAttempts;
  final int? userAttempts;
  final double? bestScore;
  final bool isCompleted;
  final bool isAvailable;
  final List<QuizQuestion>? questions;
  final DateTime? availableFrom;
  final DateTime? availableUntil;
  final DateTime createdAt;

  Quiz({
    required this.id,
    required this.title,
    this.description,
    required this.subjectId,
    this.subjectName,
    required this.timeLimit,
    required this.questionsCount,
    required this.passingScore,
    this.maxAttempts = 3,
    this.userAttempts,
    this.bestScore,
    this.isCompleted = false,
    this.isAvailable = true,
    this.questions,
    this.availableFrom,
    this.availableUntil,
    required this.createdAt,
  });

  bool get canAttempt {
    if (maxAttempts <= 0) return true;
    return (userAttempts ?? 0) < maxAttempts;
  }

  int get remainingAttempts {
    if (maxAttempts <= 0) return -1;
    return maxAttempts - (userAttempts ?? 0);
  }

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      subjectId: json['subject_id'],
      subjectName: json['subject_name'] ?? json['subject']?['name'],
      timeLimit: json['time_limit'] ?? 30,
      questionsCount: json['questions_count'] ?? 0,
      passingScore: json['passing_score'] ?? 50,
      maxAttempts: json['max_attempts'] ?? 3,
      userAttempts: json['user_attempts'],
      bestScore: json['best_score']?.toDouble(),
      isCompleted: json['is_completed'] ?? false,
      isAvailable: json['is_available'] ?? true,
      questions: json['questions'] != null
          ? (json['questions'] as List)
              .map((q) => QuizQuestion.fromJson(q))
              .toList()
          : null,
      availableFrom: json['available_from'] != null
          ? DateTime.parse(json['available_from'])
          : null,
      availableUntil: json['available_until'] != null
          ? DateTime.parse(json['available_until'])
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class QuizQuestion {
  final int id;
  final int quizId;
  final String question;
  final String? questionImage;
  final String type; // multiple_choice, true_false
  final int points;
  final int order;
  final List<QuizAnswer> answers;
  final String? explanation;
  final int? selectedAnswerId;
  final bool? isCorrect;

  QuizQuestion({
    required this.id,
    required this.quizId,
    required this.question,
    this.questionImage,
    this.type = 'multiple_choice',
    this.points = 1,
    this.order = 0,
    required this.answers,
    this.explanation,
    this.selectedAnswerId,
    this.isCorrect,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> json) {
    return QuizQuestion(
      id: json['id'],
      quizId: json['quiz_id'],
      question: json['question'],
      questionImage: json['question_image'],
      type: json['type'] ?? 'multiple_choice',
      points: json['points'] ?? 1,
      order: json['order'] ?? 0,
      answers: (json['answers'] as List?)
              ?.map((a) => QuizAnswer.fromJson(a))
              .toList() ??
          [],
      explanation: json['explanation'],
      selectedAnswerId: json['selected_answer_id'],
      isCorrect: json['is_correct'],
    );
  }
}

class QuizAnswer {
  final int id;
  final int questionId;
  final String answer;
  final String? answerImage;
  final bool? isCorrect;
  final int order;

  QuizAnswer({
    required this.id,
    required this.questionId,
    required this.answer,
    this.answerImage,
    this.isCorrect,
    this.order = 0,
  });

  factory QuizAnswer.fromJson(Map<String, dynamic> json) {
    return QuizAnswer(
      id: json['id'],
      questionId: json['question_id'],
      answer: json['answer'],
      answerImage: json['answer_image'],
      isCorrect: json['is_correct'],
      order: json['order'] ?? 0,
    );
  }
}

class QuizAttempt {
  final int id;
  final int quizId;
  final int userId;
  final int score;
  final int totalPoints;
  final double percentage;
  final bool passed;
  final int correctAnswers;
  final int wrongAnswers;
  final int timeSpent; // in seconds
  final String status;
  final List<QuizQuestion>? questions;
  final WeakAreas? weakAreas;
  final DateTime startedAt;
  final DateTime? completedAt;

  QuizAttempt({
    required this.id,
    required this.quizId,
    required this.userId,
    required this.score,
    required this.totalPoints,
    required this.percentage,
    required this.passed,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.timeSpent,
    required this.status,
    this.questions,
    this.weakAreas,
    required this.startedAt,
    this.completedAt,
  });

  String get timeSpentFormatted {
    final minutes = timeSpent ~/ 60;
    final seconds = timeSpent % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  factory QuizAttempt.fromJson(Map<String, dynamic> json) {
    return QuizAttempt(
      id: json['id'],
      quizId: json['quiz_id'],
      userId: json['user_id'],
      score: json['score'] ?? 0,
      totalPoints: json['total_points'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      passed: json['passed'] ?? false,
      correctAnswers: json['correct_answers'] ?? 0,
      wrongAnswers: json['wrong_answers'] ?? 0,
      timeSpent: json['time_spent'] ?? 0,
      status: json['status'] ?? 'completed',
      questions: json['questions'] != null
          ? (json['questions'] as List)
              .map((q) => QuizQuestion.fromJson(q))
              .toList()
          : null,
      weakAreas: json['weak_areas'] != null
          ? WeakAreas.fromJson(json['weak_areas'])
          : null,
      startedAt: DateTime.parse(json['started_at'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }
}

class WeakAreas {
  final List<String> topics;
  final List<String> recommendations;

  WeakAreas({
    required this.topics,
    required this.recommendations,
  });

  factory WeakAreas.fromJson(Map<String, dynamic> json) {
    return WeakAreas(
      topics: (json['topics'] as List?)?.cast<String>() ?? [],
      recommendations: (json['recommendations'] as List?)?.cast<String>() ?? [],
    );
  }
}
