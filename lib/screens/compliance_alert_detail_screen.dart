import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';

class ComplianceAlertDetailScreen extends StatelessWidget {
  const ComplianceAlertDetailScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(title: 'Alert Detail', child: ListView(padding: const EdgeInsets.all(24), children: [
      const SurfaceCard(child: Text('⚠  Contractor classification risk\n\nHigh risk · Resolve by Jan 22\n\nJohn’s working arrangement may meet US employee-control tests, creating tax, benefits and penalty exposure.', style: TextStyle(color: Colors.red, height: 1.4))), const SizedBox(height: 12), const SurfaceCard(child: Text('Affected worker: John Doe\nCountry: United States 🇺🇸\nCurrent type: Contractor', style: TextStyle(height: 1.5))), const SizedBox(height: 16), const Text('Recommended steps', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 10), const SurfaceCard(child: Text('1. Review working relationship\n\n2. Complete classification questionnaire\n\n3. Convert to employee if required', style: TextStyle(height: 1.5, fontWeight: FontWeight.w700))), const SizedBox(height: 16), PrimaryButton(label: 'Resolve Classification', onPressed: () => Navigator.pop(context)),
    ]));
  }
}
