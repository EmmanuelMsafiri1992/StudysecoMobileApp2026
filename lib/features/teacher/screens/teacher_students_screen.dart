import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TeacherStudentsScreen extends StatelessWidget {
  const TeacherStudentsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My Students')),
    body: ListView.builder(padding: const EdgeInsets.all(16), itemCount: 10, itemBuilder: (_, i) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
      leading: CircleAvatar(backgroundColor: AppColors.getSubjectColor(i).withOpacity(0.1), child: Text('S${i + 1}')),
      title: Text('Student ${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text('Form ${(i % 4) + 1}'),
      trailing: const Icon(Icons.chevron_right),
    ))),
  );
}
