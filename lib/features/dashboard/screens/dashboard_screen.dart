import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:my_health_app/l10n/app_localizations.dart';
import '../providers/dashboard_provider.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/loading_indicator.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final dash = context.watch<DashboardProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(l.dashboard)),
      drawer: const AppDrawer(),
      body: dash.isLoading
          ? const LoadingIndicator()
          : RefreshIndicator(
              onRefresh: () => context.read<DashboardProvider>().loadAll(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _quoteCard(context, l, dash),
                  const SizedBox(height: 16),
                  _weatherCard(context, l, dash),
                  const SizedBox(height: 16),
                  _aqiCard(context, l, dash),
                ],
              ),
            ),
    );
  }

  Widget _quoteCard(BuildContext context, AppLocalizations l, DashboardProvider dash) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.format_quote, color: Colors.white70),
              const SizedBox(width: 8),
              Text(l.motivationalQuote,
                  style: const TextStyle(color: Colors.white70, fontSize: 12)),
            ]),
            const SizedBox(height: 12),
            Text(
              dash.quote?['quote'] ?? '',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic),
            ),
            if (dash.quote?['author']?.isNotEmpty == true) ...[
              const SizedBox(height: 8),
              Text('— ${dash.quote!['author']}',
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _weatherCard(BuildContext context, AppLocalizations l, DashboardProvider dash) {
    final w = dash.weather;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.wb_sunny, color: Color(0xFFFFA726)),
              const SizedBox(width: 8),
              Text('${l.weather} — ${l.heraklion}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            if (w == null)
              const Text('Weather data unavailable')
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(children: [
                    Text(w.icon, style: const TextStyle(fontSize: 36)),
                    Text(w.description),
                  ]),
                  Column(children: [
                    Text('${w.temperature.toStringAsFixed(1)}°C',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    Text('Wind: ${w.windSpeed.toStringAsFixed(1)} km/h'),
                  ]),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _aqiCard(BuildContext context, AppLocalizations l, DashboardProvider dash) {
    final aqi = dash.airQuality;
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.air, color: Color(0xFF26C6DA)),
              const SizedBox(width: 8),
              Text(l.airQuality, style: const TextStyle(fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            if (aqi == null)
              const Text('Air quality data unavailable')
            else
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _aqiItem('AQI', '${aqi.europeanAqi}', aqi.aqiLabel),
                  _aqiItem('PM10', '${aqi.pm10.toStringAsFixed(1)} µg/m³', ''),
                  _aqiItem('PM2.5', '${aqi.pm25.toStringAsFixed(1)} µg/m³', ''),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _aqiItem(String label, String value, String sub) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (sub.isNotEmpty) Text(sub, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
