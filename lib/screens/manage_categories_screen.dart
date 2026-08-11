import 'package:flutter/material.dart';
import '../services/category_service.dart';
import '../services/db_service.dart';
import '../widgets/info_button.dart';

class ManageCategoriesScreen extends StatefulWidget {
  const ManageCategoriesScreen({super.key});

  @override
  State<ManageCategoriesScreen> createState() => _ManageCategoriesScreenState();
}

class _ManageCategoriesScreenState extends State<ManageCategoriesScreen> {
  List<Map<String, dynamic>> _custom = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final custom = await DBService.getCustomCategories();
    if (mounted)
      setState(() {
        _custom = custom;
        _loading = false;
      });
  }

  void _showAddDialog({Map<String, dynamic>? existing}) {
    final ctrl = TextEditingController(text: existing?['name'] ?? '');
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(existing == null ? "Add Category" : "Rename Category"),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            labelText: "Category name",
            hintText: "e.g. School, Church, Pets",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () async {
              final name = ctrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(context);
              if (existing == null) {
                final ok = await CategoryService.addCustom(name);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content:
                        Text(ok ? '"$name" added' : '"$name" already exists'),
                    backgroundColor: ok ? Colors.green : Colors.orange,
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              } else {
                await CategoryService.renameCustom(
                    existing['id'] as int, existing['name'] as String, name);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Renamed to "$name"'),
                    behavior: SnackBarBehavior.floating,
                  ));
                }
              }
              _load();
            },
            child: Text(existing == null ? "Add" : "Rename"),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(Map<String, dynamic> cat) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Category"),
        content: Text(
          'Delete "${cat['name']}"?\n\nAll expenses in this category will be moved to "Others".',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await CategoryService.deleteCustom(
                  cat['id'] as int, cat['name'] as String);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('"${cat['name']}" deleted'),
                  behavior: SnackBarBehavior.floating,
                ));
              }
              _load();
            },
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Manage Categories"),
        actions: [
          const InfoButton(
            title: "Custom Categories",
            body:
                "Add your own expense categories beyond the built-in 8 (Food, Transport, Bills, etc.).\n\n"
                "• Custom categories appear in all dropdowns: Add Expense, Edit Expense, Budget, Recurring\n"
                "• Rename or delete custom categories — deleted category's expenses move to 'Others'\n"
                "• The AI is aware of your custom categories and will use them when logging expenses\n"
                "• Synced to cloud and included in backup/restore",
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Add category",
            onPressed: () => _showAddDialog(),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Built-in categories (locked)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text("Built-in Categories",
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface.withValues(alpha: 0.5),
                          letterSpacing: 0.5)),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: CategoryService.builtIn
                      .map((c) => Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: Chip(
                              label:
                                  Text(c, style: const TextStyle(fontSize: 13)),
                              avatar: const Icon(Icons.lock_outline, size: 14),
                              backgroundColor: cs.surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                            ),
                          ))
                      .toList(),
                ),
                const SizedBox(height: 8),
                Divider(color: cs.outline.withValues(alpha: 0.2)),
                // Custom categories
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: Row(
                    children: [
                      Text("Custom Categories",
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: cs.onSurface.withValues(alpha: 0.5),
                              letterSpacing: 0.5)),
                      const Spacer(),
                      Text("${_custom.length} added",
                          style: TextStyle(
                              fontSize: 12,
                              color: cs.onSurface.withValues(alpha: 0.4))),
                    ],
                  ),
                ),
                if (_custom.isEmpty)
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.category_outlined,
                              size: 48, color: Colors.grey[300]),
                          const SizedBox(height: 12),
                          const Text("No custom categories yet",
                              style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 4),
                          const Text(
                              "Tap + to add categories like School, Church, Pets",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text("Add Category"),
                            onPressed: () => _showAddDialog(),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                        itemCount: _custom.length,
                        itemBuilder: (_, i) {
                          final cat = _custom[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor:
                                    cs.primary.withValues(alpha: 0.12),
                                child: Icon(Icons.label_outline,
                                    color: cs.primary, size: 18),
                              ),
                              title: Text(cat['name'] as String,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500)),
                              subtitle: const Text("Custom",
                                  style: TextStyle(fontSize: 12)),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit_outlined,
                                        size: 18),
                                    tooltip: "Rename",
                                    onPressed: () =>
                                        _showAddDialog(existing: cat),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline,
                                        size: 18, color: Colors.red),
                                    tooltip: "Delete",
                                    onPressed: () => _confirmDelete(cat),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
              ],
            ),
      floatingActionButton: _custom.isNotEmpty
          ? FloatingActionButton.extended(
              heroTag: 'fab_categories',
              onPressed: () => _showAddDialog(),
              icon: const Icon(Icons.add),
              label: const Text("Add Category"),
            )
          : null,
    );
  }
}
