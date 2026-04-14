// DatabaseHelper is no longer used.
// Data is stored in Supabase (cloud PostgreSQL).
// This stub is kept to avoid breaking any remaining imports.
class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();
}
