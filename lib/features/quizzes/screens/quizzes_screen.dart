import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/quiz_provider.dart';
import '../models/quiz_model.dart';

class QuizzesScreen extends StatefulWidget {
  const QuizzesScreen({super.key});

  @override
  State<QuizzesScreen> createState() => _QuizzesScreenState();
}

class _QuizzesScreenState extends State<QuizzesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().fetchQuizzes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.quizzes.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.quiz, size: 80, color: Colors.grey.shade400),
                const SizedBox(height: 16),
                const Text('No quizzes available', style: TextStyle(fontSize: 18)),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.fetchQuizzes(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.quizzes.length,
            itemBuilder: (context, index) {
              final quiz = provider.quizzes[index];
              return _buildQuizCard(quiz, index);
            },
          ),
        );
      },
    );
  }

  Widget _buildQuizCard(Quiz quiz, int index) {
    final color = AppColors.getSubjectColor(index);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => context.go('/quizzes/${quiz.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.quiz, color: color),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(quiz.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(height: 4),
                    Text(quiz.subjectName ?? '', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.timer, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text('${quiz.timeLimit} min', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                        const SizedBox(width: 16),
                        Icon(Icons.help_outline, size: 14, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text('${quiz.questionsCount} questions', style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      ],
                    ),
                  ],
                ),
              ),
              if (quiz.isCompleted)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('Completed', style: TextStyle(color: AppColors.success, fontSize: 12)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
