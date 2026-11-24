class PayrollDocument {
  final String id;
  final String name;
  final String type;
  final String mimeType;
  final String contentBase64;
  final DateTime uploadedAt;

  const PayrollDocument({
    required this.id,
    required this.name,
    required this.type,
    required this.mimeType,
    required this.contentBase64,
    required this.uploadedAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type,
        'mimeType': mimeType,
        'contentBase64': contentBase64,
        'uploadedAt': uploadedAt.toIso8601String(),
      };

  factory PayrollDocument.fromMap(Map<String, dynamic> map) => PayrollDocument(
        id: map['id'] as String? ?? '',
        name: map['name'] as String? ?? '',
        type: map['type'] as String? ?? 'Other',
        mimeType: map['mimeType'] as String? ?? '',
        contentBase64: map['contentBase64'] as String? ?? '',
        uploadedAt:
            DateTime.tryParse(map['uploadedAt'] as String? ?? '') ??
                DateTime.fromMillisecondsSinceEpoch(0),
      );
}
