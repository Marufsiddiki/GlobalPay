import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';

class PayrollReviewScreen extends StatelessWidget {
  const PayrollReviewScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(title: 'Review Payroll', child: ListView(padding: const EdgeInsets.all(24), children: [
      const Center(child: Text('Jan 1–15, 2026 · 4 workers', style: TextStyle(color: muted))), const SizedBox(height: 12),
      const SurfaceCard(child: Text('Payroll breakdown\n\nGross pay     \$54,620.00\nLocal tax      \$4,860.00\nBenefits       \$2,140.00\nGlobalPay fees \$580.00\n\nTotal debit    \$62,700.00 USD', style: TextStyle(height: 1.6, fontWeight: FontWeight.w600))), const SizedBox(height: 12),
      const SurfaceCard(child: Text('Exchange information\n\nRates locked until Jan 15, 4:00 PM UTC. Includes SGD, EUR, INR and USD payouts.', style: TextStyle(color: green))), const SizedBox(height: 14),
      const Text('Payouts by country', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 10), const SurfaceCard(child: Text('🇸🇬 Singapore · 1 worker · S\$8,200')), const SizedBox(height: 10), const SurfaceCard(child: Text('🇮🇳 India · 1 worker · ₹180,000')), const SizedBox(height: 16),
      PrimaryButton(label: 'Confirm & Process \$62,700', onPressed: () => Navigator.pushNamed(context, '/payroll-success')),
    ]));
  }
}
