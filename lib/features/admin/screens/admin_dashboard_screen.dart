import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Admin Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      const SizedBox(height: 24),
      Row(children: [Expanded(child: _stat('Students', '1,234', AppColors.primary)), const SizedBox(width: 12), Expanded(child: _stat('Teachers', '45', AppColors.secondary))]),
      const SizedBox(height: 12),
      Row(children: [Expanded(child: _stat('Revenue', 'MWK 2.5M', AppColors.success)), const SizedBox(width: 12), Expanded(child: _stat('Pending', '18', AppColors.warning))]),
      const SizedBox(height: 24),
      const Text('Quick Actions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      _action(Icons.people, 'Manage Users', () => context.push('/admin/users')),
      _action(Icons.payment, 'Verify Payments', () => context.push('/admin/payments')),
      _action(Icons.analytics, 'View Reports', () => context.push('/admin/reports')),
      _action(Icons.settings, 'System Settings', () {}),
    ])),
  );

  Widget _stat(String label, String value, Color color) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)), const SizedBox(height: 4), Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color))])));
  Widget _action(IconData icon, String title, VoidCallback onTap) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(leading: Icon(icon, color: AppColors.primary), title: Text(title), trailing: const Icon(Icons.chevron_right), onTap: onTap));
}
