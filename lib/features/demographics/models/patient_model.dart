class PatientModel {
  final int? id;
  final int userId;
  final String firstName;
  final String lastName;
  final String? dateOfBirth;
  final String? gender;
  final String? race;
  final String? ethnicity;
  final String? location;

  PatientModel({
    this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.dateOfBirth,
    this.gender,
    this.race,
    this.ethnicity,
    this.location,
  });

  factory PatientModel.fromMap(Map<String, dynamic> m) => PatientModel(
        id: m['id'] as int?,
        userId: m['user_id'] as int,
        firstName: m['first_name'] as String? ?? '',
        lastName: m['last_name'] as String? ?? '',
        dateOfBirth: m['date_of_birth'] as String?,
        gender: m['gender'] as String?,
        race: m['race'] as String?,
        ethnicity: m['ethnicity'] as String?,
        location: m['location'] as String?,
      );

  Map<String, dynamic> toMap() => {
        'user_id': userId,
        'first_name': firstName,
        'last_name': lastName,
        'date_of_birth': dateOfBirth,
        'gender': gender,
        'race': race,
        'ethnicity': ethnicity,
        'location': location,
      };

  String get fullName => '$firstName $lastName'.trim();
}
