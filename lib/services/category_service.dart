import 'db_service.dart';

/// Central service for all category management.
/// Replaces all hardcoded category lists app-wide.
/// Built-in categories are locked; custom categories are user-defined.
class CategoryService {
  // ── BUILT-IN CATEGORIES ───────────────────────────────────

  static const List<String> builtIn = [
    'Food',
    'Transportation',
    'Bills',
    'Shopping',
    'Entertainment',
    'Gaming',
    'Health',
    'Education',
    'Personal Care',
    'Clothing',
    'Gifts',
    'Travel',
    'Pets',
    'Others',
  ];

  // ── CACHE ─────────────────────────────────────────────────

  static List<String>? _cache;

  static void invalidate() => _cache = null;

  /// Returns all categories: built-in first, then custom (sorted A-Z).
  static Future<List<String>> getAll() async {
    if (_cache != null) return _cache!;
    final custom = await DBService.getCustomCategories();
    final customNames = custom.map((c) => c['name'] as String).toList()..sort();
    _cache = [...builtIn, ...customNames];
    return _cache!;
  }

  /// Returns only custom categories.
  static Future<List<Map<String, dynamic>>> getCustom() =>
      DBService.getCustomCategories();

  /// Add a new custom category. Returns false if name already exists.
  static Future<bool> addCustom(String name, {String? icon}) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;
    final all = await getAll();
    if (all.any((c) => c.toLowerCase() == trimmed.toLowerCase())) return false;
    await DBService.insertCustomCategory({'name': trimmed, 'icon': icon});
    invalidate();
    return true;
  }

  /// Rename a custom category. Also renames it in all existing expenses.
  static Future<void> renameCustom(
      int id, String oldName, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;
    await DBService.updateCustomCategory(id, trimmed);
    await DBService.renameExpenseCategory(oldName, trimmed);
    invalidate();
  }

  /// Delete a custom category. Expenses in that category move to 'Others'.
  static Future<void> deleteCustom(int id, String name) async {
    await DBService.deleteCustomCategory(id);
    await DBService.renameExpenseCategory(name, 'Others');
    invalidate();
  }

  /// Check if a category is built-in (locked).
  static bool isBuiltIn(String name) => builtIn.contains(name);

  /// Normalize a raw category string to a known category.
  /// Falls back to 'Others' if no match found.
  static Future<String> normalize(String raw) async {
    final all = await getAll();
    final lower = raw.toLowerCase().trim();
    // Exact match first
    for (final c in all) {
      if (c.toLowerCase() == lower) return c;
    }
    // Partial match
    for (final c in all) {
      if (lower.contains(c.toLowerCase()) || c.toLowerCase().contains(lower)) {
        return c;
      }
    }
    return 'Others';
  }
}
