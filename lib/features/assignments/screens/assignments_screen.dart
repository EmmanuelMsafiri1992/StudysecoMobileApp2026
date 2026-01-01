import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/assignment_provider.dart';

class AssignmentsScreen extends StatefulWidget {
  const AssignmentsScreen({super.key});
  @override
  State<AssignmentsScreen> createState() => _AssignmentsScreenState();
}

class _AssignmentsScreenState extends State<AssignmentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() { super.initState(); _tabController = TabController(length: 3, vsync: this); context.read<AssignmentProvider>().fetchAssignments(); }
  @override
  void dispose() { _tabController.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Consumer<AssignmentProvider>(builder: (_, p, __) {
    if (p.isLoading) return const Center(child: CircularProgressIndicator());
    return Column(children: [
      TabBar(controller: _tabController, tabs: [Tab(text: 'Pending (${p.pendingAssignments.length})'), Tab(text: 'Overdue (${p.overdueAssignments.length})'), Tab(text: 'Submitted (${p.submittedAssignments.length})')]),
      Expanded(child: TabBarView(controller: _tabController, children: [_list(p.pendingAssignments), _list(p.overdueAssignments), _list(p.submittedAssignments)])),
    ]);
  });
  Widget _list(List items) => items.isEmpty ? const Center(child: Text('No assignments')) : ListView.builder(padding: const EdgeInsets.all(16), itemCount: items.length, itemBuilder: (_, i) {
    final a = items[i];
    return Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(
      leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: a.isOverdue ? AppColors.error.withOpacity(0.1) : AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(Icons.task, color: a.isOverdue ? AppColors.error : AppColors.warning)),
      title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(a.timeRemainingFormatted),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => context.go('/assignments/${a.id}'),
    ));
  });
}
