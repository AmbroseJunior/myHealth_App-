import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_health_app/l10n/app_localizations.dart';
import '../providers/demographics_provider.dart';
import '../models/patient_model.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/app_date_utils.dart';

class DemographicsFormScreen extends StatefulWidget {
  const DemographicsFormScreen({super.key});

  @override
  State<DemographicsFormScreen> createState() => _DemographicsFormScreenState();
}

class _DemographicsFormScreenState extends State<DemographicsFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _raceCtrl = TextEditingController();
  final _ethnicityCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  String? _gender;
  DateTime? _dob;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final p = context.read<DemographicsProvider>().patient;
    if (p != null) {
      _firstCtrl.text = p.firstName;
      _lastCtrl.text = p.lastName;
      _raceCtrl.text = p.race ?? '';
      _ethnicityCtrl.text = p.ethnicity ?? '';
      _locationCtrl.text = p.location ?? '';
      _gender = p.gender;
      _dob = p.dateOfBirth != null ? DateTime.tryParse(p.dateOfBirth!) : null;
    }
  }

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _raceCtrl.dispose();
    _ethnicityCtrl.dispose();
    _locationCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final userId = context.read<AuthProvider>().userId;
    final existing = context.read<DemographicsProvider>().patient;
    await context.read<DemographicsProvider>().save(
      PatientModel(
        id: existing?.id,
        userId: userId,
        firstName: _firstCtrl.text.trim(),
        lastName: _lastCtrl.text.trim(),
        dateOfBirth: _dob != null ? AppDateUtils.formatDate(_dob!) : null,
        gender: _gender,
        race: _raceCtrl.text.trim(),
        ethnicity: _ethnicityCtrl.text.trim(),
        location: _locationCtrl.text.trim(),
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l.editProfile)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _firstCtrl,
                decoration: InputDecoration(
                  labelText: l.firstName,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => Validators.required(v, l.fieldRequired),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastCtrl,
                decoration: InputDecoration(
                  labelText: l.lastName,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => Validators.required(v, l.fieldRequired),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(l.dateOfBirth),
                subtitle: Text(
                  _dob != null
                      ? AppDateUtils.formatDateDisplay(_dob!)
                      : 'Not set',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickDate,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _gender,
                decoration: InputDecoration(
                  labelText: l.gender,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'male', child: Text(l.male)),
                  DropdownMenuItem(value: 'female', child: Text(l.female)),
                  DropdownMenuItem(value: 'other', child: Text(l.other)),
                ],
                onChanged: (v) => setState(() => _gender = v),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _raceCtrl,
                decoration: InputDecoration(
                  labelText: l.race,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _ethnicityCtrl,
                decoration: InputDecoration(
                  labelText: l.ethnicity,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationCtrl,
                decoration: InputDecoration(
                  labelText: l.location,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _saving ? null : _submit,
                  child: _saving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(l.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
