import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/chat_provider.dart';

class ChatGroupsScreen extends StatefulWidget {
  const ChatGroupsScreen({super.key});
  @override
  State<ChatGroupsScreen> createState() => _ChatGroupsScreenState();
}

class _ChatGroupsScreenState extends State<ChatGroupsScreen> {
  @override
  void initState() { super.initState(); context.read<ChatProvider>().fetchGroups(); }
  @override
  Widget build(BuildContext context) => Consumer<ChatProvider>(builder: (_, p, __) {
    if (p.isLoading) return const Center(child: CircularProgressIndicator());
    if (p.groups.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade400), const SizedBox(height: 16), const Text('No chat groups available')]));
    return RefreshIndicator(onRefresh: () => p.fetchGroups(), child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: p.groups.length, itemBuilder: (_, i) {
      final g = p.groups[i];
      return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
        leading: CircleAvatar(backgroundColor: AppColors.getSubjectColor(i).withOpacity(0.1), child: Icon(Icons.group, color: AppColors.getSubjectColor(i))),
        title: Text(g.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(g.lastMessage?.content ?? 'No messages yet', maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: g.unreadCount > 0 ? Container(padding: const EdgeInsets.all(6), decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle), child: Text('${g.unreadCount}', style: const TextStyle(color: Colors.white, fontSize: 12))) : null,
        onTap: () => context.push('/chat/${g.id}'),
      ));
    }));
  });
}
