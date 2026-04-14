import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/findrisc_result_model.dart';

class FindriscProvider extends ChangeNotifier {
  final _client = Supabase.instance.client;
  List<FindriscResultModel> results = [];
  bool isLoading = false;

  Future<void> load(String userId) async {
    isLoading = true;
    notifyListeners();
    final rows = await _client
        .from('findrisc_results')
        .select()
        .eq('user_id', userId)
        .order('recorded_at', ascending: false);
    results = rows.map((m) => FindriscResultModel.fromMap(m)).toList();
    isLoading = false;
    notifyListeners();
  }

  Future<void> save(FindriscResultModel r) async {
    await _client.from('findrisc_results').insert(r.toMap());
    await load(r.userId);
  }
}
