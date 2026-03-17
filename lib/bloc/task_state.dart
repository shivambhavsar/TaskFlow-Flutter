import '../models/task.dart';
import 'task_event.dart';

/// STATE = the complete UI state that the Bloc emits.
///
/// Android equivalent: this is your UI State class.
/// In Kotlin you might write:
///   data class TaskUiState(
///     val tasks: List<Task> = emptyList(),
///     val isLoading: Boolean = false,
///     val error: String? = null,
///     val filter: TaskFilter = TaskFilter.ALL
///   )
///
/// BLoC state works EXACTLY the same way — it's an immutable snapshot
/// of everything the UI needs to render.
///
/// IMPORTANT: BLoC compares old state vs new state using == operator.
/// If they're equal, it WON'T rebuild the UI (optimization!).
/// That's why we implement operator== and hashCode.

class TaskState {
  final List<Task> tasks;
  final bool isLoading;
  final String? error;
  final TaskFilter filter;

  const TaskState({
    this.tasks = const [],
    this.isLoading = false,
    this.error,
    this.filter = TaskFilter.all,
  });

  /// Computed properties — derived from state, not stored separately.
  /// Like Kotlin's `val pendingTasks get() = tasks.filter { !it.isCompleted }`
  List<Task> get pendingTasks => tasks.where((t) => !t.isCompleted).toList();
  List<Task> get completedTasks => tasks.where((t) => t.isCompleted).toList();
  int get pendingCount => pendingTasks.length;

  /// Filtered list based on current filter
  List<Task> get filteredTasks => switch (filter) {
        TaskFilter.all => tasks,
        TaskFilter.pending => pendingTasks,
        TaskFilter.completed => completedTasks,
      };

  /// copyWith — same pattern as our Task model
  TaskState copyWith({
    List<Task>? tasks,
    bool? isLoading,
    String? error,
    TaskFilter? filter,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,  // intentionally not using ?? so we can clear errors
      filter: filter ?? this.filter,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskState &&
          other.isLoading == isLoading &&
          other.error == error &&
          other.filter == filter &&
          _listEquals(other.tasks, tasks));

  @override
  int get hashCode => Object.hash(
        Object.hashAll(tasks),
        isLoading,
        error,
        filter,
      );

  /// Simple list equality check
  static bool _listEquals(List<Task> a, List<Task> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i] || a[i].isCompleted != b[i].isCompleted) return false;
    }
    return true;
  }
}
