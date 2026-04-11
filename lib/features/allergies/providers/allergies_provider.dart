import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/constants/db_constants.dart';
import '../models/allergy_model.dart';

class AllergiesProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<AllergyModel> allergies = [];
  bool isLoading = false;

  Future<void> load(int userId) async {
    isLoading = true;
    notifyListeners();
    final db = await _db.database;
    final rows = await db.query(DbConstants.tableAllergies,
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'created_at DESC');
    allergies = rows.map(AllergyModel.fromMap).toList();
    isLoading = false;
    notifyListeners();
  }

  Future<void> add(AllergyModel a) async {
    final db = await _db.database;
    await db.insert(DbConstants.tableAllergies, a.toMap());
    await load(a.userId);
  }

  Future<void> update(AllergyModel a) async {
    final db = await _db.database;
    await db.update(DbConstants.tableAllergies, a.toMap(),
        where: 'id = ?', whereArgs: [a.id]);
    await load(a.userId);
  }

  Future<void> delete(int id, int userId) async {
    final db = await _db.database;
    await db.delete(DbConstants.tableAllergies, where: 'id = ?', whereArgs: [id]);
    await load(userId);
  }
}
