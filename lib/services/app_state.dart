import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/currency.dart';
import '../models/payroll_run.dart';
import '../models/worker.dart';

class AppState extends ChangeNotifier {
  static const _accountsKey = 'globalpay.accounts.v1';
  static const _workersKey = 'globalpay.workers.v1';
  static const _payrollsKey = 'globalpay.payrolls.v1';

  final List<Worker> _workers = [];
  final List<PayrollRun> _payrollRuns = [];
  final Map<String, _LocalAccount> _accounts = {};
  SharedPreferences? _preferences;

  _LocalAccount? _currentAccount;
  List<Worker> _draftWorkers = [];

  bool get signedIn => _currentAccount != null;
  bool get isAdmin => _currentAccount?.role == 'admin';
  bool get isWorker => _currentAccount?.role == 'worker';
  String get currentUserName => _currentAccount?.name ?? '';
  String get currentUserEmail => _currentAccount?.email ?? '';
  Worker? get currentWorkerProfile {
    final account = _currentAccount;
    final workerId = account?.workerId;
    if (account == null || workerId == null || workerId.isEmpty) return null;
    for (final worker in _workers) {
      if (worker.id == workerId && worker.companyId == account.companyId) {
        return worker;
      }
    }
    return null;
  }

  List<Worker> get workers => _workers
      .where((worker) => worker.companyId == _currentAccount?.companyId)
      .toList();
  List<PayrollRun> get payrollRuns => _payrollRuns
      .where((run) => run.companyId == _currentAccount?.companyId)
      .toList();
  List<Worker> get draftWorkers => List.unmodifiable(_draftWorkers);
  List<Worker> get payableWorkers => workers
      .where(
        (worker) =>
            worker.complianceStatus == 'Compliant' &&
            worker.hasVerifiedUsdSalary,
      )
      .toList();
  List<Worker> get workersRequiringUsdReview =>
      workers.where((worker) => !worker.hasVerifiedUsdSalary).toList();

  Future<void> initialize() async {
    _preferences = await SharedPreferences.getInstance();
    final accountsJson = _preferences!.getString(_accountsKey);
    final workersJson = _preferences!.getString(_workersKey);
    final payrollsJson = _preferences!.getString(_payrollsKey);

    if (accountsJson == null || workersJson == null) {
      _loadDemoData();
      await _save();
      return;
    }

    final accountList = jsonDecode(accountsJson) as List<dynamic>;
    for (final item in accountList) {
      final account = _LocalAccount.fromMap(
        Map<String, dynamic>.from(item as Map),
      );
      _accounts[account.email] = account;
    }
    _workers
      ..clear()
      ..addAll(
        (jsonDecode(workersJson) as List<dynamic>).map(
          (item) => Worker.fromMap(Map<String, dynamic>.from(item as Map)),
        ),
      );
    if (payrollsJson != null) {
      _payrollRuns
        ..clear()
        ..addAll(
          (jsonDecode(payrollsJson) as List<dynamic>).map(
            (item) =>
                PayrollRun.fromMap(Map<String, dynamic>.from(item as Map)),
          ),
        );
    }
    if (_upgradeDemoPayrollData()) {
      await _save();
    }
  }

  bool _upgradeDemoPayrollData() {
    const adminEmail = 'admin@globalpay.demo';
    const workerEmail = 'sarah@globalpay.demo';
    final admin = _accounts[adminEmail];
    final workerAccount = _accounts[workerEmail];
    if (admin == null ||
        admin.role != 'admin' ||
        admin.companyId != 'demo-company' ||
        admin.passwordHash != _hashPassword('Admin123!') ||
        workerAccount == null ||
        workerAccount.companyId != admin.companyId ||
        workerAccount.workerId != 'demo-sarah') {
      return false;
    }

    var changed = false;
    const legacyDemoSalaries = {
      'demo-sarah': ('SGD', 8200.0, 8200.0),
      'demo-hans': ('EUR', 5100.0, 5100.0),
      'demo-dev': ('INR', 180000.0, 4500.0),
    };
    for (var index = 0; index < _workers.length; index++) {
      final worker = _workers[index];
      final legacyDemo = legacyDemoSalaries[worker.id];
      if (worker.companyId != 'demo-company' ||
          legacyDemo == null ||
          worker.salaryCurrency != legacyDemo.$1 ||
          worker.salary != legacyDemo.$2) {
        continue;
      }
      _workers[index] = worker.copyWith(
        salary: legacyDemo.$3,
        salaryCurrency: appCurrencyCode,
        complianceStatus: 'Compliant',
      );
      changed = true;
    }

    final hasDemoJohn = _workers.any((worker) => worker.id == 'demo-john');
    final johnEmailInUse = _accounts.containsKey('john@company.com') ||
        _workers.any((worker) => worker.email.toLowerCase() == 'john@company.com');
    if (!hasDemoJohn && !johnEmailInUse) {
      _workers.add(
        const Worker(
          id: 'demo-john',
          companyId: 'demo-company',
          name: 'John Doe',
          email: 'john@company.com',
          country: 'United States',
          role: 'Sales Rep',
          engagementType: 'Employee',
          complianceStatus: 'Compliant',
          salary: 4500,
          documents: ['Passport.pdf', 'Tax_US.pdf'],
        ),
      );
      changed = true;
    }
    return changed;
  }

  void _loadDemoData() {
    final admin = _LocalAccount(
      name: 'GlobalPay Admin',
      email: 'admin@globalpay.demo',
      role: 'admin',
      passwordHash: _hashPassword('Admin123!'),
      companyId: 'demo-company',
    );
    final workerAccount = _LocalAccount(
      name: 'Sarah Chen',
      email: 'sarah@globalpay.demo',
      role: 'worker',
      passwordHash: _hashPassword('Worker123!'),
      companyId: 'demo-company',
      workerId: 'demo-sarah',
    );
    _accounts
      ..clear()
      ..[admin.email] = admin
      ..[workerAccount.email] = workerAccount;
    _workers
      ..clear()
      ..addAll([
        Worker(
          id: 'demo-sarah',
          companyId: 'demo-company',
          name: 'Sarah Chen',
          email: workerAccount.email,
          country: 'Singapore',
          role: 'Senior Developer',
          engagementType: 'Employee',
          complianceStatus: 'Compliant',
          salary: 8200,
          documents: const ['Tax_SG.pdf'],
        ),
        const Worker(
          id: 'demo-hans',
          companyId: 'demo-company',
          name: 'Hans Müller',
          email: 'hans@company.com',
          country: 'Germany',
          role: 'Product Manager',
          engagementType: 'Employee',
          complianceStatus: 'Compliant',
          salary: 5100,
          documents: ['Employment_Agreement.pdf'],
        ),
        const Worker(
          id: 'demo-dev',
          companyId: 'demo-company',
          name: 'Dev Patel',
          email: 'dev@company.com',
          country: 'India',
          role: 'QA Engineer',
          engagementType: 'Contractor',
          complianceStatus: 'Compliant',
          salary: 4500,
          documents: ['Contractor_Agreement.pdf'],
        ),
        const Worker(
          id: 'demo-john',
          companyId: 'demo-company',
          name: 'John Doe',
          email: 'john@company.com',
          country: 'United States',
          role: 'Sales Rep',
          engagementType: 'Employee',
          complianceStatus: 'Compliant',
          salary: 4500,
          documents: ['Passport.pdf', 'Tax_US.pdf'],
        ),
      ]);
    _payrollRuns.clear();
  }

  Future<void> signIn(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    final account = _accounts[normalizedEmail];
    if (account == null || account.passwordHash != _hashPassword(password)) {
      throw const AuthException('Email or password is incorrect.');
    }
    _currentAccount = account;
    notifyListeners();
  }

  Future<void> registerAdmin({
    required String name,
    required String email,
    required String password,
    required String company,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (_accounts.containsKey(normalizedEmail)) {
      throw const AuthException('An account already exists for this email.');
    }
    final account = _LocalAccount(
      name: name.trim(),
      email: normalizedEmail,
      role: 'admin',
      passwordHash: _hashPassword(password),
      companyId: 'company-${DateTime.now().microsecondsSinceEpoch}',
      companyName: company.trim(),
    );
    _accounts[account.email] = account;
    _currentAccount = account;
    await _save();
    notifyListeners();
  }

  Future<void> addWorker({
    required Worker worker,
    required String temporaryPassword,
  }) async {
    _requireAdmin();
    final email = worker.email.trim().toLowerCase();
    if (_accounts.containsKey(email) ||
        _workers.any((existing) => existing.email.toLowerCase() == email)) {
      throw const AuthException(
          'A worker account already exists for this email.');
    }
    final account = _LocalAccount(
      name: worker.name.trim(),
      email: email,
      role: 'worker',
      passwordHash: _hashPassword(temporaryPassword),
      workerId: worker.id,
      companyId: _currentAccount!.companyId,
    );
    _workers.add(
      Worker(
        id: worker.id,
        companyId: _currentAccount!.companyId,
        name: worker.name.trim(),
        email: email,
        country: worker.country,
        role: worker.role.trim(),
        engagementType: worker.engagementType,
        complianceStatus: worker.complianceStatus,
        salary: worker.salary,
        salaryCurrency: 'USD',
        documents: worker.documents,
      ),
    );
    _accounts[email] = account;
    await _save();
    notifyListeners();
  }

  void preparePayroll({Iterable<Worker>? workers}) {
    _requireAdmin();
    final eligibleWorkers = payableWorkers;
    if (workers == null) {
      _draftWorkers = List.unmodifiable(eligibleWorkers);
    } else {
      final selectedIds = workers
          .map((worker) => '${worker.companyId}:${worker.id}')
          .toSet();
      _draftWorkers = List.unmodifiable(
        eligibleWorkers.where(
          (worker) => selectedIds.contains('${worker.companyId}:${worker.id}'),
        ),
      );
    }
    if (_draftWorkers.isEmpty) {
      throw const AuthException(
        'There are no compliant workers with verified USD salaries. Review existing salaries or add a worker with a USD salary.',
      );
    }
    notifyListeners();
  }

  Future<PayrollRun> processPayroll() async {
    _requireAdmin();
    if (_draftWorkers.isEmpty) {
      throw const AuthException('Review the payroll before confirming it.');
    }
    final run = PayrollRun(
      id: 'GP-${DateTime.now().millisecondsSinceEpoch}',
      companyId: _currentAccount!.companyId,
      createdAt: DateTime.now(),
      status: 'Demo processed',
      payments: _draftWorkers
          .map(
            (worker) => PayrollPayment(
              workerId: worker.id,
              workerName: worker.name,
              workerEmail: worker.email.toLowerCase(),
              country: worker.country,
              currency: appCurrencyCode,
              amount: worker.salary,
              status: 'Paid (demo)',
            ),
          )
          .toList(),
    );
    _payrollRuns.insert(0, run);
    _draftWorkers = [];
    await _save();
    notifyListeners();
    return run;
  }

  List<PayrollPayment> get currentWorkerPayments {
    final workerId = _currentAccount?.workerId;
    if (workerId == null || workerId.isEmpty) return [];
    return _payrollRuns
        .where((run) => run.companyId == _currentAccount?.companyId)
        .expand((run) => run.payments)
        .where((payment) => payment.workerId == workerId)
        .toList();
  }

  Future<void> updateWorkerSalaryUsd({
    required String workerId,
    required double salary,
  }) async {
    _requireAdmin();
    if (!salary.isFinite || salary <= 0) {
      throw const AuthException('Enter a valid USD salary greater than zero.');
    }
    final index = _workers.indexWhere(
      (worker) =>
          worker.id == workerId &&
          worker.companyId == _currentAccount!.companyId,
    );
    if (index == -1) {
      throw const AuthException('Worker could not be found in your company.');
    }
    _workers[index] = _workers[index].copyWith(
      salary: salary,
      salaryCurrency: appCurrencyCode,
    );
    await _save();
    notifyListeners();
  }

  Future<void> signOut() async {
    _currentAccount = null;
    _draftWorkers = [];
    notifyListeners();
  }

  void _requireAdmin() {
    if (!isAdmin) {
      throw const AuthException(
          'Only a company admin can perform this action.');
    }
  }

  Future<void> _save() async {
    final preferences = _preferences;
    if (preferences == null) {
      throw StateError('App state has not been initialized.');
    }
    await preferences.setString(
      _accountsKey,
      jsonEncode(_accounts.values.map((account) => account.toMap()).toList()),
    );
    await preferences.setString(
      _workersKey,
      jsonEncode(_workers.map((worker) => worker.toMap()).toList()),
    );
    await preferences.setString(
      _payrollsKey,
      jsonEncode(_payrollRuns.map((run) => run.toMap()).toList()),
    );
  }

  static String _hashPassword(String password) =>
      sha256.convert(utf8.encode('globalpay-demo-v1:$password')).toString();
}

class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => message;
}

class _LocalAccount {
  final String name;
  final String email;
  final String role;
  final String passwordHash;
  final String companyId;
  final String companyName;
  final String workerId;

  const _LocalAccount({
    required this.name,
    required this.email,
    required this.role,
    required this.passwordHash,
    required this.companyId,
    this.companyName = '',
    this.workerId = '',
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'role': role,
        'passwordHash': passwordHash,
        'companyId': companyId,
        'companyName': companyName,
        'workerId': workerId,
      };

  factory _LocalAccount.fromMap(Map<String, dynamic> map) => _LocalAccount(
        name: map['name'] as String? ?? '',
        email: (map['email'] as String? ?? '').toLowerCase(),
        role: map['role'] as String? ?? 'worker',
        passwordHash: map['passwordHash'] as String? ?? '',
        companyId: map['companyId'] as String? ?? '',
        companyName: map['companyName'] as String? ?? '',
        workerId: map['workerId'] as String? ?? '',
      );
}
