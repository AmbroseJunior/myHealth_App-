import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_health_app/l10n/app_localizations.dart';
import '../providers/demographics_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../../core/constants/route_names.dart';
import '../../../core/utils/app_date_utils.dart';

class DemographicsScreen extends StatefulWidget {
  const DemographicsScreen({super.key});

  @override
  State<DemographicsScreen> createState() => _DemographicsScreenState();
}

class _DemographicsScreenState extends State<DemographicsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userId = context.read<AuthProvider>().userId;
      context.read<DemographicsProvider>().load(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final demo = context.watch<DemographicsProvider>();
    final p = demo.patient;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.demographics),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.of(context).pushNamed(RouteNames.demographicsEdit),
          )
        ],
      ),
      drawer: const AppDrawer(),
      body: demo.isLoading
          ? const LoadingIndicator()
          : p == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.person_add, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(l.noDemographics, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pushNamed(RouteNames.demographicsEdit),
                        child: Text(l.editProfile),
                      ),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 50)),
                            const SizedBox(height: 12),
                            Text(p.fullName,
                                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _infoCard([
                      _row(l.dateOfBirth, p.dateOfBirth != null
                          ? AppDateUtils.formatDateDisplay(DateTime.parse(p.dateOfBirth!))
                          : '—'),
                      _row(l.gender, p.gender ?? '—'),
                      _row(l.race, p.race ?? '—'),
                      _row(l.ethnicity, p.ethnicity ?? '—'),
                      _row(l.location, p.location ?? '—'),
                    ]),
                  ],
                ),
    );
  }

  Widget _infoCard(List<Widget> rows) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: rows),
      ),
    );
  }

  Widget _row(String label, String value) {
    return ListTile(
      title: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      subtitle: Text(value, style: const TextStyle(fontSize: 16)),
    );
  }
}
