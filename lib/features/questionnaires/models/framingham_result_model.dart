class FraminghamResultModel {
  final int? id;
  final int userId;
  final String recordedAt;
  final int age;
  final String gender;
  final double totalChol;
  final double hdlChol;
  final int systolicBp;
  final bool isBpTreated;
  final bool isSmoker;
  final double riskPercent;

  FraminghamResultModel({
    this.id,
    required this.userId,
    required this.recordedAt,
    required this.age,
    required this.gender,
    required this.totalChol,
    required this.hdlChol,
    required this.systolicBp,
    required this.isBpTreated,
    required this.isSmoker,
    required this.riskPercent,
  });

  factory FraminghamResultModel.fromMap(Map<String, dynamic> m) => FraminghamResultModel(
        id: m['id'] as int?,
        userId: m['user_id'] as int,
        recordedAt: m['recorded_at'] as String,
        age: m['age'] as int,
        gender: m['gender'] as String,
        totalChol: (m['total_chol'] as num).toDouble(),
        hdlChol: (m['hdl_chol'] as num).toDouble(),
        systolicBp: m['systolic_bp'] as int,
        isBpTreated: (m['is_bp_treated'] as int) == 1,
        isSmoker: (m['is_smoker'] as int) == 1,
        riskPercent: (m['risk_percent'] as num).toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'recorded_at': recordedAt,
        'age': age,
        'gender': gender,
        'total_chol': totalChol,
        'hdl_chol': hdlChol,
        'systolic_bp': systolicBp,
        'is_bp_treated': isBpTreated ? 1 : 0,
        'is_smoker': isSmoker ? 1 : 0,
        'risk_percent': riskPercent,
      };
}
