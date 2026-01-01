class Game {
  final int id;
  final String name;
  final String type; // trivia, math_challenge, word_puzzle, memory
  final String? description;
  final String? icon;
  final String? image;
  final int? subjectId;
  final String? subjectName;
  final int pointsPerCorrect;
  final int timeLimit; // in seconds per question
  final int? questionsCount;
  final int? bestScore;
  final int? timesPlayed;
  final List<GameQuestion>? questions;
  final bool isActive;
  final DateTime createdAt;

  Game({
    required this.id,
    required this.name,
    required this.type,
    this.description,
    this.icon,
    this.image,
    this.subjectId,
    this.subjectName,
    this.pointsPerCorrect = 10,
    this.timeLimit = 30,
    this.questionsCount,
    this.bestScore,
    this.timesPlayed,
    this.questions,
    this.isActive = true,
    required this.createdAt,
  });

  String get typeDisplayName {
    switch (type) {
      case 'trivia':
        return 'Trivia';
      case 'math_challenge':
        return 'Math Challenge';
      case 'word_puzzle':
        return 'Word Puzzle';
      case 'memory':
        return 'Memory Game';
      default:
        return type;
    }
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      name: json['name'],
      type: json['type'] ?? 'trivia',
      description: json['description'],
      icon: json['icon'],
      image: json['image'],
      subjectId: json['subject_id'],
      subjectName: json['subject_name'] ?? json['subject']?['name'],
      pointsPerCorrect: json['points_per_correct'] ?? 10,
      timeLimit: json['time_limit'] ?? 30,
      questionsCount: json['questions_count'],
      bestScore: json['best_score'],
      timesPlayed: json['times_played'],
      questions: json['questions'] != null
          ? (json['questions'] as List)
              .map((q) => GameQuestion.fromJson(q))
              .toList()
          : null,
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class GameQuestion {
  final int id;
  final String question;
  final String? questionImage;
  final List<GameAnswer> answers;
  final int correctAnswerIndex;
  final String? explanation;

  GameQuestion({
    required this.id,
    required this.question,
    this.questionImage,
    required this.answers,
    required this.correctAnswerIndex,
    this.explanation,
  });

  factory GameQuestion.fromJson(Map<String, dynamic> json) {
    return GameQuestion(
      id: json['id'],
      question: json['question'],
      questionImage: json['question_image'],
      answers: (json['answers'] as List?)
              ?.map((a) => GameAnswer.fromJson(a))
              .toList() ??
          [],
      correctAnswerIndex: json['correct_answer_index'] ?? 0,
      explanation: json['explanation'],
    );
  }
}

class GameAnswer {
  final int id;
  final String answer;
  final bool isCorrect;

  GameAnswer({
    required this.id,
    required this.answer,
    this.isCorrect = false,
  });

  factory GameAnswer.fromJson(Map<String, dynamic> json) {
    return GameAnswer(
      id: json['id'],
      answer: json['answer'],
      isCorrect: json['is_correct'] ?? false,
    );
  }
}

class GameSession {
  final int id;
  final int gameId;
  final int userId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int? score;
  final int? correctAnswers;
  final int? totalQuestions;

  GameSession({
    required this.id,
    required this.gameId,
    required this.userId,
    required this.startedAt,
    this.endedAt,
    this.score,
    this.correctAnswers,
    this.totalQuestions,
  });

  factory GameSession.fromJson(Map<String, dynamic> json) {
    return GameSession(
      id: json['id'],
      gameId: json['game_id'],
      userId: json['user_id'],
      startedAt: DateTime.parse(json['started_at']),
      endedAt: json['ended_at'] != null ? DateTime.parse(json['ended_at']) : null,
      score: json['score'],
      correctAnswers: json['correct_answers'],
      totalQuestions: json['total_questions'],
    );
  }
}

class GameScore {
  final int id;
  final int gameId;
  final int userId;
  final String userName;
  final String? userAvatar;
  final int score;
  final int correctAnswers;
  final int totalQuestions;
  final int rank;
  final DateTime playedAt;

  GameScore({
    required this.id,
    required this.gameId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    required this.rank,
    required this.playedAt,
  });

  double get accuracy =>
      totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

  factory GameScore.fromJson(Map<String, dynamic> json) {
    return GameScore(
      id: json['id'],
      gameId: json['game_id'],
      userId: json['user_id'],
      userName: json['user_name'] ?? json['user']?['name'] ?? 'Unknown',
      userAvatar: json['user_avatar'] ?? json['user']?['avatar'],
      score: json['score'] ?? 0,
      correctAnswers: json['correct_answers'] ?? 0,
      totalQuestions: json['total_questions'] ?? 0,
      rank: json['rank'] ?? 0,
      playedAt: DateTime.parse(json['played_at'] ?? json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
