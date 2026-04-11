enum CalendarEventType { who5, framingham, findrisc, allergy, medication, problem }

class CalendarEventModel {
  final String title;
  final CalendarEventType type;
  final DateTime date;
  final String? subtitle;

  CalendarEventModel({
    required this.title,
    required this.type,
    required this.date,
    this.subtitle,
  });

  String get typeLabel {
    switch (type) {
      case CalendarEventType.who5: return 'WHO-5';
      case CalendarEventType.framingham: return 'Framingham';
      case CalendarEventType.findrisc: return 'FINDRISC';
      case CalendarEventType.allergy: return 'Allergy';
      case CalendarEventType.medication: return 'Medication';
      case CalendarEventType.problem: return 'Problem';
    }
  }

  String get typeIcon {
    switch (type) {
      case CalendarEventType.who5: return '🧠';
      case CalendarEventType.framingham: return '❤️';
      case CalendarEventType.findrisc: return '🩸';
      case CalendarEventType.allergy: return '⚠️';
      case CalendarEventType.medication: return '💊';
      case CalendarEventType.problem: return '📋';
    }
  }
}
