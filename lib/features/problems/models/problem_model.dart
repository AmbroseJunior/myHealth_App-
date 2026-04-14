class ProblemModel {
  final int? id;
  final String userId;
  final String icd10Code;
  final String icd10Title;
  final String status;
  final String? onsetDate;
  final String? notes;
  final String createdAt;

  ProblemModel({
    this.id,
    required this.userId,
    required this.icd10Code,
    required this.icd10Title,
    this.status = 'active',
    this.onsetDate,
    this.notes,
    required this.createdAt,
  });

  factory ProblemModel.fromMap(Map<String, dynamic> m) => ProblemModel(
        id: m['id'] as int?,
        userId: m['user_id'] as String,
        icd10Code: m['icd10_code'] as String,
        icd10Title: m['icd10_title'] as String,
        status: m['status'] as String? ?? 'active',
        onsetDate: m['onset_date'] as String?,
        notes: m['notes'] as String?,
        createdAt: m['created_at'] as String,
      );

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'icd10_code': icd10Code,
        'icd10_title': icd10Title,
        'status': status,
        'onset_date': onsetDate,
        'notes': notes,
        'created_at': createdAt,
      };
}
