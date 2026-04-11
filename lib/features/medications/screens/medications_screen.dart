import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:my_health_app/l10n/app_localizations.dart';
import '../providers/medications_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/confirm_dialog.dart';
import '../../../core/utils/app_date_utils.dart';
import '../../../core/constants/route_names.dart';

class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MedicationsProvider>().load(context.read<AuthProvider>().userId);
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final prov = context.watch<MedicationsProvider>();
    final userId = context.read<AuthProvider>().userId;

    final current = prov.medications.where((m) => m.isOngoing).toList();
    final past = prov.medications.where((m) => !m.isOngoing).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.medications),
        bottom: TabBar(
          controller: _tabs,
          tabs: [Tab(text: l.currentMedications), Tab(text: l.history)],
        ),
      ),
      drawer: const AppDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(RouteNames.medicationForm),
        child: const Icon(Icons.add),
      ),
      body: prov.isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabs,
              children: [
                _medList(context, l, current, userId, prov),
                _medList(context, l, past, userId, prov),
              ],
            ),
    );
  }

  Widget _medList(BuildContext context, AppLocalizations l, List meds, int userId, MedicationsProvider prov) {
    if (meds.isEmpty) return Center(child: Text(l.noMedications));
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: meds.length,
      itemBuilder: (_, i) {
        final m = meds[i];
        return Slidable(
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              SlidableAction(
                onPressed: (_) => Navigator.of(context)
                    .pushNamed(RouteNames.medicationForm, arguments: m),
                backgroundColor: Colors.blue,
                icon: Icons.edit,
                label: l.edit,
              ),
              SlidableAction(
                onPressed: (_) => ConfirmDialog.show(context,
                    title: l.delete,
                    content: l.deleteConfirm,
                    onConfirm: () => prov.delete(m.id!, userId)),
                backgroundColor: Colors.red,
                icon: Icons.delete,
                label: l.delete,
              ),
            ],
          ),
          child: Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: ListTile(
              leading: const CircleAvatar(child: Icon(Icons.medication)),
              title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text([
                if (m.dosage != null) m.dosage!,
                if (m.frequency != null) m.frequency!,
                if (m.startDate != null) 'Since: ${AppDateUtils.formatDateDisplay(DateTime.parse(m.startDate!))}',
                m.isOngoing ? 'Ongoing' : (m.endDate != null ? 'Until: ${AppDateUtils.formatDateDisplay(DateTime.parse(m.endDate!))}' : ''),
              ].where((s) => s.isNotEmpty).join(' · ')),
              isThreeLine: false,
              onTap: () => Navigator.of(context)
                  .pushNamed(RouteNames.medicationHistory, arguments: m.id),
            ),
          ),
        );
      },
    );
  }
}
