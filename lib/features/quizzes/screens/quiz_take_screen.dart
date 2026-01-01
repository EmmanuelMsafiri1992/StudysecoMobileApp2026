import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../../core/theme/app_colors.dart';
import '../providers/quiz_provider.dart';

class QuizTakeScreen extends StatefulWidget {
  final String quizId;
  const QuizTakeScreen({super.key, required this.quizId});

  @override
  State<QuizTakeScreen> createState() => _QuizTakeScreenState();
}

class _QuizTakeScreenState extends State<QuizTakeScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startQuiz();
  }

  Future<void> _startQuiz() async {
    final provider = context.read<QuizProvider>();
    final success = await provider.startQuiz(widget.quizId);
    if (success) _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final provider = context.read<QuizProvider>();
      if (provider.remainingTime > 0) {
        provider.updateRemainingTime(provider.remainingTime - 1);
      } else {
        _submitQuiz();
      }
    });
  }

  Future<void> _submitQuiz() async {
    _timer?.cancel();
    final provider = context.read<QuizProvider>();
    final attempt = await provider.submitQuiz();
    if (attempt != null && mounted) {
      context.pushReplacement('/quiz/${widget.quizId}/result', extra: attempt.id.toString());
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Leave Quiz?'),
            content: const Text('Your progress will be lost. Are you sure?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Leave')),
            ],
          ),
        );
        if (confirm == true) context.read<QuizProvider>().resetQuiz();
        return confirm ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Consumer<QuizProvider>(
            builder: (context, provider, _) {
              final minutes = provider.remainingTime ~/ 60;
              final seconds = provider.remainingTime % 60;
              return Text('${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}');
            },
          ),
          actions: [
            TextButton(onPressed: _submitQuiz, child: const Text('Submit')),
          ],
        ),
        body: Consumer<QuizProvider>(
          builder: (context, provider, _) {
            final question = provider.currentQuestion;
            if (question == null) return const Center(child: CircularProgressIndicator());

            return Column(
              children: [
                LinearProgressIndicator(value: provider.progress),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Question ${provider.currentQuestionIndex + 1}', style: TextStyle(color: Colors.grey.shade600)),
                        const SizedBox(height: 8),
                        Text(question.question, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 24),
                        ...question.answers.map((answer) {
                          final isSelected = provider.selectedAnswers[question.id] == answer.id;
                          return Card(
                            color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                            child: ListTile(
                              leading: Radio<int>(
                                value: answer.id,
                                groupValue: provider.selectedAnswers[question.id],
                                onChanged: (value) => provider.selectAnswer(question.id, value!),
                              ),
                              title: Text(answer.answer),
                              onTap: () => provider.selectAnswer(question.id, answer.id),
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      if (provider.currentQuestionIndex > 0)
                        Expanded(child: OutlinedButton(onPressed: provider.previousQuestion, child: const Text('Previous'))),
                      if (provider.currentQuestionIndex > 0) const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: provider.isLastQuestion ? _submitQuiz : provider.nextQuestion,
                          child: Text(provider.isLastQuestion ? 'Submit' : 'Next'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
