import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/currency.dart';
import '../models/worker.dart';
import '../services/app_state.dart';
import '../widgets/app_scaffold.dart';

class RunPayrollScreen extends StatefulWidget {
  const RunPayrollScreen({super.key});

  @override
  State<RunPayrollScreen> createState() => _RunPayrollScreenState();
}

class _RunPayrollScreenState extends State<RunPayrollScreen> {
  String? _selectedCountry;

  Future<void> _showPayrollInfo() => showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('About demo payroll'),
          content: const Text(
            'Processing payroll creates local demo payment records in USD. '
            'It does not transfer money or connect to a payment provider.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Got it'),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (!state.isAdmin) {
      return Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              state.isWorker ? '/worker-portal' : '/sign-in',
              (_) => false,
            ),
            child: const Text('Admin access required'),
          ),
        ),
      );
    }

    final allWorkers = state.payableWorkers;
    final countries =
        allWorkers.map((worker) => worker.country).toSet().toList()..sort();
    if (_selectedCountry != null && !countries.contains(_selectedCountry)) {
      _selectedCountry = null;
    }
    final workers = _selectedCountry == null
        ? allWorkers
        : allWorkers
            .where((worker) => worker.country == _selectedCountry)
            .toList();
    final totalUsd =
        workers.fold<double>(0, (total, worker) => total + worker.salary);
    final excludedCount = state.workers.length - allWorkers.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: ink),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: const Text(
          'Run Payroll',
          style:
              TextStyle(fontWeight: FontWeight.w700, color: ink, fontSize: 18),
        ),
        actions: [
          IconButton(
            tooltip: 'About demo payroll',
            onPressed: _showPayrollInfo,
            icon: const Icon(Icons.help_outline, color: ink),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _FilterControl(
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String?>(
                              value: _selectedCountry,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down),
                              style: const TextStyle(
                                color: ink,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('All Countries'),
                                ),
                                ...countries.map(
                                  (country) => DropdownMenuItem<String?>(
                                    value: country,
                                    child: Text(
                                      '${flagEmoji(country)} $country',
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                              onChanged: (country) =>
                                  setState(() => _selectedCountry = country),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FilterControl(
                          child: Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined,
                                  size: 15, color: muted),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  _currentPayrollPeriod(),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: ink,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Workers in this cycle (${workers.length})',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (workers.isEmpty)
                    const SurfaceCard(
                      child: Text(
                        'No compliant workers with verified USD salaries are available for this country.',
                        style: TextStyle(color: muted, height: 1.4),
                      ),
                    ),
                  for (final worker in workers) _WorkerTile(worker: worker),
                  if (excludedCount > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      '$excludedCount worker(s) excluded until compliance issues are resolved and salaries are verified in USD.',
                      style: const TextStyle(
                        color: muted,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 16,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Estimated Payout',
                        style: TextStyle(color: muted, fontSize: 12),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            formatUsd(totalUsd),
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: ink,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'USD',
                            style: TextStyle(color: muted, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: FilledButton(
                      onPressed: workers.isEmpty
                          ? null
                          : () {
                              try {
                                context.read<AppState>().preparePayroll(
                                      workers: workers,
                                    );
                                Navigator.pushNamed(context, '/payroll-review');
                              } on AuthException catch (error) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error.message)),
                                );
                              }
                            },
                      style: FilledButton.styleFrom(
                        backgroundColor: green,
                        disabledBackgroundColor: const Color(0xFFD0D5DD),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Process Payroll',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _currentPayrollPeriod() {
    final now = DateTime.now();
    final startDay = now.day <= 30 ? 1 : 16;
    final endDay =
        now.day <= 30 ? 30 : DateTime(now.year, now.month + 1, 0).day;
    final format = DateFormat('MMM d');
    return '${format.format(DateTime(now.year, now.month, startDay))} - '
        '${format.format(DateTime(now.year, now.month, endDay))}';
  }
}

class _FilterControl extends StatelessWidget {
  final Widget child;

  const _FilterControl({required this.child});

  @override
  Widget build(BuildContext context) => Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE3E5E8)),
        ),
        child: Center(child: child),
      );
}

class _WorkerTile extends StatelessWidget {
  final Worker worker;
  const _WorkerTile({required this.worker});

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE3E5E8)),
        ),
        child: Row(
          children: [
            Text(flagEmoji(worker.country),
                style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    worker.name,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: ink,
                    ),
                  ),
                  Text(
                    worker.role,
                    style: const TextStyle(color: muted, fontSize: 11),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatUsd(worker.salary),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: green,
                  ),
                ),
                const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 5, color: green),
                    SizedBox(width: 3),
                    Text(
                      'Compliant',
                      style: TextStyle(color: green, fontSize: 9),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
}
