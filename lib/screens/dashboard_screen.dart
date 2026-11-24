import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/currency.dart';
import '../models/payroll_run.dart';
import '../services/app_state.dart';
import '../widgets/app_scaffold.dart';
import 'sign_in_screen.dart';
import 'worker_portal_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (!state.signedIn) return const SignInScreen();
    if (state.isWorker) return const WorkerPortalScreen();

    final workers = state.workers;
    final payrollReadyWorkers = state.payableWorkers;
    final payrollEstimate = payrollReadyWorkers.fold<double>(
      0,
      (total, worker) => total + worker.salary,
    );
    final countries = workers.map((worker) => worker.country).toSet().length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      bottomNavigationBar: const AppBottomNav(currentTab: 0),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                _header(context, state),
                const SizedBox(height: 28),
                _summaryCard(
                  payrollEstimate: payrollEstimate,
                  workerCount: workers.length,
                  countryCount: countries,
                  payrollReadyCount: payrollReadyWorkers.length,
                ),
                const SizedBox(height: 22),
                const Text(
                  'Quick Actions',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w700, color: ink),
                ),
                const SizedBox(height: 12),
                const Row(
                  children: [
                    _QuickAction(
                      label: 'Run Payroll',
                      icon: Icons.play_arrow_rounded,
                      route: '/run-payroll',
                    ),
                    SizedBox(width: 10),
                    _QuickAction(
                      label: 'Add Worker',
                      icon: Icons.person_add_alt_1_outlined,
                      route: '/add-worker',
                    ),
                    SizedBox(width: 10),
                    _QuickAction(
                      label: 'View Reports',
                      icon: Icons.description_outlined,
                      route: '/analytics',
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ink),
                    ),
                    TextButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/analytics'),
                      child: const Text('See All'),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (state.payrollRuns.isEmpty)
                  _emptyActivity(context)
                else
                  ...state.payrollRuns
                      .take(3)
                      .map((run) => _RunActivityTile(run: run)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header(BuildContext context, AppState state) => Row(
        children: [
          ProfileAvatar(size: 42, name: state.currentUserName),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(color: muted, fontSize: 12),
                ),
                Text(
                  'Hello, ${state.currentUserName}',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w800, color: ink),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Compliance and notifications',
            onPressed: () => Navigator.pushNamed(context, '/compliance'),
            icon: const Icon(Icons.notifications_none_rounded, color: ink),
          ),
          IconButton(
            tooltip: 'Sign out',
            onPressed: () async {
              await state.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/welcome',
                  (_) => false,
                );
              }
            },
            icon: const Icon(Icons.logout, color: ink),
          ),
        ],
      );

  Widget _summaryCard({
    required double payrollEstimate,
    required int workerCount,
    required int countryCount,
    required int payrollReadyCount,
  }) =>
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B6B4F), Color(0xFF053D2F)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26053D2F),
              blurRadius: 16,
              offset: Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL PAYROLL VALUE',
                  style: TextStyle(
                    color: Color(0xFF8DE4C7),
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2B7A63),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: Text(
                    DateFormat('MMM yyyy').format(DateTime.now()).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Flexible(
                  child: Text(
                    formatUsd(payrollEstimate),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                const Text(
                  'USD',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              'Monthly estimate · $payrollReadyCount payroll-ready workers',
              style: const TextStyle(color: Color(0xFFC4E7DC), fontSize: 10),
            ),
            const Divider(color: Color(0x4463DDB8), height: 24),
            Row(
              children: [
                Expanded(
                  child: _Stat(
                    label: 'TOTAL HEADCOUNT',
                    value: '$workerCount Workers',
                  ),
                ),
                Expanded(
                  child: _Stat(
                    label: 'COUNTRIES',
                    value: '$countryCount Countries',
                    trailing: Icons.language,
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _emptyActivity(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE3E5E8)),
        ),
        child: Row(
          children: [
            const Icon(Icons.receipt_long_outlined, color: muted),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'No payroll activity yet. Process a demo payroll to see it here.',
                style: TextStyle(color: muted, fontSize: 12, height: 1.4),
              ),
            ),
            IconButton(
              tooltip: 'Run payroll',
              onPressed: () => Navigator.pushNamed(context, '/run-payroll'),
              icon: const Icon(Icons.arrow_forward, color: green, size: 20),
            ),
          ],
        ),
      );
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  final IconData? trailing;

  const _Stat({required this.label, required this.value, this.trailing});

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
                color: Color(0xFFA8D8C7), fontSize: 9, letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Flexible(
                child: Text(
                  value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              if (trailing != null) ...[
                const SizedBox(width: 5),
                Icon(trailing, color: const Color(0xFF63DDB8), size: 14),
              ],
            ],
          ),
        ],
      );
}

class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;

  const _QuickAction({
    required this.label,
    required this.icon,
    required this.route,
  });

  @override
  Widget build(BuildContext context) => Expanded(
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => Navigator.pushNamed(context, route),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 3),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE3E5E8)),
            ),
            child: Column(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: mint,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: green, size: 19),
                ),
                const SizedBox(height: 7),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}

class _RunActivityTile extends StatelessWidget {
  final PayrollRun run;
  const _RunActivityTile({required this.run});

  @override
  Widget build(BuildContext context) {
    final usdPayments =
        run.payments.where((payment) => payment.currency == appCurrencyCode);
    final totalUsd = usdPayments.fold<double>(
      0,
      (total, payment) => total + payment.amount,
    );
    final firstPayment = run.payments.isEmpty ? null : run.payments.first;
    final countries = run.payments.map((payment) => payment.country).toSet();
    final title =
        countries.length == 1 ? '${countries.first} Payroll' : 'Payroll Cycle';
    final date = DateFormat('MMM d').format(run.createdAt.toLocal());

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE3E5E8)),
      ),
      child: Row(
        children: [
          if (firstPayment == null)
            const Icon(Icons.receipt_long_outlined, color: muted, size: 20)
          else
            Text(
              flagEmoji(firstPayment.country),
              style: const TextStyle(fontSize: 20),
            ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: ink, fontSize: 12)),
                Text(
                  '${run.status} · $date',
                  style: const TextStyle(color: muted, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatUsd(totalUsd),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: ink,
                  fontSize: 12,
                ),
              ),
              Text(
                '${usdPayments.length} USD payout${usdPayments.length == 1 ? '' : 's'}',
                style: const TextStyle(color: muted, fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
