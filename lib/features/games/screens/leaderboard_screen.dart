import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/games_provider.dart';

class LeaderboardScreen extends StatefulWidget {
  final String gameId;
  const LeaderboardScreen({super.key, required this.gameId});
  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() { super.initState(); context.read<GamesProvider>().fetchLeaderboard(widget.gameId); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Leaderboard')),
    body: Consumer<GamesProvider>(builder: (_, p, __) {
      if (p.leaderboard.isEmpty) return const Center(child: Text('No scores yet'));
      return ListView.builder(padding: const EdgeInsets.all(16), itemCount: p.leaderboard.length, itemBuilder: (_, i) {
        final s = p.leaderboard[i];
        return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
          leading: CircleAvatar(backgroundColor: i < 3 ? [AppColors.gold, AppColors.silver, AppColors.bronze][i] : Colors.grey.shade300, child: Text('${i + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: i < 3 ? Colors.white : Colors.black))),
          title: Text(s.userName, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('${s.correctAnswers}/${s.totalQuestions} correct'),
          trailing: Text('${s.score}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
        ));
      });
    }),
  );
}
