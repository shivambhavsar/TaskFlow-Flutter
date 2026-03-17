import '../models/task.dart';

/// EVENTS = user intentions / actions sent TO the Bloc.
///
/// Android equivalent: think of these as "Actions" in MVI,
/// or the method calls you'd make on a ViewModel.
///
/// In Android you might write:
///   viewModel.addTask(task)
///   viewModel.toggleTask(id)
///
/// In BLoC, you express those as event objects:
///   bloc.add(AddTask(task))
///   bloc.add(ToggleTask(id))
///
/// WHY events instead of method calls?
/// 1. Events are data — you can log, replay, and test them
/// 2. Events can be queued — Bloc processes them one at a time (no race conditions)
/// 3. Events document every possible user action in one place

sealed class TaskEvent {}

/// Load initial tasks (like fetching from DB on screen open)
class LoadTasks extends TaskEvent {}

/// Add a new task
class AddTask extends TaskEvent {
  final Task task;
  AddTask(this.task);
}

/// Update an existing task (from detail screen)
class UpdateTask extends TaskEvent {
  final Task task;
  UpdateTask(this.task);
}

/// Toggle a task's completion status
class ToggleTask extends TaskEvent {
  final String taskId;
  ToggleTask(this.taskId);
}

/// Delete a task
class DeleteTask extends TaskEvent {
  final String taskId;
  DeleteTask(this.taskId);
}

/// Undo the last delete (restore a task)
class UndoDelete extends TaskEvent {
  final Task task;
  final int index;
  UndoDelete(this.task, this.index);
}

/// Filter tasks by status
class ChangeFilter extends TaskEvent {
  final TaskFilter filter;
  ChangeFilter(this.filter);
}

/// Possible filter values
enum TaskFilter { all, pending, completed }
