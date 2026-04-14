import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/problem_model.dart';

class ProblemsProvider extends ChangeNotifier {
  final _client = Supabase.instance.client;
  List<ProblemModel> problems = [];
  bool isLoading = false;

  Future<void> load(String userId) async {
    isLoading = true;
    notifyListeners();
    final rows = await _client
        .from('problems')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    problems = rows.map((m) => ProblemModel.fromMap(m)).toList();
    isLoading = false;
    notifyListeners();
  }

  Future<void> add(ProblemModel p) async {
    await _client.from('problems').insert(p.toMap());
    await load(p.userId);
  }

  Future<void> update(ProblemModel p) async {
    await _client.from('problems').update(p.toMap()).eq('id', p.id!);
    await load(p.userId);
  }

  Future<void> delete(int id, String userId) async {
    await _client.from('problems').delete().eq('id', id);
    await load(userId);
  }
}
