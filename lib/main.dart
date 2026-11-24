import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/dashboard_screen.dart';
import 'screens/add_worker_screen.dart';
import 'screens/analytics_screen.dart';
import 'screens/compliance_alert_detail_screen.dart';
import 'screens/compliance_center_screen.dart';
import 'screens/documents_center_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/integrations_screen.dart';
import 'screens/payroll_review_screen.dart';
import 'screens/payroll_success_screen.dart';
import 'screens/run_payroll_screen.dart';
import 'screens/sign_in_screen.dart';
import 'screens/sign_up_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/worker_details_screen.dart';
import 'screens/workers_screen.dart';
import 'services/app_state.dart';
import 'screens/worker_portal_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appState = AppState();
  await appState.initialize();
  runApp(GlobalPayApp(appState: appState));
}

class GlobalPayApp extends StatelessWidget {
  final AppState appState;
  const GlobalPayApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => appState,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GlobalPay',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFFF7F8FA),
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF006B52)),
          fontFamily: 'Arial',
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E4E7)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E4E7)),
            ),
          ),
        ),
        home: const WelcomeScreen(),
        routes: {
          '/welcome': (_) => const WelcomeScreen(),
          '/sign-in': (_) => const SignInScreen(),
          '/sign-up': (_) => const SignUpScreen(),
          '/dashboard': (_) => const DashboardScreen(),
          '/worker-portal': (_) => const WorkerPortalScreen(),
          '/forgot-password': (_) => const ForgotPasswordScreen(),
          '/add-worker': (_) => const AddWorkerScreen(),
          '/workers': (_) => const WorkersScreen(),
          '/worker-details': (_) => const WorkerDetailsScreen(),
          '/run-payroll': (_) => const RunPayrollScreen(),
          '/payroll-review': (_) => const PayrollReviewScreen(),
          '/payroll-success': (_) => const PayrollSuccessScreen(),
          '/compliance': (_) => const ComplianceCenterScreen(),
          '/compliance-alert': (_) => const ComplianceAlertDetailScreen(),
          '/documents': (_) => const DocumentsCenterScreen(),
          '/analytics': (_) => const AnalyticsScreen(),
          '/integrations': (_) => const IntegrationsScreen(),
        },
      ),
    );
  }
}
