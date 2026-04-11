import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/settings/providers/locale_provider.dart';
import '../constants/route_names.dart';
import 'package:my_health_app/l10n/app_localizations.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final auth = context.watch<AuthProvider>();

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const Icon(Icons.health_and_safety, color: Colors.white, size: 40),
                const SizedBox(height: 8),
                Text(l.appTitle,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                Text(auth.currentUser?['email'] ?? '',
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          _tile(context, Icons.home, l.dashboard, RouteNames.dashboard),
          _tile(context, Icons.person, l.demographics, RouteNames.demographics),
          const Divider(),
          _tile(context, Icons.psychology, l.who5Title, RouteNames.who5),
          _tile(context, Icons.favorite, l.framinghamTitle, RouteNames.framingham),
          _tile(context, Icons.monitor_heart, l.findRiscTitle, RouteNames.findrisc),
          const Divider(),
          _tile(context, Icons.warning_amber, l.allergies, RouteNames.allergies),
          _tile(context, Icons.medication, l.medications, RouteNames.medications),
          _tile(context, Icons.list_alt, l.problems, RouteNames.problems),
          const Divider(),
          _tile(context, Icons.calendar_month, l.calendar, RouteNames.calendar),
          _tile(context, Icons.settings, l.settings, RouteNames.settings),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text(l.logout),
            onTap: () {
              context.read<AuthProvider>().logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                  RouteNames.login, (_) => false);
            },
          ),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String label, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).pushNamed(route);
      },
    );
  }
}
