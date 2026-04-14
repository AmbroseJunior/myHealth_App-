import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/framingham_result_model.dart';

class FraminghamProvider extends ChangeNotifier {
  final _client = Supabase.instance.client;
  List<FraminghamResultModel> results = [];
  bool isLoading = false;

  Future<void> load(String userId) async {
    isLoading = true;
    notifyListeners();
    final rows = await _client
        .from('framingham_results')
        .select()
        .eq('user_id', userId)
        .order('recorded_at', ascending: false);
    results = rows.map((m) => FraminghamResultModel.fromMap(m)).toList();
    isLoading = false;
    notifyListeners();
  }

  Future<void> save(FraminghamResultModel r) async {
    await _client.from('framingham_results').insert(r.toMap());
    await load(r.userId);
  }
}
