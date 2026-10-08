import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/db_service.dart';
import '../widgets/info_button.dart';
import '../widgets/peso_mascot.dart';

/// Entry point — shows a list of chat sessions (WhatsApp-style).
class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  List<Map<String, dynamic>> _sessions = [];
  bool _loading = true;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final sessions = await DBService.getChatSessions();
    setState(() {
      _sessions = sessions;
      _loading = false;
    });
  }

  String _sessionTitle(Map<String, dynamic> session) {
    final title = session['title'] as String?;
    if (title != null && title.isNotEmpty) return title;
    final first = session['first_user_message'] as String?;
    if (first != null && first.isNotEmpty) {
      return first.length > 40 ? '${first.substring(0, 40)}…' : first;
    }
    // Fallback to date
    final created = session['created_at'] as String? ?? '';
    try {
      final dt = DateTime.parse(created);
      return DateFormat('MMM d, y').format(dt);
    } catch (_) {
      return 'Chat session';
    }
  }

  String _relativeTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final now = DateTime.now();
      final diff = now.difference(dt);
      if (diff.inDays == 0) return 'Today';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return DateFormat('EEEE').format(dt);
      if (diff.inDays < 365) return DateFormat('MMM d').format(dt);
      return DateFormat('MMM d, y').format(dt);
    } catch (_) {
      return '';
    }
  }

  bool _isArchived(Map<String, dynamic> s) =>
      (s['archived_at'] as String?) != null;

  bool _isCurrent(Map<String, dynamic> s) => (s['is_current'] as int?) == 1;

  List<Map<String, dynamic>> _filtered() {
    if (_searchQuery.isEmpty) return _sessions;
    final q = _searchQuery.toLowerCase();
    return _sessions.where((s) {
      final title = _sessionTitle(s).toLowerCase();
      final first = (s['first_user_message'] as String? ?? '').toLowerCase();
      return title.contains(q) || first.contains(q);
    }).toList();
  }

  Future<void> _deleteSession(Map<String, dynamic> session) async {
    final id = session['id'] as int;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete session?'),
        content: Text(
            'Delete "${_sessionTitle(session)}" and all its messages? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await DBService.deleteChatSession(id);
    _load();
  }

  Future<void> _archiveSession(Map<String, dynamic> session) async {
    await DBService.archiveChatSession(session['id'] as int);
    _load();
  }

  Future<void> _renameSession(Map<String, dynamic> session) async {
    final ctrl = TextEditingController(text: _sessionTitle(session));
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Rename session'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: 60,
          decoration: const InputDecoration(hintText: 'Session name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(context, ctrl.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await DBService.renameChatSession(session['id'] as int, result);
      _load();
    }
  }

  void _openSession(Map<String, dynamic> session) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _ChatSessionViewScreen(
          session: session,
          sessionTitle: _sessionTitle(session),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final sessions = _filtered();

    // Bucket into Active, Older, Archived
    final current =
        sessions.where((s) => _isCurrent(s) && !_isArchived(s)).toList();
    final recent = sessions
        .where((s) =>
            !_isCurrent(s) &&
            !_isArchived(s) &&
            (() {
              try {
                final dt = DateTime.parse(s['created_at'] as String? ?? '');
                return DateTime.now().difference(dt).inDays <= 30;
              } catch (_) {
                return false;
              }
            })())
        .toList();
    final older = sessions
        .where((s) =>
            !_isCurrent(s) &&
            !_isArchived(s) &&
            (() {
              try {
                final dt = DateTime.parse(s['created_at'] as String? ?? '');
                return DateTime.now().difference(dt).inDays > 30;
              } catch (_) {
                return false;
              }
            })())
        .toList();
    final archived = sessions.where(_isArchived).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat History'),
        actions: [
          const InfoButton(
            title: 'Chat History',
            body: 'Browse all your previous AI conversations.\n\n'
                '• Tap a session to read it\n'
                '• Long-press to rename, archive, or delete\n'
                '• Use "New Chat" in the AI screen to start a fresh conversation\n'
                '• Archived sessions are preserved but moved out of the main list\n\n'
                'Chat history is cleared when you log out — each account\'s conversations are private.',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? Center(
                  child: PesoMascot.withSpeech(
                    mood: PesoMood.thinking,
                    text:
                        'Wala pa tayong chat history!\nMag-usap tayo sa AI para magsimula.',
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                        child: TextField(
                          controller: _searchCtrl,
                          decoration: InputDecoration(
                            hintText: 'Search sessions…',
                            prefixIcon: const Icon(Icons.search, size: 18),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, size: 16),
                                    onPressed: () => setState(() {
                                      _searchCtrl.clear();
                                      _searchQuery = '';
                                    }),
                                  )
                                : null,
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 10),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                          onChanged: (v) => setState(() => _searchQuery = v),
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.only(bottom: 24),
                          children: [
                            if (current.isNotEmpty) ...[
                              _sectionHeader('● Active', cs),
                              for (final s in current)
                                _sessionTile(s, cs, isCurrent: true),
                            ],
                            if (recent.isNotEmpty) ...[
                              _sectionHeader('● Recent (last 30 days)', cs),
                              for (final s in recent) _sessionTile(s, cs),
                            ],
                            if (older.isNotEmpty) ...[
                              _sectionHeader('● Older', cs),
                              for (final s in older) _sessionTile(s, cs),
                            ],
                            if (archived.isNotEmpty) ...[
                              _sectionHeader('● Archived', cs),
                              for (final s in archived)
                                _sessionTile(s, cs, isArchived: true),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _sectionHeader(String label, ColorScheme cs) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Text(label,
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: cs.onSurface.withValues(alpha: 0.5),
              letterSpacing: 0.4)),
    );
  }

  Widget _sessionTile(Map<String, dynamic> session, ColorScheme cs,
      {bool isCurrent = false, bool isArchived = false}) {
    final msgCount = session['message_count'] as int? ?? 0;
    final created = session['created_at'] as String? ?? '';
    final title = _sessionTitle(session);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isCurrent
            ? cs.primary.withValues(alpha: 0.15)
            : cs.surfaceContainerHighest,
        child: Icon(
          isCurrent ? Icons.chat_bubble : Icons.chat_bubble_outline,
          color: isCurrent ? cs.primary : cs.onSurface.withValues(alpha: 0.5),
          size: 18,
        ),
      ),
      title: Text(
        title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          fontSize: 13.5,
        ),
      ),
      subtitle: Text(
        '$msgCount messages · ${_relativeTime(created)}${isArchived ? ' · archived' : ''}',
        style:
            TextStyle(fontSize: 11, color: cs.onSurface.withValues(alpha: 0.5)),
      ),
      trailing: const Icon(Icons.chevron_right, size: 16),
      onTap: () => _openSession(session),
      onLongPress: () => _showSessionMenu(session),
    );
  }

  void _showSessionMenu(Map<String, dynamic> session) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Rename'),
              onTap: () {
                Navigator.pop(context);
                _renameSession(session);
              },
            ),
            if (!_isArchived(session))
              ListTile(
                leading: const Icon(Icons.archive_outlined),
                title: const Text('Archive'),
                onTap: () {
                  Navigator.pop(context);
                  _archiveSession(session);
                },
              ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _deleteSession(session);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─── Session view screen (read-only bubble view) ───────────────────────────

class _ChatSessionViewScreen extends StatefulWidget {
  final Map<String, dynamic> session;
  final String sessionTitle;

  const _ChatSessionViewScreen(
      {required this.session, required this.sessionTitle});

  @override
  State<_ChatSessionViewScreen> createState() => _ChatSessionViewScreenState();
}

class _ChatSessionViewScreenState extends State<_ChatSessionViewScreen> {
  List<Map<String, dynamic>> _messages = [];
  bool _loading = true;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();
  late String _title;

  @override
  void initState() {
    super.initState();
    _title = widget.sessionTitle;
    _load();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final msgs = await DBService.getChatHistoryBySession(
        widget.session['id'] as int,
        limit: 300);
    setState(() {
      _messages = msgs;
      _loading = false;
    });
  }

  void _copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Copied'),
        duration: Duration(seconds: 1),
        behavior: SnackBarBehavior.floating));
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('h:mm a').format(dt);
    } catch (_) {
      return '';
    }
  }

  String _dayLabel(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final msgDay = DateTime(dt.year, dt.month, dt.day);
      final diff = today.difference(msgDay).inDays;
      if (diff == 0) return 'Today';
      if (diff == 1) return 'Yesterday';
      return DateFormat('MMMM d, y').format(dt);
    } catch (_) {
      return iso;
    }
  }

  List<dynamic> _buildItems() {
    final source = _searchQuery.isEmpty
        ? _messages
        : _messages.where((m) {
            final text = (m['message'] as String? ?? '').toLowerCase();
            return text.contains(_searchQuery.toLowerCase());
          }).toList();
    final items = <dynamic>[];
    String? lastDay;
    for (final msg in source) {
      final ts = msg['timestamp'] as String? ?? '';
      String dayKey;
      try {
        dayKey = DateFormat('yyyy-MM-dd').format(DateTime.parse(ts));
      } catch (_) {
        dayKey = ts;
      }
      if (dayKey != lastDay) {
        items.add({'_divider': true, 'label': _dayLabel(ts)});
        lastDay = dayKey;
      }
      items.add(msg);
    }
    return items;
  }

  Future<void> _exportSession() async {
    final lines = _messages.map((m) {
      final role = (m['role'] as String?) == 'user' ? 'You' : 'Peso';
      final ts = m['timestamp'] as String? ?? '';
      final text = m['message'] as String? ?? '';
      return '[$ts] $role: $text';
    }).join('\n\n');
    await Clipboard.setData(ClipboardData(text: lines));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Session copied to clipboard'),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = _buildItems();

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () async {
            final ctrl = TextEditingController(text: _title);
            final result = await showDialog<String>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Rename session'),
                content: TextField(
                  controller: ctrl,
                  autofocus: true,
                  maxLength: 60,
                  decoration: const InputDecoration(hintText: 'Session name'),
                ),
                actions: [
                  TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel')),
                  FilledButton(
                    onPressed: () => Navigator.pop(context, ctrl.text.trim()),
                    child: const Text('Save'),
                  ),
                ],
              ),
            );
            if (result != null && result.isNotEmpty) {
              await DBService.renameChatSession(
                  widget.session['id'] as int, result);
              setState(() => _title = result);
            }
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  _title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.edit_outlined,
                  size: 14, color: cs.onSurface.withValues(alpha: 0.4)),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy_outlined),
            tooltip: 'Copy session',
            onPressed: _exportSession,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _messages.isEmpty
              ? Center(
                  child: PesoMascot.withSpeech(
                    mood: PesoMood.thinking,
                    text: 'Walang messages dito.',
                  ),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: InputDecoration(
                          hintText: 'Search this session…',
                          prefixIcon: const Icon(Icons.search, size: 18),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 16),
                                  onPressed: () => setState(() {
                                    _searchCtrl.clear();
                                    _searchQuery = '';
                                  }),
                                )
                              : null,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                    // Message count pill
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
                      child: Text(
                        '${_messages.length} messages',
                        style: TextStyle(
                            fontSize: 11,
                            color: cs.onSurface.withValues(alpha: 0.4)),
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: items.length,
                        itemBuilder: (_, i) {
                          final item = items[i];
                          // Day divider
                          if (item is Map && item['_divider'] == true) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  const Expanded(child: Divider()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12),
                                    child: Text(item['label'] as String,
                                        style: TextStyle(
                                            fontSize: 11,
                                            color: cs.onSurface
                                                .withValues(alpha: 0.5),
                                            fontWeight: FontWeight.w500)),
                                  ),
                                  const Expanded(child: Divider()),
                                ],
                              ),
                            );
                          }
                          // Message bubble
                          final msg = item as Map<String, dynamic>;
                          final isUser = msg['role'] == 'user';
                          final text = msg['message'] as String? ?? '';
                          final time =
                              _formatTime(msg['timestamp'] as String? ?? '');
                          return Align(
                            alignment: isUser
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: GestureDetector(
                              onLongPress: () => _copyMessage(text),
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 3),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width *
                                            0.78),
                                decoration: BoxDecoration(
                                  color: isUser
                                      ? cs.primary
                                      : cs.surfaceContainerHighest,
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(14),
                                    topRight: const Radius.circular(14),
                                    bottomLeft:
                                        Radius.circular(isUser ? 14 : 2),
                                    bottomRight:
                                        Radius.circular(isUser ? 2 : 14),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(text,
                                        style: TextStyle(
                                            color: isUser ? Colors.white : null,
                                            height: 1.4)),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(time,
                                            style: TextStyle(
                                                fontSize: 9,
                                                color: isUser
                                                    ? Colors.white38
                                                    : Colors.grey[400])),
                                        const SizedBox(width: 6),
                                        GestureDetector(
                                          onTap: () => _copyMessage(text),
                                          child: Icon(Icons.copy,
                                              size: 11,
                                              color: isUser
                                                  ? Colors.white38
                                                  : Colors.grey[400]),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
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
