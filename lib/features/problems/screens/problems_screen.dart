import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:my_health_app/l10n/app_localizations.dart';
import '../providers/problems_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../core/constants/route_names.dart';

class ProblemsScreen extends StatefulWidget {
  const ProblemsScreen({super.key});

  @override
  State<ProblemsScreen> createState() => _ProblemsScreenState();
}

class _ProblemsScreenState extends State<ProblemsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProblemsProvider>().load(context.read<AuthProvider>().userId);
    });
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active': return Colors.red.shade400;
      case 'chronic': return Colors.orange;
      case 'resolved': return Colors.green;
      default: return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'active': return Icons.emergency;
      case 'chronic': return Icons.repeat;
      case 'resolved': return Icons.check_circle;
      default: return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final prov = context.watch<ProblemsProvider>();
    final userId = context.read<AuthProvider>().userId;

    return Scaffold(
      appBar: AppBar(title: Text(l.problems)),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(RouteNames.problemForm),
        child: const Icon(Icons.add),
      ),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : prov.problems.isEmpty
              ? Center(child: Text(l.noProblems))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: prov.problems.length,
                  itemBuilder: (_, i) {
                    final p = prov.problems[i];
                    return Slidable(
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) => Navigator.of(context)
                                .pushNamed(RouteNames.problemForm, arguments: p),
                            backgroundColor: Colors.blue,
                            icon: Icons.edit,
                            label: l.edit,
                          ),
                          SlidableAction(
                            onPressed: (_) => ConfirmDialog.show(context,
                                title: l.delete,
                                content: l.deleteConfirm,
                                onConfirm: () => prov.delete(p.id!, userId)),
                            backgroundColor: Colors.red,
                            icon: Icons.delete,
                            label: l.delete,
                          ),
                        ],
                      ),
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: _statusColor(p.status),
                            child: Icon(_statusIcon(p.status), color: Colors.white, size: 18),
                          ),
                          title: Text(
                            '${p.icd10Code} — ${p.icd10Title}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          ),
                          subtitle: Text([
                            p.status.toUpperCase(),
                            if (p.onsetDate != null)
                              'Since: ${AppDateUtils.formatDateDisplay(DateTime.parse(p.onsetDate!))}',
                            if (p.notes != null) p.notes!,
                          ].join(' · ')),
                          isThreeLine: p.notes != null,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
