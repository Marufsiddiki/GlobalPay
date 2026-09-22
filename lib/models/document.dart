class PayrollDocument {
  final String name;
  final String type;
  final String owner;
  final String status;
  final DateTime? expiry;

  const PayrollDocument({
    required this.name,
    required this.type,
    required this.owner,
    required this.status,
    this.expiry,
  });
}