import 'dart:convert';
import 'package:crypto/crypto.dart';
import '../database/database_helper.dart';
import '../constants/db_constants.dart';

class AuthService {
  final DatabaseHelper _db = DatabaseHelper();

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    return sha256.convert(bytes).toString();
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    final db = await _db.database;
    final hash = _hashPassword(password);
    final result = await db.query(
      DbConstants.tableUsers,
      where: 'email = ? AND password_hash = ?',
      whereArgs: [email.trim().toLowerCase(), hash],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<Map<String, dynamic>?> register(String email, String password) async {
    final db = await _db.database;
    final existing = await db.query(
      DbConstants.tableUsers,
      where: 'email = ?',
      whereArgs: [email.trim().toLowerCase()],
    );
    if (existing.isNotEmpty) return null; // email taken

    final now = DateTime.now().toIso8601String();
    final id = await db.insert(DbConstants.tableUsers, {
      'email': email.trim().toLowerCase(),
      'password_hash': _hashPassword(password),
      'created_at': now,
    });
    return {'id': id, 'email': email.trim().toLowerCase(), 'created_at': now};
  }
}
