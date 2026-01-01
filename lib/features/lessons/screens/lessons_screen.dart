import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/lessons_provider.dart';

class LessonsScreen extends StatelessWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LessonsProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.play_circle, size: 80, color: AppColors.primary.withOpacity(0.5)),
                const SizedBox(height: 16),
                const Text('Lessons', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Continue learning from where you left off', style: TextStyle(color: Colors.grey.shade600)),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => context.go('/subjects'),
                  child: const Text('Browse Subjects'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
