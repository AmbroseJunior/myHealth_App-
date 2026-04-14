import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/app_date_utils.dart';
import '../models/medication_model.dart';

class MedicationsProvider extends ChangeNotifier {
  final _client = Supabase.instance.client;
  List<MedicationModel> medications = [];
  List<Map<String, dynamic>> history = [];
  bool isLoading = false;

  Future<void> load(String userId) async {
    isLoading = true;
    notifyListeners();
    final rows = await _client
        .from('medications')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    medications = rows.map((m) => MedicationModel.fromMap(m)).toList();
    isLoading = false;
    notifyListeners();
  }

  Future<void> add(MedicationModel m) async {
    final inserted = await _client
        .from('medications')
        .insert(m.toMap())
        .select()
        .single();
    await _client.from('medication_history').insert({
      'medication_id': inserted['id'],
      'changed_at': AppDateUtils.nowIso(),
      'change_type': 'create',
      'snapshot': json.encode({...m.toMap(), 'id': inserted['id']}),
    });
    await load(m.userId);
  }

  Future<void> update(MedicationModel m) async {
    await _client.from('medications').update(m.toMap()).eq('id', m.id!);
    await _client.from('medication_history').insert({
      'medication_id': m.id,
      'changed_at': AppDateUtils.nowIso(),
      'change_type': 'update',
      'snapshot': json.encode(m.toMap()),
    });
    await load(m.userId);
  }

  Future<void> delete(int id, String userId) async {
    await _client.from('medications').delete().eq('id', id);
    await load(userId);
  }

  Future<void> loadHistory(int medicationId) async {
    final rows = await _client
        .from('medication_history')
        .select()
        .eq('medication_id', medicationId)
        .order('changed_at', ascending: false);
    history = List<Map<String, dynamic>>.from(rows);
    notifyListeners();
  }
}
