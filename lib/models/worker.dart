import 'currency.dart';
import 'document.dart';

class Worker {
  final String id;
  final String companyId;
  final String name;
  final String email;
  final String country;
  final String role;
  final String engagementType;
  final String complianceStatus;
  final double salary;
  final String salaryCurrency;
  final double? legacySalaryAmount;
  final String? legacySalaryCurrency;
  final List<String> documents;
  final List<PayrollDocument> uploadedDocuments;

  const Worker({
    this.id = '',
    this.companyId = '',
    required this.name,
    required this.email,
    required this.country,
    required this.role,
    required this.engagementType,
    required this.complianceStatus,
    required this.salary,
    this.salaryCurrency = 'USD',
    this.legacySalaryAmount,
    this.legacySalaryCurrency,
    required this.documents,
    this.uploadedDocuments = const [],
  });

  bool get hasVerifiedUsdSalary => salaryCurrency == 'USD';

  Worker copyWith({
    String? id,
    String? companyId,
    String? name,
    String? email,
    String? country,
    String? role,
    String? engagementType,
    String? complianceStatus,
    double? salary,
    String? salaryCurrency,
    double? legacySalaryAmount,
    String? legacySalaryCurrency,
    List<String>? documents,
    List<PayrollDocument>? uploadedDocuments,
  }) =>
      Worker(
        id: id ?? this.id,
        companyId: companyId ?? this.companyId,
        name: name ?? this.name,
        email: email ?? this.email,
        country: country ?? this.country,
        role: role ?? this.role,
        engagementType: engagementType ?? this.engagementType,
        complianceStatus: complianceStatus ?? this.complianceStatus,
        salary: salary ?? this.salary,
        salaryCurrency: salaryCurrency ?? this.salaryCurrency,
        legacySalaryAmount: legacySalaryAmount ?? this.legacySalaryAmount,
        legacySalaryCurrency: legacySalaryCurrency ?? this.legacySalaryCurrency,
        documents: documents ?? this.documents,
        uploadedDocuments: uploadedDocuments ?? this.uploadedDocuments,
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'companyId': companyId,
        'name': name,
        'email': email,
        'country': country,
        'role': role,
        'engagementType': engagementType,
        'complianceStatus': complianceStatus,
        'salary': salary,
        'salaryCurrency': salaryCurrency,
        'legacySalaryAmount': legacySalaryAmount,
        'legacySalaryCurrency': legacySalaryCurrency,
        'documents': documents,
        'uploadedDocuments':
            uploadedDocuments.map((document) => document.toMap()).toList(),
      };

  factory Worker.fromMap(Map<String, dynamic> map) {
    final country = map['country'] as String? ?? '';
    final salary = (map['salary'] as num?)?.toDouble() ?? 0;
    final storedCurrency = (map['salaryCurrency'] as String?)?.trim();
    final salaryCurrency =
        storedCurrency?.toUpperCase() ?? legacyCurrencyForCountry(country);
    final legacyAmount = (map['legacySalaryAmount'] as num?)?.toDouble() ??
        (salaryCurrency == 'USD' ? null : salary);
    final legacyCurrency =
        (map['legacySalaryCurrency'] as String?)?.trim().toUpperCase() ??
            (salaryCurrency == 'USD' ? null : salaryCurrency);
    return Worker(
      id: map['id'] as String? ?? '',
      companyId: map['companyId'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      country: country,
      role: map['role'] as String? ?? '',
      engagementType: map['engagementType'] as String? ?? 'Employee',
      complianceStatus: map['complianceStatus'] as String? ?? 'Review',
      salary: salary,
      salaryCurrency: salaryCurrency,
      legacySalaryAmount: legacyAmount,
      legacySalaryCurrency: legacyCurrency,
      documents: List<String>.from(map['documents'] ?? const []),
      uploadedDocuments: (map['uploadedDocuments'] as List<dynamic>? ?? [])
          .map(
            (item) => PayrollDocument.fromMap(
              Map<String, dynamic>.from(item as Map),
            ),
          )
          .toList(),
    );
  }
}
