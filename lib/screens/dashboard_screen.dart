import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Dashboard',
      showBack: false,
      currentTab: 0,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('Welcome back,', style: TextStyle(color: muted)),
          const Text('Hello, Maruf', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 26),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: green, borderRadius: BorderRadius.circular(22)),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('TOTAL PAYROLL VALUE', style: TextStyle(color: Color(0xFF63DDB8), letterSpacing: 1)),
              SizedBox(height: 14),
              Text('\$125,400.00 USD', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.w800)),
              SizedBox(height: 4),
              Text('Next payroll run scheduled in 3 days', style: TextStyle(color: Color(0xFFC4E7DC))),
              Divider(color: Color(0x3363DDB8), height: 28),
              Text('45 Employees     8 Countries', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ]),
          ),
          const SizedBox(height: 22),
          const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          Row(children: [
            Expanded(child: action(context, 'Run Payroll', Icons.play_arrow, '/run-payroll')),
            Expanded(child: action(context, 'Add Worker', Icons.person_add_alt_1, '/add-worker')),
            Expanded(child: action(context, 'View Reports', Icons.description_outlined, '/analytics')),
          ]),
          const SizedBox(height: 18),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.w700)),
            TextButton(onPressed: () => Navigator.pushNamed(context, '/workers'), child: const Text('See All')),
          ]),
          for (final row in ['🇸🇬  Singapore Cycle       \$18,450.00', '🇩🇪  Germany Office         €24,500.00', '🇺🇸  US Contractor Run      \$42,800.00'])
            Padding(padding: const EdgeInsets.only(bottom: 8), child: SurfaceCard(padding: const EdgeInsets.all(14), child: Text(row, style: const TextStyle(fontWeight: FontWeight.w700)))),
        ],
      ),
    );
  }

  Widget action(BuildContext context, String label, IconData icon, String route) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: OutlinedButton(onPressed: () => Navigator.pushNamed(context, route), child: Column(children: [Icon(icon, color: green), const SizedBox(height: 4), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: ink))])),
      );
}
