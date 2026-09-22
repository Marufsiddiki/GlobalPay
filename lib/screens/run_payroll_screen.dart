import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';

class RunPayrollScreen extends StatelessWidget {
  const RunPayrollScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(title: 'Run Payroll', child: ListView(padding: const EdgeInsets.all(24), children: [
      Row(children: [Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('All Countries (8)'))), const SizedBox(width: 10), Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Jan 1 - Jan 15')))]),
      const SizedBox(height: 18), const Text('Workers in this cycle (4)', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 10),
      for (final person in ['🇸🇬  Sarah Chen                 \$8,200.00', '🇩🇪  Hans Müller                  €5,100.00', '🇮🇳  Dev Patel                    ₹180,000.00', '🇺🇸  John Doe                     \$4,500.00']) Padding(padding: const EdgeInsets.only(bottom: 10), child: SurfaceCard(child: Text(person))),
      const SizedBox(height: 160), const SurfaceCard(child: Text('Total Estimated Payout     \$62,700.00 USD', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))), const SizedBox(height: 12),
      PrimaryButton(label: 'Process Payroll', onPressed: () => Navigator.pushNamed(context, '/payroll-review')),
    ]));
  }
}
