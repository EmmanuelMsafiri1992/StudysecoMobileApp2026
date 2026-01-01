import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../providers/subjects_provider.dart';
import '../models/subject_model.dart';

class SubjectDetailScreen extends StatefulWidget {
  final String subjectId;

  const SubjectDetailScreen({super.key, required this.subjectId});

  @override
  State<SubjectDetailScreen> createState() => _SubjectDetailScreenState();
}

class _SubjectDetailScreenState extends State<SubjectDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubjectsProvider>().fetchSubjectDetail(widget.subjectId);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SubjectsProvider>(
      builder: (context, provider, _) {
        final subject = provider.selectedSubject;

        if (provider.isLoading) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (subject == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Subject not found')),
          );
        }

        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(subject.name),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primary.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.book,
                          size: 64,
                          color: Colors.white24,
                        ),
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _buildSubjectInfo(subject),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverTabBarDelegate(
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Topics'),
                        Tab(text: 'Quizzes'),
                        Tab(text: 'Exams'),
                        Tab(text: 'Games'),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              controller: _tabController,
              children: [
                _buildTopicsList(subject.topics ?? []),
                _buildQuizzesList(subject),
                _buildExamsList(subject),
                _buildGamesList(subject),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubjectInfo(Subject subject) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (subject.description != null) ...[
            Text(
              subject.description!,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            children: [
              _buildStatCard('Topics', '${subject.topicsCount}', Icons.list),
              const SizedBox(width: 8),
              _buildStatCard('Lessons', '${subject.lessonsCount}', Icons.play_circle),
              const SizedBox(width: 8),
              _buildStatCard('Quizzes', '${subject.quizzesCount}', Icons.quiz),
            ],
          ),
          if (subject.isEnrolled && subject.progress > 0) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: subject.progress / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${subject.progress}% Complete',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicsList(List<Topic> topics) {
    if (topics.isEmpty) {
      return const Center(child: Text('No topics available'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: topics.length,
      itemBuilder: (context, index) {
        final topic = topics[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: topic.isCompleted
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: topic.isCompleted
                    ? const Icon(Icons.check, color: AppColors.success)
                    : Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
              ),
            ),
            title: Text(topic.name),
            subtitle: Text(
              '${topic.lessonsCount} lessons',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
            children: [
              if (topic.lessons != null)
                ...topic.lessons!.map((lesson) => ListTile(
                      leading: Icon(
                        lesson.isCompleted
                            ? Icons.check_circle
                            : Icons.play_circle_outline,
                        color: lesson.isCompleted
                            ? AppColors.success
                            : AppColors.primary,
                      ),
                      title: Text(lesson.title),
                      subtitle: Text(lesson.durationFormatted),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/lesson/${lesson.id}/play'),
                    )),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuizzesList(Subject subject) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.quiz, size: 64, color: AppColors.secondary),
          const SizedBox(height: 16),
          const Text('View quizzes for this subject'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => context.push('/quizzes?subject_id=${subject.id}'),
            child: const Text('View Quizzes'),
          ),
        ],
      ),
    );
  }

  Widget _buildExamsList(Subject subject) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.assignment, size: 64, color: AppColors.accent),
          const SizedBox(height: 16),
          const Text('View mock exams for this subject'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => context.push('/exams?subject_id=${subject.id}'),
            child: const Text('View Mock Exams'),
          ),
        ],
      ),
    );
  }

  Widget _buildGamesList(Subject subject) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.games, size: 64, color: Colors.purple),
          const SizedBox(height: 16),
          const Text('Play educational games for this subject'),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: () => context.push('/games?subject_id=${subject.id}'),
            child: const Text('Play Games'),
          ),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}
