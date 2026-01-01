import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/exam_provider.dart';

class ExamResultScreen extends StatelessWidget {
  final String examId;
  final String? attemptId;
  const ExamResultScreen({super.key, required this.examId, this.attemptId});

  @override
  Widget build(BuildContext context) => Consumer<ExamProvider>(builder: (_, p, __) {
    final a = p.currentAttempt;
    if (a == null) return Scaffold(appBar: AppBar(), body: const Center(child: Text('No results')));
    return Scaffold(
      appBar: AppBar(title: const Text('Exam Results')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
        Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [
          CircularPercentIndicator(radius: 60, lineWidth: 12, percent: a.percentage / 100, center: Text('${a.percentage.toInt()}%', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), progressColor: a.passed ? AppColors.success : AppColors.error, backgroundColor: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(a.passed ? 'Passed!' : 'Keep Trying!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: a.passed ? AppColors.success : AppColors.error)),
          if (a.grade != null) Padding(padding: const EdgeInsets.only(top: 8), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text('Grade: ${a.grade}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.accent)))),
        ]))),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _stat('Score', '${a.score}/${a.totalMarks}', AppColors.primary)),
          const SizedBox(width: 8),
          Expanded(child: _stat('Time', a.timeSpentFormatted, AppColors.secondary)),
        ]),
        const SizedBox(height: 24),
        ElevatedButton(onPressed: () => context.go('/exams'), child: const Text('Back to Exams')),
      ])),
    );
  });

  Widget _stat(String l, String v, Color c) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [Text(v, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: c)), Text(l, style: TextStyle(color: Colors.grey.shade600, fontSize: 12))])));
}
