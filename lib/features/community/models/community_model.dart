class CommunityPost {
  final int id;
  final int userId;
  final String userName;
  final String? userAvatar;
  final String title;
  final String content;
  final String type; // question, discussion, poll, shared_resource
  final int? subjectId;
  final String? subjectName;
  final List<String>? tags;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final bool isLiked;
  final bool isResolved;
  final List<PollOption>? pollOptions;
  final int? userVoteId;
  final List<PostComment>? comments;
  final List<PostAttachment>? attachments;
  final DateTime createdAt;

  CommunityPost({
    required this.id,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.title,
    required this.content,
    required this.type,
    this.subjectId,
    this.subjectName,
    this.tags,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.viewsCount = 0,
    this.isLiked = false,
    this.isResolved = false,
    this.pollOptions,
    this.userVoteId,
    this.comments,
    this.attachments,
    required this.createdAt,
  });

  bool get isPoll => type == 'poll';
  bool get isQuestion => type == 'question';

  CommunityPost copyWith({
    int? likesCount,
    bool? isLiked,
    int? commentsCount,
    bool? isResolved,
  }) {
    return CommunityPost(
      id: id,
      userId: userId,
      userName: userName,
      userAvatar: userAvatar,
      title: title,
      content: content,
      type: type,
      subjectId: subjectId,
      subjectName: subjectName,
      tags: tags,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      viewsCount: viewsCount,
      isLiked: isLiked ?? this.isLiked,
      isResolved: isResolved ?? this.isResolved,
      pollOptions: pollOptions,
      userVoteId: userVoteId,
      comments: comments,
      attachments: attachments,
      createdAt: createdAt,
    );
  }

  factory CommunityPost.fromJson(Map<String, dynamic> json) {
    return CommunityPost(
      id: json['id'],
      userId: json['user_id'],
      userName: json['user_name'] ?? json['user']?['name'] ?? 'Unknown',
      userAvatar: json['user_avatar'] ?? json['user']?['avatar'],
      title: json['title'],
      content: json['content'],
      type: json['type'] ?? 'discussion',
      subjectId: json['subject_id'],
      subjectName: json['subject_name'] ?? json['subject']?['name'],
      tags: (json['tags'] as List?)?.cast<String>(),
      likesCount: json['likes_count'] ?? 0,
      commentsCount: json['comments_count'] ?? 0,
      viewsCount: json['views_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      isResolved: json['is_resolved'] ?? false,
      pollOptions: json['poll_options'] != null
          ? (json['poll_options'] as List)
              .map((o) => PollOption.fromJson(o))
              .toList()
          : null,
      userVoteId: json['user_vote_id'],
      comments: json['comments'] != null
          ? (json['comments'] as List)
              .map((c) => PostComment.fromJson(c))
              .toList()
          : null,
      attachments: json['attachments'] != null
          ? (json['attachments'] as List)
              .map((a) => PostAttachment.fromJson(a))
              .toList()
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class PollOption {
  final int id;
  final String option;
  final int votesCount;
  final double percentage;

  PollOption({
    required this.id,
    required this.option,
    this.votesCount = 0,
    this.percentage = 0,
  });

  factory PollOption.fromJson(Map<String, dynamic> json) {
    return PollOption(
      id: json['id'],
      option: json['option'],
      votesCount: json['votes_count'] ?? 0,
      percentage: (json['percentage'] ?? 0).toDouble(),
    );
  }
}

class PostComment {
  final int id;
  final int postId;
  final int userId;
  final String userName;
  final String? userAvatar;
  final String content;
  final int? parentId;
  final bool isSolution;
  final int likesCount;
  final bool isLiked;
  final List<PostComment>? replies;
  final DateTime createdAt;

  PostComment({
    required this.id,
    required this.postId,
    required this.userId,
    required this.userName,
    this.userAvatar,
    required this.content,
    this.parentId,
    this.isSolution = false,
    this.likesCount = 0,
    this.isLiked = false,
    this.replies,
    required this.createdAt,
  });

  factory PostComment.fromJson(Map<String, dynamic> json) {
    return PostComment(
      id: json['id'],
      postId: json['post_id'],
      userId: json['user_id'],
      userName: json['user_name'] ?? json['user']?['name'] ?? 'Unknown',
      userAvatar: json['user_avatar'] ?? json['user']?['avatar'],
      content: json['content'],
      parentId: json['parent_id'],
      isSolution: json['is_solution'] ?? false,
      likesCount: json['likes_count'] ?? 0,
      isLiked: json['is_liked'] ?? false,
      replies: json['replies'] != null
          ? (json['replies'] as List)
              .map((r) => PostComment.fromJson(r))
              .toList()
          : null,
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}

class PostAttachment {
  final int id;
  final String name;
  final String type;
  final String url;
  final int? size;

  PostAttachment({
    required this.id,
    required this.name,
    required this.type,
    required this.url,
    this.size,
  });

  factory PostAttachment.fromJson(Map<String, dynamic> json) {
    return PostAttachment(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      url: json['url'],
      size: json['size'],
    );
  }
}
