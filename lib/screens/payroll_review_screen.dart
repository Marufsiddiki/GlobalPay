import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/currency.dart';
import '../services/app_state.dart';
import '../widgets/app_scaffold.dart';

class PayrollReviewScreen extends StatelessWidget {
  const PayrollReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (!state.isAdmin) {
      return AppScaffold(
        title: 'Access restricted',
        child: const Center(
            child: Text('Only a company admin can review payroll.')),
      );
    }
    final workers = state.draftWorkers;
    final totalUsd =
        workers.fold<double>(0, (total, worker) => total + worker.salary);

    return AppScaffold(
      title: 'Review Payroll',
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Monthly payroll · ${DateTime.now().toLocal().toString().split(' ').first}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted),
          ),
          const SizedBox(height: 12),
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payroll breakdown',
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Text('Workers included: ${workers.length}'),
                Text('Total in USD: ${formatUsd(totalUsd)}'),
                const SizedBox(height: 10),
                const Text(
                  'All amounts in this payroll are verified USD values. No currency conversion is applied.',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          for (final worker in workers)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SurfaceCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${worker.name}\n${worker.country}',
                        style: const TextStyle(height: 1.5),
                      ),
                    ),
                    Text(
                      formatUsd(worker.salary),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          const SurfaceCard(
            child: Text(
              'Demo confirmation records payouts as “Paid (demo)” so workers can view them. No bank, wallet, or payment provider is connected.',
              style: TextStyle(color: muted, height: 1.4),
            ),
          ),
          const SizedBox(height: 16),
          PrimaryButton(
            label: 'Confirm Demo Payroll',
            onPressed: () async {
              try {
                final run = await context.read<AppState>().processPayroll();
                if (context.mounted) {
                  Navigator.pushNamed(
                    context,
                    '/payroll-success',
                    arguments: run,
                  );
                }
              } on AuthException catch (error) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(error.message)),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}
