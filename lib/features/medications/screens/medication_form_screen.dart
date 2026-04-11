import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_health_app/l10n/app_localizations.dart';
import '../providers/medications_provider.dart';
import '../models/medication_model.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/app_date_utils.dart';

class MedicationFormScreen extends StatefulWidget {
  const MedicationFormScreen({super.key});

  @override
  State<MedicationFormScreen> createState() => _MedicationFormScreenState();
}

class _MedicationFormScreenState extends State<MedicationFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _freqCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _isOngoing = true;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _saving = false;
  MedicationModel? _editing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_editing == null) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is MedicationModel) {
        _editing = arg;
        _nameCtrl.text = arg.name;
        _dosageCtrl.text = arg.dosage ?? '';
        _freqCtrl.text = arg.frequency ?? '';
        _notesCtrl.text = arg.notes ?? '';
        _isOngoing = arg.isOngoing;
        _startDate = arg.startDate != null ? DateTime.tryParse(arg.startDate!) : null;
        _endDate = arg.endDate != null ? DateTime.tryParse(arg.endDate!) : null;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _dosageCtrl.dispose();
    _freqCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final userId = context.read<AuthProvider>().userId;
    final now = AppDateUtils.nowIso();
    final model = MedicationModel(
      id: _editing?.id,
      userId: userId,
      name: _nameCtrl.text.trim(),
      dosage: _dosageCtrl.text.trim().isEmpty ? null : _dosageCtrl.text.trim(),
      frequency: _freqCtrl.text.trim().isEmpty ? null : _freqCtrl.text.trim(),
      startDate: _startDate != null ? AppDateUtils.formatDate(_startDate!) : null,
      endDate: _endDate != null ? AppDateUtils.formatDate(_endDate!) : null,
      isOngoing: _isOngoing,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: _editing?.createdAt ?? now,
      updatedAt: now,
    );
    final prov = context.read<MedicationsProvider>();
    if (_editing != null) {
      await prov.update(model);
    } else {
      await prov.add(model);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _pickDate(bool isStart) async {
    final d = await showDatePicker(
      context: context,
      initialDate: (isStart ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (d != null) setState(() => isStart ? _startDate = d : _endDate = d);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isEdit = _editing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? l.editMedication : l.addMedication)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: InputDecoration(labelText: l.medicationName, border: const OutlineInputBorder()),
                validator: (v) => Validators.required(v, l.fieldRequired),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _dosageCtrl,
                decoration: InputDecoration(labelText: l.dosage, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _freqCtrl,
                decoration: InputDecoration(labelText: l.frequency, border: const OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(l.startDate),
                subtitle: Text(_startDate != null ? AppDateUtils.formatDateDisplay(_startDate!) : 'Not set'),
                trailing: const Icon(Icons.calendar_today),
                onTap: () => _pickDate(true),
                shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                title: Text(l.ongoing),
                value: _isOngoing,
                onChanged: (v) => setState(() => _isOngoing = v),
              ),
              if (!_isOngoing) ...[
                const SizedBox(height: 8),
                ListTile(
                  title: Text(l.endDate),
                  subtitle: Text(_endDate != null ? AppDateUtils.formatDateDisplay(_endDate!) : 'Not set'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _pickDate(false),
                  shape: RoundedRectangleBorder(side: const BorderSide(color: Colors.grey), borderRadius: BorderRadius.circular(4)),
                ),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: InputDecoration(labelText: l.notes, border: const OutlineInputBorder()),
                maxLines: 3,
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
