import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});
  @override
  Widget build(BuildContext context) => Consumer<ThemeProvider>(builder: (_, theme, __) => SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Appearance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
    const SizedBox(height: 8),
    Card(child: SwitchListTile(title: const Text('Dark Mode'), subtitle: const Text('Use dark theme'), value: theme.isDarkMode, onChanged: (_) => theme.toggleTheme())),
    const SizedBox(height: 24),
    const Text('Notifications', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
    const SizedBox(height: 8),
    Card(child: Column(children: [
      SwitchListTile(title: const Text('Push Notifications'), value: true, onChanged: (_) {}),
      const Divider(height: 1),
      SwitchListTile(title: const Text('Email Notifications'), value: true, onChanged: (_) {}),
      const Divider(height: 1),
      SwitchListTile(title: const Text('Sound'), value: true, onChanged: (_) {}),
    ])),
    const SizedBox(height: 24),
    const Text('About', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
    const SizedBox(height: 8),
    Card(child: Column(children: [
      ListTile(title: const Text('Version'), trailing: const Text('1.0.0')),
      const Divider(height: 1),
      ListTile(title: const Text('Terms of Service'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
      const Divider(height: 1),
      ListTile(title: const Text('Privacy Policy'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
    ])),
  ])));
}
