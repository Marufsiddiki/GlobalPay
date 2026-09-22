class ComplianceAlert {
  final String type;
  final String riskLevel;
  final String affectedWorker;
  final String country;
  final List<String> recommendedSteps;

  const ComplianceAlert({
    required this.type,
    required this.riskLevel,
    required this.affectedWorker,
    required this.country,
    required this.recommendedSteps,
  });
}