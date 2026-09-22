import 'package:flutter/foundation.dart';

import '../models/worker.dart';

class AppState extends ChangeNotifier {
  bool signedIn = false;
  final List<Worker> workers = [
    const Worker(name: 'Sarah Chen', email: 'sarah@company.com', country: 'Singapore', role: 'Senior Developer', engagementType: 'Employee', complianceStatus: 'Compliant', salary: 8200, documents: ['Tax_SG.pdf']),
    const Worker(name: 'Hans Müller', email: 'hans@company.com', country: 'Germany', role: 'Product Manager', engagementType: 'Employee', complianceStatus: 'Compliant', salary: 5100, documents: ['Employment_Agreement.pdf']),
    const Worker(name: 'Dev Patel', email: 'dev@company.com', country: 'India', role: 'QA Engineer', engagementType: 'Contractor', complianceStatus: 'Review', salary: 180000, documents: ['Contractor_Agreement.pdf']),
  ];

  void signIn() {
    signedIn = true;
    notifyListeners();
  }

  void addWorker(Worker worker) {
    workers.add(worker);
    notifyListeners();
  }
}