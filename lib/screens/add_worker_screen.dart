import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/worker.dart';
import '../services/app_state.dart';
import '../widgets/app_scaffold.dart';
import '../widgets/progress_bar.dart';

class AddWorkerScreen extends StatefulWidget {
  const AddWorkerScreen({super.key});

  @override
  State<AddWorkerScreen> createState() => _AddWorkerState();
}

class _AddWorkerState extends State<AddWorkerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _role = TextEditingController();
  final _salary = TextEditingController();
  final _password = TextEditingController();
  String _country = 'Bangladesh';
  String _engagementType = 'Employee';
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _role.dispose();
    _salary.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _addWorker() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await context.read<AppState>().addWorker(
            worker: Worker(
              id: 'worker-${DateTime.now().microsecondsSinceEpoch}',
              name: _name.text.trim(),
              email: _email.text.trim(),
              country: _country,
              role: _role.text.trim(),
              engagementType: _engagementType,
              complianceStatus: 'Compliant',
              salary: double.parse(_salary.text.replaceAll(',', '').trim()),
              documents: const [],
            ),
            temporaryPassword: _password.text,
          );
      if (mounted) Navigator.pop(context);
    } on AuthException catch (error) {
      setState(() => _error = error.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!context.watch<AppState>().isAdmin) {
      return const AppScaffold(
        title: 'Access restricted',
        child: Center(child: Text('Only a company admin can add workers.')),
      );
    }
    return AppScaffold(
      title: 'Add Worker',
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const MultiStepProgress(step: 3),
            const SizedBox(height: 18),
            const Text(
              'Create a worker profile',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const Text(
              'Worker can sign in using this email and temporary password.',
              style: TextStyle(color: muted),
            ),
            const SizedBox(height: 16),
            SurfaceCard(
              child: Column(
                children: [
                  _textField(_name, 'Legal Full Name', 'Enter full name'),
                  const SizedBox(height: 12),
                  _textField(
                    _email,
                    'Work Email',
                    'worker@company.com',
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => value == null ||
                            !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(value.trim())
                        ? 'Enter a valid email address.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _country,
                    decoration:
                        const InputDecoration(labelText: 'Country of Work'),
                    items: const [
                      'Bangladesh',
                      'Singapore',
                      'Germany',
                      'India',
                      'United States',
                    ]
                        .map((country) => DropdownMenuItem(
                              value: country,
                              child: Text(country),
                            ))
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _country = value ?? _country),
                  ),
                  const SizedBox(height: 12),
                  _textField(
                      _role, 'Role / Job Title', 'e.g. Product Designer'),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _engagementType,
                    decoration:
                        const InputDecoration(labelText: 'Engagement Type'),
                    items: const ['Employee', 'Contractor']
                        .map((type) =>
                            DropdownMenuItem(value: type, child: Text(type)))
                        .toList(),
                    onChanged: (value) => setState(
                      () => _engagementType = value ?? _engagementType,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    _salary,
                    'Monthly Salary (USD)',
                    'e.g. 180000',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      final salary = double.tryParse(
                        (value ?? '').replaceAll(',', '').trim(),
                      );
                      return salary == null || salary <= 0
                          ? 'Enter a salary greater than zero.'
                          : null;
                    },
                  ),
                  const SizedBox(height: 12),
                  _textField(
                    _password,
                    'Temporary Password (8+ characters)',
                    'Share this securely with the worker',
                    obscureText: true,
                    validator: (value) => value == null || value.length < 8
                        ? 'Use at least 8 characters.'
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const SurfaceCard(
              child: Text(
                'Payroll-ready status is a demo setting only. Verify local tax, worker classification, identity documents, and bank details before any real-world payroll.',
                style: TextStyle(color: muted, height: 1.4),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 14),
            PrimaryButton(
              label: _saving ? 'Adding worker…' : 'Add Worker & Account',
              onPressed: _saving ? () {} : _addWorker,
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField(
    TextEditingController controller,
    String label,
    String hint, {
    TextInputType? keyboardType,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) =>
      TextFormField(
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
