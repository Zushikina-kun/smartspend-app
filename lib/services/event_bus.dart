import 'dart:async';

/// Simple global event bus for cross-screen reactive updates.
/// Screens subscribe to [onExpenseChanged] and reload when fired.
class AppEventBus {
  AppEventBus._();
  static final AppEventBus instance = AppEventBus._();

  final _controller = StreamController<AppEvent>.broadcast();

  Stream<AppEvent> get stream => _controller.stream;

  void fire(AppEvent event) {
    if (!_controller.isClosed) _controller.add(event);
  }

  void dispose() => _controller.close();
}

enum AppEvent {
  expenseChanged, // expense added, edited, or deleted
  budgetChanged, // budget set or deleted
  incomeChanged, // income added or deleted
  goalChanged, // goal added, updated, or deleted
}

/// Convenience shorthand
void fireEvent(AppEvent event) => AppEventBus.instance.fire(event);
