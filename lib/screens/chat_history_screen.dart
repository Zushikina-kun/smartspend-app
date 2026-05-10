import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../services/db_service.dart';
import '../widgets/info_button.dart';

class ChatHistoryScreen extends StatefulWidget {
  const ChatHistoryScreen({super.key});

  @override
  State<ChatHistoryScreen> createState() => _ChatHistoryScreenState();
}

class _ChatHistoryScreenState extends State<ChatHistoryScreen> {
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final history = await DBService.getChatHistory(limit: 200);
    setState(() {
      _history = history;
      _loading = false;
    });
  }

  Future<void> _clearAll() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Clear History"),
        content: const Text("Delete all chat history? This cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Delete All"),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await DBService.clearChatHistory();
      if (mounted) setState(() => _history.clear());
    }
  }

  void _copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text("Copied"),
          duration: Duration(seconds: 1),
          behavior: SnackBarBehavior.floating),
    );
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return DateFormat('h:mm a').format(dt);
    } catch (_) {
      return iso;
    }
  }

  String _dayLabel(String iso) {
    try {
      final dt = DateTime.parse(iso);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final msgDay = DateTime(dt.year, dt.month, dt.day);
      final diff = today.difference(msgDay).inDays;
      if (diff == 0) return "Today";
      if (diff == 1) return "Yesterday";
      return DateFormat('MMMM d, y').format(dt);
    } catch (_) {
      return iso;
    }
  }

  /// Build a flat list with day divider items inserted
  List<dynamic> _buildItems() {
    final items = <dynamic>[];
    String? lastDay;
    for (final msg in _history) {
      final ts = msg['timestamp'] as String;
      String dayKey;
      try {
        final dt = DateTime.parse(ts);
        dayKey = DateFormat('yyyy-MM-dd').format(dt);
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = _buildItems();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat History"),
        actions: [
          const InfoButton(
            title: "Chat History",
            body: "Browse all your previous AI conversations.\n\n"
                "• Day dividers separate conversations by date\n"
                "• Long-press any message to copy it\n"
                "• Tap the copy icon on any bubble to copy\n"
                "• Tap the trash icon to clear all history\n\n"
                "Chat history is cleared when you log out — each account's conversations are private.",
          ),
          if (_history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: "Clear all",
              onPressed: _clearAll,
            ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline,
                          size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      const Text("No chat history yet.",
                          style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
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
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  item['label'] as String,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color:
                                          cs.onSurface.withValues(alpha: 0.5),
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                        );
                      }

                      // Message bubble
                      final msg = item as Map<String, dynamic>;
                      final isUser = msg['role'] == 'user';
                      final text = msg['message'] as String;
                      final time = _formatTime(msg['timestamp'] as String);

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
                                    MediaQuery.of(context).size.width * 0.78),
                            decoration: BoxDecoration(
                              color: isUser
                                  ? Theme.of(context).colorScheme.primary
                                  : cs.surfaceContainerHighest,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(14),
                                topRight: const Radius.circular(14),
                                bottomLeft: Radius.circular(isUser ? 14 : 2),
                                bottomRight: Radius.circular(isUser ? 2 : 14),
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
    );
  }
}
