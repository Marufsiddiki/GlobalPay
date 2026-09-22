import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFF004A38),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(children: [
              const Spacer(),
              Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFF096B50), borderRadius: BorderRadius.circular(18)), child: const Icon(Icons.account_balance_wallet_outlined, color: Colors.white, size: 48)),
              const SizedBox(height: 22),
              const Text('CROSS-BORDER PAYROLL', style: TextStyle(color: Colors.white, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
              const SizedBox(height: 36),
              const Text('GlobalPay', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w800)),
              const SizedBox(height: 14),
              const Text('Pay, manage, and stay compliant with\ninternational teams and contractors in one\nunified workspace.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFE0F1EB), fontSize: 16, height: 1.5)),
              const Spacer(),
              SizedBox(width: double.infinity, height: 52, child: FilledButton(onPressed: () => Navigator.pushNamed(context, '/sign-up'), style: FilledButton.styleFrom(backgroundColor: Colors.white, foregroundColor: ink, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text('Get Started', style: TextStyle(fontWeight: FontWeight.w700)))),
              const SizedBox(height: 20),
              TextButton(onPressed: () => Navigator.pushNamed(context, '/sign-in'), child: const Text('Already have an account?  Sign In', style: TextStyle(color: Colors.white))),
              const SizedBox(height: 28),
            ]),
          ),
        ),
      );
}
