import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_health_app/l10n/app_localizations.dart';
import '../../providers/framingham_provider.dart';
import '../../models/framingham_result_model.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../core/utils/score_calculators.dart';
import '../../../../core/utils/app_date_utils.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/constants/route_names.dart';
import '../../../../core/widgets/app_drawer.dart';

class FraminghamFormScreen extends StatefulWidget {
  const FraminghamFormScreen({super.key});

  @override
  State<FraminghamFormScreen> createState() => _FraminghamFormScreenState();
}

class _FraminghamFormScreenState extends State<FraminghamFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageCtrl = TextEditingController();
  final _cholCtrl = TextEditingController();
  final _hdlCtrl = TextEditingController();
  final _bpCtrl = TextEditingController();
  String _gender = 'male';
  bool _bpTreated = false;
  bool _smoker = false;
  bool _saving = false;

  double? _result;
  String? _category;

  void _calculate() {
    if (!_formKey.currentState!.validate()) return;
    final risk = framinghamRiskScore(
      age: int.parse(_ageCtrl.text),
      gender: _gender,
      totalChol: double.parse(_cholCtrl.text),
      hdlChol: double.parse(_hdlCtrl.text),
      systolicBP: int.parse(_bpCtrl.text),
      isBpTreated: _bpTreated,
      isSmoker: _smoker,
    );
    setState(() {
      _result = risk;
      _category = framinghamRiskCategory(risk);
    });
  }

  Future<void> _save() async {
    if (_result == null) {
      _calculate();
      return;
    }
    setState(() => _saving = true);
    final userId = context.read<AuthProvider>().userId;
    await context.read<FraminghamProvider>().save(
      FraminghamResultModel(
        userId: userId,
        recordedAt: AppDateUtils.nowIso(),
        age: int.parse(_ageCtrl.text),
        gender: _gender,
        totalChol: double.parse(_cholCtrl.text),
        hdlChol: double.parse(_hdlCtrl.text),
        systolicBp: int.parse(_bpCtrl.text),
        isBpTreated: _bpTreated,
        isSmoker: _smoker,
        riskPercent: _result!,
      ),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Framingham score saved!'),
        backgroundColor: Colors.green,
      ),
    );
    setState(() => _saving = false);
  }

  @override
  void dispose() {
    _ageCtrl.dispose();
    _cholCtrl.dispose();
    _hdlCtrl.dispose();
    _bpCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    Color resultColor = _result == null
        ? Colors.grey
        : _result! < 10
        ? Colors.green
        : _result! < 20
        ? Colors.orange
        : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.framinghamTitle),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.of(context).pushNamed(RouteNames.framinghamHistory),
            child: Text(l.history, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: InputDecoration(
                  labelText: l.gender,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'male', child: Text(l.male)),
                  DropdownMenuItem(value: 'female', child: Text(l.female)),
                ],
                onChanged: (v) => setState(() {
                  _gender = v!;
                  _result = null;
                }),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ageCtrl,
                decoration: InputDecoration(
                  labelText: l.age,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: Validators.number,
                onChanged: (_) => setState(() => _result = null),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _cholCtrl,
                decoration: InputDecoration(
                  labelText: l.totalCholesterol,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: Validators.number,
                onChanged: (_) => setState(() => _result = null),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _hdlCtrl,
                decoration: InputDecoration(
                  labelText: l.hdlCholesterol,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: Validators.number,
                onChanged: (_) => setState(() => _result = null),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _bpCtrl,
                decoration: InputDecoration(
                  labelText: l.systolicBP,
                  border: const OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: Validators.number,
                onChanged: (_) => setState(() => _result = null),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                title: Text(l.bpTreated),
                value: _bpTreated,
                onChanged: (v) => setState(() {
                  _bpTreated = v;
                  _result = null;
                }),
              ),
              SwitchListTile(
                title: Text(l.smoker),
                value: _smoker,
                onChanged: (v) => setState(() {
                  _smoker = v;
                  _result = null;
                }),
              ),
              const SizedBox(height: 16),
              Row(
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
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        label: Text(l.save),
                      ),
                    ),
                  ],
                ],
              ),
              if (_result != null) ...[
                const SizedBox(height: 20),
                Card(
                  color: resultColor.withOpacity(0.1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: resultColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          l.riskPercent,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${_result!.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: resultColor,
                          ),
                        ),
                        Text(
                          _category ?? '',
                          style: TextStyle(fontSize: 16, color: resultColor),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
