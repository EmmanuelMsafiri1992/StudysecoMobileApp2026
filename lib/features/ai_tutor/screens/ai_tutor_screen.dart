import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/ai_tutor_provider.dart';
import '../../subjects/providers/subjects_provider.dart';

class AiTutorScreen extends StatefulWidget {
  const AiTutorScreen({super.key});
  @override
  State<AiTutorScreen> createState() => _AiTutorScreenState();
}

class _AiTutorScreenState extends State<AiTutorScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  int? _selectedSubject;

  @override
  void initState() { super.initState(); context.read<SubjectsProvider>().fetchEnrolledSubjects(); }
  @override
  void dispose() { _controller.dispose(); _scrollController.dispose(); super.dispose(); }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty || _selectedSubject == null) return;
    await context.read<AiTutorProvider>().sendMessage(_controller.text.trim());
    _controller.clear();
    _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(children: [
      Container(padding: const EdgeInsets.all(16), color: AppColors.primary.withOpacity(0.1), child: Consumer<SubjectsProvider>(builder: (_, p, __) => DropdownButtonFormField<int>(
        value: _selectedSubject, decoration: const InputDecoration(labelText: 'Select Subject', prefixIcon: Icon(Icons.book)),
        items: p.enrolledSubjects.map((s) => DropdownMenuItem(value: s.id, child: Text(s.name))).toList(),
        onChanged: (v) { setState(() => _selectedSubject = v); if (v != null) context.read<AiTutorProvider>().initializeChat(v); },
      ))),
      Expanded(child: Consumer<AiTutorProvider>(builder: (_, p, __) {
        if (_selectedSubject == null) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.smart_toy, size: 64, color: Colors.grey.shade400), const SizedBox(height: 16), const Text('Select a subject to start chatting with AI Tutor')]));
        return ListView.builder(controller: _scrollController, padding: const EdgeInsets.all(16), itemCount: p.messages.length + (p.isTyping ? 1 : 0), itemBuilder: (_, i) {
          if (i == p.messages.length && p.isTyping) return const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.all(8), child: Text('AI is typing...', style: TextStyle(fontStyle: FontStyle.italic))));
          final m = p.messages[i];
          return Align(alignment: m.isUser ? Alignment.centerRight : Alignment.centerLeft, child: Container(
            margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: m.isUser ? AppColors.primary : Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
            child: Text(m.content, style: TextStyle(color: m.isUser ? Colors.white : Colors.black)),
          ));
        });
      })),
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]), child: Row(children: [
        Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Ask your question...', border: InputBorder.none), onSubmitted: (_) => _sendMessage())),
        IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send, color: AppColors.primary)),
      ])),
    ]),
  );
}
