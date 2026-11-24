import 'package:flutter/material.dart';

import '../models/currency.dart';
import '../models/payroll_run.dart';
import '../widgets/app_scaffold.dart';

class PayrollSuccessScreen extends StatelessWidget {
  const PayrollSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final run = ModalRoute.of(context)?.settings.arguments as PayrollRun?;
    if (run == null) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Payroll record not found.'),
                TextButton(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/dashboard',
                    (_) => false,
                  ),
                  child: const Text('Return to Dashboard'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final totalUsd = run.payments
        .where((payment) => payment.currency == appCurrencyCode)
        .fold<double>(0, (total, payment) => total + payment.amount);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 32),
            const Center(
              child: CircleAvatar(
                radius: 36,
                backgroundColor: green,
                child: Icon(Icons.check, color: Colors.white, size: 40),
              ),
            ),
            const SizedBox(height: 18),
            const Center(
              child: Text(
                'Demo payroll recorded',
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'No money was transferred. Workers can now sign in to view their demo payroll record.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted),
            ),
            const SizedBox(height: 20),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Payroll reference',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  Text(run.id),
                  const SizedBox(height: 12),
                  Text('Workers: ${run.payments.length}'),
                  Text('Total (USD): ${formatUsd(totalUsd)}'),
                  const SizedBox(height: 8),
                  Text('Status: ${run.status}'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Worker payouts',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  for (final payment in run.payments)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '${payment.workerName} · ${payment.currency == appCurrencyCode ? formatUsd(payment.amount) : 'USD verification required'} · ${payment.status}',
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            PrimaryButton(
              label: 'Return to Dashboard',
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/dashboard',
                (_) => false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
