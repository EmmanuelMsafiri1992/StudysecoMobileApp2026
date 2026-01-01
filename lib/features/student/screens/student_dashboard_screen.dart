import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/student_provider.dart';
import '../models/dashboard_model.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final studentProvider = context.watch<StudentProvider>();

    return RefreshIndicator(
      onRefresh: () => studentProvider.fetchDashboard(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome section
            _buildWelcomeSection(authProvider),
            const SizedBox(height: 20),

            // Enrollment status
            if (studentProvider.dashboardData != null)
              _buildEnrollmentCard(studentProvider.dashboardData!.enrollment),
            const SizedBox(height: 20),

            // Progress overview
            if (studentProvider.dashboardData != null)
              _buildProgressSection(studentProvider.dashboardData!.progress),
            const SizedBox(height: 20),

            // Quick actions
            _buildQuickActions(),
            const SizedBox(height: 20),

            // Subject progress
            if (studentProvider.dashboardData != null &&
                studentProvider.dashboardData!.subjectProgress.isNotEmpty)
              _buildSubjectProgress(studentProvider.dashboardData!.subjectProgress),
            const SizedBox(height: 20),

            // Upcoming items
            if (studentProvider.dashboardData != null)
              _buildUpcomingSection(studentProvider.dashboardData!.upcoming),
            const SizedBox(height: 20),

            // Recent activity
            if (studentProvider.dashboardData != null &&
                studentProvider.dashboardData!.recentActivities.isNotEmpty)
              _buildRecentActivity(studentProvider.dashboardData!.recentActivities),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(AuthProvider authProvider) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good Morning';
    } else if (hour < 17) {
      greeting = 'Good Afternoon';
    } else {
      greeting = 'Good Evening';
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          child: Text(
            authProvider.user?.name.substring(0, 1).toUpperCase() ?? 'S',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                authProvider.user?.name ?? 'Student',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEnrollmentCard(EnrollmentSummary enrollment) {
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (enrollment.status == 'approved' || enrollment.status == 'active') {
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle;
      statusText = enrollment.isTrial ? 'Trial Active' : 'Active';
    } else if (enrollment.status == 'pending') {
      statusColor = AppColors.warning;
      statusIcon = Icons.pending;
      statusText = 'Pending Approval';
    } else {
      statusColor = AppColors.error;
      statusIcon = Icons.error;
      statusText = 'Expired';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(statusIcon, color: statusColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Enrollment Status',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${enrollment.daysRemaining}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const Text(
                      'days left',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${enrollment.subjectsCount} subjects enrolled',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                if (enrollment.daysRemaining < 30)
                  TextButton(
                    onPressed: () => context.push('/extension'),
                    child: const Text('Extend Access'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(ProgressSummary progress) {
    return Row(
      children: [
        Expanded(
          child: _buildProgressCard(
            'Lessons',
            progress.completedLessons,
            progress.totalLessons,
            progress.lessonsProgress / 100,
            AppColors.primary,
            Icons.play_circle,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildProgressCard(
            'Quizzes',
            progress.completedQuizzes,
            progress.totalQuizzes,
            progress.quizzesProgress / 100,
            AppColors.secondary,
            Icons.quiz,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressCard(
    String title,
    int completed,
    int total,
    double progress,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CircularPercentIndicator(
              radius: 40,
              lineWidth: 8,
              percent: progress.clamp(0, 1),
              center: Icon(icon, color: color),
              progressColor: color,
              backgroundColor: color.withOpacity(0.2),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(
              '$completed / $total',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          children: [
            _buildQuickAction(Icons.play_circle, 'Lessons', '/lessons', AppColors.primary),
            _buildQuickAction(Icons.quiz, 'Quizzes', '/quizzes', AppColors.secondary),
            _buildQuickAction(Icons.assignment, 'Exams', '/exams', AppColors.accent),
            _buildQuickAction(Icons.games, 'Games', '/games', Colors.purple),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickAction(IconData icon, String label, String path, Color color) {
    return InkWell(
      onTap: () => context.go(path),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectProgress(List<SubjectProgress> subjects) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'My Subjects',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => context.go('/subjects'),
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: subjects.length > 5 ? 5 : subjects.length,
            itemBuilder: (context, index) {
              final subject = subjects[index];
              return Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                child: Card(
                  child: InkWell(
                    onTap: () => context.go('/subjects/${subject.id}'),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.getSubjectColor(index).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.book,
                              color: AppColors.getSubjectColor(index),
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            subject.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 12,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const Spacer(),
                          LinearProgressIndicator(
                            value: subject.progress / 100,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation(
                              AppColors.getSubjectColor(index),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${subject.progress}%',
                            style: const TextStyle(fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildUpcomingSection(UpcomingItems upcoming) {
    final allItems = <Widget>[];

    for (var assignment in upcoming.assignments.take(2)) {
      allItems.add(_buildUpcomingItem(
        Icons.task,
        assignment.title,
        'Due: ${_formatDate(assignment.dueDate)}',
        assignment.isLate ? AppColors.error : AppColors.warning,
        () => context.go('/assignments/${assignment.id}'),
      ));
    }

    for (var quiz in upcoming.quizzes.take(2)) {
      allItems.add(_buildUpcomingItem(
        Icons.quiz,
        quiz.title,
        quiz.subject,
        AppColors.secondary,
        () => context.go('/quizzes/${quiz.id}'),
      ));
    }

    if (allItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Upcoming',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...allItems,
      ],
    );
  }

  Widget _buildUpcomingItem(
    IconData icon,
    String title,
    String subtitle,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }

  Widget _buildRecentActivity(List<RecentActivity> activities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...activities.take(5).map((activity) => _buildActivityItem(activity)),
      ],
    );
  }

  Widget _buildActivityItem(RecentActivity activity) {
    IconData icon;
    Color color;

    switch (activity.type) {
      case 'lesson_completed':
        icon = Icons.play_circle;
        color = AppColors.primary;
        break;
      case 'quiz_completed':
        icon = Icons.quiz;
        color = AppColors.secondary;
        break;
      case 'achievement_earned':
        icon = Icons.emoji_events;
        color = AppColors.accent;
        break;
      default:
        icon = Icons.check_circle;
        color = AppColors.success;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          activity.title,
          style: const TextStyle(fontSize: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          timeago.format(activity.createdAt),
          style: const TextStyle(fontSize: 12),
        ),
        trailing: activity.score != null
            ? Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.getGradeColor(activity.score!.toDouble()).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${activity.score}%',
                  style: TextStyle(
                    color: AppColors.getGradeColor(activity.score!.toDouble()),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              )
            : null,
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = date.difference(now);

    if (diff.inDays == 0) {
      return 'Today';
    } else if (diff.inDays == 1) {
      return 'Tomorrow';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} days';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
