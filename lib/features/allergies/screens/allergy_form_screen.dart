import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_health_app/l10n/app_localizations.dart';
import '../providers/allergies_provider.dart';
import '../models/allergy_model.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/app_date_utils.dart';

class AllergyFormScreen extends StatefulWidget {
  const AllergyFormScreen({super.key});

  @override
  State<AllergyFormScreen> createState() => _AllergyFormScreenState();
}

class _AllergyFormScreenState extends State<AllergyFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _allergenCtrl = TextEditingController();
  final _reactionCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String? _severity;
  DateTime? _onsetDate;
  bool _saving = false;
  AllergyModel? _editing;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_editing == null) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is AllergyModel) {
        _editing = arg;
        _allergenCtrl.text = arg.allergen;
        _reactionCtrl.text = arg.reaction ?? '';
        _notesCtrl.text = arg.notes ?? '';
        _severity = arg.severity;
        _onsetDate = arg.onsetDate != null
            ? DateTime.tryParse(arg.onsetDate!)
            : null;
      }
    }
  }

  @override
  void dispose() {
    _allergenCtrl.dispose();
    _reactionCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final userId = context.read<AuthProvider>().userId;
    final now = AppDateUtils.nowIso();
    final model = AllergyModel(
      id: _editing?.id,
      userId: userId,
      allergen: _allergenCtrl.text.trim(),
      reaction: _reactionCtrl.text.trim().isEmpty
          ? null
          : _reactionCtrl.text.trim(),
      severity: _severity,
      onsetDate: _onsetDate != null
          ? AppDateUtils.formatDate(_onsetDate!)
          : null,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: _editing?.createdAt ?? now,
    );
    final prov = context.read<AllergiesProvider>();
    if (_editing != null) {
      await prov.update(model);
    } else {
      await prov.add(model);
    }
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isEdit = _editing != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? l.editAllergy : l.addAllergy)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _allergenCtrl,
                decoration: InputDecoration(
                  labelText: l.allergen,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => Validators.required(v, l.fieldRequired),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _reactionCtrl,
                decoration: InputDecoration(
                  labelText: l.reaction,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _severity,
                decoration: InputDecoration(
                  labelText: l.severity,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(value: 'mild', child: Text(l.severityMild)),
                  DropdownMenuItem(
                    value: 'moderate',
                    child: Text(l.severityModerate),
                  ),
                  DropdownMenuItem(
                    value: 'severe',
                    child: Text(l.severitySevere),
                  ),
                ],
                onChanged: (v) => setState(() => _severity = v),
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(l.onsetDate),
                subtitle: Text(
                  _onsetDate != null
                      ? AppDateUtils.formatDateDisplay(_onsetDate!)
                      : 'Not set',
                ),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _onsetDate ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (d != null) setState(() => _onsetDate = d);
                },
                shape: RoundedRectangleBorder(
                  side: const BorderSide(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesCtrl,
                decoration: InputDecoration(
                  labelText: l.notes,
                  border: const OutlineInputBorder(),
                ),
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
