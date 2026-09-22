import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';

class DocumentsCenterScreen extends StatelessWidget {
  const DocumentsCenterScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final groups = {'Identity documents': ['Passport.pdf · Md. Maruf Siddiki · Verified', 'National_ID.pdf · Aisha Rahman · Verify'], 'Tax documents': ['Tax_SG.pdf · Sarah Chen · Verified', 'W-8BEN.pdf · John Doe · 16 days'], 'Contracts': ['Employment_Agreement.pdf · Hans Müller · Signed', 'Contractor_Agreement.pdf · Dev Patel · Review']};
    return AppScaffold(title: 'Documents', currentTab: 2, actions: [TextButton(onPressed: () {}, child: const Text('+ Upload'))], child: ListView(padding: const EdgeInsets.all(24), children: [const TextField(decoration: InputDecoration(hintText: 'Search workers or documents', prefixIcon: Icon(Icons.search))), const SizedBox(height: 18), for (final group in groups.entries) ...[Text(group.key, style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 10), for (final doc in group.value) Padding(padding: const EdgeInsets.only(bottom: 10), child: SurfaceCard(child: Text(doc, style: const TextStyle(fontWeight: FontWeight.w700)))), const SizedBox(height: 8)]]));
  }
}
