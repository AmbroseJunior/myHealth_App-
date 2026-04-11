import 'package:flutter/material.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/constants/db_constants.dart';
import '../models/problem_model.dart';

class ProblemsProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  List<ProblemModel> problems = [];
  bool isLoading = false;

  Future<void> load(int userId) async {
    isLoading = true;
    notifyListeners();
    final db = await _db.database;
    final rows = await db.query(DbConstants.tableProblems,
        where: 'user_id = ?', whereArgs: [userId], orderBy: 'created_at DESC');
    problems = rows.map(ProblemModel.fromMap).toList();
    isLoading = false;
    notifyListeners();
  }

  Future<void> add(ProblemModel p) async {
    final db = await _db.database;
    await db.insert(DbConstants.tableProblems, p.toMap());
    await load(p.userId);
  }

  Future<void> update(ProblemModel p) async {
    final db = await _db.database;
    await db.update(DbConstants.tableProblems, p.toMap(),
        where: 'id = ?', whereArgs: [p.id]);
    await load(p.userId);
  }

  Future<void> delete(int id, int userId) async {
    final db = await _db.database;
    await db.delete(DbConstants.tableProblems, where: 'id = ?', whereArgs: [id]);
    await load(userId);
  }
}
