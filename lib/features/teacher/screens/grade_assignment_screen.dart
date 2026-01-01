import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class GradeAssignmentScreen extends StatefulWidget {
  final String submissionId;
  const GradeAssignmentScreen({super.key, required this.submissionId});
  @override
  State<GradeAssignmentScreen> createState() => _GradeAssignmentScreenState();
}

class _GradeAssignmentScreenState extends State<GradeAssignmentScreen> {
  final _scoreController = TextEditingController();
  final _feedbackController = TextEditingController();
  @override
  void dispose() { _scoreController.dispose(); _feedbackController.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Grade Submission')),
    body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Student Submission', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        const Text('Lorem ipsum dolor sit amet, consectetur adipiscing elit...'),
      ]))),
      const SizedBox(height: 24),
      TextField(controller: _scoreController, decoration: const InputDecoration(labelText: 'Score', hintText: 'Enter score (0-100)'), keyboardType: TextInputType.number),
      const SizedBox(height: 16),
      TextField(controller: _feedbackController, decoration: const InputDecoration(labelText: 'Feedback', hintText: 'Provide feedback for the student', alignLabelWithHint: true), maxLines: 4),
      const SizedBox(height: 24),
      ElevatedButton(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Graded!'), backgroundColor: AppColors.success)); context.pop(); }, child: const Text('Submit Grade')),
    ])),
  );
}
