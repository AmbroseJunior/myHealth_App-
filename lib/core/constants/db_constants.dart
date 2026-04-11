class DbConstants {
  static const String dbName = 'my_health_app.db';
  static const int dbVersion = 1;

  // Table names
  static const String tableUsers = 'users';
  static const String tablePatients = 'patients';
  static const String tableWho5 = 'who5_results';
  static const String tableFramingham = 'framingham_results';
  static const String tableFindrisc = 'findrisc_results';
  static const String tableAllergies = 'allergies';
  static const String tableMedications = 'medications';
  static const String tableMedicationHistory = 'medication_history';
  static const String tableProblems = 'problems';

  // Heraklion coordinates
  static const double heraklionLat = 35.3387;
  static const double heraklionLon = 25.1442;
}
