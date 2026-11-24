import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/currency.dart';
import '../models/payroll_run.dart';
import '../models/worker.dart';
import '../services/app_state.dart';
import '../widgets/app_scaffold.dart';

class WorkerPortalScreen extends StatefulWidget {
  const WorkerPortalScreen({super.key});

  @override
  State<WorkerPortalScreen> createState() => _WorkerPortalScreenState();
}

class _WorkerPortalScreenState extends State<WorkerPortalScreen> {
  int _selectedTab = 0;

  static const _titles = [
    'My Home',
    'My Salary',
    'Payments',
    'My Documents',
    'My Profile',
  ];

  Future<void> _signOut(AppState state) async {
    await state.signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/welcome', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (!state.isWorker) {
      return Scaffold(
        body: Center(
          child: FilledButton(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              '/sign-in',
              (_) => false,
            ),
            child: const Text('Sign in as a worker'),
          ),
        ),
      );
    }

    final worker = state.currentWorkerProfile;
    final records = _paymentRecords(state, worker);
    final pages = [
      _homePage(worker, records),
      _salaryPage(worker, records),
      _paymentsPage(records),
      _documentsPage(worker),
      _profilePage(worker, state.currentUserEmail),
    ];

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          _titles[_selectedTab],
          style: const TextStyle(fontWeight: FontWeight.w700, color: ink),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () => _signOut(state),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedTab,
          children: pages,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (index) => setState(() => _selectedTab = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: green,
        unselectedItemColor: muted,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            label: 'Salary',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            label: 'Payments',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.description_outlined),
            label: 'Documents',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  List<_WorkerPaymentRecord> _paymentRecords(
    AppState state,
    Worker? worker,
  ) {
    if (worker == null) return [];
    return [
      for (final run in state.payrollRuns)
        for (final payment in run.payments)
          if (payment.workerId == worker.id)
            _WorkerPaymentRecord(run: run, payment: payment),
    ]..sort((a, b) => b.run.createdAt.compareTo(a.run.createdAt));
  }

  Widget _homePage(
    Worker? worker,
    List<_WorkerPaymentRecord> records,
  ) {
    if (worker == null) {
      return _emptyPage(
        icon: Icons.person_search_outlined,
        title: 'Worker profile unavailable',
        message:
            'Your account is signed in, but a worker profile could not be found. Please contact your company administrator.',
      );
    }

    final latest = records.isEmpty ? null : records.first;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      children: [
        SurfaceCard(
          child: Row(
            children: [
              ProfileAvatar(size: 58, name: worker.name),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome back', style: TextStyle(color: muted)),
                    const SizedBox(height: 3),
                    Text(
                      worker.name,
                      style: const TextStyle(
                        color: ink,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${worker.role} · ${worker.engagementType}',
                      style: const TextStyle(color: muted),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${flagEmoji(worker.country)} ${worker.country}',
                      style: const TextStyle(color: muted, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _summaryCard(
                icon: Icons.payments_outlined,
                label: 'Monthly salary',
                value: worker.hasVerifiedUsdSalary
                    ? formatUsd(worker.salary)
                    : 'USD review needed',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryCard(
                icon: Icons.receipt_long_outlined,
                label: 'Latest payment',
                value: latest?.payment.status ?? 'No records',
                detail: latest == null ? null : _date(latest.run.createdAt),
              ),
            ),
          ],
        ),
        const SizedBox(height: 22),
        _sectionTitle('Employment information'),
        const SizedBox(height: 10),
        SurfaceCard(
          child: Column(
            children: [
              _infoRow('Job title', worker.role),
              _infoRow('Work type', worker.engagementType),
              _infoRow('Country', worker.country),
              _infoRow('Verification', worker.complianceStatus, last: true),
              const SizedBox(height: 8),
              const Text(
                'Company name and joining date are not available in your current profile.',
                style: TextStyle(color: muted, fontSize: 12, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        _sectionTitle('Recent payments'),
        const SizedBox(height: 10),
        if (records.isEmpty)
          _emptyCard(
            icon: Icons.receipt_long_outlined,
            title: 'No payment records yet',
            message:
                'Payments will appear here after your company records a payroll for you.',
          )
        else
          for (final record in records.take(3)) ...[
            _paymentCard(record),
            const SizedBox(height: 10),
          ],
        const SizedBox(height: 12),
        _sectionTitle('Quick access'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _quickAction('Salary', Icons.account_balance_wallet_outlined, 1),
            _quickAction('Payments', Icons.receipt_long_outlined, 2),
            _quickAction('Documents', Icons.description_outlined, 3),
            _quickAction('Profile', Icons.person_outline, 4),
          ],
        ),
        const SizedBox(height: 18),
        _emptyCard(
          icon: Icons.notifications_none,
          title: 'No notifications',
          message: 'There are no notifications available for your account.',
        ),
      ],
    );
  }

  Widget _salaryPage(
    Worker? worker,
    List<_WorkerPaymentRecord> records,
  ) {
    if (worker == null) {
      return _emptyPage(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Salary information unavailable',
        message: 'Your worker profile could not be found.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  color: green, size: 28),
              const SizedBox(height: 12),
              const Text('Recorded salary', style: TextStyle(color: muted)),
              const SizedBox(height: 6),
              if (worker.hasVerifiedUsdSalary)
                Text(
                  formatUsd(worker.salary),
                  style: const TextStyle(
                    color: ink,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                )
              else
                const Text(
                  'USD verification required',
                  style: TextStyle(
                    color: Colors.deepOrange,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              const Text('/ month', style: TextStyle(color: muted)),
              const Divider(height: 28),
              _infoRow('Application currency', 'USD'),
              _infoRow('Payment frequency', 'Monthly'),
              _infoRow('Salary changes', 'Contact your company admin',
                  last: true),
            ],
          ),
        ),
        if (!worker.hasVerifiedUsdSalary) ...[
          const SizedBox(height: 14),
          const SurfaceCard(
            child: Text(
              'Your salary was saved before the USD standard. The amount is hidden to avoid mislabeling it. Ask your company admin to verify and record your salary in USD; no automatic conversion is applied.',
              style: TextStyle(color: muted, height: 1.45),
            ),
          ),
        ],
        const SizedBox(height: 14),
        const SurfaceCard(
          child: Text(
            'Tax, other deductions, gross salary and net salary are not stored in the available worker profile, so they cannot be shown here.',
            style: TextStyle(color: muted, height: 1.45),
          ),
        ),
        const SizedBox(height: 22),
        _sectionTitle('Salary history'),
        const SizedBox(height: 10),
        if (records.isEmpty)
          _emptyCard(
            icon: Icons.history,
            title: 'No salary history',
            message: 'No payroll records have been recorded for you yet.',
          )
        else
          for (final record in records) ...[
            _paymentCard(record),
            const SizedBox(height: 10),
          ],
      ],
    );
  }

  Widget _paymentsPage(List<_WorkerPaymentRecord> records) {
    if (records.isEmpty) {
      return _emptyPage(
        icon: Icons.receipt_long_outlined,
        title: 'No payment history yet',
        message:
            'When a payroll record is created for your account, its date, amount, currency and status will appear here.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          '${records.length} ${records.length == 1 ? 'record' : 'records'}',
          style: const TextStyle(color: muted),
        ),
        const SizedBox(height: 12),
        for (final record in records) ...[
          _paymentCard(record, showId: true),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _documentsPage(Worker? worker) {
    final documents = worker?.uploadedDocuments ?? const [];
    if (documents.isEmpty) {
      return _emptyPage(
        icon: Icons.folder_open_outlined,
        title: 'No documents available',
        message: 'Your company has not attached any documents to your profile yet.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Documents shared with your profile',
          style: TextStyle(color: muted),
        ),
        const SizedBox(height: 12),
        for (final document in documents)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SurfaceCard(
              child: Row(
                children: [
                  const Icon(Icons.description_outlined, color: green),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: ink,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${document.type} · Uploaded ${_date(document.uploadedAt)}',
                          style: const TextStyle(color: muted, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const StatusBadge(text: 'Uploaded'),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _profilePage(Worker? worker, String email) {
    if (worker == null) {
      return _emptyPage(
        icon: Icons.person_outline,
        title: 'Profile unavailable',
        message:
            'Your worker profile could not be found. Please contact your company administrator.',
      );
    }
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SurfaceCard(
          child: Column(
            children: [
              ProfileAvatar(size: 82, name: worker.name),
              const SizedBox(height: 12),
              Text(
                worker.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: ink,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(email, style: const TextStyle(color: muted)),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _sectionTitle('Personal information'),
        const SizedBox(height: 10),
        SurfaceCard(
          child: Column(
            children: [
              _infoRow('Full name', worker.name),
              _infoRow('Email', email),
              _infoRow('Country', worker.country),
              const _InfoRow(
                label: 'Phone and address',
                value: 'Not provided',
              ),
              const _InfoRow(
                label: 'Date of birth',
                value: 'Not provided',
                last: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        _sectionTitle('Employment information'),
        const SizedBox(height: 10),
        SurfaceCard(
          child: Column(
            children: [
              _infoRow('Job title', worker.role),
              _infoRow('Employment type', worker.engagementType),
              _infoRow('Country', worker.country),
              _infoRow('Verification', worker.complianceStatus),
              const _InfoRow(
                label: 'Company, employee ID, joining date',
                value: 'Not provided',
                last: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        const SurfaceCard(
          child: Text(
            'This profile is view-only. Contact your company administrator to request a change. Salary and employment records cannot be edited here.',
            style: TextStyle(color: muted, height: 1.45),
          ),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required IconData icon,
    required String label,
    required String value,
    String? detail,
  }) {
    return SurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: green, size: 22),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(color: muted, fontSize: 12)),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: ink,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (detail != null) ...[
            const SizedBox(height: 4),
            Text(detail, style: const TextStyle(color: muted, fontSize: 12)),
          ],
        ],
      ),
    );
  }

  Widget _paymentCard(
    _WorkerPaymentRecord record, {
    bool showId = false,
  }) {
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: mint,
                child: Icon(Icons.payments_outlined, color: green),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.payment.currency == appCurrencyCode
                          ? formatUsd(record.payment.amount)
                          : 'Amount withheld',
                      style: const TextStyle(
                        color: ink,
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      record.payment.currency == appCurrencyCode
                          ? _date(record.run.createdAt)
                          : 'USD verification required · ${_date(record.run.createdAt)}',
                      style: const TextStyle(color: muted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              StatusBadge(
                text: record.payment.status,
                warning: !_isPaid(record.payment.status),
              ),
            ],
          ),
          if (showId) ...[
            const Divider(height: 24),
            _infoRow('Payroll reference', record.run.id),
            _infoRow('Payroll status', record.run.status, last: true),
          ],
        ],
      ),
    );
  }

  Widget _emptyPage({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 50),
        _emptyCard(icon: icon, title: title, message: message),
      ],
    );
  }

  Widget _emptyCard({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return SurfaceCard(
      child: Column(
        children: [
          Icon(icon, color: green, size: 32),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: ink,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: muted, height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: const TextStyle(
          color: ink,
          fontSize: 17,
          fontWeight: FontWeight.w800,
        ),
      );

  Widget _infoRow(String label, String value, {bool last = false}) {
    return _InfoRow(label: label, value: value, last: last);
  }

  Widget _quickAction(String label, IconData icon, int tab) {
    return ActionChip(
      avatar: Icon(icon, size: 18, color: green),
      label: Text(label),
      onPressed: () => setState(() => _selectedTab = tab),
    );
  }

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  bool _isPaid(String status) => status.toLowerCase().contains('paid');
}

class _WorkerPaymentRecord {
  final PayrollRun run;
  final PayrollPayment payment;

  const _WorkerPaymentRecord({required this.run, required this.payment});
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool last;

  const _InfoRow({
    required this.label,
    required this.value,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 11),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(label, style: const TextStyle(color: muted)),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  style: const TextStyle(
                    color: ink,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (!last) const SizedBox(height: 11),
        ],
      ),
    );
  }
}
