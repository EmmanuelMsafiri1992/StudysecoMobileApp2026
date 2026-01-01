class MockExam {
  final int id;
  final String title;
  final String? description;
  final int subjectId;
  final String? subjectName;
  final int duration; // in minutes
  final int questionsCount;
  final int totalMarks;
  final int passingMarks;
  final String examBoard;
  final String? year;
  final String? paper;
  final int? userAttempts;
  final double? bestScore;
  final bool isCompleted;
  final bool isAvailable;
  final List<ExamQuestion>? questions;
  final DateTime? scheduledAt;
  final DateTime createdAt;

  MockExam({
    required this.id,
    required this.title,
    this.description,
    required this.subjectId,
    this.subjectName,
    required this.duration,
    required this.questionsCount,
    required this.totalMarks,
    required this.passingMarks,
    this.examBoard = 'MANEB',
    this.year,
    this.paper,
    this.userAttempts,
    this.bestScore,
    this.isCompleted = false,
    this.isAvailable = true,
    this.questions,
    this.scheduledAt,
    required this.createdAt,
  });

  String get durationFormatted {
    final hours = duration ~/ 60;
    final mins = duration % 60;
    if (hours > 0) {
      return mins > 0 ? '$hours hr $mins min' : '$hours hr';
    }
    return '$mins min';
  }

  factory MockExam.fromJson(Map<String, dynamic> json) {
    return MockExam(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      subjectId: json['subject_id'],
      subjectName: json['subject_name'] ?? json['subject']?['name'],
      duration: json['duration'] ?? 180,
      questionsCount: json['questions_count'] ?? 0,
      totalMarks: json['total_marks'] ?? 100,
      passingMarks: json['passing_marks'] ?? 50,
      examBoard: json['exam_board'] ?? 'MANEB',
      year: json['year'],
      paper: json['paper'],
      userAttempts: json['user_attempts'],
      bestScore: json['best_score']?.toDouble(),
      isCompleted: json['is_completed'] ?? false,
      isAvailable: json['is_available'] ?? true,
      questions: json['questions'] != null
          ? (json['questions'] as List)
              .map((q) => ExamQuestion.fromJson(q))
              .toList()
          : null,
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'])
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class ExamQuestion {
  final int id;
  final int examId;
  final String question;
  final String? questionImage;
  final String type;
  final int marks;
  final int order;
  final String? section;
  final List<ExamAnswer> answers;
  final String? explanation;
  final int? selectedAnswerId;
  final bool? isCorrect;

  ExamQuestion({
    required this.id,
    required this.examId,
    required this.question,
    this.questionImage,
    this.type = 'multiple_choice',
    required this.marks,
    this.order = 0,
    this.section,
    required this.answers,
    this.explanation,
    this.selectedAnswerId,
    this.isCorrect,
  });

  factory ExamQuestion.fromJson(Map<String, dynamic> json) {
    return ExamQuestion(
      id: json['id'],
      examId: json['exam_id'],
      question: json['question'],
      questionImage: json['question_image'],
      type: json['type'] ?? 'multiple_choice',
      marks: json['marks'] ?? 1,
      order: json['order'] ?? 0,
      section: json['section'],
      answers: (json['answers'] as List?)
              ?.map((a) => ExamAnswer.fromJson(a))
              .toList() ??
          [],
      explanation: json['explanation'],
      selectedAnswerId: json['selected_answer_id'],
      isCorrect: json['is_correct'],
    );
  }
}

class ExamAnswer {
  final int id;
  final int questionId;
  final String answer;
  final String? answerImage;
  final bool? isCorrect;
  final int order;

  ExamAnswer({
    required this.id,
    required this.questionId,
    required this.answer,
    this.answerImage,
    this.isCorrect,
    this.order = 0,
  });

  factory ExamAnswer.fromJson(Map<String, dynamic> json) {
    return ExamAnswer(
      id: json['id'],
      questionId: json['question_id'],
      answer: json['answer'],
      answerImage: json['answer_image'],
      isCorrect: json['is_correct'],
      order: json['order'] ?? 0,
    );
  }
}

class ExamAttempt {
  final int id;
  final int examId;
  final int userId;
  final int score;
  final int totalMarks;
  final double percentage;
  final bool passed;
  final int correctAnswers;
  final int wrongAnswers;
  final int timeSpent;
  final String status;
  final String? grade;
  final List<ExamQuestion>? questions;
  final ExamFeedback? feedback;
  final DateTime startedAt;
  final DateTime? completedAt;

  ExamAttempt({
    required this.id,
    required this.examId,
    required this.userId,
    required this.score,
    required this.totalMarks,
    required this.percentage,
    required this.passed,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.timeSpent,
    required this.status,
    this.grade,
    this.questions,
    this.feedback,
    required this.startedAt,
    this.completedAt,
  });

  String get timeSpentFormatted {
    final hours = timeSpent ~/ 3600;
    final minutes = (timeSpent % 3600) ~/ 60;
    final seconds = timeSpent % 60;

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  factory ExamAttempt.fromJson(Map<String, dynamic> json) {
    return ExamAttempt(
      id: json['id'],
      examId: json['exam_id'],
      userId: json['user_id'],
      score: json['score'] ?? 0,
      totalMarks: json['total_marks'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
      passed: json['passed'] ?? false,
      correctAnswers: json['correct_answers'] ?? 0,
      wrongAnswers: json['wrong_answers'] ?? 0,
      timeSpent: json['time_spent'] ?? 0,
      status: json['status'] ?? 'completed',
      grade: json['grade'],
      questions: json['questions'] != null
          ? (json['questions'] as List)
              .map((q) => ExamQuestion.fromJson(q))
              .toList()
          : null,
      feedback: json['feedback'] != null
          ? ExamFeedback.fromJson(json['feedback'])
          : null,
      startedAt: DateTime.parse(json['started_at'] ?? DateTime.now().toIso8601String()),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
    );
  }
}

class ExamFeedback {
  final List<String> strengths;
  final List<String> weakAreas;
  final List<String> recommendations;
  final Map<String, double> sectionScores;

  ExamFeedback({
    required this.strengths,
    required this.weakAreas,
    required this.recommendations,
    required this.sectionScores,
  });

  factory ExamFeedback.fromJson(Map<String, dynamic> json) {
    return ExamFeedback(
      strengths: (json['strengths'] as List?)?.cast<String>() ?? [],
      weakAreas: (json['weak_areas'] as List?)?.cast<String>() ?? [],
      recommendations: (json['recommendations'] as List?)?.cast<String>() ?? [],
      sectionScores: (json['section_scores'] as Map?)?.map(
            (key, value) => MapEntry(key.toString(), (value as num).toDouble()),
          ) ??
          {},
    );
  }
}
