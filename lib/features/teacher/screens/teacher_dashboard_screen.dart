import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class TeacherDashboardScreen extends StatelessWidget {
  const TeacherDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Teacher Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      Row(children: [
        Expanded(child: _stat('Students', '24', Icons.people, AppColors.primary)),
        const SizedBox(width: 12),
        Expanded(child: _stat('Subjects', '3', Icons.book, AppColors.secondary)),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _stat('Assignments', '8', Icons.task, AppColors.accent)),
        const SizedBox(width: 12),
        Expanded(child: _stat('Pending', '12', Icons.pending, AppColors.warning)),
      ]),
      const SizedBox(height: 24),
      const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      _action(Icons.people, 'My Students', () => context.push('/teacher/students')),
      _action(Icons.assignment, 'Create Assignment', () {}),
      _action(Icons.quiz, 'Create Quiz', () {}),
      _action(Icons.grade, 'Grade Submissions', () {}),
    ])),
  );

  Widget _stat(String label, String value, IconData icon, Color color) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [Icon(icon, color: color, size: 32), const SizedBox(height: 8), Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)), Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))])));
  Widget _action(IconData icon, String title, VoidCallback onTap) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(leading: Icon(icon, color: AppColors.primary), title: Text(title), trailing: const Icon(Icons.chevron_right), onTap: onTap));
}
