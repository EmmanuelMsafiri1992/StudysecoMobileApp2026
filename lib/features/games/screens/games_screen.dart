import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/games_provider.dart';

class GamesScreen extends StatefulWidget {
  const GamesScreen({super.key});
  @override
  State<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends State<GamesScreen> {
  @override
  void initState() { super.initState(); context.read<GamesProvider>().fetchGames(); }
  @override
  Widget build(BuildContext context) => Consumer<GamesProvider>(builder: (_, p, __) {
    if (p.isLoading) return const Center(child: CircularProgressIndicator());
    if (p.games.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.games, size: 64, color: Colors.grey.shade400), const SizedBox(height: 16), const Text('No games available')]));
    return RefreshIndicator(onRefresh: () => p.fetchGames(), child: GridView.builder(padding: const EdgeInsets.all(16), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85), itemCount: p.games.length, itemBuilder: (_, i) {
      final g = p.games[i];
      final colors = [Colors.purple, AppColors.secondary, AppColors.accent, AppColors.primary];
      final color = colors[i % colors.length];
      return Card(child: InkWell(onTap: () => context.push('/game/${g.id}/play'), borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        Container(width: 56, height: 56, decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(16)), child: Icon(Icons.games, color: color, size: 28)),
        const SizedBox(height: 12),
        Text(g.name, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
        const SizedBox(height: 4),
        Text(g.typeDisplayName, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
        const Spacer(),
        if (g.bestScore != null) Row(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.emoji_events, size: 14, color: AppColors.accent), const SizedBox(width: 4), Text('Best: ${g.bestScore}', style: const TextStyle(fontSize: 12, color: AppColors.accent))]),
      ]))));
    }));
  });
}
