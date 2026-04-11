class Who5ResultModel {
  final int? id;
  final int userId;
  final String recordedAt;
  final int q1, q2, q3, q4, q5;
  final int totalScore;

  Who5ResultModel({
    this.id,
    required this.userId,
    required this.recordedAt,
    required this.q1, required this.q2, required this.q3,
    required this.q4, required this.q5,
    required this.totalScore,
  });

  int get percentScore => totalScore * 4;

  factory Who5ResultModel.fromMap(Map<String, dynamic> m) => Who5ResultModel(
        id: m['id'] as int?,
        userId: m['user_id'] as int,
        recordedAt: m['recorded_at'] as String,
        q1: m['q1'] as int, q2: m['q2'] as int, q3: m['q3'] as int,
        q4: m['q4'] as int, q5: m['q5'] as int,
        totalScore: m['total_score'] as int,
      );

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'recorded_at': recordedAt,
        'q1': q1, 'q2': q2, 'q3': q3, 'q4': q4, 'q5': q5,
        'total_score': totalScore,
      };
}
