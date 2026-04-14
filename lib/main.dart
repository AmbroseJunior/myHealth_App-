import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://lexmgsylpikqghxziswq.supabase.co',
    anonKey: 'sb_publishable_ggTfJ0JYbbVICkm9YzDsuw_LFVSXpEc',
  );

  runApp(const MyHealthApp());
}
