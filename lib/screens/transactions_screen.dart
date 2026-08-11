import 'package:flutter/material.dart';
import 'dart:async';
import '../models/expense.dart';
import '../services/db_service.dart';
import '../services/currency_service.dart';
import '../services/export_service.dart';
import '../services/category_service.dart';
import '../services/event_bus.dart';
import '../widgets/expense_tile.dart';
import '../widgets/info_button.dart';
import 'edit_expense_screen.dart';
import 'add_expense_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

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

  bool _showLowConfidenceOnly = false;
  bool _showWantsOnly = false;
  bool _showNeedsOnly = false;
  String? _activeTag;

  // Listen for AI/external data changes (update_expense, new log, delete)
  // so the list re-sorts automatically without the user needing to pull-to-refresh.
  StreamSubscription<AppEvent>? _eventSub;
  Timer? _eventDebounce;

  @override
  void initState() {
    super.initState();
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
    // (e.g. a custom category was deleted but old expenses still reference it)
    final expenseCats = expenses.map((e) => e.category).toSet();
    final knownCats = allCats.toSet();
    final orphanCats = expenseCats.difference(knownCats).toList()..sort();
    setState(() {
      _all = expenses;
      _categories = ['All', ...allCats, ...orphanCats];
      if (!_categories.contains(_selectedCategory)) _selectedCategory = 'All';
      _loading = false;
      _applyFilter();
    });
  }

  void _applyFilter() {
    final now = DateTime.now();
    List<Expense> result = List.from(_all);

    result = result.where((e) {
      try {
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
      result = result
          .where((e) =>
              e.itemName.toLowerCase().contains(q) ||
              e.category.toLowerCase().contains(q) ||
              (e.shopName?.toLowerCase().contains(q) ?? false) ||
              (e.notes?.toLowerCase().contains(q) ?? false) ||
              (e.tags?.toLowerCase().contains(q) ?? false))
          .toList();
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

  double get _filteredTotal => _filtered.fold(0.0, (s, e) => s + e.amount);

  Future<void> _edit(Expense e) async {
    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (_) => EditExpenseScreen(expense: e)));
    if (result == true) _load();
  }

  Future<void> _delete(int id) async {
    await DBService.deleteExpense(id);
    _load();
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
                      "• Filter by time period or category\n"
                      "• Long-press any transaction to select multiple, then delete them at once\n"
                      "• Tap the download icon to export the filtered list to CSV",
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
                        ])
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(p.$2),
                              selected: _period == p.$1,
                              onSelected: (_) => setState(() {
                                _period = p.$1;
                                _applyFilter();
                              }),
                              selectedColor: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.15),
                              checkmarkColor:
                                  Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        // CF-1: Low confidence filter
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text("⚠️ Low confidence"),
                            selected: _showLowConfidenceOnly,
                            onSelected: (v) => setState(() {
                              _showLowConfidenceOnly = v;
                              _applyFilter();
                            }),
                            selectedColor:
                                Colors.orange.withValues(alpha: 0.15),
                            checkmarkColor: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Category filter
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Row(
                      children: [
                        // Want/Need filter
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text("🏷️ Wants only"),
                            selected: _showWantsOnly,
                            onSelected: (v) => setState(() {
                              _showWantsOnly = v;
                              if (v) _showNeedsOnly = false;
                              _applyFilter();
                            }),
                            selectedColor:
                                Colors.orange.withValues(alpha: 0.15),
                            checkmarkColor: Colors.orange,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: const Text("✅ Needs only"),
                            selected: _showNeedsOnly,
                            onSelected: (v) => setState(() {
                              _showNeedsOnly = v;
                              if (v) _showWantsOnly = false;
                              _applyFilter();
                            }),
                            selectedColor: Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.15),
                            checkmarkColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        ..._categories
                            .map((cat) => Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: FilterChip(
                                    label: Text(cat,
                                        style: const TextStyle(fontSize: 12)),
                                    selected: _selectedCategory == cat,
                                    onSelected: (_) => setState(() {
                                      _selectedCategory = cat;
                                      _applyFilter();
                                    }),
                                    selectedColor: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withValues(alpha: 0.15),
                                    checkmarkColor:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ))
                            .toList(),
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
                      borderRadius: BorderRadius.circular(10),
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

                  // List
                  Expanded(
                    child: _filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.receipt_long_outlined,
                                    size: 56, color: Colors.grey[300]),
                                const SizedBox(height: 12),
                                const Text("No transactions found.",
                                    style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 16),
                            itemCount: _filtered.length > _displayCount
                                ? _displayCount + 1
                                : _filtered.length,
                            itemBuilder: (_, i) {
                              // Load more button at end
                              if (i == _displayCount) {
                                return Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: OutlinedButton(
                                    onPressed: () => setState(
                                        () => _displayCount += _pageSize),
                                    child: Text(
                                        "Load more (${_filtered.length - _displayCount} remaining)"),
                                  ),
                                );
                              }
                              return ExpenseTile(
                                expense: _filtered[i],
                                onEdit: _isSelecting
                                    ? null
                                    : () => _edit(_filtered[i]),
                                onDelete: _isSelecting
                                    ? null
                                    : () => _delete(_filtered[i].id!),
                                isSelected: _selected.contains(_filtered[i].id),
                                onLongPress: () {
                                  setState(() {
                                    final id = _filtered[i].id!;
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
                                          final id = _filtered[i].id!;
                                          if (_selected.contains(id)) {
                                            _selected.remove(id);
                                          } else {
                                            _selected.add(id);
                                          }
                                        });
                                      }
                                    : null,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
