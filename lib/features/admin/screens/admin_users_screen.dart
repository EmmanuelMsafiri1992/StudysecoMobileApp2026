import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AdminUsersScreen extends StatelessWidget {
  const AdminUsersScreen({super.key});
  @override
  Widget build(BuildContext context) => DefaultTabController(length: 2, child: Scaffold(
    appBar: AppBar(title: const Text('Manage Users'), bottom: const TabBar(tabs: [Tab(text: 'Students'), Tab(text: 'Teachers')])),
    body: TabBarView(children: [
      ListView.builder(padding: const EdgeInsets.all(16), itemCount: 20, itemBuilder: (_, i) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(leading: CircleAvatar(backgroundColor: AppColors.primary.withOpacity(0.1), child: Text('S${i + 1}')), title: Text('Student ${i + 1}'), subtitle: const Text('student@email.com'), trailing: PopupMenuButton(itemBuilder: (_) => [const PopupMenuItem(child: Text('View')), const PopupMenuItem(child: Text('Edit')), const PopupMenuItem(child: Text('Delete'))])))),
      ListView.builder(padding: const EdgeInsets.all(16), itemCount: 10, itemBuilder: (_, i) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(leading: CircleAvatar(backgroundColor: AppColors.secondary.withOpacity(0.1), child: Text('T${i + 1}')), title: Text('Teacher ${i + 1}'), subtitle: const Text('teacher@email.com'), trailing: PopupMenuButton(itemBuilder: (_) => [const PopupMenuItem(child: Text('View')), const PopupMenuItem(child: Text('Edit')), const PopupMenuItem(child: Text('Delete'))])))),
    ]),
    floatingActionButton: FloatingActionButton(onPressed: () {}, child: const Icon(Icons.add)),
  ));
}
