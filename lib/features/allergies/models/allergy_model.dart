class AllergyModel {
  final int? id;
  final String userId;
  final String allergen;
  final String? reaction;
  final String? severity;
  final String? onsetDate;
  final String? notes;
  final String createdAt;

  AllergyModel({
    this.id,
    required this.userId,
    required this.allergen,
    this.reaction,
    this.severity,
    this.onsetDate,
    this.notes,
    required this.createdAt,
  });

  factory AllergyModel.fromMap(Map<String, dynamic> m) => AllergyModel(
        id: m['id'] as int?,
        userId: m['user_id'] as String,
        allergen: m['allergen'] as String,
        reaction: m['reaction'] as String?,
        severity: m['severity'] as String?,
        onsetDate: m['onset_date'] as String?,
        notes: m['notes'] as String?,
        createdAt: m['created_at'] as String,
      );

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'allergen': allergen,
        'reaction': reaction,
        'severity': severity,
        'onset_date': onsetDate,
        'notes': notes,
        'created_at': createdAt,
      };
}
