import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';

class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      body: SafeArea(child: ListView(padding: const EdgeInsets.all(24), children: [
        TextButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: ink), label: const Text('Back', style: TextStyle(color: ink))),
        const SizedBox(height: 68),
        const Text('Welcome back', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: ink)),
        const SizedBox(height: 6),
        const Text('Access your GlobalPay compliance & dashboard', style: TextStyle(color: muted)),
        const SizedBox(height: 24),
        SurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Email Address'), const SizedBox(height: 8), const TextField(decoration: InputDecoration(hintText: 'maruf@company.com')),
          const SizedBox(height: 20), const Text('Password'), const SizedBox(height: 8), const TextField(obscureText: true),
          Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.pushNamed(context, '/forgot-password'), child: const Text('Forgot password?', style: TextStyle(color: green)))),
          PrimaryButton(label: 'Sign In', onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (_) => false)),
          const SizedBox(height: 22), const Center(child: Text('or continue with', style: TextStyle(color: muted))), const SizedBox(height: 14),
          Row(children: [Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Google'))), const SizedBox(width: 12), Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Apple')))]),
        ])),
        const SizedBox(height: 76),
        Center(child: TextButton(onPressed: () => Navigator.pushNamed(context, '/sign-up'), child: const Text('New to GlobalPay? Sign Up', style: TextStyle(color: green)))),
      ])),
    );
  }
}
