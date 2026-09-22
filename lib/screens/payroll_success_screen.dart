import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';

class PayrollSuccessScreen extends StatelessWidget {
  const PayrollSuccessScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: ListView(padding: const EdgeInsets.all(24), children: [
      const SizedBox(height: 36), const Center(child: CircleAvatar(radius: 36, backgroundColor: green, child: Icon(Icons.check, color: Colors.white, size: 40))), const SizedBox(height: 18), const Center(child: Text('Payroll complete', style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800))), const SizedBox(height: 8), const Center(child: Text('January payroll is processing. Workers will receive payouts by Jan 16, 2026.', textAlign: TextAlign.center, style: TextStyle(color: muted))), const SizedBox(height: 20),
      const SurfaceCard(child: Text('Payroll reference\nGP-JAN26-0842\n\nWorkers paid: 4\n\nTotal debit: \$62,700.00 USD\n\nFunding account: •••• 4821')), const SizedBox(height: 16), const SurfaceCard(child: Text('Payout summary\n\n4 payouts across Singapore, Germany, India and the United States.', style: TextStyle(color: green))), const SizedBox(height: 16),
      PrimaryButton(label: 'View Receipt', onPressed: () {}), const SizedBox(height: 10), OutlinedButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (_) => false), child: const Text('Return to Dashboard')),
    ])));
  }
}
