import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/constants/db_constants.dart';
import '../models/findrisc_result_model.dart';

class FindriscProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<FindriscResultModel> results = [];
  bool isLoading = false;

  Future<void> load(int userId) async {
    isLoading = true;
    notifyListeners();
    final db = await _db.database;
    final rows = await db.query(DbConstants.tableFindrisc,
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'recorded_at DESC');
    results = rows.map(FindriscResultModel.fromMap).toList();
    isLoading = false;
    notifyListeners();
  }

  Future<void> save(FindriscResultModel r) async {
    final db = await _db.database;
    await db.insert(DbConstants.tableFindrisc, r.toMap());
    await load(r.userId);
  }
}
