/// Lightweight in-memory circular activity log for debug builds.
/// Captures screen visits, Peso interactions, and key app events.
/// Resets on each cold start (in-memory only).
class PesoActivityLog {
  static const _maxEvents = 150;
  static final List<String> _events = [];

  static void log(String event) {
    final ts = DateTime.now().toIso8601String().substring(11, 19);
    _events.add('[$ts] $event');
    if (_events.length > _maxEvents) _events.removeAt(0);
  }

  static List<String> get events => List.unmodifiable(_events);

  static String get exportBlock {
    if (_events.isEmpty) return '  (no events this session)\n';
    return _events.map((e) => '  $e').join('\n') + '\n';
  }
}
