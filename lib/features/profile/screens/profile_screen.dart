import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => Consumer<AuthProvider>(builder: (_, auth, __) {
    final user = auth.user;
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
      CircleAvatar(radius: 50, backgroundColor: AppColors.primary.withOpacity(0.1), child: Text(user?.name.substring(0, 1).toUpperCase() ?? 'S', style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary))),
      const SizedBox(height: 16),
      Text(user?.name ?? 'Student', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
      Text(user?.email ?? '', style: TextStyle(color: Colors.grey.shade600)),
      const SizedBox(height: 8),
      if (user?.gradeLevel != null) Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(20)), child: Text(user!.gradeLevel!, style: const TextStyle(color: AppColors.primary))),
      const SizedBox(height: 32),
      _tile(Icons.person, 'Edit Profile', () => context.push('/profile/edit')),
      _tile(Icons.lock, 'Change Password', () {}),
      _tile(Icons.notifications, 'Notifications', () => context.push('/notifications')),
      _tile(Icons.settings, 'Settings', () => context.push('/settings')),
      _tile(Icons.help, 'Help & Support', () => context.push('/support')),
      const SizedBox(height: 24),
      OutlinedButton.icon(onPressed: () async { await auth.logout(); if (context.mounted) context.go('/auth/login'); }, icon: const Icon(Icons.logout, color: AppColors.error), label: const Text('Logout', style: TextStyle(color: AppColors.error))),
    ]));
  });

  Widget _tile(IconData icon, String title, VoidCallback onTap) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(leading: Icon(icon, color: AppColors.primary), title: Text(title), trailing: const Icon(Icons.chevron_right), onTap: onTap));
}
