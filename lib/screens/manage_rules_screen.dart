import 'package:flutter/material.dart';
import '../services/db_service.dart';
import '../services/category_service.dart';
import '../widgets/info_button.dart';

/// Screen for managing user-defined auto-categorization rules.
/// Rules are keyword → category mappings applied before the built-in
/// keyword list when the AI or manual entry categorizes an expense.
///
/// Example: "7-Eleven" → Food, "Grab" → Transportation
class ManageRulesScreen extends StatefulWidget {
  const ManageRulesScreen({super.key});

  @override
  State<ManageRulesScreen> createState() => _ManageRulesScreenState();
}

class _ManageRulesScreenState extends State<ManageRulesScreen> {
  List<Map<String, dynamic>> _rules = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final rules = await DBService.getCategoryRules();
    // FC-6: Compute match count for each rule from expenses
    final expenses = await DBService.getExpenses();
    final rulesWithCount = rules.map((r) {
      final kw = (r['keyword'] as String).toLowerCase();
      int count = 0;
      String? lastDate;
      for (final e in expenses) {
        final name = (e.itemName).toLowerCase();
        final shop = (e.shopName ?? '').toLowerCase();
        if (name.contains(kw) || shop.contains(kw)) {
          count++;
          if (lastDate == null || e.date.compareTo(lastDate) > 0) {
            lastDate = e.date;
          }
        }
      }
      return {...r, '_match_count': count, '_last_match': lastDate};
    }).toList();
    if (mounted)
      setState(() {
        _rules = rulesWithCount;
        _loading = false;
      });
  }

  void _showAddDialog() async {
    final keywordCtrl = TextEditingController();
    final categories = await CategoryService.getAll();
    String selectedCategory = categories.first;

    if (!mounted) return;
    await showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: const Text("Add Rule"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "When an expense description contains this keyword, automatically assign it to the selected category.",
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: keywordCtrl,
                autofocus: true,
                textCapitalization: TextCapitalization.none,
                decoration: InputDecoration(
                  labelText: "Keyword",
                  hintText: "e.g. 7-Eleven, Grab, Mercury",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                  helperText: "Case-insensitive, partial match",
                ),
              ),
              const SizedBox(height: 14),
              DropdownButtonFormField<String>(
                initialValue: selectedCategory,
                decoration: InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) =>
                    setDialog(() => selectedCategory = v ?? selectedCategory),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text("Cancel")),
            ElevatedButton(
              onPressed: () async {
                final kw = keywordCtrl.text.trim();
                if (kw.isEmpty) return;
                Navigator.pop(ctx);
                await DBService.insertCategoryRule(kw, selectedCategory);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('"$kw" → $selectedCategory rule added'),
                    backgroundColor: Colors.green,
                    behavior: SnackBarBehavior.floating,
                  ));
                }
                _load();
              },
              child: const Text("Add Rule"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteRule(Map<String, dynamic> rule) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Rule"),
        content:
            Text('Remove rule: "${rule['keyword']}" → ${rule['category']}?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    await DBService.deleteCategoryRule(rule['id'] as int);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Rule deleted"),
        behavior: SnackBarBehavior.floating,
      ));
    }
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Auto-Categorization Rules"),
        actions: [
          const InfoButton(
            title: "How Rules Work",
            body:
                "Rules let you define your own keyword → category mappings.\n\n"
                "When you or the AI logs an expense, the description is checked against your rules first. "
                "If a keyword matches, that category is used automatically.\n\n"
                "Examples:\n"
                "• \"7-Eleven\" → Food\n"
                "• \"Grab\" → Transportation\n"
                "• \"Mercury\" → Health\n"
                "• \"Shopee\" → Shopping\n\n"
                "Rules are case-insensitive and use partial matching — "
                "\"grab\" will match \"GrabFood\", \"Grab Car\", etc.\n\n"
                "Your rules take priority over the built-in keyword list.",
          ),
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Add rule",
            onPressed: _showAddDialog,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _rules.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.rule_outlined,
                          size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      const Text("No rules yet",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.grey)),
                      const SizedBox(height: 8),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          "Add rules to automatically categorize expenses by keyword. "
                          "For example: \"7-Eleven\" → Food.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: Colors.grey, fontSize: 13, height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add),
                        label: const Text("Add First Rule"),
                        onPressed: _showAddDialog,
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                    itemCount: _rules.length,
                    itemBuilder: (_, i) {
                      final rule = _rules[i];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: cs.primary.withValues(alpha: 0.12),
                            child: Icon(Icons.rule_outlined,
                                color: cs.primary, size: 18),
                          ),
                          title: Text(
                            '"${rule['keyword']}"',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontFamily: 'monospace'),
                          ),
                          subtitle: Row(
                            children: [
                              const Icon(Icons.arrow_forward,
                                  size: 12, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(rule['category'] as String,
                                  style: const TextStyle(fontSize: 12)),
                              if ((rule['_match_count'] as int? ?? 0) > 0) ...[
                                const SizedBox(width: 8),
                                Text(
                                  "· ${rule['_match_count']} match${(rule['_match_count'] as int) == 1 ? '' : 'es'}",
                                  style: TextStyle(
                                      fontSize: 11, color: Colors.grey[500]),
                                ),
                              ],
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                size: 18, color: Colors.red),
                            tooltip: "Delete rule",
                            onPressed: () => _deleteRule(rule),
                          ),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: _rules.isNotEmpty
          ? FloatingActionButton.extended(
              heroTag: 'fab_rules',
              onPressed: _showAddDialog,
              icon: const Icon(Icons.add),
              label: const Text("Add Rule"),
            )
          : null,
    );
  }
}
