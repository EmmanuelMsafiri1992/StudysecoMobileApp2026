import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/quiz_provider.dart';

class QuizResultScreen extends StatelessWidget {
  final String quizId;
  final String? attemptId;
  const QuizResultScreen({super.key, required this.quizId, this.attemptId});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuizProvider>(
      builder: (context, provider, _) {
        final attempt = provider.currentAttempt;
        if (attempt == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('No results found')));
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Quiz Results')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        CircularPercentIndicator(
                          radius: 60,
                          lineWidth: 12,
                          percent: attempt.percentage / 100,
                          center: Text('${attempt.percentage.toInt()}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          progressColor: attempt.passed ? AppColors.success : AppColors.error,
                          backgroundColor: Colors.grey.shade200,
                        ),
                        const SizedBox(height: 16),
                        Text(attempt.passed ? 'Congratulations!' : 'Keep Trying!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: attempt.passed ? AppColors.success : AppColors.error)),
                        const SizedBox(height: 8),
                        Text(attempt.passed ? 'You passed the quiz!' : 'You did not pass. Try again!', style: TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(child: _buildStatCard('Score', '${attempt.score}/${attempt.totalPoints}', AppColors.primary)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatCard('Correct', '${attempt.correctAnswers}', AppColors.success)),
                    const SizedBox(width: 8),
                    Expanded(child: _buildStatCard('Wrong', '${attempt.wrongAnswers}', AppColors.error)),
                  ],
                ),
                const SizedBox(height: 16),
                _buildStatCard('Time Spent', attempt.timeSpentFormatted, AppColors.secondary),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: () => context.go('/quizzes'), child: const Text('Back to Quizzes'))),
                    const SizedBox(width: 12),
                    Expanded(child: ElevatedButton(onPressed: () => context.go('/quiz/$quizId/take'), child: const Text('Try Again'))),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
