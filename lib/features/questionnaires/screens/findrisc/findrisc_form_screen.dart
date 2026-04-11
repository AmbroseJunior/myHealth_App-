import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_health_app/l10n/app_localizations.dart';
import '../../providers/findrisc_provider.dart';
import '../../models/findrisc_result_model.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../core/utils/score_calculators.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/widgets/app_drawer.dart';

class FindriscFormScreen extends StatefulWidget {
  const FindriscFormScreen({super.key});

  @override
  State<FindriscFormScreen> createState() => _FindriscFormScreenState();
}

class _FindriscFormScreenState extends State<FindriscFormScreen> {
  int _ageScore = 0;
  int _bmiScore = 0;
  int _waistScore = 0;
  int _physicalScore = 0;
  int _vegetableScore = 0;
  int _hypertensionScore = 0;
  int _hyperglycemiaScore = 0;
  int _familyScore = 0;
  int? _result;
  bool _saving = false;

  void _calculate() {
    setState(() {
      _result = findRiscScore(
        ageScore: _ageScore,
        bmiScore: _bmiScore,
        waistScore: _waistScore,
        physicalActivityScore: _physicalScore,
        vegetableScore: _vegetableScore,
        hypertensionScore: _hypertensionScore,
        hyperglycemiaScore: _hyperglycemiaScore,
        familyScore: _familyScore,
      );
    });
  }

  Future<void> _save() async {
    if (_result == null) { _calculate(); return; }
    setState(() => _saving = true);
    final userId = context.read<AuthProvider>().userId;
    await context.read<FindriscProvider>().save(FindriscResultModel(
          userId: userId,
          recordedAt: AppDateUtils.nowIso(),
          ageScore: _ageScore,
          bmiScore: _bmiScore,
          waistScore: _waistScore,
          physicalActivityScore: _physicalScore,
          vegetableScore: _vegetableScore,
          hypertensionScore: _hypertensionScore,
          hyperglycemiaScore: _hyperglycemiaScore,
          familyScore: _familyScore,
          totalScore: _result!,
          riskCategory: findRiscCategory(_result!),
        ));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('FINDRISC score saved!'), backgroundColor: Colors.green),
    );
    setState(() => _saving = false);
  }

  Widget _question(String title, List<String> options, List<int> values, int current, ValueChanged<int> onChange) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ...List.generate(options.length, (i) => RadioListTile<int>(
              title: Text(options[i]),
              value: values[i],
              groupValue: current,
              dense: true,
              contentPadding: EdgeInsets.zero,
              onChanged: (v) { onChange(v!); setState(() => _result = null); },
            )),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    Color resultColor = _result == null ? Colors.grey
        : _result! <= 6 ? Colors.green
        : _result! <= 11 ? Colors.lightGreen
        : _result! <= 14 ? Colors.orange
        : _result! <= 20 ? Colors.deepOrange
        : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.findRiscTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pushNamed(RouteNames.findriscHistory),
            child: Text(l.history, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _question('Age', ['Under 45 (0)', '45-54 (2)', '55-64 (3)', '65 or over (4)'],
                    [0, 2, 3, 4], _ageScore, (v) => setState(() => _ageScore = v)),
                _question('BMI (kg/m²)', ['Under 25 (0)', '25-30 (1)', 'Over 30 (3)'],
                    [0, 1, 3], _bmiScore, (v) => setState(() => _bmiScore = v)),
                _question('Waist circumference (at navel level)',
                    ['Men <94 / Women <80 (0)', 'Men 94-102 / Women 80-88 (3)', 'Men >102 / Women >88 (4)'],
                    [0, 3, 4], _waistScore, (v) => setState(() => _waistScore = v)),
                _question(l.physicalActivity,
                    ['Yes, at least 30 min/day (0)', 'No (2)'],
                    [0, 2], _physicalScore, (v) => setState(() => _physicalScore = v)),
                _question(l.eatVegetables,
                    ['Every day (0)', 'Not every day (1)'],
                    [0, 1], _vegetableScore, (v) => setState(() => _vegetableScore = v)),
                _question(l.hypertension,
                    ['No (0)', 'Yes (2)'],
                    [0, 2], _hypertensionScore, (v) => setState(() => _hypertensionScore = v)),
                _question(l.highBloodGlucose,
                    ['No (0)', 'Yes (5)'],
                    [0, 5], _hyperglycemiaScore, (v) => setState(() => _hyperglycemiaScore = v)),
                _question(l.familyDiabetes,
                    ['No (0)', 'Grandparent/aunt/uncle/cousin (3)', 'Parent/sibling/child (5)'],
                    [0, 3, 5], _familyScore, (v) => setState(() => _familyScore = v)),
                if (_result != null)
                  Card(
                    color: resultColor.withOpacity(0.1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: resultColor)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(children: [
                        Text('${l.yourScore}: $_result',
                            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: resultColor)),
                        const SizedBox(height: 8),
                        Text(findRiscDescription(_result!),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 15, color: resultColor)),
                      ]),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.calculate),
                    onPressed: _calculate,
                    label: Text(l.calculate),
                  ),
                ),
                if (_result != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.save),
                      onPressed: _saving ? null : _save,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      label: Text(l.save),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
