class Assignment {
  final int id;
  final String title;
  final String? description;
  final String? instructions;
  final int subjectId;
  final String? subjectName;
  final int? teacherId;
  final String? teacherName;
  final int totalMarks;
  final DateTime dueDate;
  final DateTime? submittedAt;
  final bool isSubmitted;
  final bool isGraded;
  final int? score;
  final String? feedback;
  final bool allowLateSubmission;
  final int? lateSubmissionPenalty;
  final List<AssignmentAttachment>? attachments;
  final AssignmentSubmission? submission;
  final DateTime createdAt;

  Assignment({
    required this.id,
    required this.title,
    this.description,
    this.instructions,
    required this.subjectId,
    this.subjectName,
    this.teacherId,
    this.teacherName,
    required this.totalMarks,
    required this.dueDate,
    this.submittedAt,
    this.isSubmitted = false,
    this.isGraded = false,
    this.score,
    this.feedback,
    this.allowLateSubmission = true,
    this.lateSubmissionPenalty,
    this.attachments,
    this.submission,
    required this.createdAt,
  });

  bool get isOverdue => DateTime.now().isAfter(dueDate);

  String get status {
    if (isGraded) return 'graded';
    if (isSubmitted) return 'submitted';
    if (isOverdue) return 'overdue';
    return 'pending';
  }

  Duration get timeRemaining => dueDate.difference(DateTime.now());

  String get timeRemainingFormatted {
    if (isOverdue) return 'Overdue';

    final diff = timeRemaining;
    if (diff.inDays > 0) {
      return '${diff.inDays} day${diff.inDays > 1 ? 's' : ''} left';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} hour${diff.inHours > 1 ? 's' : ''} left';
    } else {
      return '${diff.inMinutes} min left';
    }
  }

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      instructions: json['instructions'],
      subjectId: json['subject_id'],
      subjectName: json['subject_name'] ?? json['subject']?['name'],
      teacherId: json['teacher_id'],
      teacherName: json['teacher_name'] ?? json['teacher']?['name'],
      totalMarks: json['total_marks'] ?? 100,
      dueDate: DateTime.parse(json['due_date']),
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'])
          : null,
      isSubmitted: json['is_submitted'] ?? false,
      isGraded: json['is_graded'] ?? false,
      score: json['score'],
      feedback: json['feedback'],
      allowLateSubmission: json['allow_late_submission'] ?? true,
      lateSubmissionPenalty: json['late_submission_penalty'],
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((a) => AssignmentAttachment.fromJson(a))
              .toList()
          : null,
      submission: json['submission'] != null
          ? AssignmentSubmission.fromJson(json['submission'])
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class AssignmentAttachment {
  final int id;
  final String name;
  final String type;
  final String url;
  final int? size;

  AssignmentAttachment({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    this.size,
  });

  factory AssignmentAttachment.fromJson(Map<String, dynamic> json) {
    return AssignmentAttachment(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      url: json['url'],
      size: json['size'],
    );
  }
}

class AssignmentSubmission {
  final int id;
  final int assignmentId;
  final int studentId;
  final String? studentName;
  final String content;
  final List<AssignmentAttachment>? attachments;
  final int? score;
  final String? feedback;
  final String? grade;
  final bool isLate;
  final int? latePenaltyApplied;
  final String status;
  final DateTime submittedAt;
  final DateTime? gradedAt;

  AssignmentSubmission({
    required this.id,
    required this.assignmentId,
    required this.studentId,
    this.studentName,
    required this.content,
    this.attachments,
    this.score,
    this.feedback,
    this.grade,
    this.isLate = false,
    this.latePenaltyApplied,
    required this.status,
    required this.submittedAt,
    this.gradedAt,
  });

  bool get isGraded => status == 'graded';

  factory AssignmentSubmission.fromJson(Map<String, dynamic> json) {
    return AssignmentSubmission(
      id: json['id'],
      assignmentId: json['assignment_id'],
      studentId: json['student_id'],
      studentName: json['student_name'] ?? json['student']?['name'],
      content: json['content'] ?? '',
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((a) => AssignmentAttachment.fromJson(a))
              .toList()
          : null,
      score: json['score'],
      feedback: json['feedback'],
      grade: json['grade'],
      isLate: json['is_late'] ?? false,
      latePenaltyApplied: json['late_penalty_applied'],
      status: json['status'] ?? 'submitted',
      submittedAt: DateTime.parse(json['submitted_at']),
      gradedAt: json['graded_at'] != null
          ? DateTime.parse(json['graded_at'])
          : null,
    );
  }
}
