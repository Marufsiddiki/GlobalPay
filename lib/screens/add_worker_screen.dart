import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../models/document.dart';
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
  String? _uploadingType;
  final Map<String, PayrollDocument> _uploadedDocuments = {};
  bool _saving = false;

  static const _documentTypes = ['National ID', 'Tax Form', 'Contract'];
  static const _allowedExtensions = ['pdf', 'png', 'jpg', 'jpeg'];

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
              documents: _uploadedDocuments.values
                  .map((document) => document.name)
                  .toList(),
              uploadedDocuments: _uploadedDocuments.values.toList(),
            ),
            temporaryPassword: _password.text,
          );
      if (mounted) Navigator.pop(context);
    } on AuthException catch (error) {
      setState(() => _error = error.message);
    } on PlatformException catch (error) {
      setState(() {
        _error =
            'Could not save the worker and documents: ${error.message ?? error.code}';
      });
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDocument(String type) async {
    setState(() {
      _uploadingType = type;
      _error = null;
    });
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: _allowedExtensions,
      );
      if (!mounted) return;
      if (result.isEmpty) return;
      final file = result.single;
      final bytes = await file.readAsBytes();
      if (!mounted) return;
      if (bytes.isEmpty) {
        setState(() => _error = 'Could not read the selected file.');
        return;
      }
      final extension = file.extension?.toLowerCase();
      if (extension == null || !_allowedExtensions.contains(extension)) {
        setState(() => _error = 'Choose a PDF, PNG, or JPG file.');
        return;
      }
      final document = PayrollDocument(
        id: 'document-${DateTime.now().microsecondsSinceEpoch}',
        name: file.name,
        type: type,
        mimeType: _mimeType(extension),
        contentBase64: base64Encode(bytes),
        uploadedAt: DateTime.now(),
      );
      setState(() => _uploadedDocuments[type] = document);
    } on PlatformException catch (error) {
      if (mounted) {
        setState(() {
          _error = 'Could not select the file: ${error.message ?? error.code}';
        });
      }
    } finally {
      if (mounted) setState(() => _uploadingType = null);
    }
  }

  String _mimeType(String extension) => switch (extension) {
        'pdf' => 'application/pdf',
        'png' => 'image/png',
        _ => 'image/jpeg',
      };

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
            SurfaceCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Secure documents',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Attach a National ID, Tax Form, or Contract (PDF, PNG, JPG).',
                    style: TextStyle(color: muted, fontSize: 13),
                  ),
                  const SizedBox(height: 10),
                  for (final type in _documentTypes) _documentPicker(type),
                  const SizedBox(height: 4),
                  const Text(
                    'Documents are stored with this local demo profile. Do not upload real identity or tax documents.',
                    style: TextStyle(color: muted, fontSize: 12, height: 1.4),
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

  Widget _documentPicker(String type) {
    final document = _uploadedDocuments[type];
    final isUploading = _uploadingType == type;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed:
                  _saving || isUploading ? null : () => _pickDocument(type),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                alignment: Alignment.centerLeft,
                shape: const StadiumBorder(),
                side: BorderSide(
                  color: document == null ? const Color(0xFFE2E4E7) : green,
                ),
                backgroundColor: document == null ? Colors.white : mint,
              ),
              child: Row(
                children: [
                  Icon(
                    document == null
                        ? Icons.add_circle_outline
                        : Icons.check_circle_outline,
                    color: document == null ? muted : green,
                    size: 19,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isUploading
                          ? 'Selecting $type...'
                          : document?.name ?? 'Upload $type',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: document == null ? ink : green,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (document == null)
                    const Icon(Icons.upload_file_outlined,
                        color: muted, size: 19),
                ],
              ),
            ),
          ),
          if (document != null)
            IconButton(
              tooltip: 'Remove $type',
              onPressed: _saving
                  ? null
                  : () => setState(() => _uploadedDocuments.remove(type)),
              icon: const Icon(Icons.close, size: 18),
              visualDensity: VisualDensity.compact,
            ),
        ],
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
