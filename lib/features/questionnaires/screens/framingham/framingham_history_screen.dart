import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_health_app/l10n/app_localizations.dart';
import '../../providers/framingham_provider.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../core/utils/score_calculators.dart';
import '../../../../core/utils/app_date_utils.dart';

class FraminghamHistoryScreen extends StatefulWidget {
  const FraminghamHistoryScreen({super.key});

  @override
  State<FraminghamHistoryScreen> createState() => _FraminghamHistoryScreenState();
}

class _FraminghamHistoryScreenState extends State<FraminghamHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FraminghamProvider>().load(context.read<AuthProvider>().userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final prov = context.watch<FraminghamProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l.framinghamHistory)),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : prov.results.isEmpty
              ? Center(child: Text(l.noHistory))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: prov.results.length,
                  itemBuilder: (_, i) {
                    final r = prov.results[i];
                    final cat = framinghamRiskCategory(r.riskPercent);
                    Color c = r.riskPercent < 10 ? Colors.green : r.riskPercent < 20 ? Colors.orange : Colors.red;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: c,
                          child: Text('${r.riskPercent.toStringAsFixed(0)}%',
                              style: const TextStyle(color: Colors.white, fontSize: 11)),
                        ),
                        title: Text('CVD Risk: ${r.riskPercent.toStringAsFixed(1)}%'),
                        subtitle: Text('$cat\nAge: ${r.age}, Gender: ${r.gender}\n${AppDateUtils.formatDateDisplay(DateTime.parse(r.recordedAt))}'),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}
