import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:my_health_app/l10n/app_localizations.dart';
import '../providers/calendar_provider.dart';
import '../models/calendar_event_model.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../core/widgets/app_drawer.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CalendarProvider>().load(context.read<AuthProvider>().userId);
    });
  }

  Color _eventColor(CalendarEventType type) {
    switch (type) {
      case CalendarEventType.who5: return Colors.purple;
      case CalendarEventType.framingham: return Colors.red;
      case CalendarEventType.findrisc: return Colors.orange;
      case CalendarEventType.allergy: return Colors.amber;
      case CalendarEventType.medication: return Colors.blue;
      case CalendarEventType.problem: return Colors.teal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final calProv = context.watch<CalendarProvider>();
    final selectedEvents = calProv.eventsForDay(_selectedDay ?? DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text(l.calendarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => calProv.load(context.read<AuthProvider>().userId),
          )
        ],
      ),
      drawer: const AppDrawer(),
      body: calProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                TableCalendar<CalendarEventModel>(
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2030),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  eventLoader: calProv.eventsForDay,
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      if (events.isEmpty) return null;
                      return Positioned(
                        bottom: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: events.take(4).map((e) => Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 0.5),
                            decoration: BoxDecoration(
                              color: _eventColor(e.type),
                              shape: BoxShape.circle,
                            ),
                          )).toList(),
                        ),
                      );
                    },
                  ),
                  onDaySelected: (selected, focused) {
                    setState(() {
                      _selectedDay = selected;
                      _focusedDay = focused;
                    });
                  },
                  onPageChanged: (focused) => _focusedDay = focused,
                ),
                const Divider(height: 1),
                Expanded(
                  child: selectedEvents.isEmpty
                      ? Center(child: Text(l.noEvents, style: const TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: selectedEvents.length,
                          itemBuilder: (_, i) {
                            final e = selectedEvents[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: _eventColor(e.type),
                                  child: Text(e.typeIcon, style: const TextStyle(fontSize: 16)),
                                ),
                                title: Text(e.title, style: const TextStyle(fontSize: 14)),
                                subtitle: e.subtitle != null
                                    ? Text('${e.typeLabel} · ${e.subtitle}')
                                    : Text(e.typeLabel),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
