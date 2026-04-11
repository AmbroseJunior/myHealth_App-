import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/constants/db_constants.dart';
import '../models/patient_model.dart';

class DemographicsProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  PatientModel? patient;
  bool isLoading = false;

  Future<void> load(int userId) async {
    isLoading = true;
    notifyListeners();
    final db = await _db.database;
    final result = await db.query(
      DbConstants.tablePatients,
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    patient = result.isNotEmpty ? PatientModel.fromMap(result.first) : null;
    isLoading = false;
    notifyListeners();
  }

  Future<void> save(PatientModel p) async {
    final db = await _db.database;
    if (patient == null) {
      await db.insert(DbConstants.tablePatients, p.toMap());
    } else {
      await db.update(DbConstants.tablePatients, p.toMap(),
          where: 'id = ?', whereArgs: [patient!.id]);
    }
    await load(p.userId);
  }
}
