import 'db_service.dart';
import 'cloud_service.dart';
import 'event_bus.dart';

/// Represents a single undoable AI action.
/// Stored in memory only — not persisted to DB.
class UndoableAction {
  final String type;
  final Map<String, dynamic> snapshot; // data needed to reverse the action
  final DateTime timestamp;

  UndoableAction({
    required this.type,
    required this.snapshot,
  }) : timestamp = DateTime.now();

  /// Whether this action is still within the 60-second undo window.
  bool get isUndoable =>
      DateTime.now().difference(timestamp).inSeconds <= 60;
}

/// In-memory undo service for AI actions.
/// Only the most recent undoable action is stored.
/// Cleared on: new action recorded, screen dispose, logout.
class UndoService {
  static UndoableAction? _last;

  static UndoableAction? get last => _last;

  static bool get canUndo => _last != null && _last!.isUndoable;

  /// Record an undoable action after it has been executed.
  static void record(UndoableAction action) {
    _last = action;
  }

  /// Clear the undo buffer.
  static void clear() {
    _last = null;
  }

  /// Attempt to undo the last action. Returns true if successful.
  static Future<bool> undo() async {
    final action = _last;
    if (action == null || !action.isUndoable) {
      _last = null;
      return false;
    }
    _last = null;

    try {
      switch (action.type) {
        case 'log_expense':
        case 'log_expense_batch':
          final ids = action.snapshot['ids'] as List<int>? ?? [];
          for (final id in ids) {
            await DBService.deleteExpense(id);
          }
          fireEvent(AppEvent.expenseChanged);
          return true;

        case 'add_goal':
          final id = action.snapshot['id'] as int?;
          if (id != null) {
            await DBService.deleteGoal(id);
            fireEvent(AppEvent.goalChanged);
          }
          return true;

        case 'add_income':
          final id = action.snapshot['id'] as int?;
          if (id != null) {
            await DBService.deleteIncome(id);
            fireEvent(AppEvent.incomeChanged);
          }
          return true;

        case 'add_debt':
          final id = action.snapshot['id'] as int?;
          if (id != null) {
            await DBService.deleteDebt(id);
            fireEvent(AppEvent.expenseChanged);
          }
          return true;

        case 'add_recurring':
          final id = action.snapshot['id'] as int?;
          if (id != null) {
            await DBService.deleteRecurring(id);
            fireEvent(AppEvent.expenseChanged);
          }
          return true;

        case 'set_budget':
          // Restore previous budget amount (or delete if it was new)
          final category = action.snapshot['category'] as String?;
          final prevAmount = action.snapshot['prev_amount'] as double?;
          if (category != null) {
            if (prevAmount != null) {
              await DBService.setBudget(category, prevAmount);
            } else {
              await DBService.deleteBudget(category);
            }
            fireEvent(AppEvent.budgetChanged);
          }
          return true;

        case 'update_expense':
          // Restore previous expense state
          final prev = action.snapshot['prev'] as Map<String, dynamic>?;
          if (prev != null) {
            final db = await DBService.getDB();
            await db.update('expenses', prev,
                where: 'id = ?', whereArgs: [prev['id']]);
            // Sync the restored state to Firestore
            try { CloudService.pushDoc('expenses', prev); } catch (_) {}
            fireEvent(AppEvent.expenseChanged);
          }
          return true;

        case 'update_goal':
          final id = action.snapshot['id'] as int?;
          final prevAmount = action.snapshot['prev_amount'] as double?;
          if (id != null && prevAmount != null) {
            final goals = await DBService.getGoals();
            final goal = goals.where((g) => g['id'] == id).firstOrNull;
            if (goal != null) {
              await DBService.updateGoal({...goal, 'current_amount': prevAmount});
              fireEvent(AppEvent.goalChanged);
            }
          }
          return true;
      }
    } catch (_) {}
    return false;
  }
}
