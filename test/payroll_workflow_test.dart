import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:globalpay/models/currency.dart';
import 'package:globalpay/models/document.dart';
import 'package:globalpay/models/payroll_run.dart';
import 'package:globalpay/models/worker.dart';
import 'package:globalpay/screens/dashboard_screen.dart';
import 'package:globalpay/screens/documents_center_screen.dart';
import 'package:globalpay/screens/run_payroll_screen.dart';
import 'package:globalpay/screens/worker_portal_screen.dart';
import 'package:globalpay/services/app_state.dart';
import 'package:globalpay/services/payments_service.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AppState state;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    state = AppState();
    await state.initialize();
  });

  tearDown(() {
    state.dispose();
  });

  test('admin adds a worker and worker sees their saved payroll', () async {
    await state.signIn('ADMIN@GLOBALPAY.DEMO', 'Admin123!');
    await state.addWorker(
      worker: const Worker(
        id: 'worker-test-1',
        name: 'Test Worker',
        email: 'test.worker@example.com',
        country: 'Bangladesh',
        role: 'Designer',
        engagementType: 'Employee',
        complianceStatus: 'Compliant',
        salary: 75000,
        documents: [],
      ),
      temporaryPassword: 'TempPass123!',
    );

    expect(state.workers, hasLength(5));
    state.preparePayroll();
    final run = await state.processPayroll();

    expect(run.payments.map((payment) => payment.workerId),
        contains('worker-test-1'));
    expect(
        run.payments.map((payment) => payment.workerId), contains('demo-dev'));
    expect(
      run.payments
          .singleWhere((payment) => payment.workerId == 'worker-test-1')
          .currency,
      'USD',
    );

    final reopenedState = AppState();
    await reopenedState.initialize();
    await reopenedState.signIn('test.worker@example.com', 'TempPass123!');
    expect(reopenedState.isWorker, isTrue);
    expect(reopenedState.currentWorkerPayments, hasLength(1));
    expect(reopenedState.currentWorkerPayments.single.amount, 75000);
    reopenedState.dispose();
  });

  test('company accounts cannot see another company workers or payroll',
      () async {
    await state.signIn('admin@globalpay.demo', 'Admin123!');
    await state.addWorker(
      worker: const Worker(
        id: 'demo-private-worker',
        name: 'Private Worker',
        email: 'private.worker@example.com',
        country: 'India',
        role: 'Engineer',
        engagementType: 'Employee',
        complianceStatus: 'Compliant',
        salary: 50000,
        documents: [],
      ),
      temporaryPassword: 'TempPass123!',
    );
    state.preparePayroll();
    await state.processPayroll();
    await state.signOut();

    await state.registerAdmin(
      name: 'Another Admin',
      email: 'another.admin@example.com',
      password: 'AnotherPass123!',
      company: 'Another Company',
    );
    expect(state.workers, isEmpty);
    expect(state.payrollRuns, isEmpty);
  });

  test('invalid login fails and worker cannot run admin actions', () async {
    await expectLater(
      state.signIn('admin@globalpay.demo', 'wrong-password'),
      throwsA(isA<AuthException>()),
    );

    await state.signIn('sarah@globalpay.demo', 'Worker123!');
    expect(
      () => state.preparePayroll(),
      throwsA(isA<AuthException>()),
    );
    await expectLater(
      state.updateWorkerSalaryUsd(workerId: 'demo-sarah', salary: 9000),
      throwsA(isA<AuthException>()),
    );
  });

  test('demo admin can process payroll for all seeded demo workers', () async {
    await state.signIn('admin@globalpay.demo', 'Admin123!');
    expect(state.payableWorkers, hasLength(4));

    state.preparePayroll();
    final run = await state.processPayroll();

    expect(run.payments, hasLength(4));
    expect(run.payments.map((payment) => payment.currency).toSet(), {'USD'});
    expect(
        run.payments.map((payment) => payment.status).toSet(), {'Paid (demo)'});
    expect(run.payments.map((payment) => payment.workerName),
        contains('John Doe'));
  });

  testWidgets('admin dashboard shows actual payroll and workforce metrics',
      (tester) async {
    await state.signIn('admin@globalpay.demo', 'Admin123!');
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: DashboardScreen()),
      ),
    );

    expect(find.text('TOTAL PAYROLL VALUE'), findsOneWidget);
    expect(find.text(r'$22,300.00'), findsOneWidget);
    expect(find.text('4 Workers'), findsOneWidget);
    expect(find.text('4 Countries'), findsOneWidget);
    expect(find.textContaining('No payroll activity yet'), findsOneWidget);

    state.preparePayroll();
    await state.processPayroll();
    await tester.pumpAndSettle();

    expect(find.text('Payroll Cycle'), findsOneWidget);
    expect(find.textContaining('USD payouts'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('payroll country filter updates the total and review selection',
      (tester) async {
    await state.signIn('admin@globalpay.demo', 'Admin123!');
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(
          home: const RunPayrollScreen(),
          routes: {
            '/payroll-review': (_) =>
                const Scaffold(body: Text('Payroll review route')),
          },
        ),
      ),
    );

    expect(find.text('Workers in this cycle (4)'), findsOneWidget);
    expect(find.text('John Doe'), findsOneWidget);
    await tester.tap(find.text('All Countries'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('Germany').last);
    await tester.pumpAndSettle();

    expect(find.text('Workers in this cycle (1)'), findsOneWidget);
    expect(find.text('Hans Müller'), findsOneWidget);
    expect(find.text('Sarah Chen'), findsNothing);
    expect(find.text(r'$5,100.00'), findsNWidgets(2));
    await tester.tap(find.text('Process Payroll'));
    await tester.pumpAndSettle();

    expect(find.text('Payroll review route'), findsOneWidget);
    expect(state.draftWorkers.map((worker) => worker.id), ['demo-hans']);
  });

  test('legacy salaries stay unchanged while demo workers are payroll-ready',
      () async {
    final legacyWorker = Worker.fromMap({
      'id': 'legacy',
      'companyId': 'demo-company',
      'name': 'Legacy Worker',
      'email': 'legacy@example.com',
      'country': 'Singapore',
      'role': 'Engineer',
      'engagementType': 'Employee',
      'complianceStatus': 'Compliant',
      'salary': 8200,
      'documents': <String>[],
    });
    expect(legacyWorker.salary, 8200);
    expect(legacyWorker.salaryCurrency, 'SGD');
    expect(legacyWorker.legacySalaryAmount, 8200);
    expect(legacyWorker.legacySalaryCurrency, 'SGD');
    expect(legacyWorker.hasVerifiedUsdSalary, isFalse);

    await state.signIn('admin@globalpay.demo', 'Admin123!');
    expect(state.workersRequiringUsdReview, isEmpty);
    await state.updateWorkerSalaryUsd(workerId: 'demo-sarah', salary: 9000);
    expect(state.currentWorkerProfile, isNull);
    expect(state.payableWorkers.map((worker) => worker.id),
        contains('demo-sarah'));

    await state.signOut();
    await state.signIn('sarah@globalpay.demo', 'Worker123!');
    expect(state.currentWorkerProfile!.salary, 9000);
    expect(state.currentWorkerProfile!.salaryCurrency, 'USD');
    expect(state.currentWorkerProfile!.legacySalaryAmount, isNull);
    expect(state.currentWorkerProfile!.legacySalaryCurrency, isNull);
  });

  test('legacy payments retain their original currency and are not relabeled',
      () {
    final legacyPayment = PayrollPayment.fromMap({
      'workerId': 'legacy',
      'workerName': 'Legacy Worker',
      'workerEmail': 'legacy@example.com',
      'country': 'Singapore',
      'amount': 8200,
      'status': 'Paid',
    });
    expect(legacyPayment.amount, 8200);
    expect(legacyPayment.currency, 'SGD');
    expect(formatUsd(1234.5), r'$1,234.50');
  });

  test('payment service rejects non-USD currencies', () {
    final service = PaymentsService();
    expect(
      () => service.quote(amount: 100, currency: 'EUR'),
      throwsArgumentError,
    );
    expect(service.quote(amount: 100, currency: 'usd').currency, 'USD');
  });

  testWidgets('worker portal shows self-service sections and own profile',
      (tester) async {
    await state.signIn('sarah@globalpay.demo', 'Worker123!');
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: WorkerPortalScreen()),
      ),
    );

    expect(find.text('Sarah Chen'), findsOneWidget);
    expect(find.text('Monthly salary'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Salary'), findsOneWidget);
    expect(find.text('Payments'), findsOneWidget);
    expect(find.text('Documents'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);

    await tester.tap(find.text('Salary').last);
    await tester.pumpAndSettle();
    expect(find.text('Recorded salary'), findsOneWidget);
    expect(find.text(r'$8,200.00'), findsOneWidget);
    expect(find.textContaining('saved before the USD standard'), findsNothing);
    expect(find.text('USD verification required'), findsNothing);
    expect(find.textContaining('Tax, other deductions'), findsOneWidget);

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    expect(find.text('sarah@globalpay.demo'), findsNWidgets(2));
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets(
      'uploaded worker documents persist and appear to admin and worker',
      (tester) async {
    await state.signIn('admin@globalpay.demo', 'Admin123!');
    await state.addWorker(
      worker: Worker(
        id: 'worker-doc-test',
        name: 'Document Test',
        email: 'document.test@example.com',
        country: 'Bangladesh',
        role: 'Designer',
        engagementType: 'Contractor',
        complianceStatus: 'Compliant',
        salary: 1200,
        documents: const ['National_ID.pdf'],
        uploadedDocuments: [
          PayrollDocument(
            id: 'doc-test-1',
            name: 'National_ID.pdf',
            type: 'National ID',
            mimeType: 'application/pdf',
            contentBase64: base64Encode([1, 2, 3]),
            uploadedAt: DateTime(2026, 1, 2),
          ),
        ],
      ),
      temporaryPassword: 'TempPass123!',
    );

    final reopenedState = AppState();
    await reopenedState.initialize();
    await reopenedState.signIn('document.test@example.com', 'TempPass123!');
    expect(
      reopenedState.currentWorkerProfile!.uploadedDocuments.single.name,
      'National_ID.pdf',
    );
    expect(
      reopenedState
          .currentWorkerProfile!.uploadedDocuments.single.contentBase64,
      base64Encode([1, 2, 3]),
    );
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: reopenedState,
        child: const MaterialApp(home: WorkerPortalScreen()),
      ),
    );
    await tester.tap(find.text('Documents').last);
    await tester.pumpAndSettle();
    expect(find.text('National_ID.pdf'), findsOneWidget);

    await reopenedState.signOut();
    await reopenedState.signIn('admin@globalpay.demo', 'Admin123!');
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: reopenedState,
        child: const MaterialApp(home: DocumentsCenterScreen()),
      ),
    );
    expect(find.text('National_ID.pdf'), findsOneWidget);
    expect(find.text('Document Test · Bangladesh'), findsOneWidget);
    reopenedState.dispose();
  });
}
