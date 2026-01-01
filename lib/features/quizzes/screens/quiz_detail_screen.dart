import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/quiz_provider.dart';

class QuizDetailScreen extends StatefulWidget {
  final String quizId;
  const QuizDetailScreen({super.key, required this.quizId});

  @override
  State<QuizDetailScreen> createState() => _QuizDetailScreenState();
}

class _QuizDetailScreenState extends State<QuizDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().fetchQuizDetail(widget.quizId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, provider, _) {
        final quiz = provider.currentQuiz;

        return Scaffold(
          appBar: AppBar(title: Text(quiz?.title ?? 'Quiz')),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : quiz == null
                  ? const Center(child: Text('Quiz not found'))
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Icon(Icons.quiz, size: 64, color: AppColors.secondary),
                                  const SizedBox(height: 16),
                                  Text(quiz.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                                  if (quiz.description != null) ...[
                                    const SizedBox(height: 8),
                                    Text(quiz.description!, style: TextStyle(color: Colors.grey.shade600), textAlign: TextAlign.center),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(Icons.timer, 'Time Limit', '${quiz.timeLimit} minutes'),
                          _buildInfoRow(Icons.help_outline, 'Questions', '${quiz.questionsCount} questions'),
                          _buildInfoRow(Icons.grade, 'Passing Score', '${quiz.passingScore}%'),
                          _buildInfoRow(Icons.replay, 'Attempts', '${quiz.userAttempts ?? 0} / ${quiz.maxAttempts}'),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: quiz.canAttempt ? () => context.push('/quiz/${quiz.id}/take') : null,
                            child: Text(quiz.canAttempt ? 'Start Quiz' : 'No Attempts Left'),
                          ),
                        ],
                      ),
                    ),
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const Spacer(),
          Text(value, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }
}
