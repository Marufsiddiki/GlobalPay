import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(title: 'Analytics', child: ListView(padding: const EdgeInsets.all(24), children: [OutlinedButton(onPressed: () {}, child: const Text('Last 6 Months')), const SizedBox(height: 70), SurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('AVG MONTHLY SPEND', style: TextStyle(color: muted, fontSize: 12)), const Text('\$118,200.00 USD', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)), const SizedBox(height: 24), Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceAround, children: [for (final height in <double>[24, 38, 18, 44, 50, 56]) Container(width: 20, height: height, decoration: BoxDecoration(color: const Color(0xFF00966F), borderRadius: BorderRadius.circular(4)))])])), const SizedBox(height: 20), const SurfaceCard(child: Text('Headcount by Country\n\nUSA                         18\nSingapore                   12\nGermany                      8\nIndia                         7', style: TextStyle(height: 1.6, fontWeight: FontWeight.w600))), const SizedBox(height: 20), const Text('Regional Breakdown', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 10), Row(children: [Expanded(child: SurfaceCard(child: const Text('NORTH AMERICA\n\$58,400\n+4.2% from last month'))), const SizedBox(width: 10), Expanded(child: SurfaceCard(child: const Text('APAC REGION\n\$36,200\nStable')))])]));
  }
}
