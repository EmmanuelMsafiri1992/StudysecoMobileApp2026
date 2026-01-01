import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../../core/theme/app_colors.dart';
import '../providers/notification_provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() { super.initState(); context.read<NotificationProvider>().fetchNotifications(); }
  @override
  Widget build(BuildContext context) => Consumer<NotificationProvider>(builder: (_, p, __) => Scaffold(
    appBar: AppBar(title: const Text('Notifications'), actions: [if (p.unreadCount > 0) TextButton(onPressed: () => p.markAllAsRead(), child: const Text('Mark all read'))]),
    body: p.isLoading ? const Center(child: CircularProgressIndicator()) : p.notifications.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.notifications_off, size: 64, color: Colors.grey.shade400), const SizedBox(height: 16), const Text('No notifications')])) : RefreshIndicator(onRefresh: () => p.fetchNotifications(), child: ListView.builder(itemCount: p.notifications.length, itemBuilder: (_, i) {
      final n = p.notifications[i];
      return Dismissible(key: Key(n.id.toString()), direction: DismissDirection.endToStart, background: Container(color: AppColors.error, alignment: Alignment.centerRight, padding: const EdgeInsets.only(right: 16), child: const Icon(Icons.delete, color: Colors.white)), onDismissed: (_) => p.deleteNotification(n.id), child: ListTile(
        leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: n.isRead ? Colors.grey.shade200 : AppColors.primary.withOpacity(0.1), shape: BoxShape.circle), child: Icon(_getIcon(n.type), color: n.isRead ? Colors.grey : AppColors.primary, size: 20)),
        title: Text(n.title, style: TextStyle(fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold)),
        subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(n.message, maxLines: 2, overflow: TextOverflow.ellipsis), const SizedBox(height: 4), Text(timeago.format(n.createdAt), style: TextStyle(fontSize: 12, color: Colors.grey.shade500))]),
        onTap: () => p.markAsRead(n.id),
      ));
    })),
  ));

  IconData _getIcon(String type) {
    switch (type) { case 'achievement': return Icons.emoji_events; case 'quiz': return Icons.quiz; case 'assignment': return Icons.task; case 'payment': return Icons.payment; default: return Icons.notifications; }
  }
}
