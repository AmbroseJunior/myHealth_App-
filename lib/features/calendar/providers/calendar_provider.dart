import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/calendar_event_model.dart';

class CalendarProvider extends ChangeNotifier {
  final _client = Supabase.instance.client;
  Map<DateTime, List<CalendarEventModel>> events = {};
  bool isLoading = false;

  DateTime _normalise(DateTime d) => DateTime(d.year, d.month, d.day);

  void _add(DateTime date, CalendarEventModel event) {
    final key = _normalise(date);
    events.putIfAbsent(key, () => []).add(event);
  }

  Future<void> load(String userId) async {
    isLoading = true;
    events = {};
    notifyListeners();

    // WHO-5
    final who5 = await _client
        .from('who5_results')
        .select()
        .eq('user_id', userId);
    for (final r in who5) {
      final date = DateTime.parse(r['recorded_at'] as String);
      final score = r['total_score'] as int;
      _add(date, CalendarEventModel(
        title: 'WHO-5 Score: $score/25 (${score * 4}%)',
        type: CalendarEventType.who5,
        date: date,
      ));
    }

    // Framingham
    final framingham = await _client
        .from('framingham_results')
        .select()
        .eq('user_id', userId);
    for (final r in framingham) {
      final date = DateTime.parse(r['recorded_at'] as String);
      final risk = (r['risk_percent'] as num).toDouble();
      _add(date, CalendarEventModel(
        title: 'Framingham CVD Risk: ${risk.toStringAsFixed(1)}%',
        type: CalendarEventType.framingham,
        date: date,
      ));
    }

    // FINDRISC
    final findrisc = await _client
        .from('findrisc_results')
        .select()
        .eq('user_id', userId);
    for (final r in findrisc) {
      final date = DateTime.parse(r['recorded_at'] as String);
      final score = r['total_score'] as int;
      _add(date, CalendarEventModel(
        title: 'FINDRISC Score: $score (${r['risk_category']})',
        type: CalendarEventType.findrisc,
        date: date,
      ));
    }

    // Allergies
    final allergies = await _client
        .from('allergies')
        .select()
        .eq('user_id', userId);
    for (final r in allergies) {
      final onsetStr = r['onset_date'] as String?;
      final createdStr = r['created_at'] as String;
      final date = onsetStr != null ? DateTime.tryParse(onsetStr) : null;
      final addedDate = DateTime.parse(createdStr);
      _add(date ?? addedDate, CalendarEventModel(
        title: 'Allergy: ${r['allergen']}',
        type: CalendarEventType.allergy,
        date: date ?? addedDate,
        subtitle: r['severity'] as String?,
      ));
    }

    // Medications
    final meds = await _client
        .from('medications')
        .select()
        .eq('user_id', userId);
    for (final r in meds) {
      final startStr = r['start_date'] as String?;
      final createdStr = r['created_at'] as String;
      final date = startStr != null ? DateTime.tryParse(startStr) : null;
      final fallback = DateTime.parse(createdStr);
      _add(date ?? fallback, CalendarEventModel(
        title: 'Medication: ${r['name']}',
        type: CalendarEventType.medication,
        date: date ?? fallback,
        subtitle: r['dosage'] as String?,
      ));
    }

    // Problems
    final problems = await _client
        .from('problems')
        .select()
        .eq('user_id', userId);
    for (final r in problems) {
      final onsetStr = r['onset_date'] as String?;
      final createdStr = r['created_at'] as String;
      final date = onsetStr != null ? DateTime.tryParse(onsetStr) : null;
      final fallback = DateTime.parse(createdStr);
      _add(date ?? fallback, CalendarEventModel(
        title: '${r['icd10_code']}: ${r['icd10_title']}',
        type: CalendarEventType.problem,
        date: date ?? fallback,
        subtitle: r['status'] as String?,
      ));
    }

    isLoading = false;
    notifyListeners();
  }

  List<CalendarEventModel> eventsForDay(DateTime day) {
    return events[_normalise(day)] ?? [];
  }
}
