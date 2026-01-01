import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class CertificatesScreen extends StatelessWidget {
  const CertificatesScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(Icons.card_membership, size: 64, color: Colors.grey.shade400),
      const SizedBox(height: 16),
      const Text('Your Certificates', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text('Complete courses to earn certificates', style: TextStyle(color: Colors.grey.shade600)),
    ])),
  );
}
