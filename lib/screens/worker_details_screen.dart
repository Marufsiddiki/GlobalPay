import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/currency.dart';
import '../models/worker.dart';
import '../services/app_state.dart';
import '../widgets/app_scaffold.dart';

class WorkerDetailsScreen extends StatelessWidget {
  const WorkerDetailsScreen({super.key});

  String _money(Worker w) {
    return w.hasVerifiedUsdSalary
        ? '${formatUsd(w.salary)} / mo'
        : 'USD verification required';
  }

  Future<void> _editSalaryUsd(BuildContext context, Worker worker) async {
    final controller = TextEditingController(
      text: worker.hasVerifiedUsdSalary ? worker.salary.toStringAsFixed(2) : '',
    );
    final formKey = GlobalKey<FormState>();
    final value = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Verify salary in USD'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter the worker’s confirmed monthly USD salary. Existing amounts will not be converted automatically.',
                style: TextStyle(color: muted, height: 1.4),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: controller,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Salary (USD)'),
                validator: (input) {
                  final amount = double.tryParse(
                    (input ?? '').replaceAll(',', '').trim(),
                  );
                  return amount == null || !amount.isFinite || amount <= 0
                      ? 'Enter a valid amount greater than zero.'
                      : null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              Navigator.pop(
                dialogContext,
                double.parse(controller.text.replaceAll(',', '').trim()),
              );
            },
            child: const Text('Save USD salary'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null || !context.mounted) return;
    try {
      await context
          .read<AppState>()
          .updateWorkerSalaryUsd(workerId: worker.id, salary: value);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verified USD salary saved.')),
        );
      }
    } on AuthException catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final routeWorker = ModalRoute.of(context)?.settings.arguments as Worker?;
    if (routeWorker == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Worker Details')),
        body: const Center(child: Text('Worker details are unavailable.')),
      );
    }
    final w = state.workers.firstWhere(
      (worker) => worker.id == routeWorker.id,
      orElse: () => routeWorker,
    );
    final compliant = w.complianceStatus == 'Compliant';

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: ink),
            onPressed: () => Navigator.maybePop(context)),
        title: const Text('Employee Details',
            style: TextStyle(
                fontWeight: FontWeight.w700, color: ink, fontSize: 18)),
        actions: state.isAdmin
            ? [
                IconButton(
                  tooltip: 'Verify or update salary in USD',
                  onPressed: () => _editSalaryUsd(context, w),
                  icon: const Icon(Icons.edit_outlined, color: ink),
                ),
              ]
            : const [],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            _profileCard(w, compliant),
            const SizedBox(height: 24),
            const Text('Workspace Details',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: ink)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
              decoration: _box(),
              child: Column(children: [
                _row('Work Email', w.email),
                const Divider(height: 1, color: Color(0xFFEEF0F2)),
                _row('Monthly Salary', _money(w)),
                const Divider(height: 1, color: Color(0xFFEEF0F2)),
                _row('Payment Schedule', 'Monthly'),
              ]),
            ),
            if (w.legacySalaryAmount != null) ...[
              const SizedBox(height: 10),
              const SurfaceCard(
                child: Text(
                  'The previous salary value is retained in the record for reference. It was not converted or relabeled.',
                  style: TextStyle(color: muted, height: 1.4),
                ),
              ),
            ],
            const SizedBox(height: 24),
            const Text('Key Documents',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700, color: ink)),
            const SizedBox(height: 12),
            Row(children: [
              for (var i = 0; i < w.documents.take(2).length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: _doc(w.documents[i])),
              ],
            ]),
          ],
        ),
      ),
    );
  }

  BoxDecoration _box() => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE3E5E8)),
      );

  Widget _profileCard(Worker w, bool compliant) => Container(
        padding: const EdgeInsets.all(20),
        decoration: _box().copyWith(borderRadius: BorderRadius.circular(24)),
        child: Column(children: [
          ProfileAvatar(size: 96, name: w.name),
          const SizedBox(height: 14),
          Text(w.name,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: ink)),
          const SizedBox(height: 2),
          Text(w.role, style: const TextStyle(color: muted)),
          const SizedBox(height: 14),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _badge('${flagEmoji(w.country)} ${w.country}',
                const Color(0xFFE9FBF4), green),
            const SizedBox(width: 8),
            _badge(w.engagementType, const Color(0xFFE8F0FE),
                const Color(0xFF3B6FD4)),
          ]),
          const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(height: 1, color: Color(0xFFEEF0F2))),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: compliant ? mint : const Color(0xFFFFF7DF),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: compliant
                      ? const Color(0xFFB7EBD6)
                      : const Color(0xFFF3DC9A)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(compliant ? Icons.check : Icons.warning_amber_rounded,
                  size: 18, color: compliant ? green : const Color(0xFFB56C00)),
              const SizedBox(width: 8),
              Text(
                compliant ? 'Fully Compliant' : 'Needs Review',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: compliant ? green : const Color(0xFFB56C00)),
              ),
            ]),
          ),
        ]),
      );

  Widget _badge(String text, Color bg, Color fg) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration:
            BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
        child: Text(text,
            style: TextStyle(
                color: fg, fontWeight: FontWeight.w700, fontSize: 12)),
      );

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: const TextStyle(color: muted)),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w700, color: ink)),
        ]),
      );

  Widget _doc(String name) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: _box().copyWith(borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          const Icon(Icons.description_outlined, size: 20, color: ink),
          const SizedBox(width: 8),
          Flexible(
              child: Text(name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: ink, fontSize: 13))),
        ]),
      );
}
