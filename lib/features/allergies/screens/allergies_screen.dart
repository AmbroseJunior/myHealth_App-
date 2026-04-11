import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:my_health_app/l10n/app_localizations.dart';
import '../providers/allergies_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../core/constants/route_names.dart';

class AllergiesScreen extends StatefulWidget {
  const AllergiesScreen({super.key});

  @override
  State<AllergiesScreen> createState() => _AllergiesScreenState();
}

class _AllergiesScreenState extends State<AllergiesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AllergiesProvider>().load(context.read<AuthProvider>().userId);
    });
  }

  Color _severityColor(String? severity) {
    switch (severity) {
      case 'mild': return Colors.green;
      case 'moderate': return Colors.orange;
      case 'severe': return Colors.red;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final prov = context.watch<AllergiesProvider>();
    final userId = context.read<AuthProvider>().userId;

    return Scaffold(
      appBar: AppBar(title: Text(l.allergies)),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(RouteNames.allergyForm),
        child: const Icon(Icons.add),
      ),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : prov.allergies.isEmpty
              ? Center(child: Text(l.noAllergies))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: prov.allergies.length,
                  itemBuilder: (_, i) {
                    final a = prov.allergies[i];
                    return Slidable(
                      endActionPane: ActionPane(
                        motion: const DrawerMotion(),
                        children: [
                          SlidableAction(
                            onPressed: (_) => Navigator.of(context)
                                .pushNamed(RouteNames.allergyForm, arguments: a),
                            backgroundColor: Colors.blue,
                            icon: Icons.edit,
                            label: l.edit,
                          ),
                          SlidableAction(
                            onPressed: (_) => ConfirmDialog.show(
                              context,
                              title: l.delete,
                              content: l.deleteConfirm,
                              onConfirm: () => prov.delete(a.id!, userId),
                            ),
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
                            backgroundColor: _severityColor(a.severity),
                            child: const Icon(Icons.warning_amber, color: Colors.white),
                          ),
                          title: Text(a.allergen, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text([
                            if (a.reaction != null) 'Reaction: ${a.reaction}',
                            if (a.severity != null) 'Severity: ${a.severity}',
                            if (a.onsetDate != null) 'Onset: ${AppDateUtils.formatDateDisplay(DateTime.parse(a.onsetDate!))}',
                          ].join('\n')),
                          isThreeLine: true,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
