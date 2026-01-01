import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';

class EnrollmentScreen extends StatelessWidget {
  const EnrollmentScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Enrollment')),
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.school, size: 64, color: AppColors.primary),
      const SizedBox(height: 24),
      const Text('Start Your Learning Journey', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('Select subjects and choose a payment plan', style: TextStyle(color: Colors.grey.shade600)),
      const SizedBox(height: 32),
      ElevatedButton(onPressed: () {}, child: const Text('Select Subjects')),
    ])),
  );
}
