import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_health_app/l10n/app_localizations.dart';
import '../../providers/who5_provider.dart';
import '../../models/who5_result_model.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../core/utils/score_calculators.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/widgets/app_drawer.dart';

class Who5QuestionnaireScreen extends StatefulWidget {
  const Who5QuestionnaireScreen({super.key});

  @override
  State<Who5QuestionnaireScreen> createState() => _Who5QuestionnaireScreenState();
}

class _Who5QuestionnaireScreenState extends State<Who5QuestionnaireScreen> {
  final List<int> _answers = [3, 3, 3, 3, 3];
  bool _saving = false;

  static const List<String> _questions = [
    'I have felt cheerful and in good spirits',
    'I have felt calm and relaxed',
    'I have felt active and vigorous',
    'I woke up feeling fresh and rested',
    'My daily life has been filled with things that interest me',
  ];

  static const List<String> _labels = [
    'All of the time (5)',
    'Most of the time (4)',
    'More than half (3)',
    'Less than half (2)',
    'Some of the time (1)',
    'At no time (0)',
  ];

  Future<void> _submit() async {
    setState(() => _saving = true);
    final userId = context.read<AuthProvider>().userId;
    final total = who5TotalScore(_answers);
    await context.read<Who5Provider>().save(Who5ResultModel(
          userId: userId,
          recordedAt: AppDateUtils.nowIso(),
          q1: _answers[0], q2: _answers[1], q3: _answers[2],
          q4: _answers[3], q5: _answers[4],
          totalScore: total,
        ));
    if (!mounted) return;
    final pct = total * 4;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('WHO-5 Result'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Score: $total / 25  ($pct%)',
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(who5Category(total), textAlign: TextAlign.center),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamed(RouteNames.who5History);
            },
            child: const Text('View History'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final total = who5TotalScore(_answers);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.who5Title),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed(RouteNames.who5History),
            child: Text(l.history, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            padding: const EdgeInsets.all(16),
            child: Text(
              'Over the last 2 weeks, how often have you felt as described in the following statements?',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _questions.length,
              itemBuilder: (_, i) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${i + 1}. ${_questions[i]}',
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 8),
                      Slider(
                        value: _answers[i].toDouble(),
                        min: 0,
                        max: 5,
                        divisions: 5,
                        label: _labels[5 - _answers[i]],
                        onChanged: (v) => setState(() => _answers[i] = v.round()),
                      ),
                      Center(
                        child: Text(_labels[5 - _answers[i]],
                            style: const TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Current score: $total/25 (${total * 4}%)',
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _submit,
                    child: _saving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Submit & Save'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
