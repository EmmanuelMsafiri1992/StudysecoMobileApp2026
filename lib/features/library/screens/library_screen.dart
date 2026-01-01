import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});
  @override
  Widget build(BuildContext context) => DefaultTabController(length: 3, child: Column(children: [
    const TabBar(tabs: [Tab(text: 'Books'), Tab(text: 'Past Papers'), Tab(text: 'Notes')]),
    Expanded(child: TabBarView(children: [
      _buildSection(context, Icons.book, 'Books', 'Access reference books and textbooks'),
      _buildSection(context, Icons.description, 'Past Papers', 'Practice with previous exam papers'),
      _buildSection(context, Icons.note, 'Notes', 'Study notes and materials'),
    ])),
  ]));

  Widget _buildSection(BuildContext context, IconData icon, String title, String desc) => Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    Icon(icon, size: 64, color: AppColors.primary.withOpacity(0.5)),
    const SizedBox(height: 16),
    Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    const SizedBox(height: 8),
    Text(desc, style: TextStyle(color: Colors.grey.shade600)),
  ]));
}
