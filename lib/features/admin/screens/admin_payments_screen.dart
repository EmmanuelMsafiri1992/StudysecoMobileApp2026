import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class AdminPaymentsScreen extends StatefulWidget {
  const AdminPaymentsScreen({super.key});
  @override
  State<AdminPaymentsScreen> createState() => _AdminPaymentsScreenState();
}

class _AdminPaymentsScreenState extends State<AdminPaymentsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  @override
  void initState() { super.initState(); _tabController = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tabController.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Payment Management'),
      bottom: TabBar(controller: _tabController, tabs: const [Tab(text: 'Pending'), Tab(text: 'Verified'), Tab(text: 'Rejected')]),
    ),
    body: TabBarView(controller: _tabController, children: [
      _buildPaymentList('pending'),
      _buildPaymentList('verified'),
      _buildPaymentList('rejected'),
    ]),
  );

  Widget _buildPaymentList(String status) => ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: status == 'pending' ? 8 : status == 'verified' ? 15 : 3,
    itemBuilder: (_, i) => Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Student ${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          _statusBadge(status),
        ]),
        const SizedBox(height: 8),
        Text('Mathematics - Form 3', style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 4),
        Text('MWK 15,000', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
        const SizedBox(height: 4),
        Text('Ref: PAY${100000 + i}', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        const SizedBox(height: 4),
        Text('Dec ${20 + i}, 2024', style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        if (status == 'pending') ...[
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: OutlinedButton(onPressed: () => _showRejectDialog(), style: OutlinedButton.styleFrom(foregroundColor: AppColors.error), child: const Text('Reject'))),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(onPressed: () => _verifyPayment(i), style: ElevatedButton.styleFrom(backgroundColor: AppColors.success), child: const Text('Verify'))),
          ]),
        ],
      ])),
    ),
  );

  Widget _statusBadge(String status) {
    final color = status == 'pending' ? AppColors.warning : status == 'verified' ? AppColors.success : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Text(status.toUpperCase(), style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  void _verifyPayment(int index) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment ${index + 1} verified!'), backgroundColor: AppColors.success));
  }

  void _showRejectDialog() {
    showDialog(context: context, builder: (_) => AlertDialog(
      title: const Text('Reject Payment'),
      content: const TextField(decoration: InputDecoration(labelText: 'Reason for rejection', hintText: 'Enter reason...'), maxLines: 3),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(onPressed: () { Navigator.pop(context); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment rejected'), backgroundColor: AppColors.error)); }, style: ElevatedButton.styleFrom(backgroundColor: AppColors.error), child: const Text('Reject')),
      ],
    ));
  }
}
