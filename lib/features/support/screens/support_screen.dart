import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});
  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _controller = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  void _send() {
    if (_controller.text.trim().isEmpty) return;
    setState(() { _messages.add({'content': _controller.text.trim(), 'isUser': true}); });
    _controller.clear();
    // Simulate response
    Future.delayed(const Duration(seconds: 1), () => setState(() => _messages.add({'content': 'Thank you for your message. Our support team will get back to you soon.', 'isUser': false})));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Column(children: [
      if (_messages.isEmpty) Expanded(child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.support_agent, size: 64, color: Colors.grey.shade400), const SizedBox(height: 16), const Text('How can we help you?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text('Start a conversation with our support team', style: TextStyle(color: Colors.grey.shade600))])))
      else Expanded(child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: _messages.length, itemBuilder: (_, i) {
        final m = _messages[i];
        return Align(alignment: m['isUser'] ? Alignment.centerRight : Alignment.centerLeft, child: Container(
          margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: m['isUser'] ? AppColors.primary : Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          child: Text(m['content'], style: TextStyle(color: m['isUser'] ? Colors.white : Colors.black)),
        ));
      })),
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]), child: Row(children: [Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Type your message...', border: InputBorder.none))), IconButton(onPressed: _send, icon: const Icon(Icons.send, color: AppColors.primary))])),
    ]),
  );
}
