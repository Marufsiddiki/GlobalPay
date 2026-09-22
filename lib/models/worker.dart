class Worker {
  final String name;
  final String email;
  final String country;
  final String role;
  final String engagementType;
  final String complianceStatus;
  final double salary;
  final List<String> documents;

  const Worker({
    required this.name,
    required this.email,
    required this.country,
    required this.role,
    required this.engagementType,
    required this.complianceStatus,
    required this.salary,
    required this.documents,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'country': country,
        'role': role,
        'engagementType': engagementType,
        'complianceStatus': complianceStatus,
        'salary': salary,
        'documents': documents,
      };

  factory Worker.fromMap(Map<String, dynamic> map) => Worker(
        name: map['name'] ?? '',
        email: map['email'] ?? '',
        country: map['country'] ?? '',
        role: map['role'] ?? '',
        engagementType: map['engagementType'] ?? 'Employee',
        complianceStatus: map['complianceStatus'] ?? 'Review',
        salary: (map['salary'] as num?)?.toDouble() ?? 0,
        documents: List<String>.from(map['documents'] ?? const []),
      );
}