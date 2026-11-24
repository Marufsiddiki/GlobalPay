import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../widgets/app_scaffold.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await context.read<AppState>().signIn(_email.text, _password.text);
      if (!mounted) return;
      final route =
          context.read<AppState>().isWorker ? '/worker-portal' : '/dashboard';
      Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
    } on AuthException catch (error) {
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEAFBF4),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          children: [
            TextButton.icon(
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.chevron_left, color: ink),
              label: const Text('Back', style: TextStyle(color: ink)),
            ),
            const SizedBox(height: 34),
            const Text(
              'Welcome back',
              style: TextStyle(
                  fontSize: 32, fontWeight: FontWeight.w800, color: ink),
            ),
            const SizedBox(height: 8),
            const Text(
              'Sign in to your GlobalPay workspace.',
              style: TextStyle(color: muted, fontSize: 15),
            ),
            const SizedBox(height: 24),
            SurfaceCard(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Email Address'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      decoration:
                          const InputDecoration(hintText: 'name@company.com'),
                      validator: (value) => value == null ||
                              !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                  .hasMatch(value.trim())
                          ? 'Enter a valid email address.'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('Password'),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _password,
                      obscureText: _hidePassword,
                      decoration: InputDecoration(
                        suffixIcon: IconButton(
                          icon: Icon(_hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined),
                          onPressed: () =>
                              setState(() => _hidePassword = !_hidePassword),
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Enter your password.'
                          : null,
                      onFieldSubmitted: (_) => _signIn(),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 12),
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                    ],
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, '/forgot-password'),
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    PrimaryButton(
                      label: _loading ? 'Signing in…' : 'Sign In',
                      onPressed: _loading ? () {} : _signIn,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const SurfaceCard(
              child: Text(
                'Demo accounts\nAdmin: admin@globalpay.demo / Admin123!\nWorker: sarah@globalpay.demo / Worker123!',
                style: TextStyle(height: 1.6, color: muted),
              ),
            ),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pushNamed(context, '/sign-up'),
                child: const Text('New to GlobalPay? Create an admin account'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
