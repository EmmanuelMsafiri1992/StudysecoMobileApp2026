import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/community_provider.dart';

class PostDetailScreen extends StatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});
  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final _commentController = TextEditingController();
  @override
  void initState() { super.initState(); context.read<CommunityProvider>().fetchPostDetail(widget.postId); }
  @override
  void dispose() { _commentController.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Consumer<CommunityProvider>(builder: (_, p, __) {
    final post = p.currentPost;
    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: p.isLoading ? const Center(child: CircularProgressIndicator()) : post == null ? const Center(child: Text('Post not found')) : Column(children: [
        Expanded(child: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [CircleAvatar(child: Text(post.userName[0])), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(post.userName, style: const TextStyle(fontWeight: FontWeight.bold)), Text(post.type, style: TextStyle(fontSize: 12, color: Colors.grey.shade600))]))]),
          const SizedBox(height: 16),
          Text(post.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(post.content),
          const SizedBox(height: 16),
          Row(children: [IconButton(icon: Icon(post.isLiked ? Icons.thumb_up : Icons.thumb_up_outlined, color: post.isLiked ? AppColors.primary : null), onPressed: () => p.likePost(post.id)), Text('${post.likesCount}'), const Spacer(), Text('${post.commentsCount} comments', style: TextStyle(color: Colors.grey.shade600))]),
          const Divider(height: 32),
          const Text('Comments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (post.comments != null) ...post.comments!.map((c) => Card(margin: const EdgeInsets.only(bottom: 8), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Row(children: [CircleAvatar(radius: 12, child: Text(c.userName[0], style: const TextStyle(fontSize: 10))), const SizedBox(width: 8), Text(c.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)), if (c.isSolution) Container(margin: const EdgeInsets.only(left: 8), padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.success.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: const Text('Solution', style: TextStyle(fontSize: 10, color: AppColors.success)))]), const SizedBox(height: 8), Text(c.content)])))),
        ]))),
        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)]), child: Row(children: [Expanded(child: TextField(controller: _commentController, decoration: const InputDecoration(hintText: 'Add a comment...', border: InputBorder.none))), IconButton(onPressed: () async { if (_commentController.text.isNotEmpty) { await p.addComment(post.id, _commentController.text); _commentController.clear(); } }, icon: const Icon(Icons.send, color: AppColors.primary))])),
      ]),
    );
  });
}
