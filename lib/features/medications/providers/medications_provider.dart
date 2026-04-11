import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/constants/db_constants.dart';
import '../../../core/utils/app_date_utils.dart';
import '../models/medication_model.dart';

class MedicationsProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<MedicationModel> medications = [];
  List<Map<String, dynamic>> history = [];
  bool isLoading = false;

  Future<void> load(int userId) async {
    isLoading = true;
    notifyListeners();
    final db = await _db.database;
    final rows = await db.query(DbConstants.tableMedications,
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'created_at DESC');
    medications = rows.map(MedicationModel.fromMap).toList();
    isLoading = false;
    notifyListeners();
  }

  Future<void> add(MedicationModel m) async {
    final db = await _db.database;
    final id = await db.insert(DbConstants.tableMedications, m.toMap());
    await db.insert(DbConstants.tableMedicationHistory, {
      'medication_id': id,
      'changed_at': AppDateUtils.nowIso(),
      'change_type': 'create',
      'snapshot': json.encode({...m.toMap(), 'id': id}),
    });
    await load(m.userId);
  }

  Future<void> update(MedicationModel m) async {
    final db = await _db.database;
    await db.update(DbConstants.tableMedications, m.toMap(),
        where: 'id = ?', whereArgs: [m.id]);
    await db.insert(DbConstants.tableMedicationHistory, {
      'medication_id': m.id,
      'changed_at': AppDateUtils.nowIso(),
      'change_type': 'update',
      'snapshot': json.encode(m.toMap()),
    });
    await load(m.userId);
  }

  Future<void> delete(int id, int userId) async {
    final db = await _db.database;
    await db.delete(DbConstants.tableMedications, where: 'id = ?', whereArgs: [id]);
    await load(userId);
  }

  Future<void> loadHistory(int medicationId) async {
    final db = await _db.database;
    final rows = await db.query(DbConstants.tableMedicationHistory,
        where: 'medication_id = ?', whereArgs: [medicationId], orderBy: 'changed_at DESC');
    history = rows;
    notifyListeners();
  }
}
