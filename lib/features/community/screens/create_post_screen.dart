import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/community_provider.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});
  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _type = 'discussion';
  bool _submitting = false;

  Future<void> _submit() async {
    if (_titleController.text.isEmpty || _contentController.text.isEmpty) return;
    setState(() => _submitting = true);
    final success = await context.read<CommunityProvider>().createPost(title: _titleController.text, content: _contentController.text, type: _type);
    setState(() => _submitting = false);
    if (success && mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post created!'), backgroundColor: AppColors.success)); context.pop(); }
  }

  @override
  void dispose() { _titleController.dispose(); _contentController.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create Post'), actions: [TextButton(onPressed: _submitting ? null : _submit, child: _submitting ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Post'))]),
    body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      DropdownButtonFormField<String>(value: _type, decoration: const InputDecoration(labelText: 'Post Type'), items: const [DropdownMenuItem(value: 'question', child: Text('Question')), DropdownMenuItem(value: 'discussion', child: Text('Discussion')), DropdownMenuItem(value: 'shared_resource', child: Text('Shared Resource'))], onChanged: (v) => setState(() => _type = v!)),
      const SizedBox(height: 16),
      TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title', hintText: 'Enter a title for your post')),
      const SizedBox(height: 16),
      TextField(controller: _contentController, maxLines: 8, decoration: const InputDecoration(labelText: 'Content', hintText: 'Write your post content here...', alignLabelWithHint: true)),
    ])),
  );
}
