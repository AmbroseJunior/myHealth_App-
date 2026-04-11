import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_health_app/l10n/app_localizations.dart';
import '../providers/medications_provider.dart';
import '../../../core/utils/app_date_utils.dart';

class MedicationHistoryScreen extends StatefulWidget {
  const MedicationHistoryScreen({super.key});

  @override
  State<MedicationHistoryScreen> createState() => _MedicationHistoryScreenState();
}

class _MedicationHistoryScreenState extends State<MedicationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = ModalRoute.of(context)?.settings.arguments as int?;
      if (id != null) context.read<MedicationsProvider>().loadHistory(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final prov = context.watch<MedicationsProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l.medicationHistory)),
      body: prov.history.isEmpty
          ? Center(child: Text(l.noHistory))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: prov.history.length,
              itemBuilder: (_, i) {
                final h = prov.history[i];
                final snapshot = json.decode(h['snapshot'] as String) as Map<String, dynamic>;
                final changeType = h['change_type'] as String;
                final changedAt = DateTime.parse(h['changed_at'] as String);
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: changeType == 'create' ? Colors.green : Colors.blue,
                      child: Icon(
                        changeType == 'create' ? Icons.add : Icons.edit,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(snapshot['name'] as String? ?? ''),
                    subtitle: Text([
                      changeType.toUpperCase(),
                      AppDateUtils.formatDateDisplay(changedAt),
                      if (snapshot['dosage'] != null) snapshot['dosage'] as String,
                    ].join(' · ')),
                    isThreeLine: false,
                  ),
                );
              },
            ),
    );
  }
}
