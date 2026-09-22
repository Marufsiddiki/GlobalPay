import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      body: SafeArea(child: ListView(padding: const EdgeInsets.all(24), children: [
        TextButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back, color: ink), label: const Text('Back', style: TextStyle(color: ink))),
        const SizedBox(height: 48), const Text('Create your account', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: ink)),
        const SizedBox(height: 6), const Text('Set up the Maruf company workspace for\nglobal payroll.', style: TextStyle(color: muted)), const SizedBox(height: 18),
        SurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          for (final field in ['Full Name', 'Work Email', 'Company', 'Password']) ...[Text(field), const SizedBox(height: 7), TextField(obscureText: field == 'Password'), const SizedBox(height: 18)],
          PrimaryButton(label: 'Create Account', onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (_) => false)),
        ])),
        const SizedBox(height: 16), Center(child: TextButton(onPressed: () => Navigator.pushNamed(context, '/sign-in'), child: const Text('Already have an account? Sign In', style: TextStyle(color: green)))),
      ])),
    );
  }
}
