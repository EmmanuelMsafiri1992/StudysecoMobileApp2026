import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/assignment_provider.dart';

class AssignmentSubmitScreen extends StatefulWidget {
  final String assignmentId;
  const AssignmentSubmitScreen({super.key, required this.assignmentId});
  @override
  State<AssignmentSubmitScreen> createState() => _AssignmentSubmitScreenState();
}

class _AssignmentSubmitScreenState extends State<AssignmentSubmitScreen> {
  final _controller = TextEditingController();
  final _files = <String>[];
  bool _submitting = false;

  Future<void> _pickFiles() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) setState(() => _files.addAll(result.paths.whereType<String>()));
  }

  Future<void> _submit() async {
    if (_controller.text.isEmpty && _files.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please add content or files'), backgroundColor: AppColors.error));
      return;
    }
    setState(() => _submitting = true);
    final success = await context.read<AssignmentProvider>().submitAssignment(assignmentId: int.parse(widget.assignmentId), content: _controller.text, attachments: _files.isNotEmpty ? _files : null);
    setState(() => _submitting = false);
    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Assignment submitted!'), backgroundColor: AppColors.success));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Submit Assignment')),
    body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TextField(controller: _controller, maxLines: 8, decoration: const InputDecoration(hintText: 'Write your answer here...', border: OutlineInputBorder())),
      const SizedBox(height: 16),
      OutlinedButton.icon(onPressed: _pickFiles, icon: const Icon(Icons.attach_file), label: const Text('Attach Files')),
      if (_files.isNotEmpty) ...[ const SizedBox(height: 8), ..._files.map((f) => ListTile(leading: const Icon(Icons.insert_drive_file), title: Text(f.split('/').last), trailing: IconButton(icon: const Icon(Icons.close), onPressed: () => setState(() => _files.remove(f)))))],
      const SizedBox(height: 24),
      ElevatedButton(onPressed: _submitting ? null : _submit, child: _submitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Submit')),
    ])),
  );

  @override
  void dispose() { _controller.dispose(); super.dispose(); }
}
