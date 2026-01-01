import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/community_provider.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});
  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  @override
  void initState() { super.initState(); context.read<CommunityProvider>().fetchPosts(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Consumer<CommunityProvider>(builder: (_, p, __) {
      if (p.isLoading) return const Center(child: CircularProgressIndicator());
      if (p.posts.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.forum, size: 64, color: Colors.grey.shade400), const SizedBox(height: 16), const Text('No posts yet'), const SizedBox(height: 16), ElevatedButton(onPressed: () => context.push('/community/create'), child: const Text('Create Post'))]));
      return RefreshIndicator(onRefresh: () => p.fetchPosts(), child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: p.posts.length, itemBuilder: (_, i) {
        final post = p.posts[i];
        return Card(margin: const EdgeInsets.only(bottom: 12), child: InkWell(onTap: () => context.push('/community/post/${post.id}'), child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [CircleAvatar(radius: 16, child: Text(post.userName[0])), const SizedBox(width: 8), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(post.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), Text(post.type, style: TextStyle(fontSize: 10, color: Colors.grey.shade600))])), if (post.isQuestion) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: post.isResolved ? AppColors.success.withOpacity(0.1) : AppColors.warning.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(post.isResolved ? 'Solved' : 'Open', style: TextStyle(fontSize: 10, color: post.isResolved ? AppColors.success : AppColors.warning)))]),
          const SizedBox(height: 12),
          Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          Text(post.content, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          const SizedBox(height: 12),
          Row(children: [Icon(Icons.thumb_up_outlined, size: 16, color: Colors.grey.shade500), const SizedBox(width: 4), Text('${post.likesCount}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)), const SizedBox(width: 16), Icon(Icons.comment_outlined, size: 16, color: Colors.grey.shade500), const SizedBox(width: 4), Text('${post.commentsCount}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500))]),
        ]))));
      }));
    }),
    floatingActionButton: FloatingActionButton(onPressed: () => context.push('/community/create'), child: const Icon(Icons.add)),
  );
}
