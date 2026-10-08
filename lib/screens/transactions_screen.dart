import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/expense.dart';
import '../services/db_service.dart';
import '../services/currency_service.dart';
import '../widgets/peso_mascot.dart';
import '../services/export_service.dart';
import '../services/category_service.dart';
import '../services/event_bus.dart';
import '../widgets/expense_tile.dart';
import '../widgets/info_button.dart';
import 'edit_expense_screen.dart';
import 'add_expense_screen.dart';

// ── Sort and Group enums ──────────────────────────────────────────────────

enum TxnSortKey {
  transactionDate,
  loggedDate,
  amountDesc,
  amountAsc,
  nameAZ,
  nameZA,
  source,
}

enum TxnGroupKey {
  transactionDate,
  loggedDate,
  category,
  source,
  none,
}

String _sortLabel(TxnSortKey k) {
  switch (k) {
    case TxnSortKey.transactionDate:
      return 'Transaction date';
    case TxnSortKey.loggedDate:
      return 'Logged date';
    case TxnSortKey.amountDesc:
      return 'Amount (high → low)';
    case TxnSortKey.amountAsc:
      return 'Amount (low → high)';
    case TxnSortKey.nameAZ:
      return 'Name (A → Z)';
    case TxnSortKey.nameZA:
      return 'Name (Z → A)';
    case TxnSortKey.source:
      return 'Source';
  }
}

String _groupLabel(TxnGroupKey k) {
  switch (k) {
    case TxnGroupKey.transactionDate:
      return 'Transaction date';
    case TxnGroupKey.loggedDate:
      return 'Logged date';
    case TxnGroupKey.category:
      return 'Category';
    case TxnGroupKey.source:
      return 'Source';
    case TxnGroupKey.none:
      return 'None (flat list)';
  }
}

class TransactionsScreen extends StatefulWidget {
  /// Optional: pre-filter to only show these expense IDs on open.
  /// Used by Data Quality screen to show affected expenses.
  final List<int>? initialIds;
  const TransactionsScreen({super.key, this.initialIds});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<Expense> _all = [];
  List<Expense> _filtered = [];
  bool _loading = true;
  String _period = 'all';
  String _searchQuery = '';
  String _selectedCategory = 'All';
  final _searchCtrl = TextEditingController();
  Timer? _debounce;
  static const _pageSize = 30;
  int _displayCount = 30;
  List<String> _categories = ['All', ...CategoryService.builtIn];
  // Multi-select
  final Set<int> _selected = {};
  bool get _isSelecting => _selected.isNotEmpty;

  // Sort & Group state
  TxnSortKey _sortKey = TxnSortKey.transactionDate;
  TxnGroupKey _groupKey = TxnGroupKey.transactionDate;
  final Set<String> _collapsedGroups = {};

  bool _showLowConfidenceOnly = false;
  bool _showWantsOnly = false;
  bool _showNeedsOnly = false;
  String? _activeTag;

  // 12C: Recent AI-logged expenses for undo card (last 3, within 24h)
  List<Expense> _recentAiExpenses = [];
  bool _undoCardDismissed = false;

  // Listen for AI/external data changes (update_expense, new log, delete)
  // so the list re-sorts automatically without the user needing to pull-to-refresh.
  StreamSubscription<AppEvent>? _eventSub;
  Timer? _eventDebounce;

  @override
  void initState() {
    super.initState();
    _restoreFilter();
    _load();
    // Re-sort and reload whenever an expense is added, updated, or deleted
    // elsewhere (e.g. via the AI chat update_expense action).
    _eventSub = AppEventBus.instance.stream.listen((event) {
      if (event == AppEvent.expenseChanged) {
        _eventDebounce?.cancel();
        _eventDebounce = Timer(const Duration(milliseconds: 400), () {
          if (mounted) _load();
        });
      }
    });
  }

  Future<void> _restoreFilter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cat = prefs.getString('txn_filter_category') ?? 'All';
      final period = prefs.getString('txn_filter_period') ?? 'all';
      final sortIdx = prefs.getInt('txn_sort_key') ?? 0;
      final groupIdx = prefs.getInt('txn_group_key') ?? 0;
      if (mounted) {
        setState(() {
          _selectedCategory = cat;
          _period = period;
          _sortKey =
              TxnSortKey.values[sortIdx.clamp(0, TxnSortKey.values.length - 1)];
          _groupKey = TxnGroupKey
              .values[groupIdx.clamp(0, TxnGroupKey.values.length - 1)];
        });
      }
    } catch (_) {}
  }

  Future<void> _persistFilter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('txn_filter_category', _selectedCategory);
      await prefs.setString('txn_filter_period', _period);
      await prefs.setInt('txn_sort_key', _sortKey.index);
      await prefs.setInt('txn_group_key', _groupKey.index);
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    _eventSub?.cancel();
    _eventDebounce?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    final expenses = await DBService.getExpenses();
    final allCats = await CategoryService.getAll();
    // Also include any categories that exist in expenses but aren't in the current list
    final expenseCats = expenses.map((e) => e.category).toSet();
    final knownCats = allCats.toSet();
    final orphanCats = expenseCats.difference(knownCats).toList()..sort();

    // 12C: Last 3 AI-logged expenses within the past 24 hours for undo card
    // Use updatedAt (ISO timestamp) if available; otherwise use date == today
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final cutoff =
        DateTime.now().subtract(const Duration(hours: 24)).toIso8601String();
    final recentAi = expenses
        .where((e) {
          if (!e.aiGenerated) return false;
          if (e.updatedAt != null) return e.updatedAt!.compareTo(cutoff) >= 0;
          return e.date == today; // fallback: today's entries
        })
        .take(3)
        .toList();

    setState(() {
      _all = expenses;
      _categories = ['All', ...allCats, ...orphanCats];
      if (!_categories.contains(_selectedCategory)) _selectedCategory = 'All';
      _recentAiExpenses = recentAi;
      _loading = false;
      _applyFilter();
    });
  }

  void _applyFilter() {
    final now = DateTime.now();
    // If opened with initialIds, always show just those expenses
    if (widget.initialIds != null && widget.initialIds!.isNotEmpty) {
      final idSet = widget.initialIds!.toSet();
      setState(() {
        _filtered = _all.where((e) => idSet.contains(e.id)).toList();
        _displayCount = _pageSize;
      });
      return;
    }
    List<Expense> result = List.from(_all);

    result = result.where((e) {
      try {
        // 'logged_today' filters by when the entry was logged (updated_at),
        // not the expense date — shows all entries entered today regardless of date
        if (_period == 'logged_today') {
          final loggedDate = e.updatedAt != null
              ? e.updatedAt!.substring(0, 10)
              : e.date.substring(0, 10);
          return loggedDate ==
              DateTime.now().toIso8601String().substring(0, 10);
        }
        final d = DateTime.parse(e.date);
        switch (_period) {
          case 'daily':
            return d.year == now.year &&
                d.month == now.month &&
                d.day == now.day;
          case 'weekly':
            final weekStart = now.subtract(Duration(days: now.weekday - 1));
            return d.isAfter(weekStart.subtract(const Duration(days: 1)));
          case 'monthly':
            return d.year == now.year && d.month == now.month;
          case 'yearly':
            return d.year == now.year;
          default:
            return true;
        }
      } catch (_) {
        return true;
      }
    }).toList();

    if (_selectedCategory != 'All') {
      result = result.where((e) => e.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      // Score-based relevance: itemName match > category/shop > notes/tags
      final scored = result
          .map((e) {
            int score = 0;
            if (e.itemName.toLowerCase().contains(q))
              score = 3;
            else if (e.category.toLowerCase().contains(q))
              score = 2;
            else if ((e.shopName?.toLowerCase().contains(q) ?? false))
              score = 2;
            else if ((e.notes?.toLowerCase().contains(q) ?? false))
              score = 1;
            else if ((e.tags?.toLowerCase().contains(q) ?? false)) score = 1;
            return MapEntry(e, score);
          })
          .where((entry) => entry.value > 0)
          .toList();
      // If search is active, sort by relevance first, then apply sort key within same score
      scored.sort((a, b) => b.value.compareTo(a.value));
      result = scored.map((e) => e.key).toList();
    } else {
      // Apply sort key
      result = _sortExpenses(result);
    }

    if (_showLowConfidenceOnly) {
      result = result.where((e) => e.confidenceScore < 0.7).toList();
    }

    if (_showWantsOnly) {
      result = result.where((e) => e.isWant == true).toList();
    } else if (_showNeedsOnly) {
      result = result.where((e) => e.isWant != true).toList();
    }

    // Tag filter
    if (_activeTag != null) {
      result =
          result.where((e) => e.tags?.contains(_activeTag!) == true).toList();
    }

    _filtered = result;
    _displayCount = _pageSize;
  }

  /// Sort a list of expenses by the current sort key.
  List<Expense> _sortExpenses(List<Expense> list) {
    final sorted = List<Expense>.from(list);
    switch (_sortKey) {
      case TxnSortKey.transactionDate:
        sorted.sort((a, b) => b.date.compareTo(a.date));
        break;
      case TxnSortKey.loggedDate:
        sorted.sort((a, b) {
          final la = a.updatedAt ?? a.date;
          final lb = b.updatedAt ?? b.date;
          return lb.compareTo(la);
        });
        break;
      case TxnSortKey.amountDesc:
        sorted.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case TxnSortKey.amountAsc:
        sorted.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case TxnSortKey.nameAZ:
        sorted.sort((a, b) =>
            a.itemName.toLowerCase().compareTo(b.itemName.toLowerCase()));
        break;
      case TxnSortKey.nameZA:
        sorted.sort((a, b) =>
            b.itemName.toLowerCase().compareTo(a.itemName.toLowerCase()));
        break;
      case TxnSortKey.source:
        sorted.sort((a, b) {
          final sa = _sourceOf(a);
          final sb = _sourceOf(b);
          return sa.compareTo(sb);
        });
        break;
    }
    return sorted;
  }

  String _sourceOf(Expense e) {
    final notes = e.notes?.toLowerCase() ?? '';
    if (notes.startsWith('imported') || notes.contains('[screenshot]'))
      return 'screenshot';
    if (e.aiGenerated) return 'ai';
    return 'manual';
  }

  /// Build grouped representation: list of (header label, expenses).
  List<({String header, double total, List<Expense> items})> _buildGroups() {
    if (_groupKey == TxnGroupKey.none) {
      return [
        (
          header: '',
          total: _filtered.fold(0.0, (s, e) => s + e.amount),
          items: _filtered
        )
      ];
    }
    final map = <String, List<Expense>>{};
    for (final e in _filtered) {
      final key = _groupKeyOf(e);
      map.putIfAbsent(key, () => []).add(e);
    }
    // Sort groups by key descending (dates) or ascending (category/source)
    final keys = map.keys.toList();
    switch (_groupKey) {
      case TxnGroupKey.transactionDate:
      case TxnGroupKey.loggedDate:
        keys.sort((a, b) => b.compareTo(a)); // newest first
        break;
      case TxnGroupKey.category:
      case TxnGroupKey.source:
        keys.sort();
        break;
      case TxnGroupKey.none:
        break;
    }
    return keys.map((k) {
      final items = map[k]!;
      final total = items.fold(0.0, (s, e) => s + e.amount);
      return (header: _groupHeaderLabel(k), total: total, items: items);
    }).toList();
  }

  String _groupKeyOf(Expense e) {
    switch (_groupKey) {
      case TxnGroupKey.transactionDate:
        return e.date.length >= 10 ? e.date.substring(0, 10) : e.date;
      case TxnGroupKey.loggedDate:
        final d = e.updatedAt ?? e.date;
        return d.length >= 10 ? d.substring(0, 10) : d;
      case TxnGroupKey.category:
        return e.category;
      case TxnGroupKey.source:
        return _sourceOf(e);
      case TxnGroupKey.none:
        return '';
    }
  }

  String _groupHeaderLabel(String key) {
    switch (_groupKey) {
      case TxnGroupKey.transactionDate:
        try {
          return _formatDate(key);
        } catch (_) {
          return key;
        }
      case TxnGroupKey.loggedDate:
        try {
          return 'Logged ${_formatDate(key)}';
        } catch (_) {
          return 'Logged $key';
        }
      case TxnGroupKey.category:
        return key;
      case TxnGroupKey.source:
        switch (key) {
          case 'ai':
            return '🤖 AI';
          case 'screenshot':
            return '📷 Screenshot';
          default:
            return '✏️ Manual';
        }
      case TxnGroupKey.none:
        return '';
    }
  }

  String _formatDate(String isoDate) {
    final dt = DateTime.parse(isoDate);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);
    final diff = today.difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    // Show full date for older entries
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  /// Show the sort/group bottom sheet.
  void _showSortGroupSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2)),
                  ),
                ),
                // Sort by section
                const Text('Sort by',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: TxnSortKey.values.map((k) {
                    final selected = _sortKey == k;
                    return FilterChip(
                      label: Text(_sortLabel(k),
                          style: const TextStyle(fontSize: 12)),
                      selected: selected,
                      onSelected: (_) {
                        setSheet(() {});
                        setState(() {
                          _sortKey = k;
                          _applyFilter();
                          _persistFilter();
                        });
                      },
                      selectedColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.15),
                      checkmarkColor: Theme.of(context).colorScheme.primary,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                // Group by section
                const Text('Group by',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: TxnGroupKey.values.map((k) {
                    final selected = _groupKey == k;
                    return FilterChip(
                      label: Text(_groupLabel(k),
                          style: const TextStyle(fontSize: 12)),
                      selected: selected,
                      onSelected: (_) {
                        setSheet(() {});
                        setState(() {
                          _groupKey = k;
                          _collapsedGroups.clear();
                          _applyFilter();
                          _persistFilter();
                        });
                      },
                      selectedColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.15),
                      checkmarkColor: Theme.of(context).colorScheme.primary,
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double get _filteredTotal => _filtered.fold(0.0, (s, e) => s + e.amount);

  Future<void> _edit(Expense e) async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (_) => EditExpenseScreen(expense: e)));
    if (result == true) _load();
  }

  Future<void> _delete(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete Expense"),
        content: const Text("Delete this expense? This cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text("Delete", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    await DBService.deleteExpense(id);
    _load();
  }

  // 12C: Recent AI undo history card
  Widget _buildRecentAiCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outline.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.history, size: 14, color: cs.primary),
              const SizedBox(width: 6),
              const Text('Recently AI-logged',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
              const Text(' · tap × to remove',
                  style: TextStyle(fontSize: 11, color: Colors.grey)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _undoCardDismissed = true),
                child: Icon(Icons.close,
                    size: 16, color: cs.onSurface.withValues(alpha: 0.4)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (final e in _recentAiExpenses)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.itemName,
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w500)),
                        Text(
                          '${e.category} · ${CurrencyService.format(e.amount)}',
                          style: TextStyle(
                              fontSize: 11,
                              color: cs.onSurface.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      if (e.id == null) return;
                      await DBService.deleteExpense(e.id!);
                      _load();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Removed "${e.itemName}" from AI log'),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 2),
                        ));
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: Colors.red.withValues(alpha: 0.2)),
                      ),
                      child: const Text('Remove',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.red,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _deleteSelected() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text("Delete ${_selected.length} transactions?"),
        content: const Text("This cannot be undone."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    for (final id in _selected) {
      await DBService.deleteExpense(id);
    }
    setState(() => _selected.clear());
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: _isSelecting
            ? Text("${_selected.length} selected")
            : const Text("All Transactions"),
        leading: _isSelecting
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selected.clear()),
              )
            : null,
        actions: _isSelecting
            ? [
                IconButton(
                  icon: const Icon(Icons.select_all),
                  tooltip: "Select all",
                  onPressed: () => setState(() {
                    if (_selected.length == _filtered.length) {
                      _selected.clear();
                    } else {
                      _selected.addAll(_filtered
                          .where((e) => e.id != null)
                          .map((e) => e.id!));
                    }
                  }),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  tooltip: "Delete selected",
                  onPressed: _deleteSelected,
                ),
              ]
            : [
                const InfoButton(
                  title: "Transactions",
                  body: "This screen shows all your logged expenses.\n\n"
                      "• Search by item name or shop\n"
                      "• Use Sort / Group to change the order and grouping\n"
                      "• Filter by time period or category\n"
                      "• Long-press any transaction to select multiple, then delete them at once\n"
                      "• Tap the download icon to export the filtered list to CSV",
                ),
                // Sort/Group button
                IconButton(
                  icon: const Icon(Icons.swap_vert),
                  tooltip: "Sort & group",
                  onPressed: _showSortGroupSheet,
                ),
                IconButton(
                  icon: const Icon(Icons.download_outlined),
                  tooltip: "Export filtered to CSV",
                  onPressed: _filtered.isEmpty
                      ? null
                      : () async {
                          try {
                            await ExportService.exportToCSV(_filtered);
                          } catch (e) {
                            if (mounted)
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Export failed: $e")));
                          }
                        },
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const AddExpenseScreen()));
                    if (result == true) _load();
                  },
                ),
              ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: Column(
                children: [
                  // 12C: Recent AI undo card — only when not selecting, not searching,
                  // not dismissed, and there are recent AI-logged expenses
                  if (!_isSelecting &&
                      !_undoCardDismissed &&
                      _recentAiExpenses.isNotEmpty &&
                      _searchQuery.isEmpty &&
                      _period == 'all')
                    _buildRecentAiCard(context),

                  // Search bar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: TextField(
                      controller: _searchCtrl,
                      decoration: InputDecoration(
                        hintText: "Search transactions...",
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() {
                                    _searchQuery = '';
                                    _applyFilter();
                                  });
                                })
                            : null,
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 10),
                      ),
                      onChanged: (v) {
                        _debounce?.cancel();
                        _debounce =
                            Timer(const Duration(milliseconds: 300), () {
                          setState(() {
                            _searchQuery = v;
                            _applyFilter();
                          });
                        });
                      },
                    ),
                  ),

                  // Period filter chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    child: Row(
                      children: [
                        for (final p in [
                          ('all', 'All Time'),
                          ('daily', 'Today'),
                          ('weekly', 'This Week'),
                          ('monthly', 'This Month'),
                          ('yearly', 'This Year'),
                          ('logged_today', 'Logged Today'),
                        ])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(p.$2),
                              selected: _period == p.$1,
                              onSelected: (_) => setState(() {
                                _period = p.$1;
                                _applyFilter();
                                _persistFilter();
                              }),
                              selectedColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.15),
                              checkmarkColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        // (end of period chips)
                      ],
                    ),
                  ),

                  // Row 2: Category dropdown + Want/Need + Low confidence
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        // Category dropdown (replaces overflowing chip row)
                        Expanded(
                          child: DropdownButtonHideUnderline(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: _selectedCategory != 'All'
                                        ? cs.primary
                                        : cs.outline.withValues(alpha: 0.4)),
                                borderRadius: BorderRadius.circular(20),
                                color: _selectedCategory != 'All'
                                    ? cs.primary.withValues(alpha: 0.08)
                                    : null,
                              ),
                              child: DropdownButton<String>(
                                value: _selectedCategory,
                                isExpanded: true,
                                isDense: true,
                                style: TextStyle(
                                    fontSize: 12,
                                    color: _selectedCategory != 'All'
                                        ? cs.primary
                                        : cs.onSurface),
                                icon: Icon(Icons.arrow_drop_down,
                                    size: 18,
                                    color: _selectedCategory != 'All'
                                        ? cs.primary
                                        : cs.onSurface.withValues(alpha: 0.6)),
                                items: _categories
                                    .map((c) => DropdownMenuItem(
                                          value: c,
                                          child: Text(c,
                                              style: const TextStyle(
                                                  fontSize: 12)),
                                        ))
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() {
                                      _selectedCategory = v;
                                      _applyFilter();
                                      _persistFilter();
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Want/Need toggle chips (compact)
                        FilterChip(
                          label: const Text("Wants",
                              style: TextStyle(fontSize: 11)),
                          selected: _showWantsOnly,
                          onSelected: (v) => setState(() {
                            _showWantsOnly = v;
                            if (v) _showNeedsOnly = false;
                            _applyFilter();
                          }),
                          selectedColor: Colors.orange.withValues(alpha: 0.15),
                          checkmarkColor: Colors.orange,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        const SizedBox(width: 6),
                        FilterChip(
                          label: const Text("Needs",
                              style: TextStyle(fontSize: 11)),
                          selected: _showNeedsOnly,
                          onSelected: (v) => setState(() {
                            _showNeedsOnly = v;
                            if (v) _showWantsOnly = false;
                            _applyFilter();
                          }),
                          selectedColor: cs.primary.withValues(alpha: 0.15),
                          checkmarkColor: cs.primary,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        const SizedBox(width: 6),
                        FilterChip(
                          label:
                              const Text("⚠️", style: TextStyle(fontSize: 12)),
                          tooltip: "Low confidence only",
                          selected: _showLowConfidenceOnly,
                          onSelected: (v) => setState(() {
                            _showLowConfidenceOnly = v;
                            _applyFilter();
                          }),
                          selectedColor: Colors.orange.withValues(alpha: 0.15),
                          checkmarkColor: Colors.orange,
                          visualDensity: VisualDensity.compact,
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                      ],
                    ),
                  ),

                  // Tag filter — only shown when any expense has tags
                  Builder(builder: (ctx) {
                    final allTags = <String>{};
                    for (final e in _all) {
                      if (e.tags != null && e.tags!.isNotEmpty) {
                        allTags.addAll(
                            e.tags!.split(',').where((t) => t.isNotEmpty));
                      }
                    }
                    if (allTags.isEmpty) return const SizedBox.shrink();
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 0),
                      child: Row(
                        children: [
                          Icon(Icons.label_outline,
                              size: 14,
                              color: Theme.of(ctx)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.4)),
                          const SizedBox(width: 6),
                          ...allTags.map((tag) => Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: FilterChip(
                                  label: Text(tag,
                                      style: const TextStyle(fontSize: 11)),
                                  selected: _activeTag == tag,
                                  onSelected: (v) => setState(() {
                                    _activeTag = v ? tag : null;
                                    _applyFilter();
                                  }),
                                  selectedColor: Theme.of(ctx)
                                      .colorScheme
                                      .primary
                                      .withValues(alpha: 0.15),
                                  checkmarkColor:
                                      Theme.of(ctx).colorScheme.primary,
                                ),
                              )),
                        ],
                      ),
                    );
                  }),

                  // Summary bar
                  Container(
                    margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: cs.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: cs.primary.withValues(alpha: 0.12),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${_filtered.length} transactions",
                            style: TextStyle(
                                color: cs.onPrimaryContainer, fontSize: 13)),
                        Text(CurrencyService.format(_filteredTotal),
                            style: TextStyle(
                                color: cs.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  // List — grouped or flat depending on _groupKey
                  Expanded(
                    child: _filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                PesoMascot.withSpeech(
                                  size: 60,
                                  mood: PesoMood.thinking,
                                  text:
                                      "Wala pang nahanap!\nTry clearing your search or filters 🔍",
                                ),
                                const SizedBox(height: 8),
                                const Text("No transactions found",
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontWeight: FontWeight.w500)),
                                const SizedBox(height: 4),
                                const Text(
                                    "Try adjusting your search or filters.",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12)),
                              ],
                            ),
                          )
                        : _buildGroupedList(cs),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildGroupedList(ColorScheme cs) {
    final groups = _buildGroups();
    // For "none" grouping, render flat list with pagination
    if (_groupKey == TxnGroupKey.none) {
      final flat = groups.isEmpty ? <Expense>[] : groups.first.items;
      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount:
            flat.length > _displayCount ? _displayCount + 1 : flat.length,
        itemBuilder: (_, i) {
          if (i == _displayCount) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: OutlinedButton(
                onPressed: () => setState(() => _displayCount += _pageSize),
                child: Text(
                    "Load more (${flat.length - _displayCount} remaining)"),
              ),
            );
          }
          return _buildTile(flat[i]);
        },
      );
    }

    // Grouped list — build items list including group headers
    final items = <dynamic>[];
    for (final g in groups) {
      items.add(g); // group header
      if (!_collapsedGroups.contains(g.header)) {
        items.addAll(g.items);
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final item = items[i];
        if (item is ({String header, double total, List<Expense> items})) {
          // Group header
          final collapsed = _collapsedGroups.contains(item.header);
          return InkWell(
            onTap: () => setState(() {
              if (collapsed) {
                _collapsedGroups.remove(item.header);
              } else {
                _collapsedGroups.add(item.header);
              }
            }),
            child: Container(
              margin: const EdgeInsets.fromLTRB(12, 8, 12, 2),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: cs.primary.withValues(alpha: 0.12)),
              ),
              child: Row(
                children: [
                  Icon(
                    collapsed ? Icons.chevron_right : Icons.expand_more,
                    size: 16,
                    color: cs.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item.header.isEmpty ? 'All' : item.header,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: cs.primary),
                    ),
                  ),
                  Text(
                    '${item.items.length} · ${CurrencyService.format(item.total)}',
                    style: TextStyle(
                        fontSize: 11,
                        color: cs.onSurface.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
          );
        }
        return _buildTile(item as Expense);
      },
    );
  }

  Widget _buildTile(Expense e) {
    return ExpenseTile(
      expense: e,
      onEdit: _isSelecting ? null : () => _edit(e),
      onDelete: _isSelecting ? null : () => _delete(e.id!),
      isSelected: _selected.contains(e.id),
      onLongPress: () {
        setState(() {
          final id = e.id!;
          if (_selected.contains(id)) {
            _selected.remove(id);
          } else {
            _selected.add(id);
          }
        });
      },
      onTap: _isSelecting
          ? () {
              setState(() {
                final id = e.id!;
                if (_selected.contains(id)) {
                  _selected.remove(id);
                } else {
                  _selected.add(id);
                }
              });
            }
          : null,
    );
  }
}
