import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../constants/db_constants.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, DbConstants.dbName);
    return await openDatabase(
      path,
      version: DbConstants.dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ${DbConstants.tableUsers} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tablePatients} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        first_name TEXT,
        last_name TEXT,
        date_of_birth TEXT,
        gender TEXT,
        race TEXT,
        ethnicity TEXT,
        location TEXT,
        FOREIGN KEY (user_id) REFERENCES ${DbConstants.tableUsers}(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableWho5} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        recorded_at TEXT NOT NULL,
        q1 INTEGER, q2 INTEGER, q3 INTEGER, q4 INTEGER, q5 INTEGER,
        total_score INTEGER,
        FOREIGN KEY (user_id) REFERENCES ${DbConstants.tableUsers}(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableFramingham} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        recorded_at TEXT NOT NULL,
        age INTEGER,
        gender TEXT,
        total_chol REAL,
        hdl_chol REAL,
        systolic_bp INTEGER,
        is_bp_treated INTEGER,
        is_smoker INTEGER,
        risk_percent REAL,
        FOREIGN KEY (user_id) REFERENCES ${DbConstants.tableUsers}(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableFindrisc} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        recorded_at TEXT NOT NULL,
        age_score INTEGER,
        bmi_score INTEGER,
        waist_score INTEGER,
        physical_activity_score INTEGER,
        vegetable_score INTEGER,
        hypertension_score INTEGER,
        hyperglycemia_score INTEGER,
        family_score INTEGER,
        total_score INTEGER,
        risk_category TEXT,
        FOREIGN KEY (user_id) REFERENCES ${DbConstants.tableUsers}(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableAllergies} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        allergen TEXT NOT NULL,
        reaction TEXT,
        severity TEXT,
        onset_date TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES ${DbConstants.tableUsers}(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableMedications} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        dosage TEXT,
        frequency TEXT,
        start_date TEXT,
        end_date TEXT,
        is_ongoing INTEGER DEFAULT 1,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES ${DbConstants.tableUsers}(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableMedicationHistory} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        medication_id INTEGER NOT NULL,
        changed_at TEXT NOT NULL,
        change_type TEXT NOT NULL,
        snapshot TEXT NOT NULL,
        FOREIGN KEY (medication_id) REFERENCES ${DbConstants.tableMedications}(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE ${DbConstants.tableProblems} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        icd10_code TEXT NOT NULL,
        icd10_title TEXT NOT NULL,
        status TEXT DEFAULT 'active',
        onset_date TEXT,
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES ${DbConstants.tableUsers}(id)
      )
    ''');
  }
}
