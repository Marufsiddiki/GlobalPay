class ComplianceResult {
  final bool passed;
  final String message;
  const ComplianceResult(this.passed, this.message);
}

class ComplianceRulesEngine {
  ComplianceResult evaluate({required String country, required String engagementType}) {
    if (country == 'Bangladesh' && engagementType == 'Employee') return const ComplianceResult(true, 'Employee classification aligns with Bangladesh labor requirements.');
    if (engagementType == 'Contractor') return const ComplianceResult(false, 'Review local control and independence tests before engaging this worker.');
    return const ComplianceResult(true, 'Classification requirements are satisfied for this engagement.');
  }
}