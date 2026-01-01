import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/chat_provider.dart';

class ChatRoomScreen extends StatefulWidget {
  final String groupId;
  const ChatRoomScreen({super.key, required this.groupId});
  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() { super.initState(); context.read<ChatProvider>().joinGroup(widget.groupId); }
  @override
  void dispose() { context.read<ChatProvider>().leaveGroup(); _controller.dispose(); _scrollController.dispose(); super.dispose(); }

  void _sendMessage() async {
    if (_controller.text.trim().isEmpty) return;
    await context.read<ChatProvider>().sendMessage(_controller.text.trim());
    _controller.clear();
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) => Consumer<ChatProvider>(builder: (_, p, __) => Scaffold(
    appBar: AppBar(title: Text(p.currentGroup?.name ?? 'Chat')),
    body: Column(children: [
      Expanded(child: ListView.builder(controller: _scrollController, reverse: true, padding: const EdgeInsets.all(16), itemCount: p.messages.length, itemBuilder: (_, i) {
        final m = p.messages[i];
        final isMe = m.userId == 1; // TODO: Compare with current user
        return Align(alignment: isMe ? Alignment.centerRight : Alignment.centerLeft, child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(color: isMe ? AppColors.primary : Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (!isMe) Text(m.userName, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isMe ? Colors.white70 : AppColors.primary)),
            Text(m.content, style: TextStyle(color: isMe ? Colors.white : Colors.black)),
          ]),
        ));
      })),
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]), child: Row(children: [
        Expanded(child: TextField(controller: _controller, decoration: const InputDecoration(hintText: 'Type a message...', border: InputBorder.none), onSubmitted: (_) => _sendMessage())),
        IconButton(onPressed: _sendMessage, icon: const Icon(Icons.send, color: AppColors.primary)),
      ])),
    ]),
  ));
}
