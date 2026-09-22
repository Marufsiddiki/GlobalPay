import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../widgets/app_scaffold.dart';

class WorkersScreen extends StatelessWidget {
  const WorkersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final workers = context.watch<AppState>().workers;
    return AppScaffold(title: 'Workers', currentTab: 1, actions: [TextButton(onPressed: () => Navigator.pushNamed(context, '/add-worker'), child: const Text('+ Add'))], child: ListView(padding: const EdgeInsets.all(24), children: [
      const TextField(decoration: InputDecoration(hintText: 'Search workers or documents', prefixIcon: Icon(Icons.search))), const SizedBox(height: 18), const Text('Employees & contractors', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 10),
      ...workers.map((worker) => Padding(padding: const EdgeInsets.only(bottom: 12), child: InkWell(onTap: () => Navigator.pushNamed(context, '/worker-details', arguments: worker), child: SurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [FlagLabel(country: worker.country), const SizedBox(height: 12), Text(worker.name, style: const TextStyle(fontWeight: FontWeight.w800)), Text('${worker.role} · ${worker.engagementType}', style: const TextStyle(color: muted, fontSize: 12)), Text(worker.country, style: const TextStyle(color: Color(0xFF9AA1AC), fontSize: 11)), const SizedBox(height: 10), StatusBadge(text: worker.complianceStatus, warning: worker.complianceStatus != 'Compliant')]))))),
    ]));
  }
}
