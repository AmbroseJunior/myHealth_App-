import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_health_app/l10n/app_localizations.dart';
import '../../providers/findrisc_provider.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../core/utils/score_calculators.dart';
import '../../../../core/utils/app_date_utils.dart';

class FindriscHistoryScreen extends StatefulWidget {
  const FindriscHistoryScreen({super.key});

  @override
  State<FindriscHistoryScreen> createState() => _FindriscHistoryScreenState();
}

class _FindriscHistoryScreenState extends State<FindriscHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FindriscProvider>().load(context.read<AuthProvider>().userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final prov = context.watch<FindriscProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l.findRiscHistory)),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : prov.results.isEmpty
              ? Center(child: Text(l.noHistory))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: prov.results.length,
                  itemBuilder: (_, i) {
                    final r = prov.results[i];
                    Color c = r.totalScore <= 6 ? Colors.green
                        : r.totalScore <= 11 ? Colors.lightGreen
                        : r.totalScore <= 14 ? Colors.orange
                        : r.totalScore <= 20 ? Colors.deepOrange
                        : Colors.red;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: c,
                          child: Text('${r.totalScore}',
                              style: const TextStyle(color: Colors.white)),
                        ),
                        title: Text('Score: ${r.totalScore} — ${r.riskCategory}'),
                        subtitle: Text('${findRiscDescription(r.totalScore)}\n${AppDateUtils.formatDateDisplay(DateTime.parse(r.recordedAt))}'),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}
