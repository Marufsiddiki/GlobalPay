import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../widgets/app_scaffold.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _company = TextEditingController();
  final _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _company.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _createAccount() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AppState>().registerAdmin(
            name: _name.text,
            email: _email.text,
            password: _password.text,
            company: _company.text,
          );
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/dashboard', (_) => false);
      }
    } on AuthException catch (error) {
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mint,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back, color: ink),
              label: const Text('Back', style: TextStyle(color: ink)),
            ),
            const SizedBox(height: 32),
            const Text(
              'Create your admin account',
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.w800, color: ink),
            ),
            const SizedBox(height: 8),
            const Text(
              'This account manages workers and payroll for your company.',
              style: TextStyle(color: muted),
            ),
            const SizedBox(height: 18),
            SurfaceCard(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _field(_name, 'Full Name', 'Enter your name'),
                    const SizedBox(height: 14),
                    _field(
                      _email,
                      'Work Email',
                      'name@company.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) => value == null ||
                              !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                  .hasMatch(value.trim())
                          ? 'Enter a valid email address.'
                          : null,
                    ),
                    const SizedBox(height: 14),
                    _field(_company, 'Company', 'Company name'),
                    const SizedBox(height: 14),
                    _field(
                      _password,
                      'Password (at least 8 characters)',
                      'Create a password',
                      obscureText: true,
                      validator: (value) => value == null || value.length < 8
                          ? 'Use at least 8 characters.'
                          : null,
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                    const SizedBox(height: 18),
                    PrimaryButton(
                      label: _loading ? 'Creating account…' : 'Create Account',
                      onPressed: _loading ? () {} : _createAccount,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Demo mode: account data is stored on this device only.',
              textAlign: TextAlign.center,
              style: TextStyle(color: muted, fontSize: 12),
            ),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, '/sign-in'),
                child: const Text('Already have an account? Sign In'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label,
    String hint, {
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(labelText: label, hintText: hint),
      validator: validator ??
          (value) => value == null || value.trim().isEmpty
              ? 'This field is required.'
              : null,
    );
  }
}
