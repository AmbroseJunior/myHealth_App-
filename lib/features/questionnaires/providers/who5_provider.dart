import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/constants/db_constants.dart';
import '../models/who5_result_model.dart';

class Who5Provider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<Who5ResultModel> results = [];
  bool isLoading = false;

  Future<void> load(int userId) async {
    isLoading = true;
    notifyListeners();
    final db = await _db.database;
    final rows = await db.query(DbConstants.tableWho5,
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'recorded_at DESC');
    results = rows.map(Who5ResultModel.fromMap).toList();
    isLoading = false;
    notifyListeners();
  }

  Future<void> save(Who5ResultModel r) async {
    final db = await _db.database;
    await db.insert(DbConstants.tableWho5, r.toMap());
    await load(r.userId);
  }
}
