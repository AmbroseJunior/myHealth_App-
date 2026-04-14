import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/patient_model.dart';

class DemographicsProvider extends ChangeNotifier {
  final _client = Supabase.instance.client;
  PatientModel? patient;
  bool isLoading = false;

  Future<void> load(String userId) async {
    isLoading = true;
    notifyListeners();
    final result = await _client
        .from('patients')
        .select()
        .eq('user_id', userId);
    patient = result.isNotEmpty ? PatientModel.fromMap(result.first) : null;
    isLoading = false;
    notifyListeners();
  }

  Future<void> save(PatientModel p) async {
    if (patient == null) {
      await _client.from('patients').insert(p.toMap());
    } else {
      await _client.from('patients').update(p.toMap()).eq('id', patient!.id!);
    }
    await load(p.userId);
  }
}
