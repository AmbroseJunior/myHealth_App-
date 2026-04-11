import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_health_app/l10n/app_localizations.dart';
import '../../providers/who5_provider.dart';
import '../../../../features/auth/providers/auth_provider.dart';
import '../../../../core/utils/score_calculators.dart';
import '../../../../core/utils/app_date_utils.dart';

class Who5HistoryScreen extends StatefulWidget {
  const Who5HistoryScreen({super.key});

  @override
  State<Who5HistoryScreen> createState() => _Who5HistoryScreenState();
}

class _Who5HistoryScreenState extends State<Who5HistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().userId;
      context.read<Who5Provider>().load(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final prov = context.watch<Who5Provider>();

    return Scaffold(
      appBar: AppBar(title: Text(l.who5History)),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : prov.results.isEmpty
              ? Center(child: Text(l.noHistory))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: prov.results.length,
                  itemBuilder: (_, i) {
                    final r = prov.results[i];
                    final pct = r.totalScore * 4;
                    final cat = who5Category(r.totalScore);
                    Color catColor = pct >= 52 ? Colors.green : pct >= 28 ? Colors.orange : Colors.red;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: catColor,
                          child: Text('$pct', style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ),
                        title: Text('Score: ${r.totalScore}/25 ($pct%)'),
                        subtitle: Text('$cat\n${AppDateUtils.formatDateDisplay(DateTime.parse(r.recordedAt))}'),
                        isThreeLine: true,
                      ),
                    );
                  },
                ),
    );
  }
}
