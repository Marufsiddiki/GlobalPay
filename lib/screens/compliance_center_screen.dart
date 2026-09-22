import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';

class ComplianceCenterScreen extends StatelessWidget {
  const ComplianceCenterScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(title: 'Compliance Center', currentTab: 3, actions: [TextButton(onPressed: () {}, child: const Text('Filters'))], child: ListView(padding: const EdgeInsets.all(24), children: [
      Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(22)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('COMPANY COMPLIANCE SCORE', style: TextStyle(color: Color(0xFF63DDB8))), SizedBox(height: 12), Text('92 /100', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)), SizedBox(height: 8), Text('41 compliant · 2 reviews · 2 actions', style: TextStyle(color: Colors.white))])), const SizedBox(height: 20), const Text('Priority alerts', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 10),
      SurfaceCard(child: ListTile(leading: const Icon(Icons.warning_amber, color: Colors.red), title: const Text('Contractor classification risk'), subtitle: const Text('John Doe · United States'), onTap: () => Navigator.pushNamed(context, '/compliance-alert'))), const SizedBox(height: 12), const SurfaceCard(child: ListTile(leading: Icon(Icons.schedule), title: Text('Work permit expires soon'), subtitle: Text('Sarah Chen · Singapore'))), const SizedBox(height: 20), const Text('Country status', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 10), const SurfaceCard(child: Text('🇩🇪 Germany · 8 workers · All requirements met')), const SizedBox(height: 10), const SurfaceCard(child: Text('🇮🇳 India · 7 workers · 1 review required')),
    ]));
  }
}
