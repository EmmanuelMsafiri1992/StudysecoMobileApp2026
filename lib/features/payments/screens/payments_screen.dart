import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../providers/payment_provider.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});
  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  @override
  void initState() { super.initState(); context.read<PaymentProvider>().fetchPaymentHistory(); }
  @override
  Widget build(BuildContext context) => Consumer<PaymentProvider>(builder: (_, p, __) => Scaffold(
    body: p.payments.isEmpty ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.payment, size: 64, color: Colors.grey.shade400), const SizedBox(height: 16), const Text('No payment history'), const SizedBox(height: 24), ElevatedButton(onPressed: () => context.push('/enrollment'), child: const Text('Enroll Now'))])) : ListView.builder(padding: const EdgeInsets.all(16), itemCount: p.payments.length, itemBuilder: (_, i) {
      final pay = p.payments[i];
      return Card(margin: const EdgeInsets.only(bottom: 12), child: ListTile(
        leading: Container(width: 48, height: 48, decoration: BoxDecoration(color: pay.isVerified ? AppColors.success.withOpacity(0.1) : pay.isPending ? AppColors.warning.withOpacity(0.1) : AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(pay.isVerified ? Icons.check_circle : pay.isPending ? Icons.pending : Icons.cancel, color: pay.isVerified ? AppColors.success : pay.isPending ? AppColors.warning : AppColors.error)),
        title: Text(pay.formattedAmount, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(pay.type),
        trailing: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: pay.isVerified ? AppColors.success.withOpacity(0.1) : pay.isPending ? AppColors.warning.withOpacity(0.1) : AppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(pay.status, style: TextStyle(fontSize: 12, color: pay.isVerified ? AppColors.success : pay.isPending ? AppColors.warning : AppColors.error))),
      ));
    }),
    floatingActionButton: FloatingActionButton.extended(onPressed: () => context.push('/extension'), icon: const Icon(Icons.add), label: const Text('Extend')),
  ));
}
