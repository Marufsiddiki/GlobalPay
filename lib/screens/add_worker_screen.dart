import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/progress_bar.dart';

class AddWorkerScreen extends StatefulWidget {
  const AddWorkerScreen({super.key});
  @override
  State<AddWorkerScreen> createState() => _AddWorkerState();
}
class _AddWorkerState extends State<AddWorkerScreen> {
  int step = 1;
  @override
  Widget build(BuildContext context) {
    return AppScaffold(title: 'Add Worker', child: ListView(padding: const EdgeInsets.all(24), children: [
      MultiStepProgress(step: step), const SizedBox(height: 18),
      if (step == 1) ...[
        const Text('Who are you adding?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const Text('Use their legal identity details for payroll and compliance.', style: TextStyle(color: muted)),
        const SizedBox(height: 16),
        const SurfaceCard(child: Column(children: [TextField(decoration: InputDecoration(labelText: 'Legal Full Name', hintText: 'Aisha Rahman')), SizedBox(height: 12), TextField(decoration: InputDecoration(labelText: 'Work Email', hintText: 'aisha@company.com')), SizedBox(height: 12), TextField(decoration: InputDecoration(labelText: 'Country of Work', hintText: '🇧🇩 Bangladesh')), SizedBox(height: 12), TextField(decoration: InputDecoration(labelText: 'Role', hintText: 'Product Designer'))])),
        const SizedBox(height: 14), PrimaryButton(label: 'Continue', onPressed: () => setState(() => step = 2)),
      ] else if (step == 2) ...[
        const Text('Engagement type', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 10),
        const SurfaceCard(child: Text('● Employee\n\nLocal payroll', style: TextStyle(color: green, fontWeight: FontWeight.w700))), const SizedBox(height: 10),
        const SurfaceCard(child: Text('○ Contractor', style: TextStyle(fontWeight: FontWeight.w700))), const SizedBox(height: 14),
        const SurfaceCard(child: Column(children: [TextField(decoration: InputDecoration(labelText: 'Start Date', hintText: 'February 2, 2026')), SizedBox(height: 12), TextField(decoration: InputDecoration(labelText: 'Department', hintText: 'Product & Design'))])), const SizedBox(height: 14),
        const SurfaceCard(child: Text('Classification check passed\nEmployee classification aligns with Bangladesh labor requirements.', style: TextStyle(color: green))), const SizedBox(height: 14),
        PrimaryButton(label: 'Continue', onPressed: () => setState(() => step = 3)),
      ] else ...[
        const SurfaceCard(child: Column(children: [TextField(decoration: InputDecoration(labelText: 'Monthly Salary', hintText: '৳ 180,000 BDT')), SizedBox(height: 12), TextField(decoration: InputDecoration(labelText: 'Payment Schedule', hintText: 'Monthly · Last working day'))])), const SizedBox(height: 14),
        const Text('Secure documents', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 8), const StatusBadge(text: '✓ National ID'), const SizedBox(height: 8), const StatusBadge(text: '✓ Tax form'), const SizedBox(height: 14),
        const SurfaceCard(child: Text('Onboarding summary\n\nWorker: Aisha Rahman\nLocation: Bangladesh\nClassification: Employee · Compliant')), const SizedBox(height: 14),
        PrimaryButton(label: 'Add Worker', onPressed: () => Navigator.pop(context)),
      ],
    ]));
  }
}
