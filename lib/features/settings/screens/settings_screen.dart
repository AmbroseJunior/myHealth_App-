import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_health_app/l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/constants/route_names.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final localeProv = context.watch<LocaleProvider>();
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account info card
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const CircleAvatar(radius: 28, child: Icon(Icons.person, size: 32)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      auth.currentUser?.email ?? '',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Language section
          Text(l.language,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 8),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text(l.english),
                  secondary: const Text('🇬🇧', style: TextStyle(fontSize: 24)),
                  value: 'en',
                  groupValue: localeProv.locale.languageCode,
                  onChanged: (v) => localeProv.setLocale(Locale(v!)),
                ),
                const Divider(height: 1),
                RadioListTile<String>(
                  title: Text(l.greek),
                  secondary: const Text('🇬🇷', style: TextStyle(fontSize: 24)),
                  value: 'el',
                  groupValue: localeProv.locale.languageCode,
                  onChanged: (v) => localeProv.setLocale(Locale(v!)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Logout
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.logout, color: Colors.red),
              label: Text(l.logout, style: const TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.red)),
              onPressed: () async {
                await context.read<AuthProvider>().logout();
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.login, (_) => false);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
