import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/allergy_model.dart';

class AllergiesProvider extends ChangeNotifier {
  final _client = Supabase.instance.client;
  List<AllergyModel> allergies = [];
  bool isLoading = false;

  Future<void> load(String userId) async {
    isLoading = true;
    notifyListeners();
    final rows = await _client
        .from('allergies')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    allergies = rows.map((m) => AllergyModel.fromMap(m)).toList();
    isLoading = false;
    notifyListeners();
  }

  Future<void> add(AllergyModel a) async {
    await _client.from('allergies').insert(a.toMap());
    await load(a.userId);
  }

  Future<void> update(AllergyModel a) async {
    await _client.from('allergies').update(a.toMap()).eq('id', a.id!);
    await load(a.userId);
  }

  Future<void> delete(int id, String userId) async {
    await _client.from('allergies').delete().eq('id', id);
    await load(userId);
  }
}
