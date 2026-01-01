import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/assignment_provider.dart';

class AssignmentDetailScreen extends StatefulWidget {
  final String assignmentId;
  const AssignmentDetailScreen({super.key, required this.assignmentId});
  @override
  State<AssignmentDetailScreen> createState() => _AssignmentDetailScreenState();
}

class _AssignmentDetailScreenState extends State<AssignmentDetailScreen> {
  @override
  void initState() { super.initState(); context.read<AssignmentProvider>().fetchAssignmentDetail(widget.assignmentId); }
  @override
  Widget build(BuildContext context) => Consumer<AssignmentProvider>(builder: (_, p, __) {
    final a = p.currentAssignment;
    return Scaffold(
      appBar: AppBar(title: Text(a?.title ?? 'Assignment')),
      body: p.isLoading ? const Center(child: CircularProgressIndicator()) : a == null ? const Center(child: Text('Not found')) : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(a.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(children: [Icon(Icons.timer, size: 16, color: a.isOverdue ? AppColors.error : AppColors.warning), const SizedBox(width: 4), Text(a.timeRemainingFormatted, style: TextStyle(color: a.isOverdue ? AppColors.error : AppColors.warning))]),
            if (a.description != null) ...[const SizedBox(height: 16), Text(a.description!)],
            if (a.instructions != null) ...[const SizedBox(height: 16), const Text('Instructions:', style: TextStyle(fontWeight: FontWeight.bold)), Text(a.instructions!)],
          ]))),
          const SizedBox(height: 16),
          if (a.isSubmitted) Card(color: AppColors.success.withOpacity(0.1), child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [const Icon(Icons.check_circle, color: AppColors.success, size: 48), const SizedBox(height: 8), const Text('Submitted', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success)), if (a.score != null) Text('Score: ${a.score}/${a.totalMarks}')])))
          else ElevatedButton(onPressed: () => context.push('/assignment/${a.id}/submit'), child: const Text('Submit Assignment')),
        ]),
      ),
    );
  });
}
