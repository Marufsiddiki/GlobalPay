import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      appBar: AppBar(title: const Text('Reset Password')),
      body: ListView(padding: const EdgeInsets.all(24), children: [
        const Text('Forget password', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        const Text('Enter your Workmail', style: TextStyle(color: muted)),
        const SizedBox(height: 10),
        SurfaceCard(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Work Email'),
          const SizedBox(height: 8),
          const TextField(decoration: InputDecoration(hintText: 'maruf@company.com')),
          const SizedBox(height: 10),
          PrimaryButton(label: 'Send Reset Link', onPressed: () => Navigator.pop(context)),
        ])),
        Center(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('Return to Sign In', style: TextStyle(color: green, fontWeight: FontWeight.w700)))),
      ],),
    );
  }
}
