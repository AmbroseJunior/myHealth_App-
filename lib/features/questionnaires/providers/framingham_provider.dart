import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/constants/db_constants.dart';
import '../models/framingham_result_model.dart';

class FraminghamProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<FraminghamResultModel> results = [];
  bool isLoading = false;

  Future<void> load(int userId) async {
    isLoading = true;
    notifyListeners();
    final db = await _db.database;
    final rows = await db.query(DbConstants.tableFramingham,
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'recorded_at DESC');
    results = rows.map(FraminghamResultModel.fromMap).toList();
    isLoading = false;
    notifyListeners();
  }

  Future<void> save(FraminghamResultModel r) async {
    final db = await _db.database;
    await db.insert(DbConstants.tableFramingham, r.toMap());
    await load(r.userId);
  }
}
