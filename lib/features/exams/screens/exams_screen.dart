import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/exam_provider.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExamProvider>().fetchExams();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ExamProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return const Center(child: CircularProgressIndicator());
        if (provider.exams.isEmpty) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.assignment, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text('No mock exams available'),
          ]));
        }
        return RefreshIndicator(
          onRefresh: () => provider.fetchExams(),
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.exams.length,
            itemBuilder: (context, index) {
              final exam = provider.exams[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Container(
                    width: 48, height: 48,
                    decoration: BoxDecoration(color: AppColors.accent.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                    child: const Icon(Icons.assignment, color: AppColors.accent),
                  ),
                  title: Text(exam.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${exam.questionsCount} questions - ${exam.durationFormatted}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.go('/exams/${exam.id}'),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
