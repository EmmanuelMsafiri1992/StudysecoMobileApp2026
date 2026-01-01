import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/theme/app_colors.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bioController = TextEditingController();
  bool _saving = false;

  @override
  void initState() { super.initState(); final user = context.read<AuthProvider>().user; _nameController.text = user?.name ?? ''; _phoneController.text = user?.phone ?? ''; _bioController.text = user?.bio ?? ''; }
  @override
  void dispose() { _nameController.dispose(); _phoneController.dispose(); _bioController.dispose(); super.dispose(); }

  Future<void> _save() async {
    setState(() => _saving = true);
    final success = await context.read<AuthProvider>().updateProfile(name: _nameController.text, phone: _phoneController.text, bio: _bioController.text);
    setState(() => _saving = false);
    if (success && mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated!'), backgroundColor: AppColors.success)); context.pop(); }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Edit Profile'), actions: [TextButton(onPressed: _saving ? null : _save, child: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save'))]),
    body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(children: [
      CircleAvatar(radius: 50, backgroundColor: AppColors.primary.withOpacity(0.1), child: const Icon(Icons.camera_alt, size: 32, color: AppColors.primary)),
      const SizedBox(height: 24),
      TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person))),
      const SizedBox(height: 16),
      TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone)), keyboardType: TextInputType.phone),
      const SizedBox(height: 16),
      TextField(controller: _bioController, decoration: const InputDecoration(labelText: 'Bio', prefixIcon: Icon(Icons.info), alignLabelWithHint: true), maxLines: 3),
    ])),
  );
}
