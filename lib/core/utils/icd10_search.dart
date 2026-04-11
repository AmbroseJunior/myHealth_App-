import 'dart:convert';
import 'package:flutter/services.dart';

class Icd10Entry {
  final String code;
  final String title;
  Icd10Entry({required this.code, required this.title});

  factory Icd10Entry.fromJson(Map<String, dynamic> json) =>
      Icd10Entry(code: json['code'] as String, title: json['title'] as String);
}

class Icd10Search {
  static List<Icd10Entry>? _cache;

  static Future<List<Icd10Entry>> _load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString('assets/data/icd10_codes.json');
    final list = json.decode(raw) as List;
    _cache = list.map((e) => Icd10Entry.fromJson(e as Map<String, dynamic>)).toList();
    return _cache!;
  }

  static Future<List<Icd10Entry>> search(String query) async {
    if (query.trim().isEmpty) return [];
    final all = await _load();
    final q = query.trim().toLowerCase();
    return all
        .where((e) =>
            e.code.toLowerCase().startsWith(q) ||
            e.title.toLowerCase().contains(q))
        .take(20)
        .toList();
  }
}
