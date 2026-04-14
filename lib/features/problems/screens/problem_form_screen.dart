import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_health_app/l10n/app_localizations.dart';
import '../providers/problems_provider.dart';
import '../models/problem_model.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/utils/icd10_search.dart';
import '../../../core/utils/validators.dart';
import '../../../core/utils/app_date_utils.dart';

class ProblemFormScreen extends StatefulWidget {
  const ProblemFormScreen({super.key});

  @override
  State<ProblemFormScreen> createState() => _ProblemFormScreenState();
}

class _ProblemFormScreenState extends State<ProblemFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _searchCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  String _status = 'active';
  DateTime? _onsetDate;
  bool _saving = false;
  ProblemModel? _editing;

  List<Icd10Entry> _searchResults = [];
  bool _searching = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_editing == null) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is ProblemModel) {
        _editing = arg;
        _codeCtrl.text = arg.icd10Code;
        _titleCtrl.text = arg.icd10Title;
        _notesCtrl.text = arg.notes ?? '';
        _status = arg.status;
        _onsetDate = arg.onsetDate != null
            ? DateTime.tryParse(arg.onsetDate!)
            : null;
      }
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _codeCtrl.dispose();
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSearch(String q) async {
    if (q.trim().length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _searching = true);
    final results = await Icd10Search.search(q);
    setState(() {
      _searchResults = results;
      _searching = false;
    });
  }

  void _selectIcd(Icd10Entry entry) {
    _codeCtrl.text = entry.code;
    _titleCtrl.text = entry.title;
    _searchCtrl.clear();
    setState(() => _searchResults = []);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final userId = context.read<AuthProvider>().userId;
    final model = ProblemModel(
      id: _editing?.id,
      userId: userId,
      icd10Code: _codeCtrl.text.trim().toUpperCase(),
      icd10Title: _titleCtrl.text.trim(),
      status: _status,
      onsetDate: _onsetDate != null
          ? AppDateUtils.formatDate(_onsetDate!)
          : null,
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: _editing?.createdAt ?? AppDateUtils.nowIso(),
    );
    final prov = context.read<ProblemsProvider>();
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
      appBar: AppBar(title: Text(isEdit ? l.editProblem : l.addProblem)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ICD-10 search
              TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  labelText: l.searchIcd,
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searching
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                ),
                onChanged: _onSearch,
              ),
              if (_searchResults.isNotEmpty)
                Card(
                  margin: const EdgeInsets.only(top: 0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 220),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (_, i) {
                        final e = _searchResults[i];
                        return ListTile(
                          dense: true,
                          title: Text(
                            '${e.code} — ${e.title}',
                            style: const TextStyle(fontSize: 13),
                          ),
                          onTap: () => _selectIcd(e),
                        );
                      },
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _codeCtrl,
                decoration: InputDecoration(
                  labelText: l.icd10Code,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => Validators.required(v, l.fieldRequired),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _titleCtrl,
                decoration: InputDecoration(
                  labelText: l.diagnosis,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => Validators.required(v, l.fieldRequired),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: InputDecoration(
                  labelText: l.status,
                  border: const OutlineInputBorder(),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'active',
                    child: Text(l.statusActive),
                  ),
                  DropdownMenuItem(
                    value: 'resolved',
                    child: Text(l.statusResolved),
                  ),
                  DropdownMenuItem(
                    value: 'chronic',
                    child: Text(l.statusChronic),
                  ),
                ],
                onChanged: (v) => setState(() => _status = v!),
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
