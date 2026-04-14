class MedicationModel {
  final int? id;
  final String userId;
  final String name;
  final String? dosage;
  final String? frequency;
  final String? startDate;
  final String? endDate;
  final bool isOngoing;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  MedicationModel({
    this.id,
    required this.userId,
    required this.name,
    this.dosage,
    this.frequency,
    this.startDate,
    this.endDate,
    this.isOngoing = true,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MedicationModel.fromMap(Map<String, dynamic> m) => MedicationModel(
        id: m['id'] as int?,
        userId: m['user_id'] as String,
        name: m['name'] as String,
        dosage: m['dosage'] as String?,
        frequency: m['frequency'] as String?,
        startDate: m['start_date'] as String?,
        endDate: m['end_date'] as String?,
        isOngoing: m['is_ongoing'] as bool? ?? true,
        notes: m['notes'] as String?,
        createdAt: m['created_at'] as String,
        updatedAt: m['updated_at'] as String,
      );

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'name': name,
        'dosage': dosage,
        'frequency': frequency,
        'start_date': startDate,
        'end_date': endDate,
        'is_ongoing': isOngoing,
        'notes': notes,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}
