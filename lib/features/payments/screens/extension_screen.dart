import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ExtensionScreen extends StatelessWidget {
  const ExtensionScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Extend Access')),
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.timer, size: 64, color: AppColors.primary),
      const SizedBox(height: 24),
      const Text('Extend Your Access', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('Choose duration and payment method', style: TextStyle(color: Colors.grey.shade600)),
      const SizedBox(height: 32),
      ElevatedButton(onPressed: () {}, child: const Text('Select Duration')),
    ])),
  );
}
