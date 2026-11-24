import 'currency.dart';

class PayrollRun {
  final String id;
  final String companyId;
  final DateTime createdAt;
  final String status;
  final List<PayrollPayment> payments;

  const PayrollRun({
    required this.id,
    required this.companyId,
    required this.createdAt,
    required this.status,
    required this.payments,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'companyId': companyId,
        'createdAt': createdAt.toIso8601String(),
        'status': status,
        'payments': payments.map((payment) => payment.toMap()).toList(),
      };

  factory PayrollRun.fromMap(Map<String, dynamic> map) => PayrollRun(
        id: map['id'] as String? ?? '',
        companyId: map['companyId'] as String? ?? '',
        createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0),
        status: map['status'] as String? ?? 'Unknown',
        payments: (map['payments'] as List<dynamic>? ?? const [])
            .map(
              (payment) => PayrollPayment.fromMap(
                Map<String, dynamic>.from(payment as Map),
              ),
            )
            .toList(),
      );
}

class PayrollPayment {
  final String workerId;
  final String workerName;
  final String workerEmail;
  final String country;
  final String currency;
  final double amount;
  final String status;

  const PayrollPayment({
    required this.workerId,
    required this.workerName,
    required this.workerEmail,
    required this.country,
    required this.currency,
    required this.amount,
    required this.status,
  });

  Map<String, dynamic> toMap() => {
        'workerId': workerId,
        'workerName': workerName,
        'workerEmail': workerEmail,
        'country': country,
        'currency': currency,
        'amount': amount,
        'status': status,
      };

  factory PayrollPayment.fromMap(Map<String, dynamic> map) => PayrollPayment(
        workerId: map['workerId'] as String? ?? '',
        workerName: map['workerName'] as String? ?? '',
        workerEmail: map['workerEmail'] as String? ?? '',
        country: map['country'] as String? ?? '',
        currency: (map['currency'] as String?)?.trim().toUpperCase() ??
            legacyCurrencyForCountry(map['country'] as String? ?? ''),
        amount: (map['amount'] as num?)?.toDouble() ?? 0,
        status: map['status'] as String? ?? 'Unknown',
      );
}
