import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/who5_result_model.dart';

class Who5Provider extends ChangeNotifier {
  final _client = Supabase.instance.client;
  List<Who5ResultModel> results = [];
  bool isLoading = false;

  Future<void> load(String userId) async {
    isLoading = true;
    notifyListeners();
    final rows = await _client
        .from('who5_results')
        .select()
        .eq('user_id', userId)
        .order('recorded_at', ascending: false);
    results = rows.map((m) => Who5ResultModel.fromMap(m)).toList();
    isLoading = false;
    notifyListeners();
  }

  Future<void> save(Who5ResultModel r) async {
    await _client.from('who5_results').insert(r.toMap());
    await load(r.userId);
  }
}
