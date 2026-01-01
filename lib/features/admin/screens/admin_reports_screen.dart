import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AdminReportsScreen extends StatelessWidget {
  const AdminReportsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Reports & Analytics')),
    body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _metricCard('Total Revenue', 'MWK 2.5M', Icons.attach_money, AppColors.success)),
        const SizedBox(width: 12),
        Expanded(child: _metricCard('Active Users', '1,279', Icons.people, AppColors.primary)),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _metricCard('Enrollments', '456', Icons.school, AppColors.secondary)),
        const SizedBox(width: 12),
        Expanded(child: _metricCard('Completion Rate', '78%', Icons.check_circle, AppColors.accent)),
      ]),
      const SizedBox(height: 24),
      const Text('Revenue by Subject', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      _revenueItem('Mathematics', 'MWK 850,000', 0.34),
      _revenueItem('Physics', 'MWK 620,000', 0.25),
      _revenueItem('Chemistry', 'MWK 480,000', 0.19),
      _revenueItem('Biology', 'MWK 350,000', 0.14),
      _revenueItem('English', 'MWK 200,000', 0.08),
      const SizedBox(height: 24),
      const Text('User Growth (Last 6 Months)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
        _growthRow('Jul', 180), _growthRow('Aug', 220), _growthRow('Sep', 310), _growthRow('Oct', 280), _growthRow('Nov', 350), _growthRow('Dec', 420),
      ]))),
      const SizedBox(height: 24),
      const Text('Quick Reports', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      _reportAction(Icons.download, 'Export Revenue Report'),
      _reportAction(Icons.download, 'Export User Report'),
      _reportAction(Icons.download, 'Export Enrollment Report'),
      _reportAction(Icons.download, 'Export Performance Report'),
    ])),
  );

  Widget _metricCard(String label, String value, IconData icon, Color color) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [
    Icon(icon, color: color, size: 32),
    const SizedBox(height: 8),
    Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
    Text(label, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
  ])));

  Widget _revenueItem(String subject, String amount, double percentage) => Card(margin: const EdgeInsets.only(bottom: 8), child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(subject, style: const TextStyle(fontWeight: FontWeight.bold)), Text(amount, style: TextStyle(color: AppColors.success, fontWeight: FontWeight.bold))]),
    const SizedBox(height: 8),
    LinearProgressIndicator(value: percentage, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation(AppColors.primary)),
    const SizedBox(height: 4),
    Text('${(percentage * 100).toInt()}% of total', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
  ])));

  Widget _growthRow(String month, int users) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [
    SizedBox(width: 40, child: Text(month, style: const TextStyle(fontWeight: FontWeight.bold))),
    Expanded(child: LinearProgressIndicator(value: users / 500, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation(AppColors.primary))),
    const SizedBox(width: 12),
    Text('$users', style: const TextStyle(fontWeight: FontWeight.bold)),
  ]));

  Widget _reportAction(IconData icon, String title) => Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(leading: Icon(icon, color: AppColors.primary), title: Text(title), trailing: const Icon(Icons.chevron_right), onTap: () {}));
}
