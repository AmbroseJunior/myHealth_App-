class FindriscResultModel {
  final int? id;
  final int userId;
  final String recordedAt;
  final int ageScore;
  final int bmiScore;
  final int waistScore;
  final int physicalActivityScore;
  final int vegetableScore;
  final int hypertensionScore;
  final int hyperglycemiaScore;
  final int familyScore;
  final int totalScore;
  final String riskCategory;

  FindriscResultModel({
    this.id,
    required this.userId,
    required this.recordedAt,
    required this.ageScore,
    required this.bmiScore,
    required this.waistScore,
    required this.physicalActivityScore,
    required this.vegetableScore,
    required this.hypertensionScore,
    required this.hyperglycemiaScore,
    required this.familyScore,
    required this.totalScore,
    required this.riskCategory,
  });

  factory FindriscResultModel.fromMap(Map<String, dynamic> m) => FindriscResultModel(
        id: m['id'] as int?,
        userId: m['user_id'] as int,
        recordedAt: m['recorded_at'] as String,
        ageScore: m['age_score'] as int,
        bmiScore: m['bmi_score'] as int,
        waistScore: m['waist_score'] as int,
        physicalActivityScore: m['physical_activity_score'] as int,
        vegetableScore: m['vegetable_score'] as int,
        hypertensionScore: m['hypertension_score'] as int,
        hyperglycemiaScore: m['hyperglycemia_score'] as int,
        familyScore: m['family_score'] as int,
        totalScore: m['total_score'] as int,
        riskCategory: m['risk_category'] as String,
      );

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'recorded_at': recordedAt,
        'age_score': ageScore,
        'bmi_score': bmiScore,
        'waist_score': waistScore,
        'physical_activity_score': physicalActivityScore,
        'vegetable_score': vegetableScore,
        'hypertension_score': hypertensionScore,
        'hyperglycemia_score': hyperglycemiaScore,
        'family_score': familyScore,
        'total_score': totalScore,
        'risk_category': riskCategory,
      };
}
