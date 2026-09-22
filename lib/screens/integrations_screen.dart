import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';

class IntegrationsScreen extends StatelessWidget {
  const IntegrationsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(title: 'Integrations', child: ListView(padding: const EdgeInsets.all(24), children: [const Text('Connect Maruf Company’s HR and accounting tools to keep worker and payroll data in sync.', style: TextStyle(color: muted)), const SizedBox(height: 14), const Text('Connected', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 10), const SurfaceCard(child: Text('QuickBooks Online\nConnected · Synced 8 min ago\n\nBambooHR\nConnected · Synced today')), const SizedBox(height: 20), const Text('Available integrations', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 10), const SurfaceCard(child: Text('Xero     Connect\n\nWorkday     Connect\n\nSlack     Connect')), const SizedBox(height: 14), const SurfaceCard(child: Text('Automatic sync is on\n\nConnected systems sync daily at 2:00 AM UTC.', style: TextStyle(color: green))) ]));
  }
}
