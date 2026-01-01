import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/exam_provider.dart';

class ExamDetailScreen extends StatefulWidget {
  final String examId;
  const ExamDetailScreen({super.key, required this.examId});

  @override
  State<ExamDetailScreen> createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends State<ExamDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExamProvider>().fetchExamDetail(widget.examId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExamProvider>(builder: (context, provider, _) {
      final exam = provider.currentExam;
      return Scaffold(
        appBar: AppBar(title: Text(exam?.title ?? 'Mock Exam')),
        body: provider.isLoading ? const Center(child: CircularProgressIndicator()) : exam == null ? const Center(child: Text('Exam not found')) : SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
              const Icon(Icons.assignment, size: 64, color: AppColors.accent),
              const SizedBox(height: 16),
              Text(exam.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              if (exam.description != null) Padding(padding: const EdgeInsets.only(top: 8), child: Text(exam.description!, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600))),
            ]))),
            const SizedBox(height: 16),
            _info(Icons.timer, 'Duration', exam.durationFormatted),
            _info(Icons.help_outline, 'Questions', '${exam.questionsCount}'),
            _info(Icons.grade, 'Total Marks', '${exam.totalMarks}'),
            _info(Icons.check_circle, 'Pass Marks', '${exam.passingMarks}'),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: () => context.push('/exam/${exam.id}/take'), child: const Text('Start Exam')),
          ]),
        ),
      );
    });
  }

  Widget _info(IconData icon, String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [Icon(icon, color: AppColors.accent), const SizedBox(width: 12), Text(label), const Spacer(), Text(value, style: TextStyle(color: Colors.grey.shade600))]),
  );
}
