import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/achievement_provider.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});
  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  @override
  void initState() { super.initState(); final p = context.read<AchievementProvider>(); p.fetchAchievements(); p.fetchStats(); }
  @override
  Widget build(BuildContext context) => Consumer<AchievementProvider>(builder: (_, p, __) {
    if (p.isLoading) return const Center(child: CircularProgressIndicator());
    return SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (p.stats != null) Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
        Expanded(child: Column(children: [Text('${p.stats!.earnedAchievements}/${p.stats!.totalAchievements}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)), const Text('Earned', style: TextStyle(fontSize: 12))])),
        Container(width: 1, height: 40, color: Colors.grey.shade300),
        Expanded(child: Column(children: [Text('${p.stats!.totalPoints}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.accent)), const Text('Points', style: TextStyle(fontSize: 12))])),
        Container(width: 1, height: 40, color: Colors.grey.shade300),
        Expanded(child: Column(children: [Text('#${p.stats!.rank}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primary)), const Text('Rank', style: TextStyle(fontSize: 12))])),
      ]))),
      const SizedBox(height: 20),
      const Text('All Achievements', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.9), itemCount: p.achievements.length, itemBuilder: (_, i) {
        final a = p.achievements[i];
        return Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(children: [
          Container(width: 56, height: 56, decoration: BoxDecoration(color: a.isEarned ? AppColors.getAchievementColor(a.level) : Colors.grey.shade300, shape: BoxShape.circle), child: Icon(Icons.emoji_events, color: a.isEarned ? Colors.white : Colors.grey.shade500, size: 28)),
          const SizedBox(height: 8),
          Text(a.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12), textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 4),
          Text(a.level, style: TextStyle(fontSize: 10, color: AppColors.getAchievementColor(a.level))),
          if (!a.isEarned && a.progress != null) Padding(padding: const EdgeInsets.only(top: 8), child: LinearProgressIndicator(value: a.progressPercentage / 100, backgroundColor: Colors.grey.shade200)),
        ])));
      }),
    ]));
  });
}
